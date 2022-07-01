class avvDNSProvider
{
    [Hashtable]hidden $Methods=@{
        'domainsList'='GetDomains'
        'recordsList'='GetRecords'
    }
    [String]$BaseUri=''
    <#
    [Hashtable]hidden $Methods=@{
        'domainsList'=@{'method'='GetDomains'; 'uri'=''}
        'recordsList'=@{'method'='GetRecords'; 'uri'=''}
    }
    #>

    [array] GetMethods()
    {
        return $this.Methods
    }

    [bool] MethodIsImplemented([string]$Method)
    {
        return $this.Methods.Contains($Method)
    }

    [String] GetImplementationMethod([String]$Method)
    {
        $res=''
        if ($this.Methods.Contains($Method))
        {
            $res=$this.Methods[$Method]
            if (!($res)) { $res=$Method }
        }
        return $res
    }

    #[Microsoft.PowerShell.Commands.WebResponseObject] Request([Hashtable]$Data)
    [Hashtable] Request([Hashtable]$Data)
    {
        $res=@{
            'Error'=(New-Object PSObject)
            'ErrorCode'=0
            'ErrorMsg'=''
        }
        $raw=@{}
        try
        {
            $raw = Invoke-WebRequest @Data

            $res.add('raw', $raw)

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
            $res.ErrorMsg="$($PSItem.Exception.Message)"
            $res.raw=$raw
        }
        return $res
    }
}
