# Specify the database (e.g., "master" or "web")
$databaseName = "master"

# Get the Sitecore database
$database = Get-Database -Name $databaseName

# Define a list to store unused media items
$unusedMediaItems = @()

# Get all media library items
$mediaLibraryPath = "/sitecore/media library"
$mediaLibrary = Get-Item -Path "$($database.Name):$mediaLibraryPath"

# Iterate through media library items
$mediaLibrary.Axes.GetDescendants() | ForEach-Object {
    $mediaItem = $_
    
    # Check if the media item is referenced by any content item
    $referenced = Get-ItemReferrer -Item $mediaItem | Where-Object { $_.Paths.FullPath -notlike "$($mediaLibrary.Paths.FullPath)/*" }
    
    if ($referenced -eq $null) {
        $unusedMediaItems += $mediaItem
    }
}

# Display the list of unused media items
$unusedMediaItems | Format-Table -Property @{Label = "Media Item"; Expression = { $_.Paths.FullPath } }

Write-Host "List of unused media items:"
$unusedMediaItems.Count

# Delete unused media items (uncomment the following code to delete them)
# foreach ($unusedItem in $unusedMediaItems) {
#     Remove-Item -Path $unusedItem.Paths.FullPath
# }

# Write a message indicating that unused media items have been deleted
# Write-Host "Deleted $unusedMediaItems.Count unused media items."
