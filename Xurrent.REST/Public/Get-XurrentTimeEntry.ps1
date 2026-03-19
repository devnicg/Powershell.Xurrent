function Get-XurrentTimeEntry {
    <#
    .SYNOPSIS
        Retrieves one or more Xurrent time entries.
    .PARAMETER Id
        The numeric ID of a specific time entry.
    .PARAMETER Filter
        Hashtable of filter parameters.
    .PARAMETER Fields
        Comma-separated list of fields to return.
    .PARAMETER PerPage
        Number of records per page (1-100). Defaults to 25.
    .PARAMETER AllPages
        Automatically retrieve all pages.
    .EXAMPLE
        Get-XurrentTimeEntry
    .EXAMPLE
        Get-XurrentTimeEntry -Id 500
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
            Invoke-XurrentRestMethod -Method GET -Resource "time_entries/$Id" -QueryParameters $queryParams
        }
        else {
            $queryParams = @{ per_page = $PerPage.ToString() }
            if ($Fields) { $queryParams.fields = $Fields }
            if ($Filter) {
                foreach ($key in $Filter.Keys) {
                    $queryParams["filter[$key]"] = $Filter[$key]
                }
            }
            Invoke-XurrentRestMethod -Method GET -Resource 'time_entries' -QueryParameters $queryParams -AllPages:$AllPages
        }
    }
}
