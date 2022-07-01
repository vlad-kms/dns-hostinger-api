#using module 'C:\Program Files\WindowsPowerShell\Modules\avvClasses\classes\classCFG.ps1';

[CmdletBinding(DefaultParameterSetName='GroupToken')]
Param (
    [Parameter(ValueFromPipeline=$True, Position=0)]
    [string] $Action='getDomains',
    #[ValidateSet('selectel', 'mydns')]
    $Provider='selectel',
    [string] $Domain='mrovo.ru',
    [hashtable] $ExtParams=@{},
    [Parameter(ParameterSetName='GroupUser')]
    [string] $User,
    [Parameter(ParameterSetName='GroupUser')]
    [string] $Password,
    [Parameter(ParameterSetName='GroupToken')]
    [string] $Token=''
)

#. "C:\Program Files\WindowsPowerShell\Modules\avvClasses\classes\classCFG.ps1"
. "D:\tools\PSModules\avvClasses\classes\classCFG.ps1"
<# классы для работы с DNS #>
. ".\classes\avvDNSBase.ps1"

function Param2Splah {
    $result = [ordered]@{
        action = $Action;
        provider = $Provider;
        domain = $Domain;
        token = $ini.GetString('dns_cli', 'Token');
        user = $User;
        password = $Password;
        debug = $Debug;
        extParams = $ExtParams;
    }
    $result.extParams.token1c=$ini.GetString('dns_cli', 'Token1c');
    return $result
}

$Debug = ($PSBoundParameters.Debug -eq $True)

Write-Host "================================================"
#$PSBoundParameters
$ps = Split-Path $psCommandPath -Parent
$fileIni="$($psCommandPath).ini"

if ($Debug)
{
    $global:ini=[IniCFG]::new($fileIni)
    $global:par=Param2Splah
    $global:dnsWorker=[avvDNSBase]::new($par)
} else
{
    $ini=[IniCFG]::new($fileIni)
    $par=Param2Splah
    $dnsWorker=[avvDNSBase]::new($par)
}
if ($Debug) {
    Write-Host "Текущий каталог: $($ps)"
    Write-Host "par: ---------------------------"
    Write-Host ($par | Format-Table | Out-String)
    Write-Host "ini: ---------------------------"
    Write-Host ($ini | Format-Table | Out-String)
    Write-Host "dnsWorker: ---------------------------"
    Write-Host ($dnsWorker | Format-Table | Out-String)
}

Write-Host "================================================"

if ($Action -ne '_test_')
{
    $result = $dnsWorker.MethodDispath($Action)
}
else
{
    $par.ExtParams
}
$result

exit 0

<#
Invoke-WebRequest -uri "https://api.selectel.ru/domains/v1/791376/records/11357134" -Body (@{"content"="192.168.11.1";"name"="qw1.mrovo.ru";"ttl"="600";"type"="A" }| ConvertTo-Json) -Headers @{"X-Token"="<KEY API TELEGRAM>"; "Content-Type"="application/json"} -Method put
Invoke-WebRequest "https://api.selectel.ru/domains/v1/791376/records/11357134" -Body (@{"content"="192.168.11.1";"name"="qw1.mrovo.ru";"ttl"="600";"type"="A" }| ConvertTo-Json) -Headers @{"X-Token"="<KEY API TELEGRAM>"; "Content-Type"="application/json"}
Invoke-WebRequest -uri https://api.selectel.ru/domains/v1/791376/records/11357134 -Body (@{"content": "192.168.11.1", "name": "qw1.mrovo.ru", "ttl": 600, "type": "A" }| ConvertTo-Json) -Headers @{"X-Token"="<KEY API TELEGRAM>"; "Content-Type"="application/json"} -ContentType "application/json"

$t='avvDNSBase';$c1=New-Object -TypeName $($t) -ArgumentList 'selectel';$c1

#>
