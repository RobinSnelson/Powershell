Set-Location $PSScriptRoot

$OUs = Import-CSV -Path .\NWOus.csv

Foreach($ou in $ous)
{
    #This needs to be your full domain CN
    $path = (Get-ADDomain).distinguishedName

    $units = ($ou.DistinguishedName).Split(",")
    [array]::Reverse($Units)
    
        foreach($unit in $units)
        {
            $name = $unit.split("=")
            if($name[0] -eq "DC")
            {
                #Do Nothing
            }
            else
            {
                try
                {
                    if(Get-ADOrganizationalUnit -Identity "$unit,$Path" -ErrorAction Stop)
                    {
                        $path = "$unit,$Path"
                        Write-host "Path to create OU is now $path"
                    }    
                }
                catch
                {
                    New-ADOrganizationalUnit -Name $name[1] -Path $Path -ProtectedFromAccidentalDeletion $false
                }        
            }
        }
}
