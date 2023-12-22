##.SYNOPSIS  
##	  List of functions for use as Library for future script iterations 
##.DESCRIPTION  
##    List of functions used in include.ps1 in current and future iterations of AEP scripts. This FunctionList
## 	  is a complete set of designed functions and might not work if used "as is". Functions should be taken from
##	  this list and used in their own iterations of the include.ps1. Might add this FunctionList to a networked 
##	  location in the future for all scripts to pull from, will need to think of other design issues this might 
##	  present. 
##.NOTES 
##    FileName	 :_FunctionList_v0.18.ps1 
	  $version = '0.18'
##	  Author     :Scott Flaherty - sdflaherty@aep.com
##	  Requires	 :PowerShell V2 
##	  (PatchFix.ps1) 
##	  File Paths : LogFile  						: root\Logs
##				   Function Library 				: root\lib\include.ps1
##				   C drive errors 					: root\Logs\Error_Lists\CDrive_Fail_[date].txt
##				   Credential errors 				: root\Logs\Error_Lists\Crdentials_Fail_[date].txt
##				   DNS errors 						: root\Logs\Error_Lists\DNS_Fail_[date].txt
##				   LanDesk Version Errors 			: root\Logs\Error_Lists\LanDesk_Fail_[date].txt
##				   Ping Failure 					: root\Logs\Error_Lists\Ping_Fail_[date].txt
##				   Windows Update Service Failure 	: root\Logs\Error_Lists\WindowsUpdate_Service_Fail_[date].txt
##				   Windows DC Server Detected		: root\Logs\Error_Lists\DC_Detected_[date].txt
##				   Firewall Detected 				: root\Logs\Error_Lists\Firewall_Detected_[date].txt
##				   ServiceNow Status Errors			: root\Logs\Error_Lists\ServiceNow_Status_[date].txt
##				   Function Library 				: root\lib\include.ps1
##				   cleanup script					: root\lib\Scripts\cleanup_rev.bat
##				   LanDesk script					: root\lib\Scripts\CurrentPatchx64.bat
##				   ServiceNow .csv file	path		: 		
##					"\\hqcelfs01\complex_servers\Windows\external\Project_Tracking\tbl_cmdb_ci_Windows.csv"
##				   IISWeb.vbs						: root\lib\IISWeb.vbs
##				   adsutil.vbs						: root\lib\adsutil.vbs
##				   Bindings	Log						: root\logs\Binding_[date].txt
##	  			   LogFile  						: root\Logs\LogFile_[date].txt
##    
##.Patch Fixes 
##	  v0.01		: starting from v0.01 though this has had several iterations prior to this point. First 
##	  v0.02 	: Added script for building webpages remotely in IIS and for Adding Bindings to previously build IIS sites. 
##	  v0.03 	: Added three functions. Two have been pulled from kevin knox's PoshTools 
##				  '\\middlewaretools\public\PoshTools\PoshTools.psm1'. The third function can be used to uninstall IIS 6 websites
##				  From Windows Server 2003 boxes. 
##	  v0.04		: Added functions for checking webfarms and verifying that a server sits in a farm. Will also associate the farm with 
##				  its respective content folder location. 
##	  v0.05		: Update WebFarm and WebContent folder locations to allow for external facing site additions. 
##	  v0.06		: Updated FuncDeleteIISWebsite to work with both 2003 Servers and 2008/2012R2 servers
##	  v0.06.1	: Updated FilePaths and notes to reflect newly implemented Function (FuncDeleteIISWebsite)
##	  v0.07 	: Added function to add certificates to https:// WebBindings after first pulling them from CertMan. 
##	  v0.08 	: Updated FuncAddWebsite
##	  v0.09 	: Updated FuncIISWebsiteBinding
##	  v0.10 	: Added FuncAddSSLBinding which will allow for SSL certs to be downloaded from CertMan and then attached to https: 
##				  binding for Windows Server 2012R2 IIS Websites 
##	  v0.11 	: Added FuncUserNamePassword which will check to see if a users password is being stored and if not will update it in 
##				  the documentation then return a variable with credentials.  
##	  v0.12 	: Changed $path variable so that it will work correctly being called in Windows Task Scheduler. 
##	  v0.13 	: Added FuncCheckCurrentVersion to check version of the include.ps1 file and if not up to date download the newest 
##				  version
##	  v0.14 	: Updated FuncCheckConnectivity and FunCheckRDP to create root\Logs\Error_Lists if it has not already been created. 
##	  v0.14.1 	: Updated documentation to reflect include.ps1 across all scripts instead of segmenting by calling script. 
##	  v0.14.2 	: Updated FuncCheckCurrentVersion to display that it has been run. 
##	  v0.14.3 	: Updated FuncCheckCurrentVersion to display that it is running 
##	  v0.15 	: Rolled back update to $path due to error it was experiencing when trying to pull current root folder path.
##	  v0.16 	: corrected issue where FuncUserPassword was checking $filepath instead of $path for password file. 
##	  v0.16.1 	: cleaned up testing items from code.  
##	  v0.17 	: corrected an issue in FuncUserPassword where first if clause was not appropriately terminated. 
##	  v0.18 	: Imported rest of functions in the PatchFix script. 


#Set variables for main function 
$date = get-date -Format MM-dd-y
$path =(Resolve-Path .\).Path

#(TESTING)check the current version of the lib file stored in the IISScripting folder. 
Function FuncCheckCurrentVersion{
	write-host "checking for newest version of include.ps1" -foregroundcolor yellow 
	#load in our xml document with our current version number. 
	try{
		$xml = [XML](Get-Content "\\oh0co010\IISWEB\#IISScripting\_Lib\Variables.xml")
	}
	#if we can't load in our variables then throw an error. 
	catch{
		write-warning "Could not determine the most up to date version of lib file. Please check Variables.xml file"
	}
	
	#create a current version variable to test it against the version of the current document. 
	$currentVersion = $xml.variables.version
	write-host "CurrentVersion" -foregroundcolor yellow 
	write-host $currentVersion 
	
	write-host "Version" -foregroundcolor yellow 
	write-host $version
	
	#If the current version is not the same as the version on our computer update our includes. 
	if ($currentVersion -ne $version){
		write-host "updating your version of include.ps1 to $currentVersion" -foregroundcolor yellow 
		#Import-Module bitstransfer
		#get it from the network share. 
		$sourcePath = "\\oh0co010\IISWEB\#IISScripting\_Lib\include.ps1"
		#place it on our computer. 
		$destPath = "$path\lib\include.ps1"

		#start that transfer.
		#Start-BitsTransfer -Source $sourcePath -Destination $destPath
		Copy-Item -Path $sourcePath -Destination $destPath	
	
	
	}


}

#Turn on PSSession functionality for servers that cannot be connected to via Powershell. (Used in FunCheckRDP)
#Called by FuncCheckRDP
Function FuncEnableRemoting {
param (
    [Alias('CN')]
    $Server
)
    psexec \\$Server /accepteula -u $username -p $password -s -h -d powershell Enable-PSRemoting -Force >nul 2>&1
}

#Log any output from script
Function FuncTranscript([switch]$debug){
 # to see debuging information startTrans -debug 
 if($debug) 
   { 
    $debugPreference = "continue" 
   } #end if debug
 $dte = [dateTime]::Get_Today().DayOfWeek.tostring()
   write-debug $dte
 $dte = $dte + "_" + [dateTime]::now.hour
   write-debug $dte
 if(([datetime]::now.toLocalTIme()) -match "AM") 
    { 
       Write-debug "Inside if ..."
     $dte = $dte + "_AM"
       write-debug $dte 
    } #end if...
 else
    {
       write-debug "Inside else ..."  
     $dte = $dte + "_PM"
       write-debug $dte
    } #end else
   write-debug "Starting transcript ... $path\Logs\LogFile_$date.txt"
 start-transcript -path "$path\Logs\LogFile_$date.txt" -append
 } #end start-Trans

#Run Ping check and DNS check on the server to verify it can be reached and is online (Used in FuncInstallIIS)
Function FuncCheckConnectivity($Server,[switch]$Remember){
	
	if (!(test-path "$path/Logs/error_Lists")){
		try{
			New-Item -Path "$path/Logs/error_Lists" -type directory
		}
		catch{
			write-warning "Cannot create path $path/Logs/error_Lists for logging of Connectivity failures"
		}
	}


    $PingResult = {
          # Return $true or $false based on the result from script block $PingCheck
          foreach ($_ in $Script:arrayCanPingResult) { 
                   # Write-Host $_ 
                   if ($Server -eq $($_.Split(",")[0])) {

                   # Write-Host "We will return $($_.Split(",")[1])" -ForegroundColor Green
                    return $($_.Split(",")[1])  
                   } 
          }
    }

    $PingCheck = {

        $Error.Clear()

        if (Test-Connection -ComputerName $Server -BufferSize 16 -Count 1 -ErrorAction 0 -quiet) { # ErrorAction 0 doesn't display error information when a ping is unsuccessful
			$global:CheckConnectivityPass = "Pass"
            $ping = "Pass"; $Script:arrayCanPingResult+=@("$Server,$true");
			return ,$ping 
			
			
        } 
        else {
            $Error.Clear()
            ipconfig /flushdns | Out-Null
            ipconfig /registerdns | Out-Null
			
            [Net.DNS]::GetHostEntry($server) 2>&1 | Out-Null # Surpressing error here is not possible unless using '2> $null', but if we do this, we don't get $true or $false for the function so '| Out-Null' is an obligation
            if (!$?) {
			
				$ping = "DNS Failed"
				$global:DNSCheck = "Fail"
                # Write-Host $Error -ForegroundColor Red
                $Server | Add-Content "$path/Logs/error_Lists/DNS_Fail_$date.txt"
                $script:arrayCanPingError += "ERROR | Ping test failed: NSlookup can't find $Server, hostname incorrect or DNS issues?`n$error"
                $script:HTMLarrayCanPingError += "ERROR | Ping test failed:<br>NSlookup can't find $Server, hostname incorrect or DNS issues?<br>$error<br>"
                $Script:arrayCanPingResult+=@("$Server,$false")
                return ,$ping
                }
            else {
                if (Test-Connection -ComputerName $Server -BufferSize 16 -Count 1 -ErrorAction 0 -Quiet) {
                   Write-Host "$Server > Function Can-Ping: Ping test ok, problem resolved" -ForegroundColor Gray
                   $Script:arrayCanPingResult+=@("$Server,$true")
                   return
                }
                else {
                      $ping = "Fail"
                      $global:DNSCheck = "Fail"
                      $Server | Add-Content "$path/Logs/error_Lists/Ping_Fail_$date.txt"
                      $script:arrayCanPingError += "ERROR Ping test failed: DNS Resolving is ok but can't connect to $Server, server offline?`n$error"
                      $script:HTMLarrayCanPingError += "ERROR Ping test failed: DNS Resolving is ok but can't connect to $Server, server offline?<br>$error<br>"
                      $Script:arrayCanPingResult+=@("$Server,$false")
                      return ,$ping
                }
            }
        }
    }

    # Call the scriptblock $PingAction every time, unless the switch $Remember is provided, than we only check each server once
    if ($Remember) {
        Write-Host "$Server > Function Can-Ping: Switch '-Remember' detected" -ForegroundColor Gray
        While ($tmpPingCheckServers -notcontains $Server) { 
                  &$PingCheck
                  $script:tmpPingCheckServers = @($tmpPingCheckServers+$Server) #Script wide variable, othwerwise it stays empty when we leave the function / @ is used to store it as an Array (table) instaed of a string
        }
        &$PingResult
    } 
    else {
          &$PingCheck
          #&$PingResult

    }
}

#Verify whether the user can log into the machine through RDP for manual patching and fixing (Used in FuncInstallIIS)
Function FuncCheckRDP($Server, $Credent){
	$s = new-PsSession $server -Credential $Credent 
	
	if (!(test-path "$path/Logs/error_Lists")){
		try{
			New-Item -Path "$path/Logs/error_Lists" -type directory
		}
		catch{
			write-warning "Cannot create path $path/Logs/error_Lists for logging of RDP Connectivity failures"
		}
	}
	
	try {
		#Verify whether the RDP port is open for access.
		New-Object System.Net.Sockets.TCPClient -ArgumentList $Server,3389 | out-null
		#If RDP port is open try to establish an RDP connection to server. 
		try {
			enter-PsSession $s 
			$RDP = "Pass"
			$global:RDPCheckPass = "Pass"
			return ,$RDP 
		}
		catch {
			#If RDP port is open but a session cannot be established try to enable PSSession access on the server. 
			try{FuncEnableRemoting -server $server 
				try{
					enter-PsSession $s 
					$RDP = "Pass" 
					$global:RDPCheckPass = "Pass"
					return ,$RDP 
				}
				catch{
					$RDP = "Creden.Failed" 
					$global:RDPCheck = "Fail"
					$Server | Add-Content "$path/Logs/error_Lists/Credentials_Fail_$date.txt"
					return ,$RDP 
				}
			}
			catch{
				$RDP = "Creden.Failed" 
				$global:RDPCheck = "Fail"
				$Server | Add-Content "$path/Logs/error_Lists/Credentials_Fail_$date.txt"
				return ,$RDP 
			}
		}
	}	
	catch{ 
		$RDP = "Fail"
		$Server | Add-Content "$path/Logs/error_Lists/RDP_Fail_$date.txt"
		$global:RDPCheck = "Fail"
		return ,$RDP
		
	}
	Remove-PsSession $s 
} 

#Prompt and store a users password encrypted in Credential folder for different domains (Used in FuncInstallIIS)
Function FuncUserPassword{
	if ((Get-Content $path\Credentials\$userid'_WI.txt') -eq $Null){
		Read-Host "Please enter your WEBINT account password" -assecurestring | ConvertFrom-SecureString | out-file $path\Credentials\$userid'_WI.txt'

		}
	if ((Get-Content $path\Credentials\$userid'_CT.txt') -eq $Null){
		Read-Host "Please enter your CORPTEST account password" -assecurestring | ConvertFrom-SecureString | out-file $path\Credentials\$userid'_CT.txt'

		}
	if ((Get-Content $path\Credentials\$userid'_CORP.txt') -eq $Null){
		Read-Host "Please enter your CORP account password" -assecurestring | ConvertFrom-SecureString | out-file $path\Credentials\$userid'_CORP.txt'

		}	

}

#Pull username and credentials and return them in for use by function (Used in FuncInstallIIS)
Function FuncDomainUser ($server){	
		#Beginning variables 
		$userid = [Environment]::UserName
		
		#check domain value 
		$nbtstat = nbtstat -a $Server
		$domMatch = $nbtstat | Select-String '(\w+) +[0-9<>]{4} +GROUP '
		$domain = $domMatch.Matches[0].Groups[1].Value
		
		#Pull correct credentials based off of server domain 
		if($domain -eq "CORPTEST"){
			$username = "CORPTEST\$userid"
			$password = get-content $path\Credentials\$userid'_WI.txt' | convertto-securestring	
			$cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $username,$password
			return, $cred
		}
		if($domain -like "WEBINT"){
			$username = "WEBINT\$userid"
			$password = get-content $path\Credentials\$userid'_CT.txt' | convertto-securestring
			$cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $username,$password
			return, $cred
		}
		if($domain -eq "CORP"){
			$username = "CORP\$userid"
			$password = get-content $path\Credentials\$userid'_CORP.txt' | convertto-securestring
			$cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $username,$password
			return, $cred
		}	
		if($domain -eq $null){
			$username = "CORP\$userid"
			$password = get-content $path\Credentials\$userid'_CORP.txt' | convertto-securestring
			$cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $username,$password
			return, $cred
		}

}

#Used to reset all global variables from running of above functions (Used in FuncInstallIIS)
Function FuncResetGlobals{
		$global:DNSCheck = $null
		$global:RDPCheck = $null
		$global:DriveSpacePass = $null
		$global:WinUpPass = $null
		$global:CheckConnectivityPass = $null
		$global:RDPCheckPass = $null
		$global:AppVersionPass = $null
		$global:DriveSpacePass = $null
		$global:DC = $null

}

#Function used to create website
#pipeline mode (Integrated/Classic), Runtime Version (v2.0/v4.0), 32 bit versioning (true/false), Authentication Types (bAuth(true), aAuth(true), wAuth(true), VIP Type (sticky(true),rr(true), cookie(true)), sslOnly (true)
#if site sits in dev or test environment we will change the sitename to reflect this -d or -t 
Function FuncAddWebsite ($server, $cred, $siteName, $pipeline, $version, $bit, $bAuth, $aAuth, $wAuth, $sticky, $rr, $cookie, $sslOnly, $application, $appName, $appPath){
	
	#create variables
	$appExists = ''
	$siteExists = ''
	$rrVipName = ''
	$stickyVipName = ''
	$cookieVipName = ''
	$rrVipIP = ''
	$cookieVipIP = ''
	$stickyVipIP = ''
	$siteNameBinding = $sitename
	
	#ADDITONAL FEATURE :: 
	#If we have a dev or test server we need to change the siteName to reflect this. 
	if ($server -match 'ts'){
		$siteNameBinding = "$sitename-t"
		write-host "Test server detected" -foregroundcolor yellow
	
	}
	if ($server -match 'dv'){
		$siteNameBinding = "$sitename-d"
		write-host "Development server detected" -foregroundcolor yellow

	}
	
	#verify server can be reached and credentials allow access
	$rdpCheck = FuncCheckRDP -server $server -cred $cred
	write-host "Check $server RDP status ::"
	write-output $rdpCheck
	
	$pingCheck = FuncCheckConnectivity -server $server
	write-host "Check $server ping status ::"
	write-output $pingCheck
	
	#verify that neither the site or application are in existance. 
	$appExists = Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName)(c:\Windows\System32\inetsrv\appcmd.exe list apppool /name:$siteName) -ne $null} -ArgumentList $siteName
	
	$siteExists = Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName)(c:\Windows\System32\inetsrv\appcmd.exe list site /name:$siteName) -ne $null} -ArgumentList $siteName

	#run verification that server can be reached. 
	if ($rdpCheck -eq "Pass" -and $pingCheck -eq "Pass"){
		#Run function to get folder location and VIP information for the script to continue [$folderPath, $server, $adminShare]
		#return $folderPath, $repServer, $adminShare, $rrVipName, $stickyVipName, $cookieVipName, $rrVipIP, $cookieVipIP, $stickyVipIP
		$WContent = FuncWebContentCheck -server $server -siteName $siteName
		$folderPath = $WContent[0]
		$serverPath = $WContent[1]
		$adminShare = $WContent[2]
		
		#determine what the Middleware VIP name is for the serverfarm in question and create those variables
		if ($sticky -eq "true"){
			$vipName = $WContent[4]
			$vipIp = $WContent[8]
		}
		if ($rr -eq "true"){
			$vipName = $WContent[3]
			$vipIp = $WContent[6]
		}
		if ($cookie -eq "true"){
			$vipName = $WContent[5]
			$vipIp = $WContent[7]
		}
		
		#This is the path that we will check to see if the file has been created. 
		$testPath = "\\$serverPath" + "$adminShare"
		
		#test and verify that the folder hasn't already been created once for the farm. 
		if ($global:flagContentFolder -ne "f"){
			#if the flag hasn't been tripped still verify that the folder isn't in place. 
			if (!(test-path $testPath)){
				#create directory for website
				Invoke-Command -ComputerName $serverPath -credential $cred -Command{param($folderPath) New-Item -Path "$folderPath" -type directory -force} -ArgumentList $folderPath	
				$global:flagContentFolder = "f"
				#we need to put a wait here so the folder is deployed to all machines before continuing
				Start-Sleep -s 10
			}
			#HEY you folder you are already there...you jerk.
			else{
				write-host "website folder already exists" -foregroundcolor red
			}
		}
	
		#if the site doesnt exist then build it. Otherwise write that the site exists.  
		if ($siteExists -ne "True"){
			#if the path for the site exists create the site. 
			
			#hey is site a http or an https only site? 
			if ($sslOnly -eq "true"){
				#create website with physical path. 
				Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName, $siteNameBinding)c:\Windows\System32\inetsrv\appcmd.exe add site /name:$sitename /physicalPath:d:\WebContent\$sitename /bindings:"http/*:80:$siteNameBinding"} -ArgumentList $siteName, $siteNameBinding 
				
				#check what flavor of windows is running on our server. 
				$OSCheck = (Get-WmiObject -ComputerName $server -Credential $Cred -class Win32_OperatingSystem ).Caption
				write $OSCheck			
				
				#if its a 2012 box we will create and the binding and add the SSL cert to the binding. 
				if ($OSCheck -match "Server 2012"){
					#create website with physical path. Port 443 and adds cert is Windows 2012R2 
					FuncAddSSLBinding -server $server -sitename $sitename -bindingName $siteNameBinding -cred $cred
	
				}
				
				#if its a 2008 box we will create the binding but not push the certificate 
				else{
					Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName, $siteNameBinding)c:\Windows\System32\inetsrv\appcmd.exe add site /name:$sitename /physicalPath:d:\WebContent\$sitename /bindings:"https/*:443:$siteNameBinding"} -ArgumentList $siteName, $siteNameBinding
				}
				
			}
			else{
				#create website with physical path. 
				Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName, $siteNameBinding)c:\Windows\System32\inetsrv\appcmd.exe add site /name:$sitename /physicalPath:d:\WebContent\$sitename /bindings:"http/*:80:$siteNameBinding"} -ArgumentList $siteName, $siteNameBinding
			}
		}
		else{
			write-host "site $siteName already exists" -foregroundcolor red
		}
		#if the application doesnt exist then build it. Otherwise write that the app exists. 
		if ($appExists -ne "True"){	
			#add application pool with Runtime version (v2.0/v4.0/blank), pipeline mode (Integrated/Classic), 32Bit mode (true/false)
			Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName, $version, $pipeline, $bit) c:\Windows\System32\inetsrv\appcmd.exe add apppool /name:$sitename /managedRuntimeVersion:$version /managedPipelineMode:$pipeline /enable32BitAppOnWin64:$bit } -ArgumentList $siteName, $version, $pipeline, $bit
		}
		else{
			write-host "application $siteName already exists" -foregroundcolor red
		}
		
		#if the application or the site existed we should check the server before making any other changes. 
		if ($siteExists -ne "True" -and $appExists -ne "True"){
			#attach application pool to Website. 
			Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName)c:\Windows\System32\inetsrv\appcmd.exe set app "$sitename/" /applicationPool:"$sitename"} -ArgumentList $sitename
			
			#set Authentication
			#basic Authentication
			if ($bAuth -eq "true"){
				Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName) c:\Windows\System32\inetsrv\appcmd.exe unlock config /section:basicAuthentication}
				#enable authentication
				Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName) c:\Windows\System32\inetsrv\appcmd.exe set config "$sitename" /section:basicAuthentication /enabled:true} -ArgumentList $siteName
			}
			#windows Authentication
			if ($wAuth -eq "true"){
				#unlock windowsAuthentication
				Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName) c:\Windows\System32\inetsrv\appcmd.exe unlock config /section:windowsAuthentication}
				#enable authentication
				Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName) c:\Windows\System32\inetsrv\appcmd.exe set config "$sitename" /section:windowsAuthentication /enabled:true} -ArgumentList $siteName
			}
			#anonymous Authentication
			if ($aAuth -eq "true"){
				Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName) c:\Windows\System32\inetsrv\appcmd.exe unlock config /section:anonymousAuthentication}
				#enable authentication
				Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName) c:\Windows\System32\inetsrv\appcmd.exe set config "$sitename" /section:anonymousAuthentication /enabled:true} -ArgumentList $siteName
			}
			if ($aAuth -ne "true"){
				Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName) c:\Windows\System32\inetsrv\appcmd.exe unlock config /section:anonymousAuthentication}
				#enable authentication
				Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName) c:\Windows\System32\inetsrv\appcmd.exe set config "$sitename" /section:anonymousAuthentication /enabled:false} -ArgumentList $siteName
			} 
		}
		else{
			write-host "site or application already exist, script did not proceed" -foregroundcolor red
		
		}
		
		#Write VIP output for site if one exists 
		if ($vipName -eq '' -or $vipName -eq $null){
			write-host "no VIP selection specified." -foregroundcolor yellow
		}
		#if a VIP has been selected then we are going to output the VIP Name, IP, Sitename and Alias in the same format as NSLookup.  
		else {
			$aliases = "$siteName.aepsc.com"
			write-host "nslookup      $siteName"
			write-host "Name:         $vipName" 
			write-host "Address:      $vipIp" 
			write-host "Aliases:      $aliases" 
		
		}
		
		#APPLICATION--------------------------------------------------
		#add application to existing site if they user indicated they wanted to. 
		if ($application -eq 'true'){
			#hey our application does have a folder location lets go ahead and add it. 
			if (($testAppPath -eq "true")){
				Invoke-Command -ComputerName $server -credential $cred -Command{param($appName, $appPath, $siteName) import-module webadministration; cd IIS:\; New-Item -Path "IIS:\Sites\$siteName\$appName" -PhysicalPath $appPath -type Application} -ArgumentList $appName, $appPath, $siteName
			}
			#bummer no folder location available, no application added to site. 
			else {
				write-host "$appPath does not exist, $appName as not configured correctly" -foregroundcolor red
			
			}
		
		}
	}
}

#function used to add bindings to site. Diferentiates between https bindings and http bindings
Function FuncIISWebsiteBinding ($server, $cred, $siteName, $binding, $https, $sticky, $rr, $cookie){
	#Run function to get VIP information for the script to continue
	#return $folderPath, $repServer, $adminShare, $rrVipName, $stickyVipName, $cookieVipName, $rrVipIP, $cookieVipIP, $stickyVipIP
	$WContent = FuncWebContentCheck -server $server -siteName $siteName
	if ($sticky -eq "true"){
		$vipName = $WContent[4]
		$vipIp = $WContent[8]
	}
	if ($rr -eq "true"){
		$vipName = $WContent[3]
		$vipIp = $WContent[6]
	}
	if ($cookie -eq "true"){
		$vipName = $WContent[5]
		$vipIp = $WContent[7]
	}

	#verify that neither the site is existance. 
	$siteExists = Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName)(c:\Windows\System32\inetsrv\appcmd.exe list site /name:$siteName) -ne $null} -ArgumentList $siteName

	if ($siteExists -eq "True"){

		if ($https -eq "true"){
			#to set https binding
			FuncAddSSLBinding -server $server -sitename $sitename -bindingName $binding -cred $cred
			#Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName, $binding)c:\Windows\System32\inetsrv\appcmd.exe set config -section:system.applicationHost/sites /+"[name='$sitename'].bindings.[protocol='https',bindingInformation='*:443:"$binding"']" /commit:apphost} -ArgumentList $siteName, $binding
		}
		else{
			#to set http binding 
			Invoke-Command -ComputerName $server -credential $cred -Command{param($siteName, $binding)c:\Windows\System32\inetsrv\appcmd.exe set config -section:system.applicationHost/sites /+"[name='$sitename'].bindings.[protocol='http',bindingInformation='*:80:"$binding"']" /commit:apphost} -ArgumentList $siteName, $binding
		}
	}
	
	#Write VIP output for site if one exists 
	if ($vipName -eq '' -or $vipName -eq $null){
		write-host "no VIP selection specified." -foregroundcolor yellow
	}
	else {
		$aliases = "$binding.aepsc.com"
		write-host "nslookup      $binding"
		write-host "Name:         $vipName" 
		write-host "Address:      $vipIp" 
		write-host "Aliases:      $aliases" 
	
	}

}

#function used to check a server determine if its apart of a farm and then if it is push it to the whole farm.
Function FuncWebFarmCheck ($server){
#establish some variables
	$farm = ''
	$nServers = ''
	
	#establish Array of server within each farm 
	$internalDev = "dvvmaephqws200";
	$internalTest =	"tsvmaephqws200", "tsvmaephqws201";
	$internalProd = "vmaephqws200", "vmaephqws201", "vmaephqws202", "vmaephqws203";

	$internalCorpComDev = "dvvmaephqws210";
	$internalCorpComTest = "tsvmaephqws210", "tsvmaephqws211";
	$internalCorpComProd = "vmaephqws210", "vmaephqws211", "vmaephqws212", "vmaephqws213";

	$internalComOpsDev = "dvvmaephqws220";
	$internalComOpsTest = "tsvmaephqws220", "tsvmaephqws221";
	$internalComOpsProd = "vmaephqws220", "vmaephqws221", "vmaephqws222", "vmaephqws223";

	$internalCorporateDev = "dvvmaephqws230";
	$internalCorporateTest = "tsvmaephqws230", "tsvmaephqws231";
	$internalCorporateProd = "vmaephqws230", "vmaephqws231", "vmaephqws232", "vmaephqws233";

	$internalCustomerDev = "dvvmaephqws240";
	$internalCustomerTest = "tsvmaephqws240", "tsvmaephqws241";
	$internalCustomerProd = "vmaephqws240", "vmaephqws241", "vmaephqws242", "vmaephqws243";

	$internalTdDev = "dvvmaephqws250";
	$internalTdTest = "tsvmaephqws250", "tsvmaephqws251";
	$internalTdProd = "vmaephqws250", "vmaephqws251", "vmaephqws252", "vmaephqws253";

	$internalOtherDev = "dvvmaephqws260";
	$internalOtherTest = "tsvmaephqws260", "tsvmaephqws261";
	$internalOtherProd = "vmaephqws260", "vmaephqws261", "vmaephqws262", "vmaephqws263"
	
	$ExternalCorporateTest = "tsvmaephqws040"
	$ExternalCorporateQA = "eqvmaephqws040", "eqvmtulsaws040"
	$ExternalCorporateProd = "exvmaephqws040", "exvmtulsaws040"
	
	$ExternalAEPUtilitiesTest = "tsvmaephqws050"
	$ExternalAEPUtilitiesQA = "eqvmaephqws050", "eqvmtulsaws050"
	$ExternalAEPUtilitiesProd = "exvmaephqws050", "exvmtulsaws050", "exvmaephqws051", "exvmtulsaws051", "exvmaephqws052", "exvmtulsaws052"
	
	$ExternalOtherTest = "tsvmaephqws060"
	$ExternalOtherQA = "eqvmaephqws060", "eqvmtulsaws060"
	$ExternalOtherProd = "exvmaephqws060", "exvmtulsaws060"
	
	#establish a hash of the farm associated with each server 
	$serverFarm = @{
		"vmaephqws200" = "internalProd2008";
		"vmaephqws201" = "internalProd2008";
		"vmaephqws202" = "internalProd2008";
		"vmaephqws203" = "internalProd2008";
		"tsvmaephqws200" = "internalTest2008";
		"tsvmaephqws201" = "internalTest2008";
		"dvvmaephqws200" = "internalDev2008";
		
		"vmaephqws210" = "internalCorpComProd";
		"vmaephqws211" = "internalCorpComProd";
		"vmaephqws212" = "internalCorpComProd";
		"vmaephqws213" = "internalCorpComProd";
		"tsvmaephqws210" = "internalCorpComTest";
		"tsvmaephqws211" = "internalCorpComTest";
		"dvvmaephqws210" = "internalCorpComDev";
		
		"vmaephqws220" = "internalComOpsProd";
		"vmaephqws221" = "internalComOpsProd";
		"vmaephqws222" = "internalComOpsProd";
		"vmaephqws223" = "internalComOpsProd";
		"tsvmaephqws220" = "internalComOpsTest";
		"tsvmaephqws221" = "internalComOpsTest";
		"dvvmaephqws220" = "internalComOpsDev";
		
		"vmaephqws230" = "internalCorporateProd";
		"vmaephqws231" = "internalCorporateProd";
		"vmaephqws232" = "internalCorporateProd";
		"vmaephqws233" = "internalCorporateProd";
		"tsvmaephqws230" = "internalCorporateTest";
		"tsvmaephqws231" = "internalCorporateTest";
		"dvvmaephqws230" = "internalCorporateDev"; 
		
		"vmaephqws240" = "internalCustomerProd";
		"vmaephqws241" = "internalCustomerProd";
		"vmaephqws242" = "internalCustomerProd";
		"vmaephqws243" = "internalCustomerProd";
		"tsvmaephqws240" = "internalCustomerTest";
		"tsvmaephqws241" = "internalCustomerTest";
		"dvvmaephqws240" = "internalCustomerDev";
		
		"vmaephqws250" = "internalTdProd";
		"vmaephqws251" = "internalTdProd";
		"vmaephqws252" = "internalTdProd";
		"vmaephqws253" = "internalTdProd";
		"tsvmaephqws250" = "internalTdTest";
		"tsvmaephqws251" = "internalTdTest";
		"dvvmaephqws250" =  "internalTdDev";
		
		"vmaephqws260" = "internalOtherProd";
		"vmaephqws261" = "internalOtherProd";
		"vmaephqws262" = "internalOtherProd";
		"vmaephqws263" = "internalOtherProd";
		"tsvmaephqws260" = "internalOtherTest";
		"tsvmaephqws261" = "internalOtherTest";
		"dvvmaephqws260" = "internalOtherDev";
		
		"tsvmaephqws040" = "ExternalCorporateTest";
		"eqvmaephqws040" = "ExternalCorporateQA"; 
		"eqvmtulsaws040" = "ExternalCorporateQA";
		"exvmaephqws040" = "ExternalCorporateProd";
		"exvmtulsaws040" = "ExternalCorporateProd";
		
		"tsvmaephqws050" = "ExternalAEPUtilitiesTest"; 
		"eqvmaephqws050" = "ExternalAEPUtilitiesQA";
		"eqvmtulsaws050" = "ExternalAEPUtilitiesQA";
		"exvmaephqws050" = "ExternalAEPUtilitiesProd";
		"exvmtulsaws050" = "ExternalAEPUtilitiesProd";
		"exvmaephqws051" = "ExternalAEPUtilitiesProd";
		"exvmtulsaws051" = "ExternalAEPUtilitiesProd";
		"exvmaephqws052" = "ExternalAEPUtilitiesProd";
		"exvmtulsaws052" = "ExternalAEPUtilitiesProd";
		
		"tsvmaephqws060" = "$ExternalOtherTest";
		"eqvmaephqws060" = "ExternalOtherQA";
		"eqvmtulsaws060" = "ExternalOtherQA";
		"exvmaephqws060" = "ExternalOtherProd";
		"exvmtulsaws060" = "ExternalOtherProd";
		
	}
	
	#WHERE ALL THE FUN BEGINS--------------------------------------------------------
	
	#get our farm name given the server we have. 
	$farm = $serverFarm.Get_Item("$server")
	
	#if the server is in a farm lets find out what servers are in the farm. 
	if ($farm -ne $Null){
	#input the correct servers into the variable $nServers from the farm we are given.
		switch ($farm){		
			internalProd2008 {
				$nServers = $internalProd
			}
			internalTest2008{
				$nServers = $internalTest
			}
			internalDev2008{
				$nServers = $internalDev
			}
			internalCorpComProd{
				$nServers = $internalCorpComProd
			}
			internalCorpComTest{
				$nServers = $internalCorpComTest
			}
			internalCorpComDev{
				$nServers = $internalCorpComDev
			}
			internalComOpsProd{
				$nServers = $internalComOpsProd
			}
			internalComOpsTest{
				$nServers = $internalComOpsTest
			}
			internalComOpsDev{
				$nServers = $internalComOpsDev
			}
			internalCorporateProd{
				$nServers = $internalCorporateProd
			}
			internalCorporateTest{
				$nServers = $internalCorporateTest
			}
			internalCorporateDev{
				$nServers = $internalCorporateDev
			}
			internalCustomerProd{
				$nServers = $internalCustomerProd
			}
			internalCustomerTest{
				$nServers = $internalCustomerTest
			}
			internalCustomerDev{
				$nServers = $internalCustomerDev
			}
			internalTdProd{
				$nServers = $internalTdProd
			}
			internalTdTest{
				$nServers = $internalTdTest
			}
			internalTdDev{
				$nServers = $internalTdDev
			}
			internalOtherProd{
				$nServers = $internalOtherProd
			}
			internalOtherTest{
				$nServers = $internalOtherTest
			}
			internalOtherDev{
				$nServers = $internalOtherDev
			}
			ExternalCorporateTest{
				$nServers = $ExternalCorporateTest
			}
			ExternalCorporateQA{
				$nServers = $ExternalCorporateQA
			}
			ExternalCorporateProd{
				$nServers = $ExternalCorporateProd 
			}
			ExternalAEPUtilitiesTest{
				$nServers = $ExternalAEPUtilitiesTest 
			}
			ExternalAEPUtilitiesQA{
				$nServers = $ExternalAEPUtilitiesQA 
			}
			ExternalAEPUtilitiesProd{
				$nServers = $ExternalAEPUtilitiesProd
			}
			ExternalOtherTest{
				$nServers = $ExternalOtherTest
			}
			ExternalOtherQA{
				$nServers = $ExternalOtherQA
			}
			ExternalOtherProd{
				$nServers = $ExternalOtherProd
			}
			default{
				write-host "Well isn't that special, its not working" -foregroundcolor yellow
			}		
		}
	
		#ask if they would like to push their installation to the server farm
		
		$title20 = "INSTALL ON A FARM?"	
		$message20 = "Would you like this install to go to FARM $farm"
		$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
		$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
		$options20 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
		$choice20=$host.ui.PromptForChoice($title20, $message20, $options20, 1)
			
		switch ($choice20){
			0 {
				#if true return array of servers for use with function
				return $nServers
				
			}
			1{
				#if we don't want to treat this as a farm then just return the server back. 
				return $Server
			}
		}
	}	
	else{
		#Test
		write-host "no server farm....bummer" -foregroundcolor yellow
		return $Server
	
	}
}

#Function used to check the neccessary location of the WebContent folder be it FTP or on the static server 
#(TESTING) Determines the VIP location for given server farm whether sticky, round robin or cookie. 
Function FuncWebContentCheck ($server, $siteName){
	#establish some variables

	#establish a hash of the farm associated with each server 
	$serverContentFolder = @{
		"vmaephqws200" = "2008-p";
		"vmaephqws201" = "2008-p";
		"vmaephqws202" = "2008-p";
		"vmaephqws203" = "2008-p";
		"tsvmaephqws200" = "2008-t";
		"tsvmaephqws201" = "2008-t";

		"vmaephqws210" = "CorpCommTemplated-p";
		"vmaephqws211" = "CorpCommTemplated-p";
		"vmaephqws212" = "CorpCommTemplated-p";
		"vmaephqws213" = "CorpCommTemplated-p";
		"tsvmaephqws210" = "CorpCommTemplated-t";
		"tsvmaephqws211" = "CorpCommTemplated-t";

		"vmaephqws220" = "ComOps-p";
		"vmaephqws221" = "ComOps-p";
		"vmaephqws222" = "ComOps-p";
		"vmaephqws223" = "ComOps-p";
		"tsvmaephqws220" = "ComOps-t";
		"tsvmaephqws221" = "ComOps-t";

		"vmaephqws230" = "Corp-p";
		"vmaephqws231" = "Corp-p";
		"vmaephqws232" = "Corp-p";
		"vmaephqws233" = "Corp-p";
		"tsvmaephqws230" = "Corp-t";
		"tsvmaephqws231" = "Corp-t";

		"vmaephqws240" = "Cust-p";
		"vmaephqws241" = "Cust-p";
		"vmaephqws242" = "Cust-p";
		"vmaephqws243" = "Cust-p";
		"tsvmaephqws240" = "Cust-t";
		"tsvmaephqws241" = "Cust-t";

		"vmaephqws250" = "T&D-p";
		"vmaephqws251" = "T&D-p";
		"vmaephqws252" = "T&D-p";
		"vmaephqws253" = "T&D-p";
		"tsvmaephqws250" = "T&D-t";
		"tsvmaephqws251" = "T&D-t";

		"vmaephqws260" = "Other-p";
		"vmaephqws261" = "Other-p";
		"vmaephqws262" = "Other-p";
		"vmaephqws263" = "Other-p";
		"tsvmaephqws260" = "Other-t";
		"tsvmaephqws261" = "Other-t";
		
		"eqvmaephqws040" = "ExtCorp-q"; 
		"eqvmtulsaws040" = "ExtCorp-q";
		"exvmaephqws040" = "ExtCorp-p";
		"exvmtulsaws040" = "ExtCorp-p";
		
		"eqvmaephqws050" = "ExtAEPUtilities-q";
		"eqvmtulsaws050" = "ExtAEPUtilities-q";
		"exvmaephqws050" = "ExtAEPUtilities-p";
		"exvmtulsaws050" = "ExtAEPUtilities-p";
		"exvmaephqws051" = "ExtAEPUtilities-p";
		"exvmtulsaws051" = "ExtAEPUtilities-p";
		"exvmaephqws052" = "ExtAEPUtilities-p";
		"exvmtulsaws052" = "ExtAEPUtilities-p";
		
		"eqvmaephqws060" = "ExtOther-q";
		"eqvmtulsaws060" = "ExtOther-q";
		"exvmaephqws060" = "ExtOther-p";
		"exvmtulsaws060" = "ExtOther-p";
		
		#PUT IN THE REST OF THE STUFF BELOW!!! 

	}
	
	#WHERE ALL THE FUN BEGINS--------------------------------------------------------
	
	#get our file name location for the server we have. 
	$repFile = $serverContentFolder.Get_Item("$server")
	
	#if the server is in a farm lets find out what servers are in the farm. 
	if ($repFile -ne $Null){
	#input the correct servers into the variable $nServers from the farm we are given.
		switch ($repFile){		
			'2008-p'{
				$repServer = "vmaephqft200"
				$rrVipName = "vip-internal-2008-prod-rr.aepsc.com"
				$stickyVipName = "vip-internal-2008-prod-sticky.aepsc.com"
				$cookieVipName = "vip-internal-2008-prod-cookie.aepsc.com"
				$rrVipIP = "10.92.34.50"
				$cookieVipIP = "10.92.34.51"
				$stickyVipIP = "10.92.34.52"
				
			}
			'2008-t'{
				$repServer = "tsvmaephqft200"
				$rrVipName = "vip-internal-2008-test-rr.aepsc.com"
				$stickyVipName = "vip-internal-2008-test-sticky.aepsc.com"
				$cookieVipName = "vip-internal-2008-test-cookie.aepsc.com"
				$rrVipIP = "10.92.34.53"
				$cookieVipIP = "10.92.34.54"
				$stickyVipIP = "10.92.34.55"

			}
			CorpCommTemplated-p{
				$repServer = "vmaephqft200"
				$rrVipName = "vip-internal-aepnow-prod-rr.aepsc.com"
				$stickyVipName = "vip-internal-aepnow-prod-sticky.aepsc.com"
				$cookieVipName = "vip-internal-aepnow-prod-cookie.aepsc.com"
				$rrVipIP = "10.92.34.44"
				$cookieVipIP = "10.92.34.45"
				$stickyVipIP = "10.92.34.46"
			}
			CorpCommTemplated-t{
				$repServer = "tsvmaephqft200"
				$rrVipName = "vip-internal-aepnow-test-rr.aepsc.com"
				$stickyVipName = "vip-internal-aepnow-test-sticky.aepsc.com"
				$cookieVipName = "vip-internal-aepnow-test-cookie.aepsc.com"
				$rrVipIP = "10.92.34.47"
				$cookieVipIP = "10.92.34.48"
				$stickyVipIP = "10.92.34.49"
			}
			ComOps-p{
				$repServer = "vmaephqft200"
				$rrVipName = "vip-internal-comops-prod-rr.aepsc.com"
				$stickyVipName = "vip-internal-comops-prod-sticky.aepsc.com"
				$cookieVipName = "vip-internal-comops-prod-cookie.aepsc.com"
				$rrVipIP = "10.92.34.27"
				$cookieVipIP = "10.92.34.28"
				$stickyVipIP = "10.92.34.29"
			}
			ComOps-t{
				$repServer = "tsvmaephqft200"
				$rrVipName = "vip-internal-comops-test-rr.aepsc.com"
				$stickyVipName = "vip-internal-comops-test-sticky.aepsc.com"
				$cookieVipName = "vip-internal-comops-test-cookie.aepsc.com"
				$rrVipIP = "10.92.34.24"
				$cookieVipIP = "10.92.34.25"
				$stickyVipIP = "10.92.34.26"
			}
			Corp-p{
				$repServer = "vmaephqft200"
				$rrVipName = "vip-internal-corp-prod-rr.aepsc.com"
				$stickyVipName = "vip-internal-corp-prod-sticky.aepsc.com"
				$cookieVipName = "vip-internal-corp-prod-cookie.aepsc.com"
				$rrVipIP = "10.92.34.34"
				$cookieVipIP = "10.92.34.35"
				$stickyVipIP = "10.92.34.36"
			}
			Corp-t{
				$repServer = "tsvmaephqft200"
				$rrVipName = "vip-internal-corp-test-rr.aepsc.com"
				$stickyVipName = "vip-internal-corp-test-sticky.aepsc.com"
				$cookieVipName = "vip-internal-corp-test-cookie.aepsc.com"
				$rrVipIP = "10.92.34.31"
				$cookieVipIP = "10.92.34.32"
				$stickyVipIP = "10.92.34.33"
			}
			Cust-p{
				$repServer = "vmaephqft200"
				$rrVipName = "vip-internal-cust-prod-rr.aepsc.com"
				$stickyVipName = "vip-internal-cust-prod-sticky.aepsc.com"
				$cookieVipName = "vip-internal-cust-prod-cookie.aepsc.com"
				$rrVipIP = "10.92.34.10"
				$cookieVipIP = "10.92.34.11"
				$stickyVipIP = "10.92.34.12"
			}
			Cust-t{
				$repServer = "tsvmaephqft200"
				$rrVipName = "vip-internal-cust-test-rr.aepsc.com"
				$stickyVipName = "vip-internal-cust-test-sticky.aepsc.com"
				$cookieVipName = "vip-internal-cust-test-cookie.aepsc.com"
				$rrVipIP = "10.92.34.7"
				$cookieVipIP = "10.92.34.8"
				$stickyVipIP = "10.92.34.9"
			}
			'T&D-p'{
				$repServer = "vmaephqft200"
				$rrVipName = "vip-internal-t-and-d-prod-rr.aepsc.com"
				$stickyVipName = "vip-internal-t-and-d-prod-sticky.aepsc.com"
				$cookieVipName = "vip-internal-t-and-d-prod-cookie.aepsc.com"
				$rrVipIP = "10.92.34.40"
				$cookieVipIP = "10.92.34.4"
				$stickyVipIP = "10.92.34.39"
			}
			'T&D-t'{
				$repServer = "tsvmaephqft200"
				$rrVipName = "vip-internal-t-and-d-test-rr.aepsc.com"
				$stickyVipName = "vip-internal-t-and-d-test-sticky.aepsc.com"
				$cookieVipName = "vip-internal-t-and-d-test-cookie.aepsc.com"
				$rrVipIP = "10.92.34.38"
				$cookieVipIP = "10.92.34.3"
				$stickyVipIP = "10.92.34.2"
			}
			Other-p{
				$repServer = "vmaephqft200"
				$rrVipName = "vip-internal-other-prod-rr.aepsc.com"
				$stickyVipName = "vip-internal-other-prod-sticky.aepsc.com"
				$cookieVipName = "vip-internal-other-prod-cookie.aepsc.com"
				$rrVipIP = "10.92.34.21"
				$cookieVipIP = "10.92.34.22"
				$stickyVipIP = "10.92.34.23"
			}
			Other-t{
				$repServer = "tsvmaephqft200"
				$rrVipName = "vip-internal-other-test-rr.aepsc.com"
				$stickyVipName = "vip-internal-other-test-sticky.aepsc.com"
				$cookieVipName = "vip-internal-other-test-cookie.aepsc.com"
				$rrVipIP = "10.92.34.18"
				$cookieVipIP = "10.92.34.19"
				$stickyVipIP = "10.92.34.20"
			}
			ExtCorp-q{
				$repServer = "vmaephqft201"
			}
			ExtCorp-p{
				$repServer = "vmaephqft201"
			}
			ExtAEPUtilities-q{
				$repServer = "vmaephqft201"
			}
			ExtAEPUtilities-p{
				$repServer = "vmaephqft201"
			}
			ExtOther-q{
				$repServer = "vmaephqft201"
			}
			ExtOther-p{
				$repServer = "vmaephqft201"
			}
			default{
				write-host "How did you even get here?" -foregroundcolor yellow
			}		
		}
	}
	else{
		$repFile = "WebContent"
		$repServer = $server
	}
	
	$folderPath = "d:\$repFile\$siteName"
	$adminShare = "\d$\$repFile\$siteName"
	
	#return an array with your folder path and the server it is sitting on. 
	return $folderPath, $repServer, $adminShare, $rrVipName, $stickyVipName, $cookieVipName, $rrVipIP, $cookieVipIP, $stickyVipIP
}

#(TESTING)function used to pull SSL certs from CertMan and bind them to newly created IIS bindings/sites (Used in FuncAddWebsite)
Function FuncAddSSLBinding ($server, $sitename, $bindingName){
	#Need to add our module to pull certificate from CertMan
	Import-Module '\\middlewaretools\public\pscert\pscert.psm1'
	set-exportroot "C:\Certs"
	
	#set up our folders for exporting our certs to. 
	if (!(test-path "C:\Certs")){
		New-Item -Path "C:\Certs" -type directory
	}
	if (!(test-path "\\$server\D$\Certs")){
		Invoke-Command -ComputerName $server {New-Item -Path "D:\Certs" -type directory}
	}

	#set up variables. 
	$StoreName = 'My'
	$fqdn = $bindingName + ".aepsc.com"
	$certname = $fqdn + '.pfx'
	$pfxpath = 'D:\Certs\' + $certname
	$pfxpathTemp = 'D:\Certs\temp\' + $certname
	$pfxpathTempFolder = 'D:\Certs\temp'
	$password = ConvertTo-SecureString -String $fqdn -Force -AsPlainText
	$pfxpathTemp = 'D:\Certs\temp\' + $certname

	$sourcePath = "C:\Certs\"+ $bindingName + "*\" + $bindingName + "*" + ".pfx"
	$destPath = "\\$server\D$\Certs\" + $certname

	#import our cert from certman
	getcert -export $fqdn
	
	#move this cert to the server in question 
	Copy-Item -Path $sourcePath -Destination $destPath
	
	#verify Store Location is currently in place on server and ready to go. 
	if (test-path $destPath){
		#import into store.
		Invoke-Command -ComputerName $server -ScriptBlock{param ($storeName, $pfxpath, $password, $pfxpathTemp, $bindingName, $siteName, $pfxpathTempFolder)
			#Import the web module that we will need moving forward
			import-module webadministration
			
			#Lets start the act of doing. 
			Add-Type -AssemblyName System.Security
			$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
			write-host "cert"
			$cert
			$cert.Import($pfxpath, $password, 'Exportable')
			write-host "pfxpath"
			$pfxpath
			write-host "password"
			$password
			$StoreLocation = [System.Security.Cryptography.X509Certificates.StoreLocation]'LocalMachine'
			write-host "storelocation"
			$storeLocation
			$Store = New-Object system.security.cryptography.X509Certificates.x509Store($StoreName, $StoreLocation)
			write-host "store"
			$store
			$Store.Open('ReadWrite')
			$Store.Add($cert)

			
			#get thumbprint of our newly imported cert
			$thumbprint = $cert.thumbprint
			write-host $thumbprint -foregroundcolor yellow 
			
			#verify that our certificate was appropriately imported the first time before exporting cert. 
			if(Test-Path "cert:\localMachine\my\$thumbprint"){
				if(!(test-path $pfxpathTempFolder)){

					New-Item -Path $pfxpathTempFolder -type directory
				}
				
				#export into temp location
				Get-ChildItem -Path cert:\localMachine\my\$thumbprint | Export-PfxCertificate -FilePath $pfxpathTemp -Password $password
				
				#verify that our certificate has been exported to the temporary location. 
				if (test-path $pfxpathTemp){
					#remove the cert from store
					$Store.Remove($cert)
					$Store.Close()
					
					#verify that the initial certificate has been removed from the store before importing the new guy. 
					write-host "cert:\localMachine\my\$thumbprint" -foregroundcolor yellow 
					$test = test-path "cert:\localMachine\my\$thumbprint"
					write-host $test 
					if(!(Test-Path "cert:\localMachine\my\$thumbprint")){
						#import into store again 
						$webServerCert = Import-PfxCertificate -FilePath $pfxpathTemp cert:\localMachine\my -Password $password
						
						$privateKeyFilename = $webServerCert.PrivateKey.CspKeyContainerInfo.UniqueKeyContainerName
						$privateKeyFullPath = "c:\ProgramData\Microsoft\Crypto\RSA\MachineKeys\"+$privateKeyFilename
						$aclRule = "SYSTEM", "Full", "Allow"
						$aclEntry = New-Object System.Security.AccessControl.FileSystemAccessRule $aclRule
						$privateKeyAcl = (Get-Item $privateKeyFullPath).GetAccessControl("Access")
						$privateKeyAcl.AddAccessRule($aclEntry)
						Set-Acl $privateKeyFullPath $privateKeyAcl
						
						#add new web binding onto site and then attach the new certificate. 
						New-WebBinding -Name $siteName -Port 443 -Hostheader $bindingName -Protocol https -SslFlags 1 -force
						#c:\Windows\System32\inetsrv\appcmd.exe set config -section:system.applicationHost/sites /+"[name='$sitename'].bindings.[protocol='https',bindingInformation='*:443:"$binding"']" /commit:apphost
						New-Item -Path "IIS:\SslBindings\!443!$bindingName" -Thumbprint $thumbprint -SSLFlags 1
					}
					else{
						write-warning "initial certificate could not be removed. Script cannot continue."
					
					}
				}
				else {
					write-warning "$certname was not been moved to its temporary location, $pfxpathTemp. Script cannot continue."
				
				}
			}
			else{
				write-warning "initial certificate import has failed on $server. Script cannot continue."
			
			}
		} -ArgumentList $storeName, $pfxpath, $password, $pfxpathTemp, $bindingName, $siteName, $pfxpathTempFolder
	}
	else {
		write-warning "Certificate not moved to $destPath on $server"
	}
}

#(DEPRECATED)Pull username and credentials and return them in for use by function (Used in FuncInstallIIS)
Function FuncDomainUser ($server){	
		#Beginning variables 
		$userid = [Environment]::UserName
		
		#check domain value 
		$nbtstat = nbtstat -a $Server
		$domMatch = $nbtstat | Select-String '(\w+) +[0-9<>]{4} +GROUP '
		$domain = $domMatch.Matches[0].Groups[1].Value
		
		#Pull correct credentials based off of server domain 
		if($domain -eq "CORPTEST"){
			$username = "CORPTEST\$userid"
			$password = get-content $path\Credentials\$userid'_WI.txt' | convertto-securestring	
			$cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $username,$password
			return, $cred
		}
		if($domain -like "WEBINT"){
			$username = "WEBINT\$userid"
			$password = get-content $path\Credentials\$userid'_CT.txt' | convertto-securestring
			$cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $username,$password
			return, $cred
		}
		if($domain -eq "CORP"){
			$username = "CORP\$userid"
			$password = get-content $path\Credentials\$userid'_CORP.txt' | convertto-securestring
			$cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $username,$password
			return, $cred
		}	
		if($domain -eq $null){
			$username = "CORP\$userid"
			$password = get-content $path\Credentials\$userid'_CORP.txt' | convertto-securestring
			$cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $username,$password
			return, $cred
		}

}

#(DEPRECATED)Prompt and store a users password encrypted in Credential folder for different domains (Used in FuncInstallIIS)
Function FuncUserPassword{
	if ((Get-Content $path\Credentials\$userid'_WI.txt') -eq $Null){
		Read-Host "Please enter your WEBINT account password" -assecurestring | ConvertFrom-SecureString | out-file $path\Credentials\$userid'_WI.txt'

		}
	if ((Get-Content $path\Credentials\$userid'_CT.txt') -eq $Null){
		Read-Host "Please enter your CORPTEST account password" -assecurestring | ConvertFrom-SecureString | out-file $path\Credentials\$userid'_CT.txt'

		}
	if ((Get-Content $path\Credentials\$userid'_CORP.txt') -eq $Null){
		Read-Host "Please enter your CORP account password" -assecurestring | ConvertFrom-SecureString | out-file $path\Credentials\$userid'_CORP.txt'

		}	

}

# !!!!NEW!!!!!(TESTING)Prompt and store a users password encrypted in Credential folder if already available return credentials. 
Function FuncUserNamePassword ($server){

	#if any of our password save locations are blank then we need to get some credentials. 
	if (((Get-Content $path\Credentials\$userid'_WI.txt') -eq $Null) -or ((Get-Content $path\Credentials\$userid'_CT.txt') -eq $Null) -or ((Get-Content $path\Credentials\$userid'_CORP.txt') -eq $Null)){
		if ((Get-Content $path\Credentials\$userid'_WI.txt') -eq $Null){
			Read-Host "Please enter your WEBINT account password" -assecurestring | ConvertFrom-SecureString | out-file $path\Credentials\$userid'_WI.txt'

			}
		if ((Get-Content $path\Credentials\$userid'_CT.txt') -eq $Null){
			Read-Host "Please enter your CORPTEST account password" -assecurestring | ConvertFrom-SecureString | out-file $path\Credentials\$userid'_CT.txt'

			}
		if ((Get-Content $path\Credentials\$userid'_CORP.txt') -eq $Null){
			Read-Host "Please enter your CORP account password" -assecurestring | ConvertFrom-SecureString | out-file $path\Credentials\$userid'_CORP.txt'

			}	
	}
	#if our passwords are all exactly where they need to be then we can return credentials. 
	else{
		#Beginning variables 
		$userid = [Environment]::UserName
		
		#check domain value 
		$nbtstat = nbtstat -a $Server
		$domMatch = $nbtstat | Select-String '(\w+) +[0-9<>]{4} +GROUP '
		$domain = $domMatch.Matches[0].Groups[1].Value
		
		#Pull correct credentials based off of server domain 
		if($domain -eq "CORPTEST"){
			$username = "CORPTEST\$userid"
			$password = get-content $path\Credentials\$userid'_WI.txt' | convertto-securestring	
			$cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $username,$password
			return, $cred
		}
		if($domain -like "WEBINT"){
			$username = "WEBINT\$userid"
			$password = get-content $path\Credentials\$userid'_CT.txt' | convertto-securestring
			$cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $username,$password
			return, $cred
		}
		if($domain -eq "CORP"){
			$username = "CORP\$userid"
			$password = get-content $path\Credentials\$userid'_CORP.txt' | convertto-securestring
			$cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $username,$password
			return, $cred
		}	
		if($domain -eq $null){
			$username = "CORP\$userid"
			$password = get-content $path\Credentials\$userid'_CORP.txt' | convertto-securestring
			$cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $username,$password
			return, $cred
		}

	
	
	}

}

#Verify is a drive exists on a given server. (Used in FuncInstallIIS)
Function FuncCheckDriveLetter ($Server, $Credent, $Letter){
	
	#create static variables for function 
	$diskStats = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$Letter'" -ComputerName $Server -Credential $Credent -Authentication 6
	if ($diskStats -eq $null)
	{
		$DSpace = "Fail"
		return ,$DSpace
	}
}

#Used for installing standard AEP IIS components on remote server (IIS_8, IIS_7.5) 
Function FuncInstallIIS ($server, $cred){
	
	#Run check on OS version to differentiate between 7.5 and 8.0 IIS install. 
	$OSCheck = (Get-WmiObject -ComputerName $server -Credential $Cred -class Win32_OperatingSystem ).Caption
	
	#verify server can be reached and pssession can be established for installation
	$rdpCheck = FuncCheckRDP -server $server -cred $cred
	$pingCheck = FuncCheckConnectivity -server $server
	$driveCheck = FuncCheckDriveLetter -server $server -cred $cred -Letter 'D:'
	
	#if checks succeed then try to install IIS per AEP standards
	if ($rdpCheck -eq "Pass" -and $pingCheck -eq "Pass" -and $driveCheck -ne "Fail" )
	{
	
		#Server is Windows Server 2012 
		if ($OSCheck -match "Server 2012"){
			try{

				#install IIS features
				Invoke-Command -ComputerName $server -credential $cred -Command{Install-WindowsFeature -Name Web-Server, Web-Http-Redirect, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Basic-Auth, Web-CertProvider, Web-IP-Security, Web-Url-Auth, Web-Windows-Auth, Web-Net-Ext, Web-Net-Ext45, Web-AppInit, Web-ASP, Web-Asp-Net, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Includes, Web-Mgmt-Console, Web-Scripting-Tools, Web-Mgmt-Service} 
				
				#remove directory browsing 
				Invoke-Command -ComputerName $server -credential $cred -Command{Uninstall-WindowsFeature -Name Web-Dir-Browsing}
				
				#create path for IIS Logging. 
				Invoke-Command -ComputerName $server -credential $cred -Command{New-Item -Path "d:\LogFiles" -type directory}
				Invoke-Command -ComputerName $server -credential $cred -Command{New-Item -Path "d:\WebContent" -type directory}
				$testPath = Test-Path "\\$server\D$\LogFiles"
				$webPath = Test-Path "\\$server\D$\Webcontent"
				
				if ($testPath -and $webPath){
					#set IIS log files 
					Invoke-Command -ComputerName $server -credential $cred -Command{import-module "webadministration"}
					Invoke-Command -ComputerName $server -credential $cred -Command{Set-WebConfigurationProperty '/system.applicationHost/sites/siteDefaults/logfile' -PSPath IIS:\ -Name directory -value "d:\Logfiles"}
					Invoke-Command -ComputerName $server -credential $cred -Command{Set-WebConfigurationProperty '/system.applicationHost/sites/siteDefaults/logfile' -PSPath IIS:\ -Name localTimeRollover -value "true"}
					$log = Invoke-Command -ComputerName $server -credential $cred -Command{Get-WebConfigurationProperty "/system.applicationHost/sites/siteDefaults" -name logfile.directory}
					$time = Invoke-Command -ComputerName $server -credential $cred -Command{Get-WebConfigurationProperty -Filter '/system.applicationHost/sites/SiteDefaults/Logfile' -name localTimeRollover}
					$logLocation = $log.value
					$timeValue = $time.value
					
					write-output "Your log file is now stored at $logLocation"
					write-output "Local time rollover is set to $timeValue"
				} 
				else {
					write-output "Log files could not be created"	
				} 

			}
			
			#catch any non explained exceptions 
			catch{
				write-output "failure"
			}
		}
		
		#Server is Windows Server 2008
		if ($OSCheck -match "Server 2008"){
			
			$session = new-PsSession $server -Credential $cred
			enter-PsSession $session

			#install IIS features
			Invoke-Command -Session $session -Command{Import-Module servermanager}
			Invoke-Command -Session $session -Command{Add-WindowsFeature Web-Server, Web-Http-Redirect, Web-Asp-Net, Web-Net-Ext, Web-ASP, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Includes, Web-Log-Libraries, Web-Http-Tracing, Web-Basic-Auth, Web-Windows-Auth, Web-Url-Auth, Web-IP-Security, Web-Scripting-Tools, Web-Mgmt-Service, NET-Framework-Core} 
				
			#remove directory browsing 
			Invoke-Command -Session $session -Command{Remove-WindowsFeature Web-Dir-Browsing}
			
			#Add WebContent and LogFile file and redirect Logs to new D:/LogFile location. 
			try {
				Invoke-Command -ComputerName $server -credential $cred {New-Item -Path "d:\LogFiles" -type directory}
				Invoke-Command -ComputerName $server -credential $cred {New-Item -Path "d:\WebContent" -type directory}
				$testPath = Test-Path "\\$server\D$\LogFiles"
				$webPath = Test-Path "\\$server\D$\Webcontent"
				
				if ($testPath -and $webPath){
					#set IIS log files 
					Invoke-Command -Session $session -Command{import-module "webadministration"}
					Invoke-Command -Session $session -Command{Set-WebConfigurationProperty '/system.applicationHost/sites/siteDefaults/logfile' -PSPath IIS:\ -Name directory -value "d:\Logfiles"}
					Invoke-Command -Session $session -Command{Set-WebConfigurationProperty '/system.applicationHost/sites/siteDefaults/logfile' -PSPath IIS:\ -Name localTimeRollover -value "true"}
					$log = Invoke-Command -Session $session -Command{Get-WebConfigurationProperty "/system.applicationHost/sites/siteDefaults" -name logfile.directory}
					$time = Invoke-Command -Session $session -Command{Get-WebConfigurationProperty -Filter '/system.applicationHost/sites/SiteDefaults/Logfile' -name localTimeRollover}
					$logLocation = $log.value
					$timeValue = $time.value
					
					write-output "Your log file is now stored at $logLocation"
					write-output "Local time rollover is set to $timeValue"
				} 
				else {
					write-output "Log files could not be created"	
				} 			
			}
			catch {
				write-output "Log file creation/redirection failure"
			
			}
			
			#try to install .NET 4.0
			try{
				Import-Module bitstransfer
				Invoke-Command -ComputerName $server -credential $cred {New-Item -Path "c:\script" -type directory}
				$sourcePath = "$path/lib/Scripts/dotnetfx40_x64_x86.exe"
				$destPath = "\\$server\C$\script\dotnetfx40_x64_x86.exe"
				Start-BitsTransfer -Source $sourcePath -Destination $destPath -Credential $cred
				$sourcePath = "$path/lib/Scripts/NET_40_Installation.xml"
				$destPath = "\\$server\C$\script\NET_40_Installation.xml"
				Start-BitsTransfer -Source $sourcePath -Destination $destPath -Credential $cred
				

				try{
					#Invoke-Command -Session $session -ScriptBlock {C:\script\NETinstall.ps1}
				
					#create .NET installation task on remote server. 
					schtasks.exe /s $server /create /tn NET_4_Installion /f /xml "\\$server\C$\script\NET_40_Installation.xml" /ru $cred.getNetworkCredential().username /rp $cred.getNetworkCredential().password
					
					#invoke job to install .NET 4 on server
					schtasks.exe /s $server /run /tn NET_4_Installion
					
				}
				catch{
					write-output ".NET installer failed"
				}

			}
			catch{
				write-output ".NET 4.0 installation failure."
			} 
		}
	}
	if ($rdpCheck -ne "Pass"){
		write-host "Cannot establish session with server" -foreground red
	}
	if ($pingCheck -ne "Pass"){
		write-host "Cannot reach server" -foreground red
	}
	if ($driveCheck -eq "Fail"){
		write-host "No D: drive available for log configuration" -foreground red
	}

}

#Check installation of IIS and its neccessary paths on server. 
Function FuncCheckIIS ($server, $cred){
	$logPath = Test-Path "\\$server\D$\LogFiles"
	$webPath = Test-Path "\\$server\D$\Webcontent"
	
	#create settion to pull information 
	$session = new-PsSession $server -Credential $cred
	enter-PsSession $session
	
	#Check on log directory and time value settings 
	Invoke-Command -Session $session -Command{import-module "webadministration"}
	$log = Invoke-Command -Session $session -Command{Get-WebConfigurationProperty "/system.applicationHost/sites/siteDefaults" -name logfile.directory}
	$time = Invoke-Command -Session $session -Command{Get-WebConfigurationProperty -Filter '/system.applicationHost/sites/SiteDefaults/Logfile' -name localTimeRollover}
	$logLocation = $log.value
	$timeValue = $time.value
	
	#check on installed IIS components on machine. 
	Invoke-Command -Session $session -Command{Import-Module servermanager}
	$IISinstall = Invoke-Command -Session $session -Command{Get-WindowsFeature Web-Server, Web-Http-Redirect, Web-Asp-Net, Web-Net-Ext, Web-ASP, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Includes, Web-Log-Libraries, Web-Http-Tracing, Web-Basic-Auth, Web-Windows-Auth, Web-Url-Auth, Web-IP-Security, Web-Scripting-Tools, Web-Mgmt-Service, NET-Framework-Core, Web-Dir-Browsing} 
	
	Add-Content "$path/Logs/LogFile_$server.txt" "LogFile available on D drive ::"
	$logPath | Add-Content "$path/Logs/LogFile_$server.txt"
	Add-Content "$path/Logs/LogFile_$server.txt" "WebContent available on D drive :: "
	$webPath | Add-Content "$path/Logs/LogFile_$server.txt"
	Add-Content "$path/Logs/LogFile_$server.txt" "LogLocation fowarded to D:/Logfile ::"
	$logLocation | Add-Content "$path/Logs/LogFile_$server.txt"
	Add-Content "$path/Logs/LogFile_$server.txt" "local TimeValue set for default sites"
	$timeValue | Add-Content "$path/Logs/LogFile_$server.txt"
	Add-Content "$path/Logs/LogFile_$server.txt" "IIS Components currently installed ::"
	$IISInstall | Select DisplayName, Installed | Add-Content "$path/Logs/LogFile_$server.txt"
	
	try{
		Import-Module bitstransfer
		$sourcePath = "$path/Logs/LogFile_$server.txt"
		$destPath = "\\$server\D$\LogFiles\LogFiles_$server.txt"
		Start-BitsTransfer -Source $sourcePath -Destination $destPath -Credential $cred
	}
	catch{
		write-output "logs could not be remotely added to server."
	
	}
			

}

#Kevin Knox Function 
Function Find-HostIps {
	param (
		$alias
	)
    
    <# Notes on updating the source CSV for this method. 
    # If you run the command and receive a VIP as your reply, you need to update the source CSV from the BigIP master list
    PS U:\> Find-Hostnames amiws-d
    vip-amiws-dev.aepsc.com
    
    # Pull the entire source of the Network Map for the All[Read Only] partition in BigIP. 
    # Save it as $hostListPath (found below)
    
    # The conversion script is located in the utilities folder of the PoshTools module - all params are hard coded
    PS U:\> cd T:\PoshTools\utilities
    PS T:\PoshTools\utilities> .\Convert-HostsSourceToCsv.ps1
    PS T:\PoshTools\utilities> Find-Hostnames amiws-d
    gswlamid1.aepsc.com
    gswlamid2.aepsc.com
    #>
	Write-Verbose ("Finding '$alias'")
	$addresses = @([System.net.DNS]::GetHostAddresses($alias))
    if ($addresses.Count) {
        foreach ($address in $addresses) {
			Add-Content -path "$logpath/Logs/Bindings_$date.txt" -value ""
			Add-Content -path "$logpath/Logs/Bindings_$date.txt" -value ("Address: $address")
            Write-Host ("Address: $address")
			Add-Content -path "$logpath/Logs/Bindings_$date.txt" -value ("Name: $(([System.net.DNS]::GetHostEntry($address)).HostName)")
            Write-Host ("Name: $(([System.net.DNS]::GetHostEntry($address)).HostName)")
			
        }
    } else {
        throw "No addresses returned from DNS"
    } 
	
	$hostListPath = '\\oh0co007\itprodsysdocrepository\middleware\technology\webLogic\HostList.csv'
	$hostList = Import-Csv -Path $hostListPath
	$members = @($hostList | Where-Object {$_.hostip -eq $addresses[0].IPAddressToString})
	if ($members.Count) {
		Write-Verbose ("Found '$member'")
		$ips = @{}
		foreach ($member in $members) {
			$ips[$member.memberip]++
		}
		$ips.Keys
	} else {
		Write-Verbose ("Found no VIP")
		$addresses[0].IPAddressToString
	}
}

#Kevin Knox Function 
Function Find-HostNames {
	param (
		$alias
	)

	$ips = Find-HostIps @PsBoundParameters

		foreach ($ip in $ips) {
		
		([System.net.DNS]::GetHostEntry($ip)).HostName
		$hostname =([System.net.DNS]::GetHostEntry($ip)).HostName
	}
}

#(TESTING)Used for deletion of IIS sites on Windows 2003/2008 boxes. 
Function FuncDeleteIISWebsite ($server, $siteName){
	
	#lets see who we are playing with here 
	$OSCheck = (Get-WmiObject -ComputerName $server -class Win32_OperatingSystem ).Caption
	
	#if the server is old and fragile
	if (!($OSCheck -match "Server")){
		
		$pingCheck = FuncCheckConnectivity -server $server
		if ($pingCheck -ne "Pass" ){
			write-host "Ping check was not successful. Server could not be found" -foregroundcolor red
		}
	}
	if ($OSCheck -match "Server 2003"){
		write-output "Windows 2003R2 detected"
		#who doesn't love some variables? We'll make ours here. 
		$siteNeeded = $siteName
		$bindings = @()
		
		write-host "sitename" -foregroundcolor yellow
		write-host $siteNeeded
		#verify server can be reached and pssession can be established for installation
		$pingCheck = FuncCheckConnectivity -server $server
		
		#if checks succeed then lets kill it with fire.
		if ($pingCheck -eq "Pass" ){
			#Set up variables for use
			$logLocation = ''
			$hashmap = @{}
			$PathMatch = @()
			$vbScriptPath = "\\oh0co010\IISWEB\#IISScripting\IISWebsiteRemoval\lib\adsutil.vbs"

			#TRANSFER adsutil.vbs TO SERVER 
			$scriptName = "adsutil.vbs"
			if (!(test-path "\\$server\C$\script")){
				Invoke-Command -ComputerName $server {New-Item -Path "c:\script" -type directory}
			}

			#import module for transfering files to remote computer
			if (!(test-path "\\$server\C$\script\$scriptName")){
				#Import-Module bitstransfer
				#get it from the network share. 
				$sourcePath = "\\oh0co010\IISWEB\#IISScripting\IISWebsiteRemoval\lib\$scriptName"
				#place it on our server. 
				$destPath = "\\$server\C$\script\$scriptName"

				#start that transfer.
				#Start-BitsTransfer -Source $sourcePath -Destination $destPath
				Copy-Item -Path $sourcePath -Destination $destPath				
			}
			if (Test-Path $destPath){
				#Get List of sites on server 
				$sitePathArray = Invoke-Command -ComputerName $server -Command{cscript.exe C:\script\adsutil.vbs ENUM /P W3SVC}
				
				#strip crap from out of sitePath
				$PathMatch = $sitePathArray | Select-String 'W3SVC\/\d+'
				
				
				#Loop through your new list of sites on the server. 
				foreach($sitePath in $PathMatch){
					
					#return the Path into a usable variable 
					$Path = $sitePath.matches[0].value 
					

					#USE NEW VARIABLE TO PULL SITENAME FROM SERVERCOMMENT
					#build our path to use to get our serverName
					$serverCommentCommand = $Path + "/ServerComment"
					

					#Get the server name from the path 
					$siteName = Invoke-Command -ComputerName $server -Command{param($serverCommentCommand)cscript.exe C:\script\adsutil.vbs get $serverCommentCommand} -ArgumentList $serverCommentCommand
					
					#strip crap from out of the siteName 
					$siteMatch = $siteName | Select-String '"([^"]+)"'
					
					write-host "Test Site Match" -foregroundcolor yellow 
					write-output $siteMatch
				
					#return the Site into a usable variable 
					$site = $sitematch.matches[0].value 
					$site = $site-ireplace '"', ''			
					
					#Add the value of all that fun stuff to my hashmap 
					$hashmap.Add("$site", "$path")
				}

				write-host "siteName" -foregroundcolor yellow
				write-host $siteNeeded
				
				#We need to make sure this site is even on this server before proceeding.
				#pull the sitepath given the siteName we are trying to get rid of. 
				$Path = $hashmap.Get_item($siteNeeded)
				
				write-host "Path" -foregroundcolor yellow
				write-host $Path
				
				#woops this site is no longer among the living. 
				if ($path -eq $null){
					write-host "Site does not exist on this server." -foregroundcolor red
						
				}
				
				#I'm not dead yet. Site found Pass Go collect 200 dollars. 
				else{		
					#FINDING THE SITE LOGFILE LOCATION
					#Will need to verify that site doesn't have its own default log location

					#Create the command that we need to run for LogFileDirectory
					$logFileCommand = $Path + "/LogFileDirectory"
					#Run the command 
					$logDirectory = Invoke-Command -ComputerName $server -Command{param($logFileCommand)cscript.exe C:\script\adsutil.vbs get $logFileCommand} -ArgumentList $logFileCommand
					$logMatchError = $logDirectory | Select-String '("LogFileDirectory")'

					#looks like we didn't have a log location....lets get the default Location
					if ($logMatchError -ne $null){
						
						#GetDefault IIS log location 
						$logDirectory = Invoke-Command -ComputerName $server -Command{cscript.exe C:\script\adsutil.vbs get W3SVC/LogFileDirectory}
						$logMatchError = $logDirectory | Select-String '(Error)'
						
						#Looks like we didn't have any log location...bummer. 
						if ($logMatchError -ne $null){
							write-host "Could not find default log file location"
						}

					}

					#cleanup our logDirectory 
					$logMatch = $logDirectory | Select-String '[\(EXPANDSZ\)] (.*$)'

					#$logs = $logMatch[2].matches[0].groups[1].value
					$logs = $logMatch[2].matches[0].groups[1].value
					write-host "Logs" -foregroundcolor yellow
					write-host $logs

					#FINDING THE BINDINGS FOR THE SITE 
					#pull the sitepath given the site we are trying to get rid of. 
					$Path = $hashmap.Get_item($siteNeeded)
					#Create the command that we need to run for ServerBindings 
					$serverBindingCommand = $Path + "/ServerBindings"
					#Run the command 
					$siteBindings = Invoke-Command -ComputerName $server -Command{param($serverBindingCommand)cscript.exe C:\script\adsutil.vbs get $serverBindingCommand} -ArgumentList $serverBindingCommand
					
					#Need to loop through all the returns. 
					#Match our bindings 
					$bindingMatch = $siteBindings | Select-String '"[0-9.:]+(.*)"'

					#I need to get all the binding values into my array. sloppy way to loop just keep going and don't shoot any errors
					for($i = 0; $i -lt 100; $i ++){
						try{
							$bindings += $bindingMatch[$i].matches[0].groups[1].value
						}
						catch{
							$i = 100
						}
					
					}
					
					write-host "bindings" -foregroundcolor yellow
					write-host $bindings

					#GET LOG FILE ABSOLUTE LOCATION WITH OUR INFORMATION 
					#cleanup path for use with LogFile 
					$Path = $Path -ireplace '/', ''
					#Put our parts together to output the path we need to delete. 
					$logFile = $logs + "\" + $Path

					write-host "LogFile path" -foregroundcolor yellow
					write-host $logFile

					#FIND THE DNS RECORDS WE WILL NEED TO RETURN TO COMMAND CENTER. 
					write-host "DNS records" -foregroundcolor yellow 
					foreach ($binding in $bindings){
						write-host "test logpath" -foregroundcolor yellow 
						write-host $logpath
						$records = find-hostnames $binding
						Add-Content -path "$logpath/Logs/Bindings_$date.txt" -value $binding
						Add-Content -path "$logpath/Logs/Bindings_$date.txt" -value $records
						write-output $binding

					}
					
					#ASK IF WE WOULD LIKE TO DELETE THE SITE 
					$title1 = "DELETE SITE"
					$message1 = "Would you like to DELETE $siteNeeded"
					$Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
					$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
					$options1 = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
					$choice1=$host.ui.PromptForChoice($title1, $message1, $options1, 1)
								
					switch ($choice1){
						0 { 
							#delete the sites log file
							Invoke-Command -ComputerName $server -Command{param($logFile)Remove-Item $logFile -Force -Recurse} -ArgumentList $logFile
							
							$scriptName = "iisweb.vbs"
							#we need to make sure our .vbs script is out there to call on 
							$sourcePath = "\\oh0co010\IISWEB\#IISScripting\IISWebsiteRemoval\lib\$scriptName"
							#place it on our server. 
							$destPath = "\\$server\C$\script\$scriptName"

							#start that transfer. 
							#Start-BitsTransfer -Source $sourcePath -Destination $destPath 
							Copy-Item -Path $sourcePath -Destination $destPath
							
							if (Test-Path $destPath){
							#FINALLY!!! Lets kill the beast 
								$siteBindings = Invoke-Command -ComputerName $server -Command{param($siteNeeded)cscript.exe C:\script\iisweb.vbs /delete $siteNeeded} -ArgumentList $siteNeeded
							}
							else{
								write-warning "iisweb.vbs could not be copied to $server"
							}
										
						}
						1 { 
							
						}
					}
				}
			}
			else{
				write-warning "adsutil.vbs could not be copied to $server"
			}
		}
	}
	#stupid 2003 lets play with some newer toys. 
	if ($OSCheck -match "Server 2008" -or $OSCheck -match "Server 2012"){
		write-output "Window 2012/2008 R2 Detected."
		#import module for IIS 
		Invoke-Command -Session $session -Command{import-module "webadministration"}
		
		#verify that the site and application are in existance. 
		$appExists = Invoke-Command -ComputerName $server -Command{param($siteName)(c:\Windows\System32\inetsrv\appcmd.exe list apppool /name:$siteName) -ne $null} -ArgumentList $siteName
		
		$siteExists = Invoke-Command -ComputerName $server -Command{param($siteName)(c:\Windows\System32\inetsrv\appcmd.exe list site /name:$siteName) -ne $null} -ArgumentList $siteName
		
		#check to verify my site actually exists before proceeding with deletion. 
		if ($siteExists -eq "True" -and $appExists -eq "True"){
			
			
			try{
				#check location for WebContent path 
				$status = Invoke-Command -ComputerName $server -Command{param($siteName)Get-Website -name $siteName} -ArgumentList $siteName
				$Path = $status.physicalPath
				
				#Run function to get folder location for the script to continue [$folderPath, $server, $adminShare]
				$WContent = FuncWebContentCheck -server $server -siteName $siteName
				$folderPath = $WContent[0]
				$serverPath = $WContent[1]
				$adminShare = $WContent[2]

				#This crap will need to go away KILL IT WITH FIRE!!! 
				$FTPPath = "\\$serverPath" + "$adminShare"

				
			}
			catch{
				write-output "could not find WebContent path for $sitename" -foregroundcolor
			
			}
			#lets get the variable we need for our logfile path. 
			$logFileDirectory = $status.logfile.directory
			$websiteID = $status.id
			$logFile = $logFileDirectory + '\'+ 'W3SVC' + $websiteID
			
			if(!(Invoke-Command -ComputerName $server -Command{param($logFile)test-path $logFile} -ArgumentList $logFile)){
				write-output "could not find LogFile path $logFile for $sitename" -foregroundcolor
				
			}

			#LETS INFORM OURSELVES AS TO WHAT WE ARE KILLING
			write-host "SiteName" -foregroundcolor yellow 
			write-host $siteName
			
			write-host "LogFile Location" -foregroundcolor yellow
			write-host $logFile
			
			write-host "WebContent Location" -foregroundcolor yellow
			write-host $Path
			
			write-host "FTP WebContent Location" -foregroundcolor yellow 
			write-host $FTPPath
			
			#LETS CHECK OUR BINDINGS 
			
			#start by getting the website information from the server 
			$bindingStatus =Invoke-Command -ComputerName $server -Command{param($siteName)Get-WebSite -name $siteName} -ArgumentList $siteName
			
			#we are looking for the binding information here. 
			[string]$bindingInfo = $bindingStatus.bindings.Collection
			
			#lets split this into an array of the binding information 
			[string[]]$bind = $BindingInfo.Split(" ")
			
			
			write-host "Bindings" -foregroundcolor yellow
			#lets get our bindings and put it somewhere where we might be able to use it. 
			Do{
				[string[]]$Bindings2 = $Bind[($i+1)].Split(":")
				#write-host "Bindings2" -foregroundcolor yellow
				#write-output $Bindings2
				
				$bindingHeader = $Bindings2[2]
				#write-host "BindingsHeader" -foregroundcolor yellow
				#write-output $BindingHeader
				
				write-output $bindingHeader
				$records = find-hostnames $bindingHeader
				#write-host "records" -foregroundcolor yellow
				#write-output $records
				
				Add-Content -path "$logpath/Logs/Bindings_$date.txt" -value $bindingHeader
				Add-Content -path "$logpath/Logs/Bindings_$date.txt" -value $records
				

				$i=$i+2
			} while ($i -lt ($bindings.count))

			#LETS GET THIS THING DELETED 
			#ASK IF WE WOULD LIKE TO DELETE THE SITE 
				$title1 = "DELETE SITE"
				$message1 = "Would you like to DELETE $siteNeeded"
				$Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
				$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
				$options1 = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
				$choice1=$host.ui.PromptForChoice($title1, $message1, $options1, 1)
							
				switch ($choice1){
					0 { 
						try{
							#delete site from server 
							Invoke-Command -ComputerName $server -Command{param($siteName)c:\Windows\System32\inetsrv\appcmd.exe delete site $siteName} -ArgumentList $siteName
						}
						catch{
							write-host "could not delete $siteName from $server" -foregroundcolor red
						
						}
						
						try{
							#delete application from server 
							Invoke-Command -ComputerName $server -Command{param($siteName)Remove-WebAppPool -name $siteName} -ArgumentList $siteName
						}
						catch{
							write-host "could not delete $siteName application from $server" -foregroundcolor red
							
						}
						try{
							#delete Webcontent path for site. 
							Invoke-Command -ComputerName $server -Command{param($path)Remove-Item $path -Force -Recurse} -ArgumentList $path
						}
						catch{
							write-host "could not delete $path from $server" -foregroundcolor red
						
						}
						try{
							#delete Webcontent path for site. 
							Invoke-Command -ComputerName $serverPath -Command{param($folderPath)Remove-Item $folderPath -Force -Recurse} -ArgumentList $folderPath
						}
						catch{
							write-host "could not delete $folderPath from $serverPath" -foregroundcolor red
						
						}
						try{
							#delete LogFile path for site. 
							Invoke-Command -ComputerName $server -Command{param($logFile)Remove-Item $logFile -Force -Recurse} -ArgumentList $logFile
						}
						catch{
							write-host "could not delete $logFile from $server" -foregroundcolor red
						
						}
			 
									
					}
					1 { 
						
					}
				}
		}		
		else{
			write-host "could not find $siteName site or application object for deletion" -foregroundcolor red
		
		}
	
	}
}

#(TESTING)Display a popup dialog box when there are no vulscan.exe processes running
Function FuncVulScanDone($server) {

	[bool]$firstTime = $true
	#  If there are no iexlore processes, display a pop up dialog box and quit.
	do {
		Start-Sleep -Seconds 5
		$i = 0
		
		try {
			Get-Process -Name vulscan -errorAction stop -computerName $server | ForEach-Object {$i++}
		}
		catch [exception] {                   
		# Get-process returned no instances of iexplore running
			$i = 0
		}
		
		if ($i -gt 1 -and $firstTime) {
			# pop up for more than 1 vulscans running
			$countBox = New-Object -ComObject wscript.shell
			$countBox.popup("$server has $i vulscan.exes running.",0,"$server has $i vulscan.exes running",0) | Out-Null
			$firstTime = $false
		}
		
	} while ($i -gt 0)
	   

	$doneBox = New-Object -ComObject wscript.shell
	[console]::Beep(2000,1000)
	$doneBox.popup("$server patching is complete.",0,"$server patching is complete",0) | Out-Null
	
}

#(TESTING)Used for pulling data from up to csv file with ServerNow records.
Function FuncServiceNowStatus ($server, $Path, $LogPath){
	#Filter the file to determine the age of the .csv before moving forward 
	#age of file in days
	$intFileAge = 10 
	#path to file 
	$strFilePath = $Path
	
	Filter Select-FileAge{
	param ($days)
		#exclude folders from result set 
		if ($_.PSisContainer){}
		#if the file is outside of the age range return an error 
		if ($_.LastWriteTime -lt (Get-Date).AddDays($days* -1)){
			write-output "NOTE: ServiceNow .csv file is old, "
		
		}
	
	}
	get-Childitem -recurse $strFilePath | Select-FileAge $intFileAge 
	
	#start the ServiceNow Status check on .csv file. 
	$hostListPath = $Path
	$hostList = Import-csv -Path $hostListPath
	
	#error check for the files availability 
	if ( $hostListPath -ne $null){
		$status = $hostList|where-object{$_.name -eq $server}
		$serverStatus = $status.'install status'
		
		#if the server does not have a status return not available 
		if ($serverStatus -ne $null){
			if ($serverStatus -eq "Disposed" -or $serverStatus -eq "Retired"){
				Add-Content -path "$LogPath/Logs/error_Lists/ServiceNow_Status_$date.txt" -value "$server - $serverStatus"
			
			}
			return, $serverStatus 
		
		}
		else{
			$serverStatus = "Not Available"
			Add-Content -path "$LogPath/Logs/error_Lists/ServiceNow_Status_$date.txt" -value "$server - $serverStatus"
			return, $serverStatus
		
		}
		
	}
	else{
		write-output "ServiceNow .csv file could not be imported"
	}

}

#(TESTING)Run Cleanup.bat file in order to clean C drive if noted that it does not have enough space. 
Function FuncRunScriptFile ($server,$scriptName,$credent){
	
	#create folder for script items 
	Invoke-Command -ComputerName $server -credential $credent {New-Item -Path "c:\script" -type directory}
	

	#import file to script folder within server in question 
	Import-Module bitstransfer
	$sourcePath = "$path/lib/Scripts/$scriptName"
	$destPath = "\\$server\C$\script\$scriptName"
	Start-BitsTransfer -Source $sourcePath -Destination $destPath -Credential $credent
	
	if (Test-Path "\\$server\C$\script\cleanup_rev.bat"){
		#Run script on given server. 
		Invoke-Command -ComputerName $server -ScriptBlock {C:\script\cleanup_rev.bat} -Credential $credent

	}
	else {
		write-output "cleanup script file could not be created and run on host server"
	
	}
}

#Run LanDesk script manually on server. 
Function FuncRunLanDesk ($server,$credent){
	
	#create folder for script items 
	Invoke-Command -ComputerName $server -credential $credent {New-Item -Path "c:\script" -type directory}
	

	#import file to script folder within server in question 
	Import-Module bitstransfer
	$sourcePath = "$path/lib/Scripts/CurrentPatchx64.cmd"
	$destPath = "\\$server\C$\script\CurrentPatchx64.cmd"
	Start-BitsTransfer -Source $sourcePath -Destination $destPath -Credential $credent
	
	if (Test-Path "\\$server\C$\script\CurrentPatchx64.cmd"){
		#Run script on given server. 
		Invoke-Command -ComputerName $server -ScriptBlock {C:\script\CurrentPatchx64.cmd} -Credential $credent
		FuncVulScanDone -server $server

		
	}
	else {
		write-output "LanDesk script file could not be created and run on host server"
	
	}
	
}

#Use regular expressions to verify whether the server is a DC 
Function FuncCheckDC ($server){
	$dcMatch = $server | Select-String '(DC)+[0-9]{1,10}'
	
	if ($dcMatch -ne $Null){
		$DC = "Detected" 
		$Server | Add-Content "$path/Logs/error_Lists/DC_Detected_$date.txt"
		return ,$DC
	
	}
	else {
		$DC = "Not Detected"
		$global:DC = "pass"
		return ,$DC
	
	}

} 

#Check the Windows Update Service and (if not set correctly)attempt to set it to automatic/running. 
Function FuncWinUPCheckService ($Server, $Credent){
	#Create variable used with invoke command 
		$arrService = Invoke-Command -ComputerName $Server -Credential $Credent {Get-Service -name wuauserv}
	
	#check to see if the service is running. 
	if ($arrService.Status -eq $null){
		$WUpdate = "Fail"
		return, $WUpdate	
	}
	if ($arrService.Status -ne "Running" -and $count -lt 1){
		$count++ 
		Invoke-Command -ComputerName $Server -Credential $Credent {Get-Service -Name wuauserv | Set-Service -Status Running -StartupType Automatic}
		FuncWinUPCheckService -Server $Server -Credent $Credent 
		
	}
	
	if ($arrService.Status -ne "Running" -and $count -gt 1){
		$WUpdate = "Failed"
		$Server | Add-Content "$path/Logs/error_Lists/WindowsUpdate_Service_Fail_$date.txt"
		return, $WUpdate
	
	}

	if ($arrService.Status -eq "Running") {
		$count = 0
		$WUpdate = "Pass"
		$global:WinUpPass = "Pass"
		return, $WUpdate
	}
	
}

#Check for an application and its version currently installed 
Function FuncApplicationVersion ($Server, $AppName, $Version, $Credent){
	$arrService = gwmi win32_product -computer $server -filter "name LIKE '%$AppName%'" -Credential $Credent
	$installedVersion = $arrService.version
	
	if ($arrService.version -eq $null){
		$AVersion = "Not Installed"
		return ,$AVersion
	}
	if ($arrService.version -lt $Version){
		$AVersion = $arrService.version 
		Add-Content -path "$path/Logs/error_Lists/LanDesk_Fail_$date.txt" -value "$server - $installedVersion"
		return ,$AVersion
	} 
	else {
		$AVersion = $arrService.version 
		$global:AppVersionPass = "Pass"
		return ,$AVersion
		
	}

}

#Verify drive space on server. If the drive space is less than required run cleanup script. 
Function FuncCheckDriveSpace ($Server, $driveSpace, $Credent){
	
	#create static variables for function 
	$diskStats = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='c:'" -ComputerName $Server -Credential $Credent -Authentication 6
	if ($diskStats -eq $null)
	{
		$DSpace = "Server Failed"
		return ,$DSpace
	}
	else{
		$fs = $diskStats.FreeSpace / 1024 / 1024 
		
		#check if the disk space is less than 800MB 
		if ($fs  -lt $driveSpace){
			FuncRunScriptFile -server $server -scriptName "cleanup_rev.bat" -credent $Credent
			
			#Recheck status of drive after running cleanup script. 
			$diskStats = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='c:'" -ComputerName $Server -Credential $Credent -Authentication 6
			$fs = $diskStats.FreeSpace / 1024 / 1024 
			
			if ($fs  -lt $driveSpace){
				$space = $diskStats.FreeSpace / 1024 / 1024 / 1024 
				$space = [Math]::Round($space,1)
				$DSpace = "Fail " + $space + "GB"
				$Server | Add-Content "$path/Logs/error_Lists/CDrive_Fail_$date.txt"
				return ,$DSpace
			}

			else{
				$space = $diskStats.FreeSpace / 1024 / 1024 / 1024 
				$space = [Math]::Round($space,1)
				$DSpace = "Pass " + $space + "GB"
				$global:DriveSpacePass = "Pass"
				return ,$DSpace 
			}
			
		} 
		else {
			$space = $diskStats.FreeSpace / 1024 / 1024 / 1024 
			$space = [Math]::Round($space,1)
			$DSpace = "Pass " + $space + "GB"
			$global:DriveSpacePass = "Pass"
			return ,$DSpace 
		}
	}
}


#TO DO -----------------------------------------------------------
#(DONE)Check version of current lib against version of lib stored in IISScripting folder. 
#(DONE)Add function that does both user password and user name functionality.
#(DONE)Import remaining functions from PatchFix script.  