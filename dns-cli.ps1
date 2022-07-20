#using module 'C:\Program Files\WindowsPowerShell\Modules\avvClasses\classes\classCFG.ps1';

[CmdletBinding(DefaultParameterSetName='GroupToken')]
Param (
    [Parameter(ValueFromPipeline=$True, Position=0)]
    [string] $Action='getDomains',
    [string] $FileIni='',
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
    $ini.CFG['dns_cli'].Keys.foreach({
        if ( ! $result.extParams.Contains($_) ){
            $result.extParams[$_]=$ini.GetString('dns_cli', $_);
        }
    })
    #$result.extParams.token1c=$ini.GetString('dns_cli', 'Token1c');
    return $result
}

$isImportClasses = $false
try
{
    # попытка импорта модуля avvClasses
    Write-Host "Пробуем импорт модуля avvClasses."
    Import-Module -Name 'avvClasses' -Force -ErrorAction Stop
    $isImportClasses = $True
} catch {
    #Write-Host $PSItem
    Write-Host "Нет модуля avvClasses для импорта. Попробуем including файлов."
    $isImportClasses = $false
}

if (!$isImportClasses) {
    try
    {
        ### Подключение файлов с классами ############################################
        Write-Host "Пробуем including файлов."
        # class IniCFG
        $fileClass='classCFG.ps1'
        $pathModule="$Env:AVVPATHCLASSES"
        if (!(Test-Path -Path "$($pathModule)\$($fileClass)"))
        {
            $pathModule="$Env:ProgramFiles"
        }
        if (!(Test-Path -Path "$($pathModule)\$($fileClass)"))
        {
            throw "Нет требуемых файлов $($fileClass)"
        }
        $fileClass="$($pathModule)\$($fileClass)"
        # including file
        . "$fileClass"

        $isIncludeClassCFG=$true
    }
    catch
    {
        Write-Host "Не получился including файлов. Прервать выполнения скрипта."
        $isIncludeClassCFG=$false
        throw
    }
} ### if (!$isImportClasses) {

<# Подключаем классы для работы с DNS из текущего каталога запуска .\classes #>
. ".\classes\avvDNSBase.ps1"


$Debug = ($PSBoundParameters.Debug -eq $True)

Write-Host "================================================"
#$PSBoundParameters
if (!$FileIni)
{
    $ps = Split-Path $psCommandPath -Parent
    $FileIni = "$( $psCommandPath ).ini"
}

if ($Debug)
{
    if ($isImportClasses) {
        $global:ini = Get-IniCFG -Filename "$($fileIni)"
    }
    elseif ($isIncludeClassCFG)
    {
        $global:ini = [IniCFG]::new($fileIni)
    }
    $global:par=Param2Splah
    $global:dnsWorker=[avvDNSBase]::new($par)
} else
{
    if ($isImportClasses) {
        $ini = Get-IniCFG -Filename "$($fileIni)"
    }
    elseif ($isIncludeClassCFG)
    {
        $ini = [IniCFG]::new($fileIni)
    }
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
