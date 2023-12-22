#Function used to Transfer .csv files from servers to a log file on IISWEB\#IISScripting share. 
Function funcTransferFiles ($servers){
	foreach ($server in $servers) {
		if (Test-Path "\\$server\c$\Temp\WebSiteProperties.csv"){
			#get it from the network share. 
			$sourcePath = "\\$server\c$\Temp\WebSiteProperties.csv" 
			#place it on our computer. 
			$fileName = $server + '_WebSiteProperties.csv'
			$destPath = "\\oh0co010\IISWEB\#IISScripting\IISSiteChecker\Logs\Temp\$fileName"

			#start that transfer.
			Copy-Item -Path $sourcePath -Destination $destPath -force
		
		
		}
		else{
			write-host "$server is missing its expected WebSiteProperties.csv"
		
		}
	}
}

#Merge-CSVFiles -CSVFiles C:\temp\file1.csv,C:\temp\file2.csv -OutputFile c:\temp\output.csv
function funcMergeCSVFiles { 
[cmdletbinding()] 
param( 
    [string[]]$CSVFiles, 
    [string]$OutputFile,
	[string]$server
) 
$Output = @(); 

$date = (Get-Date).ToString('MMddyyyy')
$OutputFile = "\\oh0co010\IISWEB\#IISScripting\IISSiteChecker\Logs\WebSiteProperties_$server.csv" 
$CSVFiles = Get-ChildItem -Path '\\oh0co010\IISWEB\#IISScripting\IISSiteChecker\Logs\Temp' -Name '$server_WebSiteProperties.csv'

foreach($CSV in $CSVFiles) { 
    if(Test-Path ('\\oh0co010\IISWEB\#IISScripting\IISSiteChecker\Logs\Temp\' +$CSV)) { 
        
		$CSV = '\\oh0co010\IISWEB\#IISScripting\IISSiteChecker\Logs\Temp\' +$CSV
        $FileName = [System.IO.Path]::GetFileName($CSV) 
        $temp = Import-CSV -Path $CSV | select *, @{Expression={$FileName};Label="FileName"} 
        $Output += $temp 
 
    } else { 
        Write-Warning "$CSV : No such file found" 
    } 
 
} 
$Output | Export-Csv -Path $OutputFile -NoTypeInformation 
Write-Output "$OutputFile successfully created" 
 
} 

#Function used to grab the site properties from each site on a selected server. 
Function funcGetServerWebsites ($server) {
	Import-Module WebAdministration
	Remove-Item "C:\temp\WebSiteProperties.csv"
	$Websites = Get-ChildItem IIS:\Sites
	$date = (Get-Date).ToString('MMddyyyy')
	$hostname = $env:computername
	foreach ($Site in $Websites) {

		$Binding = $Site.bindings
		[string]$BindingInfo = $Binding.Collection
		[string[]]$Bindings = $BindingInfo.Split(" ")#[0]
		$i = 0
		$status = $site.state
		$path = $site.PhysicalPath
		$fullName = $site.name
		$state = ($site.name -split "-")[0]
		$Collection = ($site.name -split "-")[1]
		$anon = get-WebConfigurationProperty -Filter /system.webServer/security/authentication/AnonymousAuthentication -Name Enabled -PSPath IIS:\sites -Location $site.name | select-object Value
		$basic = get-WebConfigurationProperty -Filter /system.webServer/security/authentication/BasicAuthentication -Name Enabled -PSPath IIS:\ -location $site.name | select-object Value
		$win = get-WebConfigurationProperty -Filter /system.webServer/security/authentication/WindowsAuthentication -Name Enabled -PSPath IIS:\ -location $site.name | select-object Value
		
		#set sitename so we can pull the correct application pool 
		$name = $site.name 
		
		#put application pool information in a variable so we can pull what we are after. 
		try{
			$applicationPool = Get-ItemProperty IIS:\AppPools\$name 
		}
		catch{
			write-host "Application Pool does not exist for $name"
		}
		
		Do{
			if( $Bindings[($i)] -notlike "sslFlags=*"){
				[string[]]$Bindings2 = $Bindings[($i+1)].Split(":")
				$obj = New-Object PSObject
				$obj | Add-Member Date $Date
				$obj | Add-Member Host $server
				$obj | Add-Member State $state
				$obj | Add-Member Collection $Collection
				$obj | Add-Member SiteName $Site.name
				$obj | Add-Member SiteID $site.id
				$obj | Add-member Path $site.physicalPath
				$obj | Add-Member Protocol $Bindings[($i)]
				$obj | Add-Member Port $Bindings2[1]
				$obj | Add-Member Header $Bindings2[2]
				$obj | Add-member AuthAnon $Anon.value
				$obj | Add-member AuthBasic $basic.value
				$obj | Add-member AuthWin $win.value
				$obj | Add-member Status $status
				$obj | Add-member runTime $applicationPool.managedRuntimeVersion
				$obj | Add-member PipeLineMode $applicationPool.managedPipelineMode
				$obj | Add-member bitEnabled $applicationPool.enable32BitAppOnWin64
				$obj | export-csv "C:\temp\WebSiteProperties.csv" -Append -notypeinformation
				$i=$i+2
			}
			else{$i=$i+1}
		} while ($i -lt ($bindings.count))		
	}
}

Function funcSendEmail {
	$date = (Get-Date).ToString('MMddyyyy')

	#SEND EMAIL 
	$emailFrom = "middleware-iis@aep.com"
	$emailTo = "middleware-iis@aep.com"
	$subject = 'IIS Server Farm Website Properties Spreadsheet' 
	$body = 'sent from server vmaephqft200 on : ' + $date
	$emailSmtpServer = "mailmta.aepsc.com"
	$attachment = "\\oh0co010\IISWEB\#IISScripting\IISSiteChecker\Logs\WebSiteProperties_$date.csv"
	Send-MailMessage -To $emailTo -From $emailFrom -Subject $Subject -attachment $attachment -Body $Body -BodyAsHTML -SmtpServer $emailSmtpServer
	
}

##MAIN----------------------------------------------------------------------------

#Attempt to run powershell permissions as administrator, warn if you don't have permissions
If (-NoT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do Not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}
#Set variables for main function
$ServerListFile = "ServerList.txt" 

#Remove trailing whitespace and blank lines from list of servers
(gc ServerList.txt) | Foreach {$_.TrimEnd()} | where {$_ -ne ""} | Set-Content ServerList.txt
$ServerList = Get-Content $ServerListFile -ErrorAction SilentlyContinue   
$Result = @()

#silence all error messages; Remove this in order to do error checking on script 
$ErrorActionPreference = "SilentlyContinue"

#get our credentials 
$cred = Get-credential
if ((Get-Content ServerList.txt) -eq $Null){
	$server = read-host "Please enter the computer to test" 
	Invoke-Command -ComputerName $server -credential $cred -ScriptBlock ${function:funcGetServerWebsites} -ArgumentList $server
	funcTransferFiles -servers $server
	funcMergeCSVFiles -server $server 
}
else {
	$server = $serverList
	foreach ($s in $server){
		Invoke-Command -ComputerName $s -ScriptBlock ${function:funcGetServerWebsites} -ArgumentList $s
	}
	funcTransferFiles -servers $server
	funcMergeCSVFiles function
	funcSendEmail function

}