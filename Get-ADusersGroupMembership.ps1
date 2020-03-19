Import-Module ActiveDirectory

$SB = "OU=Users,OU=!Central,OU=Europe,DC=ads01,DC=dir,DC=net"

$allUsers = Get-ADUser -Filter * -SearchBase $SB
$results = @()
 
foreach($user in $allUsers)
{
    $userGroups = Get-ADPrincipalGroupMembership -Identity $user
    foreach($group in $userGroups)
    {
        $adGroup = Get-ADGroup -Identity $group -Properties Description
        $results += $adGroup | Select-Object -Property @{name='User';expression={$user.sAMAccountName}},Name,Description
    }
}
$results | Export-Csv -Path 'D:\Users\myuser\Documents\Membership.csv' -NoTypeInformation -Encoding Unicode
