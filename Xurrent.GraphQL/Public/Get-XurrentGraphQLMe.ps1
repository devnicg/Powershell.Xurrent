function Get-XurrentGraphQLMe {
    <#
    .SYNOPSIS
        Retrieves the current authenticated user from the Xurrent GraphQL API.
    .DESCRIPTION
        Returns the person record for the currently authenticated user (the 'me' query).
    .PARAMETER Fields
        The GraphQL fields to return. Defaults to 'id name primaryEmail'.
    .EXAMPLE
        Get-XurrentGraphQLMe
    .EXAMPLE
        Get-XurrentGraphQLMe -Fields 'id name primaryEmail account { id name }'
    .OUTPUTS
        PSCustomObject.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Fields = 'id name primaryEmail'
    )

    $query = "{ me { $Fields } }"
    Invoke-XurrentGraphQLRequest -Query $query
}
