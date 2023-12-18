# Set the path to the item for which you want to retrieve page views
$itemPath = "/sitecore/content/Home"

# Query the reporting database to retrieve unique ItemIDs
$query = @"
SELECT ItemID
FROM [dbo].[Fact_PageViews]
GROUP BY ItemID
HAVING SUM(Views) <= 1
"@

# Execute the query
$pageViews = Invoke-Sqlcmd -ServerInstance "<your SQL instance>" -Database "<reporting database>" -Username "sa" -Password "<password>" -Query $query

# Output the result
foreach ($row in $pageViews) {
    $itemId = $row.ItemID

    # Query the content database to retrieve the item name
    $item = Get-Item -Path "master:" -ID $itemId
    if ($item) {
        Write-Output ("Page Views for ItemID {0}: {1}" -f $itemId, $item.Paths.FullPath)
    }
    else {
        Write-Output ("Item not found for ItemID: {0}" -f $itemId)
    }
}
