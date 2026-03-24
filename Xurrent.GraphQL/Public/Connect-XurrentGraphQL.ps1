function Connect-XurrentGraphQL {
    <#
    .SYNOPSIS
        Establishes a connection to the Xurrent GraphQL API.
    .DESCRIPTION
        Stores the API token, account identifier, and GraphQL endpoint URI in a
        module-scoped variable so that all subsequent Xurrent GraphQL commands can
        use them without requiring you to pass credentials each time.
    .PARAMETER ApiToken
        The personal access token or OAuth bearer token used to authenticate with
        the Xurrent GraphQL API. Treat this value as a secret.
    .PARAMETER Account
        The Xurrent account identifier (e.g. 'wdc' or 'my-company').
        This is sent as the X-Xurrent-Account request header.
    .PARAMETER Region
        The Xurrent region. Determines the GraphQL endpoint URL.
        Accepted values: 'Global', 'AU', 'QA', 'QA-AU'.
        Defaults to 'Global'.
    .PARAMETER BaseUri
        Override the automatically derived endpoint URI with a custom URL.
        Use this when connecting to sandbox or custom environments.
    .EXAMPLE
        Connect-XurrentGraphQL -ApiToken 'mytoken' -Account 'wdc'
        Connects to the global GraphQL endpoint using the 'wdc' account.
    .EXAMPLE
        Connect-XurrentGraphQL -ApiToken 'mytoken' -Account 'wdc' -Region 'AU'
        Connects to the Australia-region GraphQL endpoint.
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
        [ValidateSet('Global', 'AU', 'QA', 'QA-AU')]
        [string] $Region = 'Global',

        [Parameter(Mandatory, ParameterSetName = 'CustomUri')]
        [ValidateNotNullOrEmpty()]
        [string] $BaseUri
    )

    $regionUriMap = @{
        'Global' = 'https://graphql.xurrent.com/'
        'AU'     = 'https://graphql.au.xurrent.com/'
        'QA'     = 'https://graphql.xurrent.qa/'
        'QA-AU'  = 'https://graphql.au.xurrent.qa/'
    }

    if ($PSCmdlet.ParameterSetName -eq 'Region') {
        $BaseUri = $regionUriMap[$Region]
    }

    if (-not $BaseUri.EndsWith('/')) {
        $BaseUri = "$BaseUri/"
    }

    $Script:XurrentGraphQLContext = [PSCustomObject]@{
        ApiToken = $ApiToken
        Account  = $Account
        BaseUri  = $BaseUri
        Region   = if ($PSCmdlet.ParameterSetName -eq 'Region') { $Region } else { 'Custom' }
    }

    Write-Verbose "Connected to Xurrent GraphQL: Account='$Account', BaseUri='$BaseUri'"
}
