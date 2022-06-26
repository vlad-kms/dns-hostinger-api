#using module 'C:\Program Files\WindowsPowerShell\Modules\avvClasses\classes\classCFG.ps1';

[CmdletBinding(DefaultParameterSetName='GroupToken')]
Param (
    [Parameter(ValueFromPipeline=$True, Position=0)]
    [ValidateSet('domainsList', 'recordsList')]
    [string] $Action='domainList',
    [ValidateSet('selectel', 'mydns')]
    $Provider='selectel',
    [string] $Domain='mrovo.ru',
    [Parameter(ParameterSetName='GroupUser')]
    [string] $User,
    [Parameter(ParameterSetName='GroupUser')]
    [string] $Password,
    [Parameter(ParameterSetName='GroupToken')]
    [string] $Token=''
)

. "C:\Program Files\WindowsPowerShell\Modules\avvClasses\classes\classCFG.ps1"

function Param2Splah {
    $result = @{
        Action = $Action;
        Provider = $Provider;
        Domain = $Domain;
        IdDomain = $IdDomain
        Token = $ini.GetString('dns_cli', 'Token');
        User = $User;
        Password = $Password;
        Debug = $Debug;
    }
    return $result
}

function Get-DomainsList {
    Param (
        [Parameter(ValueFromPipeline=$True, Position=0)]
        [hashtable]$params
    )
    try {
        switch ($params.Provider) {
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
        switch ($params.Provider) {
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

#$PSBoundParameters
$ps = Split-Path $psCommandPath -Parent
$fileIni="$($psCommandPath).ini"
$global:ini=[IniCFG]::new($fileIni)

echo "================================================"
$Debug = ($PSBoundParameters.Debug -eq $True)
$global:par=Param2Splah
if ($Debug) {
    $par
    $ini
}
#$par
#@PSBoundParameters
#$PSBoundParameters

$result = switch ($Action) {
    'domainsList' {Get-DomainsList $par;}
    'recordsList' {Get-RecordsList $par;}
    default {Write-Host "Неверно указано действие" -ForegroundColor Red}
}

echo $result

exit 0

# все домены
$c=Invoke-WebRequest -Method Get -Headers @{"X-Token"="$token";"Content-Type"="application/json"} "https://api.selectel.ru/domains/v1/";$arrC=ConvertFrom-Json $c.content;$arrC|Sort-Object -Property name|ft
# все записи домена
$c=Invoke-WebRequest -Method Get -Headers @{"X-Token"="$token";"Content-Type"="application/json"} "https://api.selectel.ru/domains/v1/$domain/records";$arrC=ConvertFrom-Json $c.content;$arrC|Sort-Object -Property name|ft

