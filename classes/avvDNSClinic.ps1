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
        if ($this.MethodREST.toUpper() -eq 'GET')
        {
            $data.Uri+="?access_token=$($Arguments.extParams.Token1c)"
        }
        elseif ($this.MethodREST.toUpper() -eq 'POST')
        {
            $data.Add('Body', "{'access_token':'$($Arguments.extParams.Token1c)'}")
        }
        else
        {

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
        if ($this.MethodREST.toUpper() -eq 'GET')
        {
            $data.Uri+="?access_token=$($Arguments.extParams.Token1c)"
        }
        elseif ($this.MethodREST.toUpper() -eq 'POST')
        {
            $data.Add('Body', "{'access_token':'$($Arguments.extParams.Token1c)'}")
        }
        else
        {

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
        <#
        if ($this.MethodREST.toUpper() -eq 'GET')
        {
            $data.Uri+="?access_token=$($Arguments.extParams.Token1c)"
        }
        elseif ($this.MethodREST.toUpper() -eq 'POST')
        {
            $data.Add('Body', "{'access_token':'$($Arguments.extParams.Token1c)'}")
        }
        else
        {

        }
        #>

        $data.Uri += '/' + ($this.PrepareParams($Arguments.extParams, @('extUri'), @(), @('access_token'), $data.Method)).uri

        $res=$this.Request($data)

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
        $data.Uri += '/' + ($this.PrepareParams($Arguments.extParams, @('extVersion'), @(), @(), $data.Method)).uri
        $res=$this.Request($data)
        return $res
    }

}
