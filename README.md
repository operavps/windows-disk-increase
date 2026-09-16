# windows-disk-increase
A ready-to-use powershell script for Windows operating systems to mount &amp; increase the C drive

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
