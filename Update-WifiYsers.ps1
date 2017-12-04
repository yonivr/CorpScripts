#made by Yoni Rivkin 
#Requires -module Posh-SSH

#Parameters
$SFTPUser = "Wifi-ADSync-SystemBO"
$SFTPPass = "85eGOUN5" | ConvertTo-SecureString -asPlainText -Force
$SFTPCred =  New-Object System.Management.Automation.PSCredential($SFTPUser,$SFTPPass)
$SFTPServer = "sftp.888holdings.com"
$ScriptRoot = "C:\scripts\AD-Sync\v2"
$CleanUsers = "CleanUsers.csv"
$count=0
$OU = "OU=WiFi,OU=Users,OU=888free.net,DC=888Free,DC=net"
#connect to SFTP
$s = new-SFTPSession -credential $SFTPCred -ComputerName $SFTPServer
#get file from SFTP

#get latest file containing cleanusers

"Downloading $File..."
Get-SFTPFile -SFTPSession $s -RemoteFile $CleanUsers -LocalPath $ScriptRoot -Overwrite

#create new 888free users
    #iterate list of users
    #check if user exists in Dirty AD
        #If user doesnt exist create user
$CleanADUsers = Import-Csv $ScriptRoot\$CleanUsers
($CleanADUsers).count

$CleanADUsers | foreach-object {
    $user = $_.SamAccountName
	$UserExists = Get-ADObject -Filter {SamAccountName -eq $user}        
	 if(!$UserExists)
	{
        $UserPass = "Hrz"+$_.extensionAttribute2
        $SecurePass = (ConvertTo-SecureString $UserPass -AsPlainText -force)
        $UserDisplayName = $_.name
        $GivenName = $_.GivenName
        $Surname = $_.Surname
        
		$UserPrinicpalName = $user + "@888free.net" 
        
       New-ADUser `
        -SamAccountName $user `
        -UserPrincipalName $UserPrinicpalName`
        -Name $UserDisplayName `
        -DisplayName $UserDisplayName `
        -GivenName $GivenName `
        -SurName $Surname `
        -Path $OU `
        -AccountPassword $SecurePass `
        -Enabled $True `
        -ChangePasswordAtLogon:$false
        
        "user:$user
         upn:$UserPrinicpalName 
         displayname:$UserDisplayName 
         cn:$GivenName 
         sn:$Surname
         password:$UserPass
         ou:$OU
         
         "

		
		$count=$count + 1
	}
 }
$count
