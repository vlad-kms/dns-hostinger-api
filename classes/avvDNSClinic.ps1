using module '.\avvDNSProvider.ps1'

#using module "D:\tools\selectel.dns-hosting\classes\avvDNSSelectel.ps1"
#. .\avvDNSProvider.ps1

class avvDNSClinic : avvDNSProvider
{
    [Hashtable]hidden $Methods=@{
        #'help'='GetHelp'
        'version'='GetVersion'
        'v'='GetVersion'
        'companies'='GetCompanies'
        'clinics'='GetClinics'
        'doctors'='GetDoctors'
    }
    [int]hidden $Version=1
    [String]$BaseUri="https://dbg.alt.av-kms.ru/api_dbg/hs/er/v$($this.Version)"
    [String]$MethodREST=(Invoke-Expression -Command "if ($($this.Version) -eq 1) {'Get'} elseif ($($this.Version) -eq 2) {'Post'} else {''}" )

    [void] Init([Hashtable]$Params)
    {
        $this.extParams = $Params;
        if ($Params.Contains('ClinicVersion'))
        {
            $this.SetVersion($Params['ClinicVersion']);
        }
    }

    [void] SetVersion([int]$value)
    {
        $this.Version = $value
        $this.BaseUri="https://dbg.alt.av-kms.ru/api_dbg/hs/er/v$($value)"
        $this.MethodREST=(Invoke-Expression -Command "if ($($Value) -eq 1) {'Get'} elseif ($($value) -eq 2) {'Post'} else {''}" )
    }

    [Hashtable] PrepareParams([Hashtable]$Data, [String[]]$DesiredParams2Uri, [String[]]$DesiredParams2Body,
                              [String[]]$DesiredParams, [String]$TypeRequest, [String[]]$DesiredHeaders, [String]$Method)
    {
        $result=@{
            uri=''
            body=''
        }
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

    #static [Microsoft.PowerShell.Commands.WebResponseObject] Request([Hashtable]$Data)
    [Hashtable] Request([Hashtable]$Data)
    {
        $res=@{}
        try
        {
            $res=([avvDNSProvider]$this).Request($Data)
            #$arrC=ConvertFrom-Json $res.raw.content;
            $result = ($res.raw.Content)

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

    <#############################################################

    #############################################################>
    [Hashtable] GetCompanies([Hashtable]$Arguments)
    {
        #GET https://api.t.mrovo.ru/api/hs/er/v1/info
        $data=@{
            'Method'=$this.MethodREST
            'Uri'="$($this.BaseUri)/companies"
        }
        $data4Uri = $this.PrepareParams($Arguments.extParams, @('ExtUri'), @(), @('access_token'), '', @(), $data.Method);
        $data.Uri += '/' + $data4Uri.uri
        if ($this.Version -eq 2)
        {
            # POST
            $Data.Body = $data4Uri.Body;
        }
        $res=$this.Request($data)

        return $res
    }

    <#############################################################

    #############################################################>
    [Hashtable] GetClinics([Hashtable]$Arguments)
    {
        #GET https://api.t.mrovo.ru/api/hs/er/v1/info
        $data=@{
            'Method'=$this.MethodREST
            'Uri'="$($this.BaseUri)/clinics"
        }
        $data4Uri = $this.PrepareParams($Arguments.extParams, @('ExtUri'), @(), @('access_token'), '', @(), $data.Method);
        $data.Uri += '/' + $data4Uri.uri
        if ($this.Version -eq 2)
        {
            # POST
            $Data.Body = $data4Uri.Body;
        }
        $res=$this.Request($data)

        return $res
    }

    <#############################################################

    #############################################################>
    [Hashtable] GetDoctors([Hashtable]$Arguments)
    {
        #GET https://api.t.mrovo.ru/api/hs/er/v1/info
        $data=@{
            'Method'=$this.MethodREST
            'Uri'="$($this.BaseUri)/doctors"
        }
        #$data4Uri = $this.PrepareParams($Arguments.extParams, @('ExtUri','ClinicVersion'), @('ExtUri','access_token','p2'), @('access_token','ExtUri','p1'), $data.Method);
        $data4Uri = $this.PrepareParams($Arguments.extParams, @('ExtUri'), @(), @('access_token'), '', @(), $data.Method);
        $data.Uri += '/' + $data4Uri.uri
        if ($this.Version -eq 2)
        {
            # POST
            $Data.Body = $data4Uri.Body;
        }
        $res=$this.Request($data);

        return $res
    }

    <#############################################################

    #############################################################>
    [Hashtable] GetVersion([Hashtable]$Arguments)
    {
        #GET https://api.t.mrovo.ru/api/hs/er/v1/info
        $data=@{
            'Method'=$this.MethodREST
            'Uri'="$($this.BaseUri)/version"
        }
        $data.Uri += '/' + ($this.PrepareParams($Arguments.extParams, @('ExtVersion'), @(), @(), '', @(), $data.Method)).uri
        $res=$this.Request($data)
        return $res
    }

}
