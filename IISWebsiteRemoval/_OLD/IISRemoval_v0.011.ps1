##.SYNOPSIS  
##	  Given a server and sitename allow for the deletion of a Windows 2003 IIS Website remotely
##.DESCRIPTION  
##    When running script user will be prompted for a servername and sitename. Once entered the script
##	  will remotely run adsutil.vbs tools on the server in order to get the websites W3SVC name and its logging
##	  path. Once this is done bindings will also be pulled from the site and NSLookup commands will be run
##	  to find IP, VIP and server information. this information will be put in a log file in order to be used at 
##	  a later date. Once these initial steps have been completed the user will be prompted to delete the site. Using
##	  IISWeb.vbs the script will then delete the site and also will delete the LogFile location. The script will then
##	  prompt the user for removal of another site if required.  
##
##.NOTES 
##    FileName	 :IISRemoval_v0.011.ps1 
##	  Author     :Scott Flaherty - sdflaherty@aep.com
##	  Requires	 :PowerShell V2  
##
##	  File Paths : LogFile  						: root\IISWebsiteRemoval2003\Logs
##				   Function Library 				: root\lib\include.ps1
##				   IISWeb.vbs						: root\lib\IISWeb.vbs
##				   adsutil.vbs						: root\lib\adsutil.vbs
##    
##.Patch Fixes 
##	  v0.01		: initial build
##	  v0.011	: added synopsis and description to script 

#Import the functions and tools I need to perform most of our jobs. 
$path =(Resolve-Path .\).Path
."$path\lib\include.ps1"
#."\\oh0co010\IISWEB\#IISScripting\IISWebsiteRemoval2003\lib\include.ps1"

#MAIN--------------------------------------------------------------------------------------------

#silence all error messages; Remove this in order to do error checking on script 
$ErrorActionPreference = "SilentlyContinue"

#Attempt to run powershell permissions as administrator, warn if you don't have permissions
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}

#flag variable for DNS Failure used to stop all functions but DNS check from running on failure
FuncResetGlobals

#Start logging information displayed on console. 
FuncTranscript function

#Lets run this Removal for the first time. 
$server = read-host "Please enter the SERVER that the site is stored on"
$siteName = read-host "Please enter the name of the SITE to delete"
FuncDeleteIISWebsite -server $server -siteName $siteName

write-output ""
Write-Host "---------------------------------------------------------------" -foreground yellow
	
DO{
	write-host $global:flag
	$title = "IIS WEBSITE DELETION"
	$message = "Would you like to run on another SITE or SERVER?"
	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
	$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
	$choice=$host.ui.PromptForChoice($title, $message, $options, 1)
	
	switch ($choice){
		0 { $server = read-host "Please enter the SERVER that the site is stored on"
			$siteName = read-host "Please enter the name of the SITE to delete"
				FuncDeleteIISWebsite -server $server -siteName $siteName
		}
		1 { $global:flag = "q"}
		
		}
		
		
}
While ($global:flag -ne "q")

#PAUSE the console so you can verify your information. 
Write-Host "---------------------------------------------------------------" -foreground yellow

#CLEANUP
#remove any and all PSSessions that might be hung by previous process and reset all flags. 
get-pssession | remove-pssession
$global:flag = ''
FuncResetGlobals

read-host "Press Any Key to close window....."

