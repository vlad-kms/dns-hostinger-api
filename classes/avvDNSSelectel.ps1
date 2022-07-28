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
        $this.Methods.Add('DeleteRecord', '')
        $this.Methods.Add('del', 'DeleteRecord')
    }

    [Hashtable] GetDomains([Hashtable]$Arguments)
    {
        $data = $this.PrepareParams($Arguments.extParams, @('domainId', 'export'), @(), @(), '', @(), 'Get');
        $data.Uri = "$($this.BaseUri)$($data.Uri)";
        $data.Headers += @{ 'X-Token' = "$($Arguments.token)"; 'Content-Type' = 'application/json' };
        $res = $this.Request($data);

        if (!$Arguments.extParams.Contains('export'))
        {
            $arrC = ConvertFrom-Json $res.raw.content;
            $result = ($arrC|Sort-Object -Property name|Format-Table);
        }
        else
        {
            # результат - зона в формате BIND (string с разделителями `n (перенос строк))
            $arrC = $res.raw.content.split("`n");
            $result = $arrC.getEnumerator() | Sort-Object;
        }
        $res.add('resarr', $arrC);
        $res.add('result', $result);
        if ($this.extParams.Contains('classDebug') -and $this.extParams.classDebug )
        {
            $res.add('this', $this);
            $res.add('Arguments', $Arguments);
        }
        if ($res.raw.StatusCode -ne 200)
        {
            $res.ErrorCode=22; # StatusCode из ответа на http запроса <> 200
        }

        return $res
    }

    [Hashtable] GetRecords([Hashtable]$Arguments)
    {
        <#
        if ($Arguments.extParams.Contains('domain'))
        {
            $domainName = $Arguments.extParams.domain;
        }
        else
        {
            $domainName = $Arguments.domain;
        }
        if ($Arguments.extParams.Contains('domainId'))
        {
            $domainName = $Arguments.extParams.domainId;
        }
        #>
        $Arguments.extParams.add('records', 'records');
        $data = $this.PrepareParams($Arguments.extParams, @('domainId', 'records', 'recordId'), @(), @(), '', @(), 'Get');
        $data.Uri = "$($this.BaseUri)$($data.Uri)";
        $data.Headers += @{ 'X-Token' = "$($Arguments.token)"; 'Content-Type' = 'application/json' };
        $res=$this.Request($data);

        $arrC = ConvertFrom-Json $res.raw.content;
        $result = ($arrC|Sort-Object -Property name|Format-Table);

        #$res.add('raw', $raw)
        $res.add('resarr', $arrC);
        $res.add('result', $result);
        if ($this.extParams.Contains('classDebug') -and $this.extParams.classDebug )
        {
            $res.add('this', $this);
            $res.add('Arguments', $Arguments);
        }
        if ($res.raw.StatusCode -ne 200)
        {
            $res.ErrorCode=22; # StatusCode из ответа на http запроса <> 200
        }
        return $res
    }

    [Hashtable] DeleteRecord([Hashtable]$Arguments)
    {
        $res=@{
            'Error'=(New-Object PSObject)
            'ErrorCode'=0
        }
        try
        {
            if ($Arguments.extParams.Contains('domain'))
            {
                $domainId = $Arguments.extParams.domain;
            }
            else
            {
                $domainId = $Arguments.domain;
            }
            if ($Arguments.extParams.Contains('domainId'))
            {
                $domainId = $Arguments.extParams.domainId;
            }
            if ($this.extParams.Contains('recordId'))
            {
                $recordId = $this.extParams.recordId;
            }
            else
            {
                throw "Not resource record ID DNS"
            }
            $raw = Invoke-WebRequest -Method Delete -Headers @{ 'X-Token' = "$( $Arguments.token )"; 'Content-Type' = 'application/json' } "$($this.BaseUri)/$($domainId)/records/$($recordId)";
            $arrC = ConvertFrom-Json $raw.content;
            $result = $arrC;
            $res.add('raw', $raw)
            $res.add('resarr', $arrC)
            $res.add('result', $result)
            if ($raw.StatusCode -ne 200)
            {
                $res.ErrorCode=23 # StatusCode из ответа на http запроса <> 200
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