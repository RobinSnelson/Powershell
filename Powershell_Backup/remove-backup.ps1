$RSErrorLogPreference = "c:\Temp\errors.txt"

function Remove-RSOldBackup
{
    <#
    .Synopsis
       Removes Old Backups
    .DESCRIPTION
       Removes old backups against a retentionperiod that is set by the CSV file, any folder older than the retentionperiod in days will be removed
    .EXAMPLE
       remove-RSOldbackup -Backupfolder ANYFOLDER -retentionPeriod aNUMBER
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$BackupFolder,

        [Parameter(Mandatory=$true)]
        [int]$retentionPeriod

    )
      $folders = Get-ChildItem -Path $BackupFolder -Directory
      if ($folders){
        foreach($folder in $folders){
        $dayDifference = [datetime] (get-date) - [datetime] ($folder.CreationTime)
        Write-Verbose "Difference is $($dayDifference.days)"
            if ($($dayDifference.days) -gt $retentionPeriod){
               remove-item -path "$folderToTidy\$($folder.name)" -recurse -force
            }
      }
      }else{
        Write-Verbose "$Folder not available to Check"
        $folder | out-file $RSErrorLogPreference -Append
      }
}


