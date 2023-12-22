$path =(Resolve-Path .\).Path
."$path\lib\include.ps1"

##.SYNOPSIS  
##	   
##.DESCRIPTION  
##    
##.NOTES 
##    FileName	 :IISWebSiteInstall_v0.21.ps1 
##	  Author     :Scott Flaherty - sdflaherty@aep.com
##	  Requires	 :PowerShell V2  
##    
##.Patch Fixes 
##	  v0.01		: initial build. 
##	  v0.02		: allowed for sites to be set up as SSL only 
##	  v0.02		: allowed for new bindings to sites
##	  v0.03		: Corrected issue where sites did not have default binding when being built.
##	  v0.04		: Added ability for user to either select building new site or adding web binding to site.  
##	  v0.05		: Corrected bug with SSL only call, was pulling wrong message and wrong variables.
## 	  v0.06		: Removed ability for user to call script on multiple server (prone to error)
##	  v0.07	    : Added pssession clear at beginning of script to cleanup any previous sessions on computer. 
##	  v0.08	    : Added ability to use settings for multiple servers. Will be prompted after first server has been deployed to.
##	  v0.09	    : Arranged questions to fit with Catalog task associated with this script.
##	  v0.10	    : Added check for WebBinding function, will now verify that the site is in place before adding the WebBinding to it. 
##	  v0.11	    : Added FuncWebFarmCheck to verify if site is on a webfarm and if it is give opportunity to add site to all webfarm servers.
##	  v0.12	    : Renamed IISWebsiteBinding to FuncIISWebsiteBinding to align with rest of Function nominclature.
##	  v0.13	    : (DEPRECATED) Added ability to use settings for multiple servers. Will be prompted after first server has been deployed to
##	  v0.14	    : Corrected issue where prompt would be displayed for installing on BLANK farm if server was not apart of farm.
##	  v0.15	    : Corrected issue where folder location wasn't being tested correctly which prevented the addition of folder to Content folder.
##	  v0.16	    : Added flag that would trip on Content folder creation so that folder would only be created once for server farm loop. 
##	  v0.17	    : Corrected issue where windows authentication would not enable when selected
##	  v0.18	    : Corrected issue where Anonymous authentication would always be enabled upon building of new site. 
##	  v0.19	    : Corrected issue where authentication could not be pushed to machine since webcontent folder did not yet exist. Put 
##				  powershell script in 10 second hold to allow for replication of folder. 
##	  v0.20	    : added ability for user to select VIP type. This will give information for the farm and the type of VIP in question for TCP/IP
##				  request. 
##	  v0.21	    : Changed prompts for 32BIT to correctly reflect those options presented in ServiceNow tickets 
	
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

#Reset all global variables as found in lib 
FuncResetGlobals

#Start logging information displayed on console.
FuncTranscript function

#Take password information from user if we do not already have it saved. Place this secured into a file in Credentials folder
FuncUserPassword 

#MAIN---------------------------------------------------------------------------

#Function FuncAddWebsite ($server, $cred, $siteName, $pipeline, $version, $bit, $bAuth, $aAuth, $wAuth)
#pipeline mode (Integrated/Classic), Runtime Version (v2.0/v4.0), 32 bit versioning (true/false), Authentication Types (bAuth(true), aAuth(true), wAuth(true))
#continue to prompt user for server input until they quit. 
DO{
	write-host $global:flag
	$message6 = "Would you like to install a WEBSITE on a server?"
	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
	$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
	$options6 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
	$choice6=$host.ui.PromptForChoice($title6, $message6, $options6, 1)
		
	switch ($choice6){
		0 {
			
			#server you want to install the site on. 
			$server = read-host "Please enter the SERVER to add WEBSITE to"
			
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
			$True = New-Object System.Management.Automation.Host.ChoiceDescription "&True", "True"
			$False = New-Object System.Management.Automation.Host.ChoiceDescription "&False", "False"
			$options2 = [System.Management.Automation.Host.ChoiceDescription[]]($True, $False)
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
			$choice=$host.ui.PromptForChoice($title, $message, $options, 1)
						
			switch ($choice){
				0 { 
					$pipeline = "Integrated"
									
				}
				1 { 
					$pipeline = "Classic"
				}
			}
			
			#SSL ONLY--------------------------------------------------------
			$title8 = "SSL ONLY"
			$message8 = "Would you like site to be SSL only?"
			$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
			$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
			$options8 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
			$choice8 =$host.ui.PromptForChoice($title8, $message8, $options8, 1)
							
			switch ($choice8){
				0 { 
					$sslOnly = "true"
									
				}
				1 { 
					$sslOnly = ""
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
			
			#VIP TYPE ----------------------------------------------------------------------
			do {
				write-host ""
				write-host "A - Sticky"
				write-host "B - Round Robin"
				write-host "C - Cookie"
				write-host "D - None Selected"
				write-host ""
				write-host -nonewline "Type your choice and press Enter: "
				
				$choice = read-host
				
				$ok = $choice -match '^[abcd]+$'
				
				if ( -not $ok) { write-host "Invalid selection" }
			} until ( $ok )
			
			if ($choice -eq "A" -or $choice -eq "a"){
				$sticky = "true"

			}
			if ($choice -eq "B" -or $choice -eq "b"){
				$rr = "true"

			}
			if ($choice -eq "C" -or $choice -eq "c"){
				$cookie = "true"

			}
			if ($choice -eq "D" -or $choice -eq "d"){
				write-host "No VIP Selected"
			}

			#grab credentials for running function
			$cred = FuncDomainUser -server $server
			ForEach($Server in $Servers){
				write-host $server -foregroundcolor yellow
				
				#Function FuncAddWebsite ($server, $cred, $siteName, $pipeline, $version, $bit, $bAuth, $aAuth, $wAuth $sticky, $rr, $cookie, $sslOnly)
				FuncAddWebsite -server $server -cred $cred -siteName $siteName -pipeline $pipeline -version $version -bit $bit -bAuth $bAuth -aAuth $aAuth -wAuth $wAuth -sticky $sticky -rr $rr -cookie $cookie -sslOnly $sslOnly
				write-host "------------------------------------------"-foregroundcolor yellow
			}
			#flag used so that Content folder only gets rolled out once when looping through list of servers
			$global:flagContentFolder = ''
			
		}
		#if the user doesn't want to build a site prompt them to add web binding to site. 
		1 { 
			
			$message9 = "Would you like to add a WEBBINDING to a server?"
			$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
			$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
			$options9 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
			$choice9=$host.ui.PromptForChoice($title9, $message9, $options9, 1)
			
			switch ($choice9){
				0 { 
					#create variables for running script 
					
					$server = read-host "Please enter the server that site is located on"
					
					#Get farm servers if they exist. 
					$servers = FuncWebFarmCheck -server $server
					$siteName = read-host "Please enter the name of the site"
					$binding = read-host "Please enter web binding you would like to add to site"
					
					#SSL ONLY--------------------------------------------------------
					$title10 = "HTTPS/HTTP"
					$message10 = "Would you like binding to use https?"
					$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
					$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
					$options10 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
					$choice10 =$host.ui.PromptForChoice($title10, $message10, $options10, 1)
							
					switch ($choice10){
						0 { 
							$https = "true"
									
						}
						1 { 
							$https = "false"
						}
					}
					
					#VIP TYPE ----------------------------------------------------------------------
					do {
						write-host ""
						write-host "A - Sticky"
						write-host "B - Round Robin"
						write-host "C - Cookie"
						write-host "D - None Selected"
						write-host ""
						write-host -nonewline "Type your choice and press Enter: "
						
						$choice = read-host
						
						$ok = $choice -match '^[abcd]+$'
						
						if ( -not $ok) { write-host "Invalid selection" }
					} until ( $ok )
					
					if ($choice -eq "A" -or $choice -eq "a"){
						$sticky = "true"

					}
					if ($choice -eq "B" -or $choice -eq "b"){
						$rr = "true"

					}
					if ($choice -eq "C" -or $choice -eq "c"){
						$cookie = "true"

					}
					if ($choice -eq "D" -or $choice -eq "d"){
						write-host "No VIP Selected"
					}

					#Pull credentials for the server in question 
					$cred = FuncDomainUser -server $server
					ForEach($Server in $Servers){
						write-host $server -foregroundcolor yellow 

						#Function IISWebsiteBinding ($server, $cred $siteName(STRING), $binding(STRING), $https(TRUE/FALSE))
						FuncIISWebsiteBinding -server $server -cred $cred -siteName $siteName -binding $binding -https $https -sticky $sticky -rr $rr -cookie $cookie 
						write-host "------------------------------------------"-foregroundcolor yellow
					}		
				}

				#I don't want to add a WebBinding to the site. 
				1 { 
					$global:flag = "q"
				}
					
			}
		}		
	}		
}
While ($global:flag -ne "q")			





#MAIN CLOSE---------------------------------------------------------------------

#PAUSE the console so you can verify your information. 
Write-Host "---------------------------------------------------------------" -foreground yellow

#CLEANUP----------------------------------------------------------

#remove any and all PSSessions that might be hung by previous process and reset all flags. 
get-pssession | remove-pssession
$global:flag = ''
$global:flagServer = ''
$global:flagBinding = ''
FuncResetGlobals

read-host "Press Any Key to close window....."

####Current Testing Features#####
#(TESTING)Function FuncWebContentCheck
#(TESTING)Function FuncAddWebsite 
#(TESTING)Function FuncIISWebsiteBinding
#(TESTING)Function FuncWebFarmCheck
#(TESTING)FuncWebContentCheck

#####Version 1.0 Features#####

#####Future Features#####
#Allow script to be run from share folder location 
#Attach security groups to WebContent folder. 
#Pull information straight from ServiceNow ticket. 
#Create website that can be used to reject/approve website requests.
#Create txt document that can be sent through ServiceNow for TCP/IP requests.
#Allow for script to be run on external website servers.

 
