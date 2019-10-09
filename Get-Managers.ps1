Clear-Host

$userData = @()

# GET ALL AZURE AD USERS
$aadusers = Get-AzureADUser -All $true | Select-Object DisplayName, UserPrincipalName
#Uncomment the line below if you need to test with 100 users and comment line above
#$aadusers = Get-AzureADUser -Top 100 | Select-Object DisplayName, UserPrincipalName

# LOOP THROUGH USERS
foreach ($usr in $aadusers)
    {  
        $aadmanager = Get-AzureADUserManager -ObjectId $usr.UserPrincipalName | Select-Object DisplayName, UserPrincipalName
        $uUDP = $usr.DisplayName
        $uUPN = $usr.UserPrincipalName

        If($null -eq $aadmanager) {
            $mName = "None"
            $mUPN = "None"
        }else {
            $mName = $aadmanager.DisplayName
            $mUPN = $aadmanager.UserPrincipalName

            $uData = New-Object -TypeName psobject
            $uData | Add-Member -MemberType NoteProperty -Name UserDisplayName -Value $uUDP
            $uData | Add-Member -MemberType NoteProperty -Name UserPrincipalName -Value $uUPN
            $uData | Add-Member -MemberType NoteProperty -Name ManagerDisplayName -Value $mName
            $uData | Add-Member -MemberType NoteProperty -Name ManagerUPN -Value $mUPN

            $userData += $uData
        }
    }

# EXPORT DATA TO EXCEL
$userData | Select-Object UserDisplayName, UserPrincipalName, ManagerDisplayName, ManagerUPN | Export-Excel -Path C:\Exports\User_Manager_Report.xlsx -BoldTopRow -AutoSize
