#using module 'C:\Program Files\WindowsPowerShell\Modules\avvClasses\classes\classCFG.ps1';

[CmdletBinding(DefaultParameterSetName='GroupToken')]
Param (
    [Parameter(ValueFromPipeline=$True, Position=0)]
    [string] $Action='getDomains',
    [ValidateSet('selectel', 'mydns')]
    $Provider='selectel',
    [string] $Domain='mrovo.ru',
    [string] $Record='',
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
        idDomain = $IdDomain
        token = $ini.GetString('dns_cli', 'Token');
        user = $User;
        password = $Password;
        debug = $Debug;
    }
    return $result
}

function Get-DomainsList {
    Param (
        [Parameter(ValueFromPipeline=$True, Position=0)]
        [hashtable]$params
    )
    try {
        switch ($params.provider) {
            selectel {
                $c=Invoke-WebRequest -Method Get -Headers @{"X-Token"="$($params.Token)";"Content-Type"="application/json"} "https://api.selectel.ru/domains/v1/";
                $arrC=ConvertFrom-Json $c.content;
                $result = ($arrC|Sort-Object -Property name|ft)
            }
            default {$result = "Not supported provider"}
        }
    } catch {
        $result = "Error read domains"
    }
    return $result
}

function Get-RecordsList {
    Param (
        [Parameter(ValueFromPipeline=$True, Position=0)]
        [hashtable]$params
    )
    try {
        #$dompar=Get-DomainParam -params $params
        switch ($params.provider) {
            selectel {
                #$c=Invoke-WebRequest -Method Get -Headers @{"X-Token"="$($params.Token)";"Content-Type"="application/json"} "https://api.selectel.ru/domains/v1/$($dompar)/records";
                $c=Invoke-WebRequest -Method Get -Headers @{"X-Token"="$($params.Token)";"Content-Type"="application/json"} "https://api.selectel.ru/domains/v1/$($domain)/records";
                $arrC=ConvertFrom-Json $c.content;
                $result = ($arrC|Sort-Object -Property name|ft)
            }
            default {$result = ""}
        }
    } catch {
        $result = "Error read records domain $($params.Domain)"
    }
    return $result
}

$Debug = ($PSBoundParameters.Debug -eq $True)

echo "================================================"
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
    echo "Текущий каталог: $($ps)"
    echo "par: ---------------------------"
    $par
    echo "ini: ---------------------------"
    $ini
    echo "dnsWorker: ---------------------------"
    $dnsWorker
}
<#
$result = switch ($Action) {
    'domainsList' {Get-DomainsList $par;}
    'recordsList' {Get-RecordsList $par;}
    'recordAdd' {echo $($par);}
    default {Write-Host "Invalid action specified" -ForegroundColor Red}
}
#>
echo "================================================"

$result = $dnsWorker.MethodDispath($Action)

$result

echo "================================================"
exit 0

<#
Invoke-WebRequest -uri "https://api.selectel.ru/domains/v1/791376/records/11357134" -Body (@{"content"="192.168.11.1";"name"="qw1.mrovo.ru";"ttl"="600";"type"="A" }| ConvertTo-Json) -Headers @{"X-Token"="<KEY API TELEGRAM>"; "Content-Type"="application/json"} -Method put
Invoke-WebRequest "https://api.selectel.ru/domains/v1/791376/records/11357134" -Body (@{"content"="192.168.11.1";"name"="qw1.mrovo.ru";"ttl"="600";"type"="A" }| ConvertTo-Json) -Headers @{"X-Token"="<KEY API TELEGRAM>"; "Content-Type"="application/json"}
Invoke-WebRequest -uri https://api.selectel.ru/domains/v1/791376/records/11357134 -Body (@{"content": "192.168.11.1", "name": "qw1.mrovo.ru", "ttl": 600, "type": "A" }| ConvertTo-Json) -Headers @{"X-Token"="<KEY API TELEGRAM>"; "Content-Type"="application/json"} -ContentType "application/json"

$t='avvDNSBase';$c1=New-Object -TypeName $($t) -ArgumentList 'selectel';$c1

#>
