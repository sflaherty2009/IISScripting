$path =(Resolve-Path .\).Path
."C:\scripts\_lib\include_test.ps1"

##.SYNoPSIS  
##	   Allow change of website configuration across all farm members for a given site. 
##.DESCRIPTION  
##    
##.NoTES 
##    FileName	 :IISWebSiteConfig_v0.01.ps1 
##	  Author     :Scott Flaherty - sdflaherty@aep.com
##	  Requires	 :PowerShell V2  
##    
##.Patch Fixes 
##	  v0.01		: initial build. 
##	  v0.02		: Added include.ps1 auto update functionality to script. Unless frontend revisions are neccessitated majority of 
##				  Patch Fix information will be found in include.ps1 
##	  v0.03		: Allowed configuration functionality to be turned on and off for sites being modified. 
##	  v0.04		: Updated prompts to remove duplicate answer inputs. 
##	  v0.05		: Updated prompts to select no change upon pressing enter and not selecting an option. Changed selection on all prompts to be 
##			      uniform No Change 
##	  v0.05		: Corrected prompt for Windows Authentication. Should be set as No and not No Change. Also Set ANoNYMOUS to ANONYMOUS. 
##	  v0.07		: After script is done running will relaunch Launcher.ps1 so tasks can continue to be run. 


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
If (-NoT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do Not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}

#Reset all global variables as found in lib 
FuncResetGlobals

#Start logging information displayed on console.
FuncTranscript function

#Take password information from user if we do Not already have it saved. Place this secured into a file in Credentials folder
FuncUserPassword 

#MAIN---------------------------------------------------------------------------

DO{
	write-host $global:flag
	$message6 = "Would you like to change a WEBSITES configuration on a server?"
	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
	$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
	$options6 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $No)
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
			$rDisable = New-Object System.Management.Automation.Host.ChoiceDescription "No change", "No change"
			$options1 = [System.Management.Automation.Host.ChoiceDescription[]]($2, $4, $rDisable)
			$choice1=$host.ui.PromptForChoice($title1, $message1, $options1, 2)
						
			switch ($choice1){
				0 { 
					$version = "v2.0"
									
				}
				1 { 
					$version = "v4.0"
				}
				2 { 
					$version = "off"
				}
			}
			
			#BIT APPLICATIONS--------------------------------------------------------
			$title2= "ENABLE 32BIT APPLICATIONS"
			$message2 = "Would you like to enable 32bit applications for site?"
			$Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
			$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
			$bDisable = New-Object System.Management.Automation.Host.ChoiceDescription "No change", "No change"
			$options2 = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No, $bDisable)
			$choice2=$host.ui.PromptForChoice($title2, $message2, $options2, 2)
						
			switch ($choice2){
				0 { 
					$bit = "true"
									
				}
				1 { 
					$bit = "false"
				}
				2 { 
					$bit = "off"
				}
			}
			
			#pipeline mode for site-----------------------------------------------------------
			$title = "PIPELINE MODE"
			$message = "Would you like Integrated/Classic pipeline mode?"
			$integrated = New-Object System.Management.Automation.Host.ChoiceDescription "&Integrated", "Integrated"
			$classic = New-Object System.Management.Automation.Host.ChoiceDescription "&Classic", "Classic"
			$pDisable = New-Object System.Management.Automation.Host.ChoiceDescription "No change", "No change"
			$options = [System.Management.Automation.Host.ChoiceDescription[]]($Integrated, $Classic, $pDisable)
			$choice=$host.ui.PromptForChoice($title, $message, $options, 2)
						
			switch ($choice){
				0 { 
					$pipeline = "Integrated"
									
				}
				1 { 
					$pipeline = "Classic"
				}
				2 { 
					$pipeline = "off"
				}
			}
			
			#TURN ON OFF AUTHENTICATION CHANGES. 
			$title8 = "AUTHENTICATION"
			$message8 = "Would you like to make changes to Authentication?"
			$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
			$No = New-Object System.Management.Automation.Host.ChoiceDescription "No Change", "No Change"
			$options8 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $No)
			$choice8 =$host.ui.PromptForChoice($title8, $message8, $options8, 1)
							
			switch ($choice8){
				0 { 
					#ANoNYMOUS AUTHENTICATION--------------------------------------------------------
					$title4 = "ANONYMOUS AUTHENTICATION"
					$message4 = "Would you like ANonymous Authentication Enabled?"
					$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
					$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
					$options4 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $No)
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
					$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
					$options5 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $No)
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
					$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
					$options3 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $No)
					$choice3 =$host.ui.PromptForChoice($title3, $message3, $options3, 1)
									
					switch ($choice3){
						0 { 
							$wAuth = "true"
											
						}
						1 { 
							$wAuth = ""
						}
					}								
				}
				1 { 
					$Auth = 'off'
				}
			}
				
			
			#END AUTHENTICATION CHANGES. 
			
			#WEBSITE APPLICATION--------------------------------------------------------
			$title7 = "WEBSITE APPLICATION"
			$message7 = "Would you like to add application to $siteName"
			$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
			$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
			$aDisable = New-Object System.Management.Automation.Host.ChoiceDescription "No change", "No change"
			$options7 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $No, $aDisable)
			$choice7 =$host.ui.PromptForChoice($title7, $message7, $options7, 2)
							
			switch ($choice7){
				0 { 
					$application = "true"
					$appName = read-host "Please type in the application name"
					$appPath = read-host "Please type in the application path"
									
				}
				1 { 
					$application = ""
				}
				2 { 
					$application = "off"
				}
			}
			

			#grab credentials for running function
			$cred = FuncDomainUser -server $server
			ForEach($Server in $Servers){
				write-host $server -foregroundcolor yellow
				
				#Function FunChangeWebSettings($server, $cred, $siteName, $pipeline, $version, $bit, $bAuth, $aAuth, $wAuth, $application, $appName, $appPath)
				FunChangeWebSettings -server $server -cred $cred -siteName $siteName -pipeline $pipeline -version $version -bit $bit -bAuth $bAuth -aAuth $aAuth -wAuth $wAuth -Auth $auth -application $application -appname $appName -appPath $appPath
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
invoke-expression -Command "C:\scripts\Launcher.ps1"