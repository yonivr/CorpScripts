#Parameters
$SFTPUser = "Wifi-ADSync-SystemBO"
$SFTPPass = "85eGOUN5" | ConvertTo-SecureString -asPlainText -Force
$SFTPCred =  New-Object System.Management.Automation.PSCredential($SFTPUser,$SFTPPass)
$SFTPServer = "sftp.888holdings.com"
$newDirtyUsersFile = "NewDirtyUsers.csv"
$DirtyUsers = "AllDirtyUsers.csv"
$ADSyncRoot = "C:\scripts\AD-Sync"

#Cleanup
remove-item $ADSyncRoot\$newDirtyUsersFile    -ErrorAction SilentlyContinue
remove-item $ADSyncRoot\$DirtyUsers    -ErrorAction SilentlyContinue
Get-SFTPSession | Remove-SFTPSession
#connect to SFTP
$s = new-SFTPSession -credential $SFTPCred -ComputerName $SFTPServer

#Download list of users to create in 888free
"Downloading $File..."
Get-SFTPFile -SFTPSession $s -RemoteFile $newDirtyUsersFile -LocalPath $ADSyncRoot

#Generate updated list of users 
$AllDirtyADUsers = Get-ADUser -Filter * -SearchBase $OU  | select Name,GivenName,Surname,SamAccountName,Enabled | Export-Csv $DirtyUsers -NoTypeInformation
Remove-SFTPItem -SFTPSession $s -Path "/$DirtyUsers"     -ErrorAction SilentlyContinue
Set-SFTPFile -SFTPSession $s -RemotePath / -LocalFile "$ADSyncRoot\$DirtyUsers"     -ErrorAction SilentlyContinue

#Delete all created files
remove-item $ADSyncRoot\$newDirtyUsersFile     -ErrorAction SilentlyContinue
remove-item  $ADSyncRoot\$DirtyUsers    -ErrorAction SilentlyContinue
Get-SFTPSession | Remove-SFTPSession
