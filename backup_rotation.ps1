<#
.Synopsis
 Simple Backups/logs Rotation script.
.Description
 This script will delete files and folders that older then specified Days count or items that exceeded Ammount value (sorted by CreationTime property).
 WARNING!
 Use either Days or Amount!
 The script will process items on Days only if both parameters specified.
.Example
   backup_rotation.ps1 -TargetFolder <path_to_backup_folder> -[Days <N>|Amount <N>] [-Pattern <some_pattern_or_wildcard>]
.Example
   c:\utils\backup_rotation.ps1 -TargetFolder "E:\ALS\A2LP\backup" -Pattern "backup*SinglePageCheckoutPix" -Days 7
  Will keep backups for last 7 days:
.Example
   c:\backup_rotation.ps1  -TargetFolder C:\Temp -Amount 7
  Will keep last 7 items 
#>
 
Param (
    [Parameter(Mandatory=$True)]
        [string]$TargetFolder,
    [Parameter(Mandatory=$False)]
        [string]$Pattern,
    [Parameter(Mandatory=$False)]
        [int]$Days = $false,
    [Parameter(Mandatory=$False)]
        [int]$Amount = $false,
    [Parameter(Mandatory=$false)]
        [Boolean]$SendEmail = $false,
    [Parameter(Mandatory=$False)]
        [string]$MailTo = "none@example.com",
    [Parameter(Mandatory=$False)]
        [string]$MailFrom = "none@example.com",
    [Parameter(Mandatory=$False)]
        [string]$MailServer = "mail.example.com"
)
 
# generates a nicely formatted time stamp for logging
function StampTime() {
    return "[" + (Get-Date -Format u) + "]"
}
 
# record the script name
$scriptName = ($MyInvocation.MyCommand).Name
# record the path
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path $scriptPath
# set the event source
New-EventLog -LogName "Application" -Source "CustomScripts" -ErrorAction SilentlyContinue
Write-EventLog -LogName Application -Source "CustomScripts" -EventId 1000 -EntryType Information -Message "$scriptName Started"

#main

try {
    # if there's no trailing slash add it
    if ( !$TargetFolder.EndsWith("\") ) {
        $TargetFolder += "\"
    }
 
    # date to append
    $date = Get-Date -Format "yyyy-MM-dd-hhmmss"
 
    # log
    $log = ""
    # check the path
    if ( (Test-Path -Path $TargetFolder) -eq $false ) {
        # path is bad
        $log = (StampTime) + (" $TargetFolder appears to be unreachable or invalid`n")
    } else {
 
        $log += (StampTime) + (" Searching $LogPath...`n")
	# if no patter, than filter all
        if(!$Pattern) {
	  $Pattern = "*"
	}
	# Rotate last N days, if specified
        if($Days) {
		  $ItemList = Get-Childitem -Path $TargetFolder -Filter $Pattern  | Where{$_.LastWriteTime -gt (Get-Date).AddDays(-$Days)} 
	# Rotate last N items, if specified
	} elseif ($Amount) {
		  $ItemList = Get-Childitem -Path "$TargetFolder" -Filter $Pattern -force | Sort-Object -Property CreationTime -Descending | Select-Object  -Skip $Amount
	# You'd better choose what to delete
	   } else {
		  $log = (StampTime) + (" Retention policy didn't set `n")
	    }
	# Check if there is job to do
        if ( $ItemList.Count -eq $null ) {
            # none
            $log += (StampTime) + ("Found 0 log files`n")
        } else {
            # got some
                $log += (StampTime) + (" Found " + $ItemList.Count + " log files`n")
            # loop through the list 
	
           ForEach ( $f in $ItemList ) {
		  Remove-Item  $TargetFolder$f -Force -Recurse -Confirm:$false
		  $log += (StampTime) + (" $f Removed`n")
            }
          }          
         $log += (StampTime) + (" Complete")            
            
            }
            # done output details to the console
            if ( $SendEmail -eq $true ) {
                $MailSubject = "[SUCCESS] Rotate Logs - " + $s.Name + " (" + $LogFile + ")"
                Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $log -SmtpServer $MailServer -Priority Low
            }
        }
    
    # write the details to the event log
    
 Catch [System.Exception] {
    # something went wrong
    if ( $SendEmail -eq $true ) {
        $MailSubject = "[ERROR] Rotate Logs"
        Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $Error[0] -SmtpServer $MailServer -Priority High
    }
    Write-EventLog -LogName Application -Source "CustomScripts" -EventId 1000 -EntryType Error -Message $Error[0]
} 

Finally
 {
  Write-EventLog -LogName "Application" -Source "CustomScripts" -EventId 1000 -EntryType Information -Message $log
 }
