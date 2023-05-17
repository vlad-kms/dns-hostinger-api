Param (
    [Parameter(ValueFromPipeline=$True, Position=0, Mandatory=$True)]
    [string] $FileIni
)

function RecordOfName([string]$Name, [Hashtable]$recordsHash)
{
    $result = @();
    if ($recordsHash.Keys -like $Name)
    {
        $result = $recordsHash[$Name]
    };
    return [array]$result;
}

function resolveCNAME([string]$Name, [Hashtable]$recordsHash)
{
    <#
    Param (
        [Parameter(ValueFromPipeline=$True, Position=0, Mandatory=$True)]
        [string] $FileIni
    )
    #>
    $result = @();
    $recordsArray = @();
    $recordsArray += (RecordOfName -Name $Name -recordsHash $recordsHash);
    $result += $recordsArray;
    $recordsArray.foreach({
        if ($_.type.ToUpper() -eq 'CNAME')
        {
            <## взять recordDNS.content, найти запись DNS для этого значения
            #   занести в результат эту запись
            #   повторять пока тип CNAME и нашли эту запись
            #>
            $result += resolveCNAME -Name $_.content -recordsHash $recordsHash;
        }
    })
    return $result;
}

## получить список всех доменов от SELECTEL
$listDomains = ( .\dns-cli.ps1 -FileIni $FileIni -Provider 'selectel' -Action 'getDomains' -ExtParams @{'classDebug'=1;} );
## получить для каждого домена все ресурсные записи
$hashDomains = @{};
$hashRecords = @{};
$hashCname = @{};
$listDomains.response.resarr.foreach({
    $hashDomain = ($_ | ConvertJSONToHash);
    $records = ( .\dns-cli.ps1 -FileIni $FileIni -Provider 'selectel' -Action 'getRecords' -ExtParams @{'classDebug'=1; 'domainId'=$_.Name;} );
    $hashDomain.add('records', $records.response.resarr);
    $hashDomains.add($_.Name, $hashDomain);

    foreach ($record in $records.response.resarr)
    {
        if  ( ($record.type.ToUpper() -eq 'CNAME') `
                -or ($record.type.ToUpper() -eq 'A') `
                -or ($record.type.ToUpper() -eq 'AAAA')# -or $True
            )
        {
            <#
            $recordHash = ($record | ConvertJSONToHash);
            $recordHash.add( 'domain', $_.Name);
            $recordHash.add( 'processedAlready', $False);
            #>
            <##>
            $recordHash = $record;
            $recordHash | Add-Member -MemberType NoteProperty -Name 'domain' -Value $_.Name;
            $recordHash | Add-Member -MemberType NoteProperty -Name 'processedAlready' -Value $False;
            #>
            if ($hashRecords.Contains($record.Name))
            {
                $hashRecords[$record.name] += $recordHash;
            }
            else
            {
                $hashRecords.add($record.name, @($recordHash));
            }
        }
    }
})

#$listdomains;
#$hashDomains
$hashCNAME = @{};
$result = @{};
$result.add('hashDomains', $hashDomains);
$result.add('hashRecords', $hashRecords);
foreach ($recordName in $hashRecords.Keys)
{
    if (
        ($hashRecords["$($recordName)"].type.ToUpper() -eq 'CNAME') -and
                (! $hashRecords["$($recordName)"].processAlready)
    )
    {
        #$hashRecords["$($recordName)"].processAlready = $True;
        $hashCNAME.add($recordName, (resolveCNAME -Name $recordName -recordsHash $hashRecords));
    }
}

$result.add('hashCNAME', $hashCname);

$badHashCNAME = @{};

$hashCname.Keys.ForEach({
    #$q=("E:\projects\my-configs\src\dns-hostinger\dns-cli.ps1.ini"  | .\examples\ex-002-check-all-CNAME.ps1); $q.hashCNAME.keys.ForEach({ $_; $q.hashCNAME.$_ |Format-Table });$q.hashCNAME.'ccc1.t.mrovo.ru'|format-table
    $a = $hashCname.$_;
    if ($a[$a.Count-1].type.ToUpper() -eq 'CNAME')
    {
        $badHashCNAME.add($_, $a);
    }
})
$result.add('badHashCNAME', $badHashCNAME);

$result