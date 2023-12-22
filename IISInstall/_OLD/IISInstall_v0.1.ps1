$path =(Resolve-Path .\).Path
."$path\lib\include.ps1"

##.SYNOPSIS  
##	  Script used for the installation of IIS 8 on servers   
##.DESCRIPTION  
##    This script uses a function found in lib that will invoke windows Install-WindowsFeature method
##	  via powershell. The script will first verify a server can be reached by first attempting a ping check. 
##	  The script will then use pssesion to verify the server can run powershell scripting remotely. After 
##	  these checks come back succesful the script will check that a D: drive exists for establishment of IIS ##	   logs per AEP standards. The script will then install IIS by invoking commands on the server in question. 
##	  This script can be used with either a .txt document with a list of servers (one per line) or on a per 
##	  server basis if this list is not available. This lists required name is ServerList.txt
##.NOTES 
##    FileName	 :IISInstall_v0.1.ps1 
##	  Author     :Scott Flaherty - sdflaherty@aep.com
##	  Requires	 :PowerShell V2 
##				  ServerList.txt for checking multiple servers 
##    
##.Patch Fixes 
##	  v0.1		: Initial build of IISInstall script for use with IIS 8 installs.
##	  v0.2		: Added check to verify logfile is in place before running powershell script to add logs to location
##	  v0.3		: corrected issue where logfile was not being added to computer correctly.
##	  v0.4		: Added output that showed current path of log file after commands were run. 

	
#MAIN---------------------------------------------------------------------------

#Set variables for main function 
$date = get-date -Format MM-dd-y
$path =(Resolve-Path .\).Path
$ServerListFile = "ServerList.txt" 
$userid = [Environment]::UserName
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

#Reset all global variables as found in lib 
FuncResetGlobals

#Remove trailing whitespace and blank lines from list of servers
(gc ServerList.txt) | Foreach {$_.TrimEnd()} | where {$_ -ne ""} | Set-Content ServerList.txt
$ServerList = Get-Content $ServerListFile -ErrorAction SilentlyContinue   
$Result = @()  

#Start logging information displayed on console. 
FuncTranscript function

#Take password information from user if we do not already have it saved. Place this secured into a file in Credentials folder
FuncUserPassword 

#If serverlist does not have information request user input
if ((Get-Content ServerList.txt) -eq $Null){
	$server = read-host "Please enter the computer where you'd like to install IIS" 
	$cred = FuncDomainUser -server $server
	FuncInstallIIS -server $server -cred $cred
	
	write-output ""
	Write-Host "---------------------------------------------------------------" -foreground yellow
	
	#continue to prompt user for server input until they quit. 
	DO{
		write-host $global:flag
		$message = "Would you like to install IIS on another server?"
		$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
		$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
		$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
		$choice=$host.ui.PromptForChoice($title, $message, $options, 1)
		
		switch ($choice){
			0 { $server = read-host "Please enter the computer to test"
					$cred = FuncDomainUser -server $server
					FuncInstallIIS -server $server -cred $cred
			}
			1 { $global:flag = "q"}
			
		}
		
		
	}
	While ($global:flag -ne "q")
}

#If serverlist has information run loop on list of included servers
else{ 
	ForEach($Server in $ServerList){
		write-host $server "-----------------------------------------------------" -foreground yellow
		$cred = FuncDomainUser -server $server
		FuncInstallIIS -server $server -cred $cred
		write-host ""
	}
}	

#PAUSE the console so you can verify your information. 
Write-Host "---------------------------------------------------------------" -foreground yellow

#CLEANUP----------------------------------------------------------

#remove any and all PSSessions that might be hung by previous process and reset all flags. 
get-pssession | remove-pssession
$global:flag = ''
FuncResetGlobals

read-host "Press Any Key to close window....."

####Current Testing Features#####
#(TESTING) FuncInstallIIS : Function used for the installation of IIS 8 of server systems remotely. 

#####Version 1.0 Features#####

#####Future Features#####
#Installation of IIS 7.5 on remote system, if neccessary 
#Tie script to ServiceNow requests for IIS installation. 
#Clean up lib .ps1 for use with IISInstall script. 
 
