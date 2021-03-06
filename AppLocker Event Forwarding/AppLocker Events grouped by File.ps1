###########################
#This script can be run on a server that collects forwarded AppLocker events 
#to help perform basic analysis by grouping the events by file path 
#to show if there are any files that are being blocked many times. 
#
#This script can take two arguments with the first specifying the number of 
#previous days worth of events to retrieve and the second specifying the number
#of previous hours worth of events to retrieve.  By default, without any 
#arguments specified, the script will retrieve one day's events.
###########################

Import-Module AppLocker

$daysToGet = 1
$hoursToGet = 0

if($args.Length -ge 1) 
{  
  $daysToGet = $args[0] 
}
if($args.Length -ge 2) 
{ 
  $hoursToGet = $args[1] 
}
$timespan = (get-date) - (new-timespan -Days $daysToGet -Hours $hoursToGet)

Write-Host Retrieving AppLocker events since $timespan
$events = Get-WinEvent -LogName ForwardedEvents | Where {$_.timecreated -ge $timespan -and $_.ProviderName -eq "Microsoft-Windows-AppLocker"} 
if($events -eq $Null) {
  Write-Host No AppLocker events found in the requested time range.
  Exit
}
ForEach ($event in $events) 
{
  $event.Message = $event.Message.TrimEnd(" was prevented from running.")
  $event.Message = $event.Message.TrimEnd(" was allowed to run but would have been prevented from running if the AppLocker policy were enforced.")
}

Write-Host Showing counts of AppLocker events per file path since $timespan
$events | Group-Object Message | Sort-Object Count -Descending | Format-Table Count,Name -AutoSize
