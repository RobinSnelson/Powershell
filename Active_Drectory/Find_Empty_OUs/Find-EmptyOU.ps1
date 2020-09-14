$OUs = Get-ADOrganizationalUnit -Filter *

Add-Content -path .\EmptyOUs2911.csv -value '"Name","DistinguishedName","memberCount"'
$file = ".\EmptyOUs2911.csv"

foreach($ou in $ous){

    $members = Get-ADObject -Filter * -SearchBase $ou.DistinguishedName
    $newline = "{0},{1},{2}" -f $ou.Name,$ou.DistinguishedName,($members.count).ToString()
    $newline | add-content -Path $file

}