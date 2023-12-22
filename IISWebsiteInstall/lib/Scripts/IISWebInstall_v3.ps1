#enter session to run commands. 
$cred = Get-Credential
$session = new-PsSession $server -Credential $cred
enter-PsSession $session

#get preliminary information. 
$server = read-host "please enter computer to install website"
$siteName = read-host "please enter siteName"

#add modules needed to run tasks. 
Invoke-Command -Session $session -Command{Import-Module WebAdministration}
Invoke-Command -Session $session -Command{Import-Module ServerManager}

#create AppPool 
Invoke-Command -Session $session -Command{New-WebAppPool -Name $siteName -force}

#create directory for WebSite
Invoke-Command -Session $session -Command{New-Item -type directory -path "d:\webcontent\$siteName" -force}

#create Site
Invoke-Command -Session $session -Command{New-Website -Name $siteName -Port 80 -PhysicalPath "d:\webcontent\$siteName" -ApplicationPool $siteName}

get-pssession | remove-pssession




