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
