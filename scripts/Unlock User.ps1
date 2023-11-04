# Specify the username of the user you want to unlock
$usernameToUnlock = "UsernameToUnlock"

# Unlock the user
$user = [System.Web.Security.Membership]::GetUser($usernameToUnlock)
if ($user -ne $null) {
    $user.UnlockUser() # Ensure the user is not locked
    $user.IsApproved = $true
    [System.Web.Security.Membership]::UpdateUser($user)
    Write-Host "User '$usernameToUnlock' has been unlocked."
}
else {
    Write-Host "User '$usernameToUnlock' not found."
}
