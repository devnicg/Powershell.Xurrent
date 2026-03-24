function Connect-Xurrent {
    <#
    .SYNOPSIS
        Establishes a connection to the Xurrent REST API.
    .DESCRIPTION
        Stores the API token, account identifier, and base URI in a module-scoped
        variable so that all subsequent Xurrent commands can use them without
        requiring you to pass credentials each time.
    .PARAMETER ApiToken
        The personal access token or OAuth bearer token used to authenticate with
        the Xurrent API. Treat this value as a secret.
    .PARAMETER Account
        The Xurrent account identifier (e.g. 'wdc' or 'my-company').
        This is sent as the X-4me-Account request header.
    .PARAMETER Region
        The Xurrent region. Determines the base API URL.
        Accepted values: 'EU', 'US', 'AU', 'UK', 'CH', 'QA'.
        Defaults to 'EU'.
    .PARAMETER BaseUri
        Override the automatically derived base URI with a custom URL.
        Use this when connecting to on-premises or sandbox environments.
    .EXAMPLE
        Connect-Xurrent -ApiToken 'mytoken' -Account 'wdc'
        Connects to the EU region using the 'wdc' account.
    .EXAMPLE
        $token = Read-Host -Prompt 'API Token' -AsSecureString
        $plain  = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($token))
        Connect-Xurrent -ApiToken $plain -Account 'wdc' -Region 'US'
    .OUTPUTS
        None. Sets the module-scoped connection context.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Region')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ApiToken,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Account,

        [Parameter(ParameterSetName = 'Region')]
        [ValidateSet('EU', 'US', 'AU', 'UK', 'CH', 'QA')]
        [string] $Region = 'EU',

        [Parameter(Mandatory, ParameterSetName = 'CustomUri')]
        [ValidateNotNullOrEmpty()]
        [string] $BaseUri
    )

    $regionUriMap = @{
        EU = 'https://api.xurrent.com/v1/'
        US = 'https://api.xurrent.us/v1/'
        AU = 'https://api.xurrent.com.au/v1/'
        UK = 'https://api.xurrent.co.uk/v1/'
        CH = 'https://api.xurrent.ch/v1/'
        QA = 'https://api.xurrent.qa/v1/'
    }

    if ($PSCmdlet.ParameterSetName -eq 'Region') {
        $BaseUri = $regionUriMap[$Region]
    }

    if (-not $BaseUri.EndsWith('/')) {
        $BaseUri = "$BaseUri/"
    }

    $Script:XurrentContext = [PSCustomObject]@{
        ApiToken = $ApiToken
        Account  = $Account
        BaseUri  = $BaseUri
        Region   = if ($PSCmdlet.ParameterSetName -eq 'Region') { $Region } else { 'Custom' }
    }

    Write-Verbose "Connected to Xurrent: Account='$Account', BaseUri='$BaseUri'"
}
