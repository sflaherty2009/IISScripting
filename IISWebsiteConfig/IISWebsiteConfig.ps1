$path =(Resolve-Path .\).Path
."$path\lib\include.ps1"

##.SYNOPSIS  
##	   Allow change of website configuration across all farm members for a given site. 
##.DESCRIPTION  
##    
##.NOTES 
##    FileName	 :IISWebSiteConfig_v0.01.ps1 
##	  Author     :Scott Flaherty - sdflaherty@aep.com
##	  Requires	 :PowerShell V2  
##    
##.Patch Fixes 
##	  v0.01		: initial build. 
##	  v0.02		: Added include.ps1 auto update functionality to script. Unless frontend revisions are neccessitated majority of 
##				  Patch Fix information will be found in include.ps1 


#MAIN---------------------------------------------------------------------------

#Set variables for main function 
$date = get-date -Format MM-dd-y
$path =(Resolve-Path .\).Path
$userid = [Environment]::UserName
$global:flag = ''
$global:flagServer = ''
$global:flagBinding = ''

#cleanup any sessions that might prevent script from proceeding.
get-pssession | remove-pssession

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
."$path\lib\include.ps1"

#Reset all global variables as found in lib 
FuncResetGlobals

#Start logging information displayed on console.
FuncTranscript function

#Take password information from user if we do not already have it saved. Place this secured into a file in Credentials folder
FuncUserPassword 

#MAIN---------------------------------------------------------------------------

DO{
	write-host $global:flag
	$message6 = "Would you like to change a WEBSITES configuration on a server?"
	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
	$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
	$options6 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
	$choice6=$host.ui.PromptForChoice($title6, $message6, $options6, 1)
		
	switch ($choice6){
		0 {
			
			#server you want to install the site on. 
			$server = read-host "Please enter the SERVER to change WEBSITE configuration to"
			
			#Get farm servers if they exist. 
			$servers = FuncWebFarmCheck -server $server
			$siteName = read-host "Please enter the name of the SITE"

			#Runtime Version for site--------------------------------------------------------
			$title1 = "RUNTIME VERSION"
			$message1 = "Would you like runtime version v2.0/v4.0 for site?"
			$2 = New-Object System.Management.Automation.Host.ChoiceDescription "&2", "2"
			$4 = New-Object System.Management.Automation.Host.ChoiceDescription "&4", "4"
			$options1 = [System.Management.Automation.Host.ChoiceDescription[]]($2, $4)
			$choice1=$host.ui.PromptForChoice($title1, $message1, $options1, 1)
						
			switch ($choice1){
				0 { 
					$version = "v2.0"
									
				}
				1 { 
					$version = "v4.0"
				}
			}
			
			#BIT APPLICATIONS--------------------------------------------------------
			$title2= "ENABLE 32BIT APPLICATIONS"
			$message2 = "Would you like to enable 32bit applications for site?"
			$Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
			$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
			$options2 = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
			$choice2=$host.ui.PromptForChoice($title2, $message2, $options2, 1)
						
			switch ($choice2){
				0 { 
					$bit = "true"
									
				}
				1 { 
					$bit = "false"
				}
			}
			
			#pipeline mode for site-----------------------------------------------------------
			$title = "PIPELINE MODE"
			$message = "Would you like Integrated/Classic pipeline mode?"
			$integrated = New-Object System.Management.Automation.Host.ChoiceDescription "&Integrated", "Integrated"
			$classic = New-Object System.Management.Automation.Host.ChoiceDescription "&Classic", "Classic"
			$options = [System.Management.Automation.Host.ChoiceDescription[]]($Integrated, $Classic)
			$choice=$host.ui.PromptForChoice($title, $message, $options, 0)
						
			switch ($choice){
				0 { 
					$pipeline = "Integrated"
									
				}
				1 { 
					$pipeline = "Classic"
				}
			}

			#ANONYMOUS AUTHENTICATION--------------------------------------------------------
			$title4 = "ANONYMOUS AUTHENTICATION"
			$message4 = "Would you like Anonymous Authentication Enabled?"
			$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
			$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
			$options4 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
			$choice4 =$host.ui.PromptForChoice($title4, $message4, $options4, 1)
							
			switch ($choice4){
				0 { 
					$aAuth = "true"
									
				}
				1 { 
					$aAuth = ""
				}
			}
			#BASIC AUTHENTICATION--------------------------------------------------------
			$title5 = "BASIC AUTHENTICATION"
			$message5 = "Would you like Basic Authentication Enabled?"
			$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
			$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
			$options5 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
			$choice5 =$host.ui.PromptForChoice($title5, $message5, $options5, 1)
							
			switch ($choice5){
				0 { 
					$bAuth = "true"
									
				}
				1 { 
					$bAuth = ""
				}
			}
			
			#WINDOWS AUTHENTICATION--------------------------------------------------------
			$title3 = "WINDOWS AUTHENTICATION"
			$message3 = "Would you like Windows Authentication Enabled?"
			$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
			$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
			$options3 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
			$choice3 =$host.ui.PromptForChoice($title3, $message3, $options3, 1)
							
			switch ($choice3){
				0 { 
					$wAuth = "true"
									
				}
				1 { 
					$wAuth = ""
				}
			}
			
			#WEBSITE APPLICATION--------------------------------------------------------
			$title7 = "WEBSITE APPLICATION"
			$message7 = "Would you like to add application to $siteName"
			$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
			$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
			$options7 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
			$choice7 =$host.ui.PromptForChoice($title7, $message7, $options7, 1)
							
			switch ($choice7){
				0 { 
					$application = "true"
					$appName = read-host "Please type in the application name"
					$appPath = read-host "Please type in the application path"
									
				}
				1 { 
					$application = ""
				}
			}
			

			#grab credentials for running function
			$cred = FuncDomainUser -server $server
			ForEach($Server in $Servers){
				write-host $server -foregroundcolor yellow
				
				#Function FunChangeWebSettings($server, $cred, $siteName, $pipeline, $version, $bit, $bAuth, $aAuth, $wAuth, $application, $appName, $appPath)
				FunChangeWebSettings -server $server -cred $cred -siteName $siteName -pipeline $pipeline -version $version -bit $bit -bAuth $bAuth -aAuth $aAuth -wAuth $wAuth -application $application -appname $appName -appPath $appPath
				write-host "------------------------------------------"-foregroundcolor yellow
			}
			#flag used so that Content folder only gets rolled out once when looping through list of servers
			$global:flagContentFolder = ''
			
		}
		#if the user doesn't want to configure site stop doing things
		1 { 
			$global:flag = "q"
		}
	}
}
While ($global:flag -ne "q")