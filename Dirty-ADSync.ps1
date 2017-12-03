#Parameters
$OU = "OU=WiFi,OU=Users,OU=888free.net,DC=888Free,DC=net"
$DefaultADPassword = "Israel888"
$SFTPUser = "Wifi-ADSync-SystemBO"
$SFTPPass = "85eGOUN5" | ConvertTo-SecureString -asPlainText -Force
$SFTPCred =  New-Object System.Management.Automation.PSCredential($SFTPUser,$SFTPPass)
$SFTPServer = "sftp.888holdings.com"
$newDirtyUsersFile = "NewDirtyUsers.csv"
$DirtyUsers = "AllDirtyUsers.csv"
$ADSyncRoot = "C:\scripts\AD-Sync"
$ExistingUsers = "C:\scripts\AD-Sync\existingusers1.txt"
#Create new 888free users
$count=0
$newDirtyUsers | foreach-object {
	$user=$_.SamAccountName
	$Searcher = [ADSISearcher]"sAMAccountName=$User"
	$Results = $Searcher.FindOne()            
	if(!$Results)
	{
		$UserPass = "Hrz"+$_.extensionAttribute2
		$userprinicpalname = $_.SamAccountName + "@888free.net" 
		#New-ADUser -SamAccountName $_.SamAccountName -UserPrincipalName $userprinicpalname -Name $_.name -DisplayName $_.name -GivenName $_.cn -SurName $_.sn -Path $OU -AccountPassword (ConvertTo-SecureString $DefaultADPassword -AsPlainText -force) -Enabled $True -ChangePasswordAtLogon:$true
		"$userprinicpalname	$UserPass "
		$count=$count + 1
	}
	else
	{
		$_.SamAccountName | Out-File C:\scripts\AD-Sync\existingusers1.txt -Append
	}
 }
$count
