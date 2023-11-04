$database = "master"
$root = Get-Item -Path (@{$true = "$($database):\content\home"; $false = "$($database):\content" }[(Test-Path -Path "$($database):\content\home")])
$baseTemplate = Get-Item master:\"sitecore\templates\User Defined\Web2014\Container\Pages"
$periodOptions = [ordered]@{Before = 1; After = 2; }
$maxDaysOptions = [ordered]@{"-- Skip --" = [int]::MaxValue; 30 = 30; 90 = 90; 120 = 120; 365 = 365; }
$settings = @{
    Title            = "Report Filter"
    OkButtonName     = "Proceed"
    CancelButtonName = "Abort"
    Description      = "Filter the results for Components updated on or after the specified date"
    Parameters       = @(
        @{
            Name    = "root"; 
            Title   = "Choose the report root"; 
            Tooltip = "Only items from this root will be returned.";
        },
        @{ 
            Name    = "selectedDate"
            Value   = [System.DateTime]::Now
            Title   = "Date"
            Tooltip = "Filter the results for items updated on or before/after the specified date"
            Editor  = "date time"
        },
        @{
            Name    = "selectedPeriod"
            Title   = "Period"
            Value   = 1
            Options = $periodOptions
            Tooltip = "Pick whether the items should have been last updated before or after the specified date"
            Editor  = "radio"
        },
        @{
            Name    = "selectedMaxDays"
            Title   = "Max Days"
            Value   = [int]::MaxValue
            Options = $maxDaysOptions
            Tooltip = "Pick the maximum number of days to include starting with the specified date"
            Editor  = "combo"
        }
    )
    Icon             = [regex]::Replace($PSScript.Appearance.Icon, "Office", "OfficeWhite", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    ShowHint         = $true
}

$result = Read-Variable @settings
if ($result -ne "ok") {
    Exit
}

function Get-LastUpdated($item) {
    
    Write-Host $item.Paths.FullPath
    Write-Log $item.Paths.FullPath
    
    $allitems = Get-ItemReference  -Path "$($database):$($item.Paths.FullPath)" | Where-Object { $_.Name -ne 'Header' -and $_.Name -ne 'HeaderView' -and $_.Name -ne 'Top-Component' -and $_.Name -ne 'Footer' -and $_.Name -ne 'FooterView' -and $_.Name -ne 'Search Box' -and $_.Name -ne 'Global Navigation' -and $_.Name -ne 'Global-Nav' -and $_.Name -ne 'Folder' -and $_.TemplateName -ne 'Device' -and $_.TemplateName -ne 'Workflow' -and $_.TemplateName -ne 'Layout' -and $_.TemplateName -ne 'Branch' -and $_.TemplateName -ne 'Meta Tag' -and $_.TemplateName -ne 'List Configuration' -and $_.TemplateName -ne 'State' }  | Sort-Object __Updated -descending
   
    Write-Log "allitems count=$($allitems.Count)"
    if ($allitems.Count -ne 0) {
        foreach ($associateditem in $allitems) {
            if ($associateditem.HasChildren) {
                $descendants = Get-ChildItem -Path "$($database):$($associateditem.Paths.FullPath)" -Recurse -WithParent | Where-Object { $_.Paths.FullPath.StartsWith('/sitecore/content/') } | Sort-Object __Updated -descending | Select -First 1
            }
            if ($descendants -ne $null) {
                if ($lastUpdated -ne $null -and ($lastUpdated -lt $descendants.Fields[[Sitecore.FieldIDs]::Updated].Value) -or ($lastUpdated -lt $associateditem.Fields[[Sitecore.FieldIDs]::Updated].Value)) {
                    Write-Host $descendants.Paths.FullPath +":"+ $descendants.Fields[[Sitecore.FieldIDs]::Updated].Value
                    Write-Host $associateditem.Paths.FullPath +":"+ $associateditem.Fields[[Sitecore.FieldIDs]::Updated].Value
                    
                    Write-Log $descendants.Paths.FullPath +"1:"+ $descendants.Fields[[Sitecore.FieldIDs]::Updated].Value
                    Write-Log $associateditem.Paths.FullPath +":"+ $associateditem.Fields[[Sitecore.FieldIDs]::Updated].Value
                   
                    if ($descendants.Fields[[Sitecore.FieldIDs]::Updated].Value -gt $associateditem.Fields[[Sitecore.FieldIDs]::Updated].Value) {
                        $lastUpdated = $descendants.Fields[[Sitecore.FieldIDs]::Updated].Value
                    }
                    else {
                        $lastUpdated = $associateditem.Fields[[Sitecore.FieldIDs]::Updated].Value
                    }
                }
            }
            else {
                if ($lastUpdated -ne $null -and ($lastUpdated -lt $item.Fields[[Sitecore.FieldIDs]::Updated].Value) -or ($lastUpdated -lt $associateditem.Fields[[Sitecore.FieldIDs]::Updated].Value)) {
                    Write-Host $item.Paths.FullPath +":"+ $item.Fields[[Sitecore.FieldIDs]::Updated].Value
                    Write-Host $associateditem.Paths.FullPath +":"+ $associateditem.Fields[[Sitecore.FieldIDs]::Updated].Value
                    
                    Write-Log $item.Paths.FullPath +"2:"+ $item.Fields[[Sitecore.FieldIDs]::Updated].Value
                    Write-Log $associateditem.Paths.FullPath +":"+ $associateditem.Fields[[Sitecore.FieldIDs]::Updated].Value
                    
                    if ($item.Fields[[Sitecore.FieldIDs]::Updated].Value -gt $associateditem.Fields[[Sitecore.FieldIDs]::Updated].Value) {
                        $lastUpdated = $item.Fields[[Sitecore.FieldIDs]::Updated].Value
                    }
                    else {
                        $lastUpdated = $associateditem.Fields[[Sitecore.FieldIDs]::Updated].Value
                    }
                }
            }
        }
        return  [Sitecore.DateUtil]::IsoDateToDateTime($lastUpdated)
    }
    else {
        return  [Sitecore.DateUtil]::IsoDateToDateTime($item.Fields[[Sitecore.FieldIDs]::Updated].Value)
    }
}
filter Where-LastUpdated {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Sitecore.Data.Items.Item]$Item,
        
        [datetime]$Date = ([datetime]::Today),
        [switch]$IsBefore,
        
        [int]$MaxDays
    )
    
    $convertedDate = [Sitecore.DateUtil]::IsoDateToDateTime($item.Fields[[Sitecore.FieldIDs]::Updated].Value)
    $isWithinDate = $false
    if ($IsBefore.IsPresent) {
        if ($convertedDate -le $Date) {
            $isWithinDate = $true
        }
    }
    else {
        if ($convertedDate -ge $Date) {
            $isWithinDate = $true
        }
    }
    
    if ($isWithinDate) {
        if ($MaxDays -lt [int]::MaxValue) {
            if ([math]::Abs(($convertedDate - $Date).Days) -le $MaxDays) {
                $item
            }
        }
        else {
            $item
        }
    }
}

$stdTemplate = "{AB86861A-6030-46C5-B394-E8F99E8B87DB}" #base template guid
$childTemplates = $baseTemplate.Axes.GetDescendants() | Where-Object { [Sitecore.Data.Managers.TemplateManager]::GetTemplate($_).InheritsFrom($stdTemplate) }
Write-Host $root.Paths.FullPath

foreach ($childTemplate in $childTemplates) {
    #$items += Find-Item -Index sitecore_master_index -Where 'TemplateId = @0 and Path.StartsWith(@1)' -WhereValues $childitem.ID, $root.Paths.FullPath | Initialize-Item
    $items += @($childTemplate | Get-ItemReferrer | Where-Object { $_.ItemPath.StartsWith($root.Paths.FullPath) } | Where-LastUpdated -Date $selectedDate -IsBefore:($selectedPeriod -eq 1) -MaxDays $selectedMaxDays | Initialize-Item)
}
#$items = @($root) + @(($root.Axes.GetDescendants())) | Where-LastUpdated -Date $selectedDate -IsBefore:($selectedPeriod -eq 1) -MaxDays $selectedMaxDays | Initialize-Item

$message = "before"
if ($selectedPeriod -ne 1) {
    $message = "after"
}

if ($items.Count -eq 0) {
    Show-Alert "There are no items updated on or after the specified date"
}
else {
    $props = @{
        Title           = "Items Last Updated Report"
        InfoTitle       = "Items last updated $($message) date $($selectedDate)"
        InfoDescription = "Lists all items last updated $($message) the date selected."
        PageSize        = 25
    }
    
    $items |
    Show-ListView @props -Property @{Label = "Name"; Expression = { $_.DisplayName } },
    @{Label = "Actual Last Updated"; Expression = { $_.__Updated } },
    @{Label = "Last Published"; Expression = { $_."__Last Published" } },
    @{Label = "Related Item Last Updated"; Expression = { Get-LastUpdated($_) } },
    @{Label = "Updated by"; Expression = { $_."__Updated by" } },
    @{Label = "Created"; Expression = { $_.__Created } },
    @{Label = "Created by"; Expression = { $_."__Created by" } },
    @{Label = "Template Name"; Expression = { $_.TemplateName } },
    @{Label = "Path"; Expression = { $_.ItemPath } }
}
Close-Window