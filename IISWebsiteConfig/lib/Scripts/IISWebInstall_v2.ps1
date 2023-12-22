$script = {
    $strName = "mytest"
    $strUsr=   "testuser"
    $strPass = "testPass"
    $strPath = "D:\WebContent\"
    $strNewURL = "mytest-dev.com"
	
	Import-Module WebAdministration
	Import-Module ServerManager
	
	#Create App Pool
	New-WebAppPool -Name $strName -force
    #Set-ItemProperty ($strPath + $strName) -name processModel.identityType -value 3
    #Set-ItemProperty ($strPath + $strName) -name processModel.username -value $strUsr
    #Set-ItemProperty ($strPath + $strName) -name processModel.password -value $strPass
       
    #Create Web Site
	
    New-Website –Name $strName –Port '80' –HostHeader $strNewURL –PhysicalPath $strPath -ApplicationPool $strName
    #Set-ItemProperty ($strPath + $strName) -name applicationPool -value $strName
    #Set-ItemProperty ($strPath + $strName) -name ApplicationDefaults.applicationPool -value $strName
    #Set-ItemProperty ($strPath + $strName) -name ..username -value $strUsr
    #Set-ItemProperty ($strPath + $strName) -name ..password -value $strPass
	
       
}

#Here's how you execute it with remoting
#Invoke-Command -ComputerName "tsvmaephqws006" -ScriptBlock $script
$cred = Get-Credential
$session = new-PsSession "tsvmaephqws006" -Credential $cred
enter-PsSession $session
$session
write-output "test2"
Invoke-Command -Session $session -ScriptBlock{$script}
write-output "test3"
get-pssession | remove-pssession