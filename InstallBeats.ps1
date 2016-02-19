Function Get-BeatsParams($filename, $ServerName, $CertName)
{
	(Get-Content $filename) | Foreach-Object {
		$out = $_ -replace "<SERVERNAME>",$ServerName 
		$out -replace "<CERTNAME>",$CertName;
	}
}

Function Uninstall-Service 
{
Param (
$ServiceName
)
	if (Get-Service $ServiceName -ErrorAction SilentlyContinue) {
	  $service = Get-WmiObject -Class Win32_Service -Filter "name='$ServiceName'"
	  $service.delete()
	}
}


Function Install-Service
{
Param (
$ServiceName,
$Command
)
Uninstall-Service -ServiceName  $ServiceName
# create new service
New-Service -name $ServiceName -displayName $ServiceName -binaryPathName $Command 
}

$ServerName = "elk.example.org:5044"
$CertName = 'C:\\Program Files\\Beats\\logstash-forwarder.crt'
$LibBeatConfig = Get-BeatsParams -FileName 'LibBeatConfig.yml' -ServerName $ServerName -CertName $CertName


Uninstall-Service -ServiceName "winlogbeat"
Uninstall-Service -ServiceName "topbeat"
Uninstall-Service -ServiceName "filebeat"

Stop-Service winlogbeat -ErrorAction SilentlyContinue
Stop-Service topbeat -ErrorAction SilentlyContinue
Remove-Item -Recurse -Confirm:$False 'C:\Program Files\Beats\' -ErrorAction SilentlyContinue

New-Item  -ItemType Directory -Path 'C:\Program Files\Beats\'
Copy-Item ".\logstash-forwarder.crt"  -Destination 'C:\Program Files\Beats\logstash-forwarder.crt'
Copy-Item -Recurse '.\topbeat-1.1.0-windows' -Destination 'C:\Program Files\Beats\topbeat'
Copy-Item -Recurse '.\winlogbeat-1.1.0-windows' -Destination 'C:\Program Files\Beats\winlogbeat'
Copy-Item -Recurse '.\filebeat-1.1.0-windows' -Destination 'C:\Program Files\Beats\filebeat'

Add-Content 'C:\Program Files\Beats\topbeat\topbeat.yml' $LibBeatConfig
Add-Content 'C:\Program Files\Beats\winlogbeat\winlogbeat.yml' $LibBeatConfig
Add-Content 'C:\Program Files\Beats\filebeat\filebeat.yml' $LibBeatConfig

Install-Service -ServiceName "winlogbeat" -Command '"C:\\Program Files\\Beats\\winlogbeat\\winlogbeat.exe" -c "C:\\Program Files\\Beats\\winlogbeat\\winlogbeat.yml"'
Install-Service -ServiceName "topbeat" -Command '"C:\\Program Files\\Beats\\topbeat\\topbeat.exe" -c "C:\\Program Files\\Beats\topbeat\\topbeat.yml"'

Start-Service winlogbeat
Start-Service topbeat