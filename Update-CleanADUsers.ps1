#made by Yoni Rivkin 
#Requires -module Posh-SSH

#Parameters
<#$SparkwareDC = "dcbuch01.sparkware.corp"#>
$HrzBase = "OU=Users,OU=Herzliya,OU=Organization,DC=888holdings,DC=corp"
#$KievBase = "OU=Users,OU=Kiev,OU=Organization,DC=888holdings,DC=corp"
$SFTPUser = "Wifi-ADSync-SystemBO"
$SFTPPass = "85eGOUN5" | ConvertTo-SecureString -asPlainText -Force
$SFTPCred =  New-Object System.Management.Automation.PSCredential($SFTPUser,$SFTPPass)
$SFTPServer = "sftp.888holdings.com"
$ADSyncRoot=(Get-Location).Path
#//$date = (get-date -Format dd-MM-yy-mm-ss)
#Get users
#$SparkwareUsers = get-aduser -Filter * -Server $SparkwareDC -Properties extensionAttribute2 | Where-Object{($_.extensionAttribute2 -like "2*") -and ($_.enabled -eq $true)  } | Select-Object Name,GivenName,Surname,SamAccountName,extensionAttribute2,enabled
$HrzUSers = get-aduser -Filter {enabled -eq $true} -SearchBase $HrzBase -Properties extensionAttribute2 | Where-Object{($_.extensionAttribute2 -like "2*") } | Select-Object Name,GivenName,Surname,SamAccountName,extensionAttribute2,enabled
#$KievUsers = Get-ADUser -Filter * -SearchBase $KievBase -Properties extensionAttribute2 | Where-Object{($_.extensionAttribute2 -like "2*") -and ($_.enabled -eq $true)  } | Select-Object Name,GivenName,Surname,SamAccountName,extensionAttribute2,enabled
$UsersToAdd = $SparkwareUsers + $HrzUSers + $KievUsers
$UserList = "$ADSyncRoot\CleanUsers.csv"
$UsersToAdd | Export-csv $UserList
#Upload users
$UsersToAdd.Count
$s = new-SFTPSession -credential $SFTPCred -ComputerName $SFTPServer
Set-SFTPFile -SFTPSession $s -RemotePath / -LocalFile $UserList -Overwrite
