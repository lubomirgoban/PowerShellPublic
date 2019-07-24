<#
.SYNOPSIS
    Get users from particular domain with "empty" UPN and set correct UPN for those users.

.DESCRIPTION
    Get users from particular domain with "empty" UPN and set correct UPN for those users.

.INPUTS
    DC
    UPNdomain

.OUTPUTS

.NOTES
    Version:        1.0
    Author:         Lubomir Goban
    Creation Date:  16.07.2019
    Updated:        
  
.EXAMPLE
    None
#>

Clear-Host
Import-Module ActiveDirectory
Import-Module ImportExcel #Comment out if not needed

# GET CURRENT DATE. IT IS USED IN EXCEL FILE NAME
$date = Get-Date

################################
### CREDENTIALS USED TO SET UPNs
$username = "<username>"
$pass = Get-Content "$Env:USERPROFILE\Documents\Scripts\sys_mca_sa.txt" | ConvertTo-SecureString
$cred = New-Object System.Management.Automation.PSCredential($username, $pass)

##########
### SERVER
$DC = "<server name>"

##############################
# DOMAIN FOR USERPRINCIPALNAME
$UPNdomain = "<domain>"

############################################
# PATH WHERE THE EXPORTED FILE WILL BE SAVED
$file = "$Env:USERPROFILE\Documents\Exports\processed_users_$date.xlsx"

Write-Progress -Activity "Loading users.."
###############################
# GET LIST OF USERS FROM DOMAIN
$fportalusers = Get-ADUser -Server $DC -Filter * -Properties UserPrincipalName | 
                Select-Object Name, SamAccountName, Surname, UserPrincipalName | 
                Where-Object { ($_.UserPrincipalName -eq $NULL) `
                            -or ($_.UserPrincipalName -like $_.Name) `
                            -or ($_.UserPrincipalName -like $_.Surname) `
                            -and ($_.Surname -ne $NULL) `
                            -and ($_.Name -match '\D\d{0}$') # This expression filter out names with any number. If we change number to 1 or so, it will show name with 1 number at the end.
                        }

Write-Progress -Activity "Exporting users.."
$fportalusers | Export-Excel -path $file -WorkSheetname Users-noUPN -ClearSheet -AutoSize -BoldTopRow -FreezeTopRow -AutoFilter

Write-Host "Users exported to Excel.. Done." -ForegroundColor Magenta `r`n
Write-Host "Your file is saved in $file" -ForegroundColor Green `r`n

############################
# SET UPN FOR EXPORTED USERS
Set-ADUser $_.SamAccountName -UserPrincipalName "$($_.SamAccountname)@$UPNdomain" -server $DC -credential $cred

Write-Host "UPNs has been set.." -ForegroundColor Green
