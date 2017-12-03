#made by Yoni Rivkin 
#Requires -module Posh-SSH

#Parameters
$SFTPUser = "Wifi-ADSync-SystemBO"
$SFTPPass = "85eGOUN5" | ConvertTo-SecureString -asPlainText -Force
$SFTPCred =  New-Object System.Management.Automation.PSCredential($SFTPUser,$SFTPPass)
$SFTPServer = "sftp.888holdings.com"
$ScriptRoot = "C:\scripts\AD-Sync\v2"
$date = (get-date -Format dd-MM-yy-mm-ss)
$CleanADUsers = "$ScriptRoot\LatestClean-$date.csv"
$count=0
#connect to SFTP
$s = new-SFTPSession -credential $SFTPCred -ComputerName $SFTPServer
#get file from SFTP

#get latest file containing cleanusers
$LatestCleanUsers = (Get-SFTPChildItem -SFTPSession $s | Where-Object {$_.Name -like "*CleanUsers*"} | Sort-Object LastAccessTime -Descending | Select-Object -First 1 | Select-Object name).name

"Downloading $File..."
Get-SFTPFile -SFTPSession $s -RemoteFile $LatestCleanUsers -LocalPath $ScriptRoot -Overwrite

#create new 888free users
    #iterate list of users
    #check if user exists in Dirty AD
        #If user doesnt exist create user
$CleanADUsers = Import-Csv $ScriptRoot\$LatestCleanUsers
$CleanADUsers | foreach-object {
    $user = $_.SamAccountName
	$UserExists = Get-ADObject -Filter {SamAccountName -eq $user}        
	 if(!$UserExists)
	{
		$UserPass = "Hrz"+$_.extensionAttribute2
		$userprinicpalname = $user + "@888free.net" 
		#New-ADUser -SamAccountName $_.SamAccountName -UserPrincipalName $userprinicpalname -Name $_.name -DisplayName $_.name -GivenName $_.cn -SurName $_.sn -Path $OU -AccountPassword (ConvertTo-SecureString $DefaultADPassword -AsPlainText -force) -Enabled $True -ChangePasswordAtLogon:$true
		"$userprinicpalname	$UserPass"
		$count=$count + 1
	}
 }
$count

#delete files from SFTP
#Remove-SFTPItem -SFTPSession $s -Path "/$LatestCleanUsers"     -ErrorAction SilentlyContinue

#delete file locally
#remove-item  $CleanADUsers -ErrorAction SilentlyContinue
