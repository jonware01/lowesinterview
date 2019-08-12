using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request for rooms."

# Interact with query parameters or the body of the request.
$status = [HttpStatusCode]::OK

# Clear old sessions
Get-PSSession | Remove-PSSession

# Get a session
$Username = "jware@dragoncomputersolutions.com"
$Passwd = ConvertTo-SecureString "[neverdothis]" -AsPlainText -Force
$UserCredential = New-Object System.Management.Automation.PSCredential ($Username, $Passwd)
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

# Import the session
$Commands = @("Get-Mailbox","Get-Place","Get-User")
Import-PSSession -Session $Session -DisableNameChecking:$true -AllowClobber:$true -CommandName $Commands | Out-Null

# Get room mailboxes
$roomMailboxes = Get-Mailbox -ResultSize unlimited | where {$_.recipientTypeDetails -eq "roomMailbox"}

# Build objects with all room info
$rooms = @()
foreach($room in $roomMailboxes) {
    $place = Get-Place -Identity $room.DisplayName
    $user = Get-User -Identity $room.DisplayName

    $builtRoom = [ordered]@{
        Id = $room.Id
        Identity = $room.Identity
        SamAccountName = $room.SamAccountName
        ResourceCapacity = $room.ResourceCapacity
        UserPrincipalName = $room.UserPrincipalName
        Alias = $room.Alias
        DisplayName = $room.DisplayName
        PrimarySmtpAddress = $room.PrimarySmtpAddress
        EmailAddresses = $room.EmailAddresses
        HiddenFromAddressListsEnabled = $room.HiddenFromAddressListsEnabled
        Floor = $place.Floor
        Street = $user.StreetAddress
        City = $user.City
        State = $user.StateOrProvince
        Zip = $user.PostalCode
        Department = $user.Department 
        Company = $user.Company
    }

    $rooms += $builtRoom
}

# Clear sessions
Get-PSSession | Remove-PSSession

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $rooms
})
