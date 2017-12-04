<#
made by Yoni Rivkin 
Requires -module Posh-SSH
Requires -module AD
Purpose: get list of users from clean and create users in dirty AD
#>

#Parameters
#SFTP cred
$SFTPUser = "Wifi-ADSync-SystemBO"
$SFTPPass = "85eGOUN5" | ConvertTo-SecureString -asPlainText -Force
$SFTPCred =  New-Object System.Management.Automation.PSCredential($SFTPUser,$SFTPPass)
$SFTPServer = "sftp.888holdings.com"
#File details
$ScriptRoot = "C:\scripts\Create-WifiUsers"
$CleanUsers = "CleanUsers.csv"
#general param
$count=0#count users to create
$OU = "OU=WiFi,OU=Users,OU=888free.net,DC=888Free,DC=net"
#connect to SFTP
$s = new-SFTPSession -credential $SFTPCred -ComputerName $SFTPServer -AcceptKey:$true
#get file from SFTP and overwrite old file

"Downloading $File..."
Get-SFTPFile -SFTPSession $s -RemoteFile $CleanUsers -LocalPath $ScriptRoot -Overwrite 

$CleanADUsers = Import-Csv $ScriptRoot\$CleanUsers
($CleanADUsers).count

#create new 888free users
$CleanADUsers | foreach-object { #iterate list of users
    $user = $_.SamAccountName
	$UserExists = Get-ADObject -Filter {SamAccountName -eq $user}  
    #check if user exists in Dirty AD      
	if(!$UserExists)
	{ #If user doesnt exist create user
        
        #parameters
        $UserPass = "Hrz"+$_.extensionAttribute2
        $SecurePass = (ConvertTo-SecureString $UserPass -AsPlainText -force)
        $UserDisplayName = $_.name
        $GivenName = $_.GivenName
        $Surname = $_.Surname
        
		$UserPrinicpalName = $user + "@888free.net" 
        #user creation
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
		$count=$count + 1#count users to create
	}
 }
$count#users created count

#close SFTP session
Get-SFTPSession | Remove-SFTPSession
#remove user list
Remove-Item $ScriptRoot\$CleanUsers
