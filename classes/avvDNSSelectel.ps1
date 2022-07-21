using module '.\avvDNSProvider.ps1'

#using module "D:\tools\selectel.dns-hosting\classes\avvDNSSelectel.ps1"
#. .\avvDNSProvider.ps1

class avvDNSSelectel : avvDNSProvider
{
    [String]$BaseUri="https://api.selectel.ru/domains/v1"

    avvDNSSelectel() : base() {
        $this.Methods.Add('GetDomains', '')
        $this.Methods.Add('GetRecords', '')
        $this.Methods.Add('gd', 'GetDomains')
        $this.Methods.Add('gr', 'GetRecords')
    }

    [Hashtable] GetDomains([Hashtable]$Arguments)
    {
        $res=@{
            'Error'=(New-Object PSObject)
            'ErrorCode'=0
        }
        try{
            $raw=Invoke-WebRequest -Method Get -Headers @{"X-Token"="$($Arguments.token)";"Content-Type"="application/json"} "$($this.BaseUri)";
            $arrC=ConvertFrom-Json $raw.content;
            $result = ($arrC|Sort-Object -Property name|Format-Table)

            $res.add('raw', $raw)
            $res.add('resarr', $arrC)
            $res.add('result', $result)
            if ($raw.StatusCode -ne 200)
            {
                $res.ErrorCode=22 # StatusCode из ответа на http запроса <> 200
            }
        }
        catch
        {
            $res.ErrorCode=21 # Exception http запроса
            $res.Error=$PSItem
        }
        return $res
    }

    [Hashtable] GetRecords([Hashtable]$Arguments)
    {
        $res=@{
            'Error'=(New-Object PSObject)
            'ErrorCode'=0
        }
        try
        {
            $raw = Invoke-WebRequest -Method Get -Headers @{ 'X-Token' = "$( $Arguments.token )"; 'Content-Type' = 'application/json' } "$($this.BaseUri)/$($Arguments.domain)/records";
            $arrC = ConvertFrom-Json $raw.content;
            $result = ($arrC|Sort-Object -Property name|Format-Table)

            $res.add('raw', $raw)
            $res.add('resarr', $arrC)
            $res.add('result', $result)
            if ($raw.StatusCode -ne 200)
            {
                $res.ErrorCode=22 # StatusCode из ответа на http запроса <> 200
            }
        }
        catch
        {
            $res.ErrorCode=21 # Exception http запроса
            $res.Error=$PSItem
        }
        return $res
    }
}