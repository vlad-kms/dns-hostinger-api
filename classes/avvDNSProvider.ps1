class avvDNSProvider
{
    [Hashtable]hidden $Methods=@{
        'domainsList'='GetDomains'
        'recordsList'='GetRecords'
    }
    [String]$BaseUri=''
    [bool]$IsInit=$False
    [Hashtable]$extParams=@{}
    [Hashtable]$PreparedUri=@{}
    <#
    [Hashtable]hidden $Methods=@{
        'domainsList'=@{'method'='GetDomains'; 'uri'=''}
        'recordsList'=@{'method'='GetRecords'; 'uri'=''}
    }
    #>

    #avvDNSProvider
    [void] Init([Hashtable]$Params)
    {
        $this.extParams = $Params;
    }

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

    [Hashtable] PrepareParams([Hashtable]$Data, [String[]]$DesiredParams2Uri, [String[]]$DesiredParams2Body,
                              [String[]]$DesiredParams, [String]$TypeRequest)
    {
        $result=@{
            uri=''
            body=''
        }
        return $result;


        $DesiredParams2Uri.foreach({
            if ($Data.Contains($_))
            {
                $result.uri += $Data[$_] + '/'
            }
        })
        if ($result.uri.Length -gt 0)
        {
            $result.uri = $result.uri.Substring(0, $result.uri.Length-1)
        }
        $DesiredParams2Body.foreach({
            if ($Data.Contains($_))
            {
                $result.body += ("'$_':'$($Data[$_])';")
            }
        })
        if ($TypeRequest.ToUpper() -eq 'GET')
        {
            $res = ''
            $DesiredParams.foreach({
                if ($Data.Contains($_))
                {
                    $res += "$($_)=$($Data[$_])" + '&'
                }
            })
            if ($res.Length -gt 0)
            {
                $res = '?' + $res.Substring(0, $res.Length-1)
            }
            $result.uri += $res
        }
        elseif ($TypeRequest.ToUpper() -eq 'POST')
        {
            $DesiredParams.foreach({
                if ($Data.Contains($_))
                {
                    $result.body += "'$_':'" + $Data[$_] + "';";
                }
            })
        }
        if ($result.body.Length -gt 0)
        {
            $result.body = $result.body.Substring(0, $result.body.Length-1)
            $result.body = '{' + $result.body + '}'
        }
        $this.PreparedUri = $result;
        return $result
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
            if ($this.extParams.Contains('classDebug') -and $this.extParams.classDebug){
                $res.add('data', $data);
            }

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
