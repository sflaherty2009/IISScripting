."C:\scripts\_lib\include_test.ps1"

#SETUP---------------------------------------------------------------------------

#Set variables for main function 
$date = get-date -Format MM-dd-y
$global:flag = ''

#silence all error messages; Remove this in order to do error checking on script 
$ErrorActionPreference = "SilentlyContinue"

#Attempt to run powershell permissions as administrator, warn if you don't have permissions
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}

#check for most up to date version of includes.ps1 then reload include.ps1 file.  
FuncCheckCurrentVersion function
."C:\scripts\_lib\include_test.ps1"

#Reset all global variables as found in lib 
FuncResetGlobals

#Start logging information displayed on console. (TURNED OFF)
FuncTranscript function

#Take password information from user if we do not already have it saved. Place this secured into a file in Credentials folder
FuncUserPassword 

#MAIN---------------------------------------------------------------------------

do {
	write-host ""
	write-host "IIS Scripts"
	write-host "Which process would you like to run on an IIS server?"
	write-host ""
	write-host "A - IIS Installation"
	write-host "B - IIS Website Change"
	write-host "C - IIS Website Addition"
	write-host "D - IIS Website Removal"
	write-host "E - Quit Service"
	write-host ""
	write-host -nonewline "Please select the script you would like to run: "
	
	$choice = read-host
	
	$ok = $choice -match '^[abcde]+$'
				
	if ( -not $ok) { write-host "Invalid selection" }
	} until ( $ok )
	
	if ($choice -eq "A" -or $choice -eq "a"){
		if(test-path "C:\scripts\IISInstall\IISInstall_test.ps1"){
			invoke-expression -Command "C:\scripts\IISInstall\IISInstall_test.ps1"
		}
		else{
			write-warning "C:\scripts\IISInstall\IISInstall_test.ps1 cannot be found and script will exit"
		}

	}
	if ($choice -eq "B" -or $choice -eq "b"){
		if(test-path "C:\scripts\IISWebsiteConfig\IISWebsiteConfig_test.ps1"){
			invoke-expression -Command "C:\scripts\IISWebsiteConfig\IISWebsiteConfig_test.ps1"
		}
		else{
			write-warning "C:\scripts\IISWebsiteConfig\IISWebsiteConfig_test.ps1 cannot be found and script will exit"
		}

	}
	if ($choice -eq "C" -or $choice -eq "c"){
		if(test-path "C:\scripts\IISWebsiteInstall\IISWebSiteInstall_test.ps1"){
			invoke-expression -Command "C:\scripts\IISWebsiteInstall\IISWebSiteInstall_test.ps1"
		}
		else{
			write-warning "C:\scripts\IISWebsiteInstall\IISWebSiteInstall_test.ps1 cannot be found and script will exit"
		}
		
	}
	if ($choice -eq "D" -or $choice -eq "d"){
		if(test-path "C:\scripts\IISWebsiteRemoval\IISRemoval_test.ps1"){
			invoke-expression -Command "C:\scripts\IISWebsiteRemoval\IISRemoval_test.ps1"
		}
		else{
			write-warning "C:\scripts\IISWebsiteRemoval\IISRemoval_test.ps1 cannot be found and script will exit"
		}
		
	}
	if ($choice -eq "E" -or $choice -eq "e"){
		exit 
	}	
