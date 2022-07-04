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
    [String]$BaseUri="https://dbg.alt.av-kms.ru/api_dbg/hs/er/v1"
    [String]$MethodREST='Get'

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
    [Hashtable] GetVersion([Hashtable]$Arguments)
    {
        #GET https://api.t.mrovo.ru/api/hs/er/v1/info
        $data=@{
            'Method'=$this.MethodREST
            'Uri'="$($this.BaseUri)/version"
        }
        if ($this.MethodREST.toUpper() -eq 'GET')
        {
            if ( $Arguments.extParams.extVersion -and $Arguments.extParams.extVersion -ne '0')
            {
                $data.Uri += "?ext=$( $Arguments.extParams.extVersion )"
            }
        }
        elseif ($this.MethodREST.toUpper() -eq 'POST')
        {
            if ( $Arguments.extParams.extVersion -and $Arguments.extParams.extVersion -ne '0')
            {
                $data.Add('Body', "{'ext':'$( $Arguments.extParams.extVersion )'}")
            }
        }
        else
        {

        }
        $res=$this.Request($data)
        return $res
    }

}
