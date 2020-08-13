#set locatin to where the script is
Set-Location $PSScriptRoot

#Fill Variable with all groups from AD
$groups = Get-ADGroup -Filter *

#Set up CSV to recieve Empty group Info
Add-Content -path .\EmptyGroups2911.csv -value '"Name","Group Scope","Samaccountname"'
$file = ".\EmptyGroups2911.csv"

#Cycle through each group to see if its empty or not
foreach($group in $groups){

    $members = Get-ADGroupMember -Identity $group.distinguishedname -Recursive

    #If Empty then record the name
    if($members.count -eq 0){

        $newline = "{0},{1},{2}" -f $group.name,$group.GroupScope,$group.Samaccountname
        $newline | add-content -Path $file

    }else{
        #Nothing
    }

}


