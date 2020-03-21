<#
.Synopsis
    Writes event to an eventlog
.DESCRIPTION
    Writes given events to a supplied eventlog if that log doesn't exist then it creates the named log and then registers teh source to it, if the log exists
    it just registers the event source to it, usually the script name. Then continues to write the event as apprpriate.
.PARAMETER LogName
    The log name which the evnt is to be wrote to, defaults to 'Application'
.PARAMETER SourceName
    The source name to be registered, eg the name of the script.
.PARAMETER Message
    The messaage to be passed in as the event.
.PARAMETER EventID
    The eventID number this has to be an integer.
.PARAMETER Eventtype
    The Event type for the event in question, this is a linited parameter its limited to "Warning","Information", "Error", "FailureAudit", "SuccessAudit"
.EXAMPLE
    New-RSEVENT -LogName TheLog -SourceName TheScript -Message "Message from the Script" -EventID 12 -EventType "Warning"
    This writes an event to the log 'TheLog' after creating it for the source 'TheScript' after registering the source with the event ID 12 and the message "Message from the Script"
.NOTES  
    File Name  : new-event.ps1  
    Author     : Robin Snelson
    Version    : 1.0
    Date       : 09/02/2016
#>
function New-RSEvent
{
    [CmdletBinding()]
    
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$logName = 'Application',

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$SourceName,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$Message,
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [int]$EventID,

        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("Warning","Information", "Error", "FailureAudit", "SuccessAudit")]
        [string]$Eventtype = 'Information'
    )


    if ([System.Diagnostics.Eventlog]::Exists($logname) -eq $false){
            Try{
                New-EventLog -logName $logName -Source $SourceName -ErrorAction Stop -ErrorVariable MyErr
            }
            Catch
            {
                Write-Warning "EventLog Creation Failed"
                Write-Warning "The Error was $MyErr"
            }
    }
    else
    {
            Write-Verbose "Log Exists Testing Source"
    
            if([System.Diagnostics.EventLog]::SourceExists($sourcename) -eq $True){
                #EventSource exists
                Write-Verbose "Source exists Also"
            }
            else
            {
                #If the eventsource doesnt exist then create it
                Try{
                New-EventLog -LogName $logName -Source $sourceName -ErrorAction Stop -ErrorVariable MyErr
                }
                Catch
                {
                Write-Warning "EventLog Creation Failed"
                Write-Warning "The Error was $MyErr"
                }
            }
    }


    Write-EventLog -logName $logname -Source $SourceName -eventid $EventID -EntryType $Eventtype  -Message $Message
}

New-RSEvent -SourceName "SomeString" -EventID 16 -Message "a  test" -Eventtype Error