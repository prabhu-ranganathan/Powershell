function HasPersonalization($item) {
    # Check if the item has personalization conditions in either __renderings or __Final Renderings
    $renderingsField = $item.Fields["__renderings"]
    $finalRenderingsField = $item.Fields["__Final Renderings"]

    $IsRenderingField = ($null -ne $renderingsField -and $null -ne $renderingsField.Value -and $renderingsField.Value.Contains('<conditions'))
    $IsFinalRenderingField = ($null -ne $finalRenderingsField -and $null -ne $finalRenderingsField.Value -and $finalRenderingsField.Value.Contains('<conditions'))
    
    return $IsRenderingField -or $IsFinalRenderingField
}

# Specify the item path where you want to check for personalization
$itemPath = "/sitecore/content/home"

# Get the item
$item = Get-Item -Path $itemPath

# Call the HasPersonalization function
$hasPersonalization = HasPersonalization -item $item

if ($hasPersonalization) {
    Write-Host "Personalization conditions are present in the item."
}
else {
    Write-Host "No personalization conditions found in the item."
}

