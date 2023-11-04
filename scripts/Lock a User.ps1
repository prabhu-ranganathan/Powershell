# Specify the username of the user you want to lock
$usernameToLock = "UsernameToLock"

# Lock the user
$user = [System.Web.Security.Membership]::GetUser($usernameToLock)
if ($user -ne $null) {
    $user.UnlockUser() # Ensure the user is not locked
    $user.IsApproved = $false
    [System.Web.Security.Membership]::UpdateUser($user)
    Write-Host "User '$usernameToLock' has been locked."
}
else {
    Write-Host "User '$usernameToLock' not found."
}
