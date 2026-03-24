function Invoke-XurrentGraphQLQuery {
    <#
    .SYNOPSIS
        Executes an arbitrary GraphQL query against the Xurrent API.
    .DESCRIPTION
        Sends a custom GraphQL query to the Xurrent GraphQL endpoint. Use this for
        queries not covered by dedicated cmdlets, or when you need full control over
        the query structure and returned fields.
    .PARAMETER Query
        The GraphQL query string. Must be a valid GraphQL query.
    .PARAMETER Variables
        Optional hashtable of GraphQL variables referenced in the query.
    .PARAMETER AllPages
        Automatically follows cursor-based pagination and returns all nodes.
        The query must include pageInfo { endCursor hasNextPage } and use
        an $after variable for this to work.
    .EXAMPLE
        Invoke-XurrentGraphQLQuery -Query '{ me { id name primaryEmail } }'
    .EXAMPLE
        Invoke-XurrentGraphQLQuery -Query 'query($id: ID!) { request(id: $id) { id subject status } }' -Variables @{ id = 'abc123' }
    .EXAMPLE
        $query = @'
        query($first: Int, $after: String) {
            requests(first: $first, after: $after) {
                nodes { id subject status }
                pageInfo { endCursor hasNextPage }
            }
        }
        '@
        Invoke-XurrentGraphQLQuery -Query $query -Variables @{ first = 100 } -AllPages
    .OUTPUTS
        PSCustomObject representing the GraphQL response data.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Query,

        [Parameter()]
        [hashtable] $Variables,

        [Parameter()]
        [switch] $AllPages
    )

    $params = @{ Query = $Query }
    if ($Variables) { $params.Variables = $Variables }
    if ($AllPages)  { $params.AllPages = $true }

    Invoke-XurrentGraphQLRequest @params
}
