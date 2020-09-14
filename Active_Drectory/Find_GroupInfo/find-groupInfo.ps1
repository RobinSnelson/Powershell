#set locatin to where the script is
Set-Location $PSScriptRoot

#clear the values in the groups variable
$groups = $null

#fill the groups variable
$groups = Get-ADGroup -filter *

#Create CV where to store Details of the groups
Add-Content -path .\GroupsInfo.csv -value '"Name","Number Of Members", "Group Scope", "Group category"'
$file = ".\GroupsInfo.csv"

#Check each group for the details required
Foreach($group in $groups){
    #get all the information about the group
    $groupFull = get-adgroup -filter * -Properties * | Where-Object {$_.name -like $group.name}

    #find all the users for the group
    $groupUsers = Get-ADGroupMember $groupFull.distinguishedname -Recursive
    #Save the information out to a file for future use
    $groupUsers | Export-Csv -Path ".\info_for_$($group.name).txt"

    #write the information for the group into the CSV 
    $newline = "{0},{1},{2},{3}" -f $group.name,$groupUsers.count,$groupFull.GroupScope,$groupFull.GroupCategory
    $newline | add-content -Path $file


}