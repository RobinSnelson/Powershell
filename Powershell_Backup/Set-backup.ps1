#Gets list of backup jobs

if(!(test-path "e:\Development\Powershell_Backup\backups.csv")){
Write-Warning "CSV of backups Missing"

} else {

Write-Verbose "Getting list of Backup Jobs"
$backupJobs = Import-Csv -Path "e:\Development\Powershell_Backup\backups.csv"

}


#Gets Date
$date = (get-date -Format ddMMyy).ToString()

function createFolder ([string]$pathTo,[string]$folderCreate)
{
    New-Item -Path $pathTo -Itemtype Directory -Name $folderCreate
}


function tidyUp ([string]$folderToTidy,[int32]$retentionPeriod)
{

$folders = Get-ChildItem -Path $folderToTidy -Directory

    foreach($folder in $folders){

        $dayDifference = [datetime] (get-date) - [datetime] ($folder.CreationTime)

        Write-host "Difference is $($dayDifference.days)"

        if ($($dayDifference.days) -gt $retentionPeriod){

        remove-item -path "$folderToTidy\$($folder.name)" -recurse -force
        }
    
    }
}


foreach($backupJob in $backupJobs){
    
    #If the Main backup job has not been ran before then this will create the main folder, after checking whether it exists
    if (!(Test-Path "$($backupJob.to)\$($backupJob.Name)")) {
        
    createFolder -pathTo $($backupJob.to) -folderCreate $($backupJob.Name)

    }
        #Should I backup the files or not
        $freqDiff =[datetime] (Get-Date) - [datetime] ((Get-ChildItem -Path "$($backupJob.to)\$($backupJob.Name)" -directory |?{$_.PSIsContainer} | Sort CreationTime )[-1]).CreationTime

        if($backupJob.freq -eq "0"){
                #This creates the folder for the individual Backup of the day
                if (!(Test-Path "$($backupJob.to)\$($backupJob.Name)\$($backupJob.Name)-$date")) {
               
                createFolder -pathTo "$($backupJob.to)\$($backupJob.Name)" -folderCreate "$($backupJob.Name)-$date"

                }

                #Get the files to backup, place them in the $files variable
                $files = get-childitem -path $backupJob.from -recurse

                #Back all the files up
                #Foreach ($file in $files){

                    write-host  (get-date).ToShortTimeString()

                    #Change made here******************************************************************************************************************
                    copy-item -Path $backupJob.from -Recurse -Destination "$($backupJob.to)\$($backupJob.Name)\$($backupJob.Name)-$date"  -verbose

                    #robocopy $($backupJob.from) "$($backupJob.to)\$($backupJob.Name)\$($backupJob.Name)-$date" /MIR /R:0 /W:0 /NFL /NDL

                    #write-host "File copied"
                #}

                #Call Tidy Up function
                tidyUp -folderToTidy "$($backupJob.to)\$($backupJob.Name)" -retentionPeriod $($backupjob.retention)
        
        } elseif( $freqDiff -ge $backupJob.Freq) {

                #This creates the folder for the individual Backup of the day
                if (!(Test-Path "$($backupJob.to)\$($backupJob.Name)\$($backupJob.Name)-$date")) {
               
                createFolder -pathTo "$($backupJob.to)\$($backupJob.Name)" -folderCreate "$($backupJob.Name)-$date"

                }

                #Get the files to backup, place them in the $files variable
                $files = get-childitem -path $backupJob.from -recurse

                copy-item  -Path $backupJob.from -Destination "$($backupJob.to)\$($backupJob.Name)\$($backupJob.Name)-$date\"

                #Call Tidy Up function
                tidyUp -folderToTidy "$($backupJob.to)\$($backupJob.Name)" -retentionPeriod $($backupjob.retention)


        }

      


}






