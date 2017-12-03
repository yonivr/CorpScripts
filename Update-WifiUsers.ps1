#made by Yoni Rivkin 
#Requires -module Posh-SSH

#Parameters
$SFTPUser = "Wifi-ADSync-SystemBO"
$SFTPPass = "85eGOUN5" | ConvertTo-SecureString -asPlainText -Force
$SFTPCred =  New-Object System.Management.Automation.PSCredential($SFTPUser,$SFTPPass)
$SFTPServer = "sftp.888holdings.com"
$CleanADUsers = "C:\scripts\AD-Sync\LatestClean.csv"
$count
#connect to SFTP
$s = new-SFTPSession -credential $SFTPCred -ComputerName $SFTPServer
#get file from SFTP

#get latest file containing cleanusers
$LatestCleanUsers = (Get-SFTPChildItem -SFTPSession $s | Where-Object {$_.Name -like "*CleanUsers*"} | Sort-Object LastAccessTime -Descending | Select-Object -First 1 | Select-Object name).name

"Downloading $File..."
Get-SFTPFile -SFTPSession $s -RemoteFile $LatestCleanUsers -LocalPath $CleanADUsers

#create new 888free users
    #iterate list of users
    #check if user exists in Dirty AD
        #If user doesnt exist create user
$CleanADUsers | foreach-object {
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
 }
$count

#delete files from SFTP
