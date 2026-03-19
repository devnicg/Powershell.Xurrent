function Get-XurrentPerson {
    <#
    .SYNOPSIS
        Retrieves one or more Xurrent people (user accounts).
    .DESCRIPTION
        Returns a list of people or a single person by ID.
    .PARAMETER Id
        The numeric ID of a specific person to retrieve.
    .PARAMETER Filter
        Hashtable of filter parameters, e.g. @{ primary_email = 'user@example.com' }.
    .PARAMETER Fields
        Comma-separated list of fields to return.
    .PARAMETER PerPage
        Number of records per page (1-100). Defaults to 25.
    .PARAMETER AllPages
        Automatically retrieve all pages and return every matching record.
    .EXAMPLE
        Get-XurrentPerson
    .EXAMPLE
        Get-XurrentPerson -Id 42
    .EXAMPLE
        Get-XurrentPerson -Filter @{ primary_email = 'alice@example.com' }
    .OUTPUTS
        PSCustomObject or array of PSCustomObject.
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int] $Id,

        [Parameter(ParameterSetName = 'List')]
        [hashtable] $Filter,

        [Parameter()]
        [string] $Fields,

        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(1, 100)]
        [int] $PerPage = 25,

        [Parameter(ParameterSetName = 'List')]
        [switch] $AllPages
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $queryParams = @{}
            if ($Fields) { $queryParams.fields = $Fields }
            Invoke-XurrentRestMethod -Method GET -Resource "people/$Id" -QueryParameters $queryParams
        }
        else {
            $queryParams = @{ per_page = $PerPage.ToString() }
            if ($Fields) { $queryParams.fields = $Fields }
            if ($Filter) {
                foreach ($key in $Filter.Keys) {
                    $queryParams["filter[$key]"] = $Filter[$key]
                }
            }
            Invoke-XurrentRestMethod -Method GET -Resource 'people' -QueryParameters $queryParams -AllPages:$AllPages
        }
    }
}
