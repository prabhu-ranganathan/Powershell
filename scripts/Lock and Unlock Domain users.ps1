# Specify the Sitecore domain (e.g., "extranet")
$domainName = "extranet"

# Get all users in the specified domain
$users = Get-User -Domain $domainName

# Specify the username of the admin user
$adminUsername = "admin"

# Check if a content freeze is active (set to $true if content freeze is active, $false otherwise)
$contentFreezeActive = $false

if ($contentFreezeActive) {
    # Content freeze is active, lock non-admin users
    foreach ($user in $users) {
        if ($user.UserName -ne $adminUsername) {
            $user | Lock-UserAccount
            Write-Host "User locked: $($user.UserName)"
        }
    }

    Write-Host "Non-admin users have been locked during the content freeze."
}
else {
    # Content freeze is over, unlock previously locked non-admin users
    foreach ($user in $users) {
        if ($user.UserName -ne $adminUsername) {
            $user | Unlock-UserAccount
            Write-Host "User unlocked: $($user.UserName)"
        }
    }

    Write-Host "Previously locked non-admin users have been unlocked after the content freeze."
}
