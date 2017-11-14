#Test sending email with different display name or email
# Create message, add From mailaddress with custom display name
$Message = New-Object System.Net.Mail.MailMessage
$Message.From = New-Object System.Net.Mail.MailAddress 'yoni.rivkin@888holdings.com','Jon Smith'
$Message.To.Add('yoni.rivkin@888holdings.com')
$Message.Subject = 'Exciting email!'
$Message.Body = @'
Hi Recipient

Check my cool display name in Outlook!

Regards
Some Person
'@

# Send using SmtpClient
$SmtpClient = New-Object System.Net.Mail.SmtpClient 'smtp.888holdings.com'
$SmtpClient.Send($Message)
