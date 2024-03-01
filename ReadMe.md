# ADM Account Check and Delete Script

## Overview
This PowerShell script is designed to audit and manage Active Directory (AD) accounts, specifically focusing on ADM (administrative) accounts. It identifies and deletes ADM accounts under certain conditions, providing a comprehensive report through email notifications.

## Prerequisites
PowerShell environment

Active Directory module

Internet connectivity for online gallery module installation

## Usage
**Configure Settings:**

Adjust the following global settings in the script to suit your environment:

```
$Global:transcriptPath = "C:\ProgramData\Scripts\ADM_acc_check_and_delete\logs\" # Location of the log file

$Global:emailSmtpServer = "domain-com.mail.protection.outlook.com" # 365 domain for email notifications

$Global:emailTo = "email@domain.com" # Email notification recipient

$Global:emailFrom = "email@domain.com" # Email notification sender
```
**Run the Script:**

Execute the script to perform the ADM account audit and deletion.

```
.\ADM_Account_Check_and_Delete.ps1
```

**Review Email Notification:**

The script sends an email notification with the results of the audit, including deleted accounts and remaining active ADM accounts.

## Features
**Transcription Logging:**

The script logs its activities in a transcript file located at the specified path.

**Module Management:**

Automatically loads required modules, ensuring they are available for use.

**ADM Account Audit:**

Retrieves ADM accounts from Active Directory.
Identifies main user accounts associated with each ADM account.

**Account Handling:**

Deletes ADM accounts with inactive or missing main user accounts.

**Email Notification:**

Sends a detailed email notification summarizing the audit results.

## Results

The email notification includes three sections:

**Deleted Accounts - Unable to Locate Main Account:**

Lists ADM accounts for which the main account could not be located.

**Deleted Accounts - Main Account Disabled:**

Lists ADM accounts deleted due to the main account being disabled.

**Remaining Active ADM Accounts:**

Lists ADM accounts that are still active after the audit.

## Note
Make sure to review the email notification for detailed results after running the script.

**Disclaimer**: Use this script with caution in a controlled environment. Understand its impact on the Active Directory environment before execution.

Feel free to contribute or report issues!