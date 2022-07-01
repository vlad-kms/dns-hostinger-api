using module '.\avvDNSProvider.ps1'

#using module "D:\tools\selectel.dns-hosting\classes\avvDNSSelectel.ps1"
#. .\avvDNSProvider.ps1

class avvDNSMydns : avvDNSProvider
{
    [Hashtable]hidden $Methods=@{
        'gd'='GetDomains'
        'gr'='GetRecords'
    }
    [String]$BaseUri="https://api.selectel.ru/domains/v1"

    #static [Microsoft.PowerShell.Commands.WebResponseObject] Request([Hashtable]$Data)
    [Hashtable] Request([Hashtable]$Data)
    {
        $res=@{}
        try
        {
            $res=([avvDNSProvider]$this).Request($Data)
            $arrC=ConvertFrom-Json $res.raw.content;
            $result = ($arrC|Sort-Object -Property name|Format-Table)

            $res.add('result', $result)
            if ($res.raw.StatusCode -ne 200)
            {
                $res.ErrorCode=22 # StatusCode из ответа на http запроса <> 200
                $res.ErrorMsg="Код ответа на запрос $($Data.Uri) равен $($res.raw.StatusCode)" # StatusCode из ответа на http запроса <> 200
                #throw $res.ErrorMsg
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

    [Hashtable] GetDomains([Hashtable]$Arguments)
    {
        $res=$this.Request(@{
            'Method'='Get'
            'Headers'=@{"X-Token"="$($Arguments.token)";"Content-Type"="application/json"}
            'Uri'="$($this.BaseUri)"
        })
        return $res
    }

    [Hashtable] GetRecords([Hashtable]$Arguments)
    {
        $res=$this.Request(@{
            'Method'='Get'
            'Headers'=@{"X-Token"="$($Arguments.token)";"Content-Type"="application/json"}
            'Uri'="$($this.BaseUri)/$( $Arguments.domain )/records"
        })
        return $res
    }
}
