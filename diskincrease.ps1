# Keep settings local when invoked through iex.
& {
    $ErrorActionPreference = 'Stop'
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw 'Open Windows PowerShell using Run as administrator, then run the command again.'
        }
        Import-Module Storage -ErrorAction Stop
        Update-HostStorageCache -ErrorAction Stop
        $partition = Get-Partition -DriveLetter C -ErrorAction Stop
        $maximumSize = (Get-PartitionSupportedSize -DriveLetter C -ErrorAction Stop).SizeMax
        if ($maximumSize -le $partition.Size) {
            Write-Host 'No additional space is available to extend C:. Enlarge the underlying disk and ensure unallocated space is immediately after C:; a recovery partition can block extension.' -ForegroundColor Yellow
            return
        }
        $beforeGB = [math]::Round($partition.Size / 1GB, 2)
        $maximumGB = [math]::Round($maximumSize / 1GB, 2)
        $answer = Read-Host "Extend C: from $beforeGB GB to $maximumGB GB? [Y/N]"
        if ($answer -notmatch '^\s*(y|yes)\s*$') {
            Write-Host 'Disk extension was not approved.' -ForegroundColor Yellow
            return
        }
        Resize-Partition -DiskNumber $partition.DiskNumber -PartitionNumber $partition.PartitionNumber -Size $maximumSize -ErrorAction Stop
        $after = Get-Partition -DiskNumber $partition.DiskNumber -PartitionNumber $partition.PartitionNumber -ErrorAction Stop
        if ($after.Size -le $partition.Size) {
            throw 'C: did not increase in size. Check the disk layout in Disk Management.'
        }
        $afterGB = [math]::Round($after.Size / 1GB, 2)
        Write-Host "C: extended: $beforeGB GB -> $afterGB GB" -ForegroundColor Green
    }
    catch {
        Write-Error -Message ("Disk extension failed: {0}" -f $_.Exception.Message) -ErrorAction Continue
    }
}
