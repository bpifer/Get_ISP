[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
 
$api_key = '838c4cb10811057d2b3fdaca59aadd28651f53de'
$endpoint = 'https://n118.meraki.com/api/v0/organizations/523581/inventory/'

 $header = @{
        
        "X-Cisco-Meraki-API-Key" = $api_key
        "Content-Type"           = 'application/json'
        
    }

$store=Read-Host "Enter Store Number"
 
$request = Invoke-RestMethod -Method GET -Uri $endpoint -Headers $header
$ip = ($request | Where-Object {($_.Model -like '*MX*'-and $_.name -like "*$store*")}).publicIP

$page = Invoke-RestMethod -URI "http://ip-api.com/json/$ip"
Write-host $page.isp
Sleep 20