function Get-XurrentGraphQLContext {
    <#
    .SYNOPSIS
        Returns the current Xurrent GraphQL connection context.
    .DESCRIPTION
        Returns the module-level connection context that was established by Connect-XurrentGraphQL.
        Throws an error if no connection has been established.
    .OUTPUTS
        PSCustomObject with connection details (ApiToken, Account, BaseUri).
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    if (-not $Script:XurrentGraphQLContext) {
        throw 'No Xurrent GraphQL connection found. Please run Connect-XurrentGraphQL first.'
    }

    return $Script:XurrentGraphQLContext
}
