﻿<#
	.Synopsis
	Script to manage passwords in encrypted xml files.

	.Description
	The user is given a menu to create/open file and then add/remove/retrieve encrypted passords

	.Example
	PS> PasswordManager.ps1
	.Notes
	.Link
#>
# ========= Parameters ====================================================


# ========= Functions ======================================================

Function Read-PasswordXmlFile
{
	Param
	(
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[IO.FileInfo]$XmlFile,

		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[String]$MasterPassword
	)
	try
	{
		$PasswordData = @{}
		if ($XmlFile.Exists)
		{
			$PasswordXml = [xml](Get-Content $XmlFile)
			ForEach ($XmlNode in @($PasswordXml.Credentials.Credential | Where-Object {$_.Account}))
			{
				$Account = ConvertFrom-EncryptedString -Encrypted $XmlNode.Account -Passphrase $MasterPassword
				$PasswordData[$Account] = $(ConvertFrom-EncryptedString -Encrypted $XmlNode.Password -Passphrase $MasterPassword)
			}
		}
		Write-Output $PasswordData
	}
	catch
	{
		throw "Failed to read xml file '$($XmlFile.FullName)'"
	}
}

Function Write-PasswordXmlFile
{
	Param
	(
		[Parameter(Mandatory=$true)]
		[HashTable]$PasswordData,

		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[IO.FileInfo]$XmlFile,

		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[String]$MasterPassword
	)
	try
	{
		$MemoryStream = New-Object IO.MemoryStream
		$XmlWriter = [Xml.XmlWriter]::Create($MemoryStream)
		$XmlWriter.WriteStartElement('Credentials')
		ForEach ($HashEntry in @($PasswordData.GetEnumerator() | Sort-Object Name))
		{
			$XmlWriter.WriteStartElement('Credential')
			$XmlWriter.WriteAttributeString('Account',$(ConvertTo-EncryptedString -String $HashEntry.Name -Passphrase $MasterPassword))
			$XmlWriter.WriteAttributeString('Password',$(ConvertTo-EncryptedString -String $HashEntry.Value -Passphrase $MasterPassword))
			$XmlWriter.WriteEndElement()
		}
		$XmlWriter.WriteEndElement()
		$XmlWriter.Close()
		$MemoryStream.Position=0
		$Xml = (New-Object IO.StreamReader $MemoryStream).ReadToEnd()
		$XmlData = [xml]$Xml
		$XmlData.Save($XmlFile)
	}
	catch
	{
		throw "Failed to write xml file '$($XmlFile.FullName)'"
	}
}

Function Read-MasterPassword
{
	$MP1 = Read-Host -AsSecureString -Prompt 'Enter the Master Password'
	$MP2 = Read-Host -AsSecureString -Prompt 'Re-enter the Master Password'
	$MPCred1 = New-Object Management.Automation.PSCredential 'MasterPassword',$MP1
	$MPCred2 = New-Object Management.Automation.PSCredential 'MasterPassword',$MP2
	if ($MPCred1.GetNetworkCredential().Password -eq '') {throw "Master Password cannot be empty"}
	if ($MPCred1.GetNetworkCredential().Password –ne $MPCred2.GetNetworkCredential().Password) {throw 'Passwords are not the same'}
	return $MPCred1.GetNetworkCredential().Password
}

Function Write-PasswordManagerEvent
{
	Param
	(
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[String]$TextData
	)
	Write-CustomEvent -LogName Application -EventID 1000 -EventType Information -TextData $TextData -EventSource 'Password Manager'
	# Write-Log -LogText $TextData -LogOnly
}

Function Start-MainMenu
{
	$MenuOptions =
	@{
		'D' = 'Delete Password'
		'G' = 'Get Password'
		'N' = 'New File'
		'O' = 'Open File'
		'R' = 'Reset Master Password'
		'S' = 'Set Password'
		'X' = 'Exit'
	}

	$Exit = $false
	$FirstRun = $true
	$Script:XmlFile = $null

	While (!$Exit)
	{
		if ($FirstRun) {$FirstRun = $false} else {Start-Pause}
		Clear-Errors
		Clear-Host

		# --- Write a summary
		Write-Host "`n`t===================================================================`n"
		Write-Host "`t`t`tPassword Manager Main Menu"
		Write-Host "`n`t===================================================================`n"
		Write-Host -ForegroundColor Green "`tTarget File: $($XmlFile.Name)"
		Write-Host -ForegroundColor Green "`n`t--- Options ---`n"
		$MenuOptions.Keys | Sort-Object | ForEach-Object {Write-Host "`t$($_):`t$($MenuOptions[$_])"}
		Write-Host "`n`t===================================================================`n"

		# --- Request an action from the user
		$Choice = Get-Choice -Prompt "`tSelect Option [$($($MenuOptions.Keys | Sort-Object) -Join ',')]" -Choices $MenuOptions.Keys
		$Option = $MenuOptions.$Choice

		# --- Process the action
		try
		{
			Switch ($Option)
			{
				'Delete Password'
				{
					if (!$XmlFile) {throw "No xml file selected, open an existing file or create a new file"}
					$PasswordData = Read-PasswordXmlFile -XmlFile $XmlFile -MasterPassword $MasterPassword
					if (!$PasswordData.Count) {throw "No accounts found in xml file"}
					$AccountName = Select-ListItem -ListItems $($PasswordData.Keys | Sort-Object) -Title 'Password Manager' -Prompt 'Select Account'
					if (!$AccountName) {throw 'No account selected'}
					if ($(Get-Choice -Prompt "Delete password for '$AccountName' [Y/N]?") -eq 'N') {throw "Action cancelled"}
					$PasswordData.Remove($AccountName)
					Write-PasswordXmlFile -PasswordData $PasswordData -XmlFile $XmlFile -MasterPassword $MasterPassword
					Write-Host "Password of account '$AccountName' deleted ok"
					Write-PasswordManagerEvent "User $env:UserName deleted password for account '$AccountName' from file $($XmlFile.FullName)"
				}
				'Get Password'
				{
					if (!$XmlFile) {throw "No xml file selected, open an existing file or create a new file"}
					$PasswordData = Read-PasswordXmlFile -XmlFile $XmlFile -MasterPassword $MasterPassword
					if (!$PasswordData.Count) {throw "No accounts found in xml file"}
					$AccountName = Select-ListItem -ListItems $($PasswordData.Keys | Sort-Object) -Title 'Password Manager' -Prompt 'Select Account'
					if (!$AccountName) {throw 'No account selected'}
					$PasswordData.$AccountName | Clip
					Write-Host "Password of account '$AccountName' copied to clipboard"
					Write-PasswordManagerEvent "User $env:UserName accessed password for account '$AccountName' from file $($XmlFile.FullName)"
				}
				'New File'
				{
					$NewXmlFile = Select-SaveFile -Title 'Password Manager' -Filter 'xml files (*.xml)|*.xml'
					if (!$NewXmlFile) {throw "No xml file selected"}
					$CheckLockFile = [IO.FileInfo]("$($NewXmlFile.FullName).lock")
					if ($CheckLockFile.Exists) {throw "xml file is locked by user: $(Get-Content $CheckLockFile)"}
					$MasterPassword = Read-MasterPassword
					Write-PasswordXmlFile -PasswordData @{} -XmlFile $NewXmlFile -MasterPassword $MasterPassword
					if ($LockFile) {$LockFile.Delete()}
					$LockFile = $CheckLockFile
					"$env:UserName" | Out-File -FilePath $LockFile.FullName
					$XmlFile = $NewXmlFile
					Write-Host "New xml file created ok"
					Write-PasswordManagerEvent "User $env:UserName created new password xml file $($XmlFile.FullName)"
				}
				'Open File'
				{
					$OpenXmlFile = Select-File -Title 'Password Manager' -Filter 'xml files (*.xml)|*.xml'
					if (!$OpenXmlFile) {throw "No xml file selected"}
					if ($OpenXmlFile -eq $XmlFile) {throw "That file already open"}
					$CheckLockFile = [IO.FileInfo]("$($OpenXmlFile.FullName).lock")
					if ($CheckLockFile.Exists) {throw "xml file is locked by user: $(Get-Content $CheckLockFile)"}
					$SecString = Read-Host -AsSecureString -Prompt 'Enter the Master Password'
					$MPCred = New-Object Management.Automation.PSCredential 'MasterPassword',$SecString
					if ($MPCred.GetNetworkCredential().Password -eq '') {throw "Master Password cannot be empty"}
					$MasterPassword = $MPCred.GetNetworkCredential().Password
					$PasswordData = Read-PasswordXmlFile -XmlFile $OpenXmlFile -MasterPassword $MasterPassword
					if ($LockFile) {$LockFile.Delete()}
					$LockFile = $CheckLockFile
					"$env:UserName" | Out-File -FilePath $LockFile.FullName
					$XmlFile = $OpenXmlFile
					Write-Host "Target file set to '$($XmlFile.FullName)'"
					Write-PasswordManagerEvent "User $env:UserName opened password xml file $($XmlFile.FullName)"
				}
				'Reset Master Password'
				{
					if (!$XmlFile) {throw "No xml file selected, open an existing file or create a new file"}
					$PasswordData = Read-PasswordXmlFile -XmlFile $XmlFile -MasterPassword $MasterPassword
					if (!$PasswordData.Count) {throw "No accounts found in xml file"}
					$NewMasterPassword = Read-MasterPassword
					Write-PasswordXmlFile -PasswordData $PasswordData -XmlFile $XmlFile -MasterPassword $NewMasterPassword
					$MasterPassword = $NewMasterPassword
					Write-Host "Master password reset for '$($XmlFile.FullName)'"
					Write-PasswordManagerEvent "User $env:UserName reset master password for file $($XmlFile.FullName)"
				}
				'Set Password'
				{
					if (!$XmlFile) {throw "No xml file selected, open an existing file or create a new file"}
					$PasswordData = Read-PasswordXmlFile -XmlFile $XmlFile -MasterPassword $MasterPassword
					$Credential = $Host.UI.PromptForCredential('Password Manager','Enter new credentials','','')
					if (!$Credential) {throw "Invalid Credential"}
					if (!$Credential.GetNetworkCredential().Password) {throw "Password cannot be empty"}
					if ($PasswordData.Keys -Contains $Credential.UserName -AND $(Get-Choice -Prompt 'Over-Write Existing Entry [Y/N]?') -eq 'N') {throw "Action cancelled"}
					$PasswordData[$Credential.UserName.TrimStart('\')] = $Credential.GetNetworkCredential().Password
					Write-PasswordXmlFile -PasswordData $PasswordData -XmlFile $XmlFile -MasterPassword $MasterPassword
					Write-Host "New password added for account '$($Credential.UserName.TrimStart('\'))'"
					Write-PasswordManagerEvent "User $env:UserName added/updated password for account '$($Credential.UserName.TrimStart('\'))' in file $($XmlFile.FullName)"
				}
				'Exit'
				{
					if ($LockFile) {$LockFile.Delete()}
					if ($PasswordData) {Remove-Variable -Name PasswordData}
					$Exit = $true
				}
			}
		}
		catch
		{
			Write-Warning 'Action Failed:'
			Show-Errors
		}
	}
}

# ========= Main ===========================================================

try
{
	# --- Header
	$ErrorActionPreference = 'Stop'
	Push-Location -LiteralPath $(Split-Path -Parent $MyInvocation.MyCommand.Path)
	try {Import-Module WintelTools} catch {Write-Host "WintelTools Module Not Loaded";Exit 1}
	# Start-Script $MyInvocation.MyCommand.Name
	
	# --- Check the user is running elevated
	# if (!$(Test-isMyAccountAdmin)) {throw "This script must be run with elevated privileges"}

	# --- Start the menu
	Start-MainMenu

	# --- Exit
	Exit-Success
}
catch
{
	Exit-Error
}
finally
{
	if (@(Get-Variable -Scope Script | Select-Object -ExpandProperty Name) -Contains 'MasterPassword') {Remove-Variable -Scope Script -Name MasterPassword}
}