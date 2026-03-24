function Get-XurrentGraphQLTask {
    <#
    .SYNOPSIS
        Retrieves one or more Xurrent tasks via the GraphQL API.
    .PARAMETER Id
        The node ID of a specific task to retrieve.
    .PARAMETER Filter
        A hashtable of filter parameters.
    .PARAMETER Fields
        The GraphQL fields to return. Defaults to 'id subject status'.
    .PARAMETER First
        Number of records per page (1-100). Defaults to 25.
    .PARAMETER AllPages
        Automatically follows cursor-based pagination.
    .EXAMPLE
        Get-XurrentGraphQLTask
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
        [string] $Fields = 'id subject status',

        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(1, 100)]
        [int] $First = 25,

        [Parameter(ParameterSetName = 'List')]
        [switch] $AllPages
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $query = "query(`$id: ID!) { task(id: `$id) { $Fields } }"
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
    tasks(first: `$first, after: `$after$filterArgs) {
        nodes { $Fields }
        pageInfo { endCursor hasNextPage }
    }
}
"@
            Invoke-XurrentGraphQLRequest -Query $query -Variables $variables -AllPages:$AllPages
        }
    }
}
