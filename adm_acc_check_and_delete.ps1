# SETTINGS

$Global:transcriptPath = "C:\ProgramData\Scripts\ADM_acc_check_and_delete\logs\" # Location of the log file
$Global:emailSmtpServer = "domain-com.mail.protection.outlook.com" # 365 domain which will be used to send the email
$Global:emailTo = "email@domain.com" # send email notification to this address
$Global:emailFrom = "email@domain.com" # send email notification from this address

function Transcribe { 
    #transcript logging
    $currentAdmin = $env:Username
    $adminPC = $env:ComputerName
    $date = Get-Date -f yyyy-MM-dd_hh-mm-ss
    $transcriptFile = $transcriptPath + $currentAdmin + "_" + "$adminPC" + "_" + $date + ".txt" 
    Start-Transcript -Path $transcriptFile -noclobber
}

# Start transcript
Transcribe

function Load-Module ($m) {

    # If module is imported say that and do nothing
    if (Get-Module | Where-Object { $_.Name -eq $m }) {
        write-host "Module $m is already imported."
    }
    else {

        # If module is not imported, but available on disk then import
        if (Get-Module -ListAvailable | Where-Object { $_.Name -eq $m }) {
            Import-Module $m -Verbose
            Clear-Host
        }
        else {

            # If module is not imported, not available on disk, but is in online gallery then install and import
            if (Find-Module -Name $m | Where-Object { $_.Name -eq $m }) {
                Install-Module -Name $m -Force -Verbose -Scope CurrentUser
                Import-Module $m -Verbose
                Clear-Host
            }
            else {

                # If the module is not imported, not available and not in the online gallery then abort
                write-host "Module $m not imported, not available and not in an online gallery, exiting."
                EXIT 1
            }
        }
    }
}

function Print-Array($m){
    Foreach($a in $m)
    {
        Write-Host $a
    }
}

# Import the ActiveDirectory module
Load-Module "ActiveDirectory"

$users = Get-ADuser -filter "samaccountname -like 'adm.*'"
$errorusers = @()
$activeusers = @()
$deleteusers =@()


# Checking each account
foreach($user in $users)
{
    if($user.enabled -eq $True) # If the adm. account is enabled
    {
        $mainaccountname = $user.SamAccountName.Substring(4)
        try{
            $mainuser = Get-ADUser $mainaccountname # Looking for main account (what's after adm.)
        }catch{
            try
            {
                $mainaccountname = $user.GivenName + "." + $user.Surname.Split(" ")[0] # Looking for main account with FirstName.Surname
                $mainuser = Get-ADUser $mainaccountname
            }catch
            {
                #Write-Host "WARNING! Cannot find main account for $($user.samaccountname)"
                $errorusers += $user.SamAccountName
				Remove-ADUser -Identity $user -ea 0 -Confirm:$false
                $user = $null
                Continue
            }
        }

        if($mainuser.enabled -eq $False)
        {
            #Write-Host "$($mainuser.samaccountname) is DISABLED, deleting $($user.SamAccountName)"
            $deleteusers += $user.SamAccountName
            Remove-ADUser -Identity $user -ea 0 -Confirm:$false
        }else
        {
            #Write-Host "$($mainuser.samaccountname) is enabled, ignoring $($user.SamAccountName)"
            $activeusers += $user.SamAccountName
        }

    } else
    {
        $deleteusers += $user.SamAccountName
        Remove-ADUser -Identity $user -ea 0 -Confirm:$false
    }
}

Write-Host
Write-Host "Can't find main users accounts for: "
Print-Array($errorusers)
Write-Host
Write-Host "Accounts to be deleted: "
Print-Array($deleteusers)
Write-Host
Write-Host "Accounts with active main users: "
Print-Array($activeusers)

$erroruserstext = $null
$deleteuserstext = $null
$activeuserstext = $null

foreach($u in $errorusers)
{
    $erroruserstext += $u + "`r`n"
}

foreach($d in $deleteusers)
{
    $deleteuserstext += $d + "`r`n"
}

foreach($a in $activeusers)
{
    $activeuserstext += $a + "`r`n"
}

# Email Notification
$emailSubject = "ADM Account Audit Notification"
$emailBody = @"
Hello,

ADM accounts have been checked, please see the results below.

Deleted user accounts for which main account could not be located: 
$($erroruserstext)
Deleted user accounts for which main account is disabled:
$($deleteuserstext)
Remaining active adm accounts:
$($activeuserstext)

IT Team
"@
     
Send-MailMessage -To $emailTo -From $emailFrom -Subject $emailSubject -Body $emailBody -SmtpServer $emailSmtpServer