function CreateIISWebsite
{
 param (
        [string]$iisAppName,
        [string]$directoryPath,
		[string]$iisAppPoolDotNetVersion
        [string]$rhost,
        [string]$un,
        [string]$pw
    )

$MSDeployExe = "C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe"
Import-Module WebAdministration

#navigate to the app pools root
cd IIS:\AppPools\

#check if the app pool exists
if (Test-Path $iisAppName -pathType container)
{
    Remove-Item $iisAppName -recurse   
}

#create the app pool
$appPool = New-Item $iisAppName
$appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion

Set-ItemProperty IIS:\AppPools\$iisAppName managedRuntimeVersion $iisAppPoolDotNetVersion

Set-ItemProperty -Path IIS:\AppPools\$iisAppName -Name processmodel.identityType -Value 3
Set-ItemProperty -Path IIS:\AppPools\$iisAppName -Name processmodel.username -Value $un
Set-ItemProperty -Path IIS:\AppPools\$iisAppName -Name processmodel.password -Value $pw


#navigate to the sites root
cd IIS:\Sites\

#check if the site exists
if (Test-Path $iisAppName -pathType container)
{
	#DO SOMETHING HERE
}
else{
	#create the site
	$iisApp = New-Item $iisAppName -bindings @{protocol="http";bindingInformation=":80:" +     $iisAppName} -physicalPath $directoryPath
	$iisApp | Set-ItemProperty -Name "applicationPool" -Value $iisAppName
}
}
