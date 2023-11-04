# Retrieve user information from the ASP.NET Membership database
$users = [System.Web.Security.Membership]::GetAllUsers()

# Define a list of properties to display
$properties = @(
    @{ Label = "User"; Expression = { $_.UserName } },
    @{ Label = "Is Online"; Expression = { $_.IsOnline } },
    @{ Label = "Creation Date"; Expression = { $_.CreationDate } },
    @{ Label = "Last Login Date"; Expression = { $_.LastLoginDate } },
    @{ Label = "Last Activity Date"; Expression = { $_.LastActivityDate } }
)

# Display user information in a tabular format
$users | Show-ListView -Property $properties -Title "User Information" -PageSize 25
