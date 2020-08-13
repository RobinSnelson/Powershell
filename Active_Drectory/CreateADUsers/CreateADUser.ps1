Add-Type -AssemblyName presentationframework, presentationcore
Add-Type -Assembly Microsoft.VisualBasic
<#
Sample CSV File copy out an fill in as required save as a CSV next to main file
givenname,surname,enabled,Path,ChangePassword
Harry,Spider,yes,"OU=Users,OU=Work,DC=heliostech,DC=Local",No
Terry,Jamieson,No,"OU=Users,OU=Work,DC=heliostech,DC=Local",No
Pietro,Parker,yes,"OU=Users,OU=Work,DC=heliostech,DC=Local",No
#>

#Enter Name of CSV that contains the Data as set out above
$UserstoCreate = import-csv -Path ".\user.csv"
#Enter Dmain Name
$domain = "heliostech.local"
#sets date for Password CSV
$date = get-date -format HHmmddMMyyyy
add-content -path .\NewUsers$date.csv -Value '"Active Directory Name","FirstName","SurName","Password","EmailAddress","UPN"'
$file = ".\NewUsers$date.csv"

#Create s new password for each new user against a given length and special characters
function new-securepassword ([int]$length,[int]$specialcharacters){
    $pw = ([System.Web.Security.Membership]::GeneratePassword($length,$specialcharacters))
    return $pw
}

function New-SamAccountName([String]$givenName,[string]$Surname){

    #Create Sam to check
    $User= "$($givenname[0])$surname"

    try{ 
        #Check if SAM exists
        Get-ADUser -Identity $User -ErrorAction SilentlyContinue | out-null
            #if Sam exists find out next available integer
            $count = 0
            do {
                #create new user to test
                $count ++
                $samToTest = "$User$count"
            try{
                #check new user doesnt exist
                Get-aduser -Identity $samToTest -ErrorAction stop | out-null
                #$NewSam = $samToTest
            }catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
                #Increment the 
                $NewSam = $samToTest
                $numberFound = $count
            }
        }until ($numberFound -eq $count)
    }catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{ 
    #Write-Host "$User doesn't exist" -ForegroundColor Red
    $NewSam = $user
    }catch{ 
    Write-Output "Something else bad happened" 
    }    
    return $NewSam
}

Function New-EmailAddress([String]$givenName,[string]$Surname,[String]$Sam,[String]$domain){
    #Checks to see if a user with the same first name and surname is present
$ProspectiveEmail = "$givenname.$surname"
$testVar = $Sam[-1]
    if(get-aduser -filter {(Givenname -eq $givenname) -and (Surname -eq $surname)}){
        if([Microsoft.VisualBasic.information]::IsNumeric($testvar)){
           $newSurname = "$surname$testVar"
        }else{
            $newSurname = $surname
        }
        $ProspectiveEmail = "$givenname.$newSurname"
        $NewEmail = "$ProspectiveEmail@$domain"
       
    }else{

        $ProspectiveEmail = "$givenname.$Surname"
        $NewEmail = "$ProspectiveEmail@$domain"

    }

    return $NewEmail
   
}

foreach($account in $UserstoCreate){
    $splatt = $null

    $SamAccountName = New-SamAccountName -givenName $account.givenname -Surname $account.surname
    $mailAddresstoAdd = New-EmailAddress -givenName $account.givenname -Surname $account.surname -Sam $SamAccountName -domain $domain
   

    if($account.ChangePassword -eq "Yes"){
    $changePassword = $true
    } else {
    $changePassword = $false
    }

    $SurnameTest = ($mailAddresstoAdd).split("@")
    $surnameTestVar = ($SurnameTest[0])[-1]

    if([Microsoft.VisualBasic.information]::IsNumeric($Surnametestvar)){
        $newSurname = "$($account.surname)$SurnametestVar"
    }else{
         $newSurname = $account.surname
     }
    
    
    $splatt = @{
        displayname = "$($account.givenname) $($account.surname)"
        givenname = $account.givenname
        surname = $newSurname
        emailaddress = $mailAddresstoAdd
        userprincipalname = $mailAddresstoAdd
        name = "$($account.givenname) $newSurname"
        samaccountname = $SamAccountName
        path = $account.path
        ChangePasswordAtLogon = $changePassword
    }

$nameToCheck = $splatt.samaccountname

    if(@(get-aduser -filter 'SamAccountName -eq $nameToCheck').count -eq 0){
    #create new AD user using the splatt hash table after to checking if the account exists
    New-aduser @splatt
    #Create and manage Passwords for new Users
    $pw = new-securepassword -length 10 -specialcharacters 1
    $password = $pw | ConvertTo-SecureString -AsPlainText -Force
    Set-ADAccountPassword -identity $splatt.samaccountname -NewPassword $password
        if($account.Enabled = "Yes"){
            Set-ADUser -Identity $nameToCheck -Enabled $true
        }
    $newline = "{0},{1},{2},{3},{4},{5}" -f $splatt.Name,$account.givenname,$account.surname,$pw,$splatt.emailaddress,$splatt.userprincipalname
    $newline | Add-Content $file
    }else{
    write-warning "User $nameToCheck already exists"
    }
}
