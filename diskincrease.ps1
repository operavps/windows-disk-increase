#Requires -RunAsAdministrator

# ============================================================
# Windows C: Drive Extension Script
# ============================================================
# This script:
#   1. Updates the Windows storage cache
#   2. Checks the current C: partition size
#   3. Detects the maximum supported partition size
#   4. Asks for confirmation before extending C:
#   5. Extends the partition to the maximum available size
# ============================================================

$ErrorActionPreference = "Stop"


# ------------------------------------------------------------
# Load Storage Module
# ------------------------------------------------------------
# Provides Get-Partition, Resize-Partition, and related
# storage management commands.
# ------------------------------------------------------------

Import-Module Storage


# ------------------------------------------------------------
# Refresh Storage Information
# ------------------------------------------------------------
# Forces Windows to refresh its view of the attached disks
# and available storage space.
# ------------------------------------------------------------

Update-HostStorageCache


# ------------------------------------------------------------
# Get C: Drive Information
# ------------------------------------------------------------
# $currentPartition = Current size of the C: partition
# $maximumSize      = Maximum size supported by the disk
#                     and partition layout
# ------------------------------------------------------------

$currentPartition = Get-Partition -DriveLetter C
$maximumSize = (Get-PartitionSupportedSize -DriveLetter C).SizeMax


# ------------------------------------------------------------
# Check Whether Additional Space Is Available
# ------------------------------------------------------------

if ($maximumSize -le $currentPartition.Size) {

    Write-Host ""
    Write-Host "No additional disk space is available to extend." `
        -ForegroundColor Red

    exit 0
}


# ------------------------------------------------------------
# Calculate and Display Disk Sizes
# ------------------------------------------------------------

$currentSizeGB = [math]::Round(
    $currentPartition.Size / 1GB,
    2
)

$maximumSizeGB = [math]::Round(
    $maximumSize / 1GB,
    2
)

Write-Host ""
Write-Host "Current C: drive size : $currentSizeGB GB"
Write-Host "Available maximum     : $maximumSizeGB GB"
Write-Host ""


# ------------------------------------------------------------
# Ask User for Confirmation
# ------------------------------------------------------------
# Y = Continue with disk extension
# N = Cancel
# ------------------------------------------------------------

$confirmation = choice `
    /C YN `
    /N `
    /M "Extend C: drive from $currentSizeGB GB to $maximumSizeGB GB? [Y/N] "


# ------------------------------------------------------------
# Extend C: Drive
# ------------------------------------------------------------

if ($LASTEXITCODE -eq 1) {

    Write-Host ""
    Write-Host "Extending C: drive..." -ForegroundColor Cyan

    Resize-Partition `
        -DriveLetter C `
        -Size $maximumSize


    # --------------------------------------------------------
    # Verify New Partition Size
    # --------------------------------------------------------

    $finalSizeGB = [math]::Round(
        (Get-Partition -DriveLetter C).Size / 1GB,
        2
    )

    Write-Host ""
    Write-Host "C: drive successfully extended." `
        -ForegroundColor Green

    Write-Host "Disk: $currentSizeGB GB -> $finalSizeGB GB" `
        -ForegroundColor Green
}
else {

    # --------------------------------------------------------
    # User Cancelled the Operation
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "Disk extension was not approved." `
        -ForegroundColor Yellow
}
