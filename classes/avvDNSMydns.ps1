using module '.\avvDNSProvider.ps1'

#using module "D:\tools\selectel.dns-hosting\classes\avvDNSSelectel.ps1"
#. .\avvDNSProvider.ps1

class avvDNSMydns : avvDNSProvider
{
    [Hashtable]hidden $Methods=@{
        'gd'='GetDomains'
        'gr'='GetRecords'
    }

    #static [Microsoft.PowerShell.Commands.WebResponseObject] Request([Hashtable]$Data)
    static [Hashtable] Request([Hashtable]$Data)
    {
        $res=@{
            'Error'=(New-Object PSObject)
            'ErrorCode'=0
            'ErrorMsg'=''
        }
        try
        {
            $raw = Invoke-WebRequest @Data
            $arrC=ConvertFrom-Json $raw.content;
            $result = ($arrC|Sort-Object -Property name|Format-Table)

            $res.add('raw', $raw)
            $res.add('result', $result)
            if ($raw.StatusCode -ne 200)
            {
                $res.ErrorCode=22 # StatusCode из ответа на http запроса <> 200
                $res.ErrorMsg="Код ответа на запрос $($Data.Uri) равен $($raw.StatusCode)" # StatusCode из ответа на http запроса <> 200
                throw $res.ErrorMsg
            }
        }
        catch
        {
            $res.ErrorCode=21 # Exception http запроса
            $res.Error=$PSItem
            $res.ErrorMsg=$PSItem.Exception.Message
        }
        return $res
    }

    static [Hashtable] GetDomains([Hashtable]$Arguments)
    {
        $res=[avvDNSMydns]::Request(@{
            'Method'='Get'
            'Headers'=@{"X-Token"="$($Arguments.token)";"Content-Type"="application/json"}
            'Uri'="https://api.selectel.ru/domains/v1/"
        })
        return $res
    }

    static [Hashtable] GetRecords([Hashtable]$Arguments)
    {
        $res=[avvDNSMydns]::Request(@{
            'Method'='Get'
            'Headers'=@{"X-Token"="$($Arguments.token)";"Content-Type"="application/json"}
            'Uri'="https://api.selectel.ru/domains/v1/$( $Arguments.domain )/records"
        })
        return $res
    }
}