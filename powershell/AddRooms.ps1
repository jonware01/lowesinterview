using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Clear sessions
Get-PSSession | Remove-PSSession

# Generate a session
$Username = "jware@dragoncomputersolutions.com"
$Passwd = ConvertTo-SecureString "[neverdothis]" -AsPlainText -Force
$UserCredential = New-Object System.Management.Automation.PSCredential ($Username, $Passwd)
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

# Import session
$Commands = @("New-Mailbox", "Set-Place", "Set-User", "Set-CalendarProcessing", "Get-Mailbox")
Import-PSSession $Session -DisableNameChecking -CommandName $Commands | Out-Null

# Interact with query parameters or the body of the request.
$roomsCreated = 0
foreach($room in $Request.Body) {
    $name = $room.Name
    $email = $room.Email
    $capacity = $room.Capacity
    $department = $room.Department
    $company = $room.Company
    $hide = $room.Hide
    $floor = $room.Floor
    $phone = $room.Phone
    $street = $room.Street
    $city = $room.City
    $state = $room.State
    $zip = $room.Zip

    # If required params are set, process the request
    if ($name -and $email) {
        try {
            $status = [HttpStatusCode]::OK

            # Generate the mailbox
            New-Mailbox -Name $name -DisplayName $name -ResourceCapacity $capacity -PrimarySmtpAddress $email -Room
            
            # Sleep for thirty seconds
            Start-Sleep -s 30

            # Set Location Information
            Set-Place -Identity $name -Floor $floor
            Set-User -Identity $name -Street $street -City $city -State $state -PostalCode $zip -Department $department -Company $company
            
            # Set calendar processing
            Set-CalendarProcessing -Identity $name -AutomateProcessing AutoAccept -AllowRecurringMeetings ([System.Convert]::ToBoolean($repeat)) -MaximumDurationInMinutes (60*$duration) -BookingWindowInDays $lead -AllBookInPolicy $true
            
            $roomsCreated++;
        }
        catch {
            [HttpStatusCode]::BadRequest
            $body = "An error occurred generating $name"
        }
    }
}

$body = "Created ${$roomsCreated} rooms"

# Clear sessions
Get-PSSession | Remove-PSSession

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $body
})
