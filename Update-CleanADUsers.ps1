<#
made by Yoni Rivkin
Uloade to SFTP list of active employees
Requires -module Posh-SSH
Requires -module AD
#>

#Parameters
#AD parameters
$HrzBase = "OU=Users,OU=Herzliya,OU=Organization,DC=888holdings,DC=corp"
#SFTP parameters
$SFTPUser = "Wifi-ADSync-SystemBO"
$SFTPPass = "passowrd" | ConvertTo-SecureString -asPlainText -Force
$SFTPCred =  New-Object System.Management.Automation.PSCredential($SFTPUser,$SFTPPass)
$SFTPServer = "sftp.888holdings.com"
#general parameters
$ADSyncRoot=(Get-Location).Path
#Get users
$HrzUSers = get-aduser -Filter {enabled -eq $true} -SearchBase $HrzBase -Properties extensionAttribute2 | Where-Object{($_.extensionAttribute2 -like "2*") } | Select-Object Name,GivenName,Surname,SamAccountName,extensionAttribute2,enabled
$UsersToAdd =  $HrzUSers
$UserList = "$ADSyncRoot\CleanUsers.csv"
$UsersToAdd | Export-csv $UserList
#Upload users
$UsersToAdd.Count
$s = new-SFTPSession -credential $SFTPCred -ComputerName $SFTPServer
Set-SFTPFile -SFTPSession $s -RemotePath / -LocalFile $UserList -Overwrite
#close SFTP session
Get-SFTPSession | Remove-SFTPSession
#clean local list
remove-item $UserList
