using module '.\avvDNSProvider.ps1'

#using module "D:\tools\selectel.dns-hosting\classes\avvDNSSelectel.ps1"
#. .\avvDNSProvider.ps1

class avvDNSSelectel : avvDNSProvider
{

    avvDNSSelectel() : base() {
        $this.Methods.Add('GetDomains', '')
        $this.Methods.Add('GetRecords', '')
    }

    static [Hashtable] GetDomains([Hashtable]$Arguments)
    {
        $res=@{
            'Error'=(New-Object PSObject)
            'ErrorCode'=0
        }
        try{
            $raw=Invoke-WebRequest -Method Get -Headers @{"X-Token"="$($Arguments.token)";"Content-Type"="application/json"} "https://api.selectel.ru/domains/v1/";
            $arrC=ConvertFrom-Json $raw.content;
            $result = ($arrC|Sort-Object -Property name|Format-Table)

            $res.add('raw', $raw)
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

    static [Hashtable] GetRecords([Hashtable]$Arguments)
    {
        $res=@{
            'Error'=(New-Object PSObject)
            'ErrorCode'=0
        }
        try
        {
            $raw = Invoke-WebRequest -Method Get -Headers @{ 'X-Token' = "$( $Arguments.token )"; 'Content-Type' = 'application/json' } "https://api.selectel.ru/domains/v1/$( $Arguments.domain )/records";
            $arrC = ConvertFrom-Json $raw.content;
            $result = ($arrC|Sort-Object -Property name|Format-Table)

            $res.add('raw', $raw)
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
    #avvDNSSelectel
}