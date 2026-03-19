function Get-XurrentGraphQLRequest {
    <#
    .SYNOPSIS
        Retrieves one or more Xurrent requests via the GraphQL API.
    .DESCRIPTION
        Queries the Xurrent GraphQL API for requests. Supports retrieving a single
        request by node ID, or listing requests with optional filtering and pagination.
    .PARAMETER Id
        The node ID of a specific request to retrieve.
    .PARAMETER Filter
        A hashtable of filter parameters to narrow results (e.g. @{ status = 'assigned' }).
    .PARAMETER Fields
        The GraphQL fields to return. Defaults to 'id requestId subject status category'.
    .PARAMETER First
        Number of records to return per page (1-100). Defaults to 25.
    .PARAMETER AllPages
        Automatically follows cursor-based pagination and returns all matching records.
    .EXAMPLE
        Get-XurrentGraphQLRequest
    .EXAMPLE
        Get-XurrentGraphQLRequest -Id 'NG1lLTEyMzQ1'
    .EXAMPLE
        Get-XurrentGraphQLRequest -Filter @{ status = 'assigned' } -AllPages
    .OUTPUTS
        PSCustomObject or array of PSCustomObject.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Id,

        [Parameter(ParameterSetName = 'List')]
        [hashtable] $Filter,

        [Parameter()]
        [string] $Fields = 'id requestId subject status category',

        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(1, 100)]
        [int] $First = 25,

        [Parameter(ParameterSetName = 'List')]
        [switch] $AllPages
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $query = "query(`$id: ID!) { request(id: `$id) { $Fields } }"
            Invoke-XurrentGraphQLRequest -Query $query -Variables @{ id = $Id }
        }
        else {
            $filterArgs = ''
            $variables = @{ first = $First }
            $varDefs = '$first: Int, $after: String'

            if ($Filter) {
                $filterParts = @()
                foreach ($key in $Filter.Keys) {
                    $varName = "filter_$key"
                    $varDefs += ", `$$varName: String"
                    $variables[$varName] = $Filter[$key]
                    $filterParts += "${key}: `$$varName"
                }
                $filterArgs = ", filter: { $($filterParts -join ', ') }"
            }

            $query = @"
query($varDefs) {
    requests(first: `$first, after: `$after$filterArgs) {
        nodes { $Fields }
        pageInfo { endCursor hasNextPage }
    }
}
"@
            Invoke-XurrentGraphQLRequest -Query $query -Variables $variables -AllPages:$AllPages
        }
    }
}
