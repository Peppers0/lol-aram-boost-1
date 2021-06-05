
$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.size(33,14)

Write-Output "Welcome, please select:`n`n"

$process = "LeagueClientUx.exe"

$arguments = Get-WmiObject Win32_Process -Filter "name = '$process'" | Select-Object CommandLine
 
$arguments -match 'remoting-auth-token=([Ia-zA-Z0-9_-]*)' > $null
$token= $matches[1] 

$arguments -match '--app-port=([0-9]*)' > $null
$port= $matches[1]


$url= "/lol-lobby/v2/lobby"
$auth =  [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("riot:" + $token))
$baseurl = "https://127.0.0.1:" + $port 
$params = @{
 "queueId"="450";
}
$Headers = @{
    Authorization = "Basic " + $auth;
    "Content-Type" = "application/json";
}
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$menu = "1-Team Boost(only works in champion select)`n`n`n`3-Restart`n4-Exit`n`n" + 'Select'

while($true)
{
    $secim = Read-Host -Prompt $menu  
    cls
    switch ( $secim){        
       1{
            $URI = $baseurl  + '/lol-login/v1/session/invoke?destination=lcdsServiceProxy&method=call&args=["","teambuilder-draft","activateBattleBoostV1",""]'
            Invoke-WebRequest -UseBasicParsing -URI $URI  -Method "POST" -Headers $Headers -Body ($params|ConvertTo-Json) > $null
            "Successfully unlocked team boost.(hopefully :p)`n"     
        }
        3{
            "this doesnt work for now :( please restart script by hand."
        }
        4 {"farewell.";exit}
    }
}

