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
        <##
        $res=@{
            'Error'=(New-Object PSObject)
            'ErrorCode'=0
        }
        try
        {
            if ($this.extParams.Contains('domain'))
            {
                $domainName = $Arguments.extParams.domain;
            }
            else
            {
                $domainName = $Arguments.domain;
            }
            $raw = Invoke-WebRequest -Method Get -Headers @{ 'X-Token' = "$( $Arguments.token )"; 'Content-Type' = 'application/json' } "$($this.BaseUri)/$($domainName)/records";
            $arrC = ConvertFrom-Json $raw.content;
            $result = ($arrC|Sort-Object -Property name|Format-Table)

            $res.add('raw', $raw)
            $res.add('resarr', $arrC)
            $res.add('result', $result)

            #$res.add('this', $this);
            #$res.add('Arguments', $Arguments);
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
        ##>
        <##>
        if ($Arguments.extParams.Contains('domain'))
        {
            $domainName = $Arguments.extParams.domain;
        }
        else
        {
            $domainName = $Arguments.domain;
        }
        $data=@{
            'Method' = 'Get'
            'Uri' = "$($this.BaseUri)/$($domainName)/records"
            'Headers' = @{ 'X-Token' = "$($Arguments.token)"; 'Content-Type' = 'application/json' }
        }
        $extUri = '';
        if ($Arguments.extParams.Contains('recordId')) {
            $extUri += '/' + $Arguments.extParams.recordId;
        }
        $data.Uri += $extUri;
        $res=$this.Request($data);

        $arrC = ConvertFrom-Json $res.raw.content;
        $result = ($arrC|Sort-Object -Property name|Format-Table);

        #$res.add('raw', $raw)
        $res.add('resarr', $arrC);
        $res.add('result', $result);

        #$res.add('this', $this);
        #$res.add('Arguments', $Arguments);
        if ($res.raw.StatusCode -ne 200)
        {
            $res.ErrorCode=22; # StatusCode из ответа на http запроса <> 200
        }
        return $res
        ##>
    }

    [Hashtable] DeleteRecord([Hashtable]$Arguments)
    {
        $res=@{
            'Error'=(New-Object PSObject)
            'ErrorCode'=0
        }
        try
        {
            if ($this.extParams.Contains('domain'))
            {
                $domainId = $this.extParams.domain;
            }
            else
            {
                $domainId = $Arguments.domain;
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