# Specify the database (e.g., "master" or "web")
$databaseName = "master"

# Get the Sitecore database
$database = Get-Database -Name $databaseName

# Get all locked items in the database
$lockedItems = Get-Item -Path "$($database.Name):/sitecore" -Language * -Version * | Where-Object { $_.Locking.IsLocked() }

# Unlock each locked item
foreach ($item in $lockedItems) {
    if ($item.Locking.HasLock()) {
        $item.Editing.EndEdit()
        Write-Host "Unlocked: $($item.Paths.FullPath)"
    }
}

Write-Host "All locked items have been unlocked."
