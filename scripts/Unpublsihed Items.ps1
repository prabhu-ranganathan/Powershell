# Specify the database (e.g., "master" or "web")
$databaseName = "master"

# Get the Sitecore database
$database = Get-Database -Name $databaseName

# Get all items that are not published
$unpublishedItems = Get-Item -Path "$($database.Name):/sitecore/content/Home" -Language * -Version * | Where-Object { $_.Publishing.NeverPublish }

# Display the list of unpublished items
$unpublishedItems | Format-Table -Property @{Label = "Item Path"; Expression = { $_.Paths.FullPath } }

Write-Host "List of unpublished items:"
$unpublishedItems.Count
