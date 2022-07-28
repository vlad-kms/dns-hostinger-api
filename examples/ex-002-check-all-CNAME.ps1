Param (
    [Parameter(ValueFromPipeline=$True, Position=0, Mandatory=$True)]
    [string] $FileIni
)

## получить список всех доменов от SELECTEL
$listDomains = ( .\dns-cli.ps1 -FileIni $FileIni -Provider 'selectel' -Action 'getDomains' -ExtParams @{'classDebug'=1;} );
## получить для каждого домена все ресурсные записи
$hashDomains=@{};
$listDomains.response.resarr.foreach({
    $hashDomain = ($_ | ConvertJSONToHash);
    $records = ( .\dns-cli.ps1 -FileIni $FileIni -Provider 'selectel' -Action 'getRecords' -ExtParams @{'classDebug'=1; 'domainId'=$_.Name;} );
    $hashDomain.add('records', $records.response.resarr);
    $hashDomains.add($_.Name, $hashDomain);
})

#$listdomains;
$hashDomains
