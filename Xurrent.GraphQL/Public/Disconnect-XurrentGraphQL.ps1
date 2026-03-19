function Disconnect-XurrentGraphQL {
    <#
    .SYNOPSIS
        Clears the current Xurrent GraphQL connection context.
    .DESCRIPTION
        Removes the module-scoped connection context that was created by
        Connect-XurrentGraphQL. After calling this function, all Xurrent GraphQL
        commands will fail until Connect-XurrentGraphQL is called again.
    .EXAMPLE
        Disconnect-XurrentGraphQL
    .OUTPUTS
        None.
    #>
    [CmdletBinding()]
    param()

    $Script:XurrentGraphQLContext = $null
    Write-Verbose 'Disconnected from Xurrent GraphQL.'
}
