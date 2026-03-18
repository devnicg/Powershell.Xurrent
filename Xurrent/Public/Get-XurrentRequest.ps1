function Get-XurrentRequest {
    <#
    .SYNOPSIS
        Retrieves one or more Xurrent requests (service requests / incidents).
    .DESCRIPTION
        Returns a list of requests or a single request by ID.
        Use -Filter to narrow the results, -Fields to select specific fields,
        and -AllPages to automatically retrieve all paginated results.
    .PARAMETER Id
        The numeric ID of a specific request to retrieve.
    .PARAMETER Filter
        A hashtable of filter parameters. Keys correspond to Xurrent filter names,
        e.g. @{ status = 'in_progress'; category = 'incident' }.
    .PARAMETER Fields
        Comma-separated list of fields to return, e.g. 'id,subject,status,team'.
    .PARAMETER PerPage
        Number of records per page (1-100). Defaults to 25.
    .PARAMETER AllPages
        Automatically retrieve all pages and return every matching record.
    .EXAMPLE
        Get-XurrentRequest
        Returns the first page of requests.
    .EXAMPLE
        Get-XurrentRequest -Id 12345
        Returns a single request with ID 12345.
    .EXAMPLE
        Get-XurrentRequest -Filter @{ status = 'in_progress' } -AllPages
        Returns all in-progress requests.
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
            $resource = "requests/$Id"
            $queryParams = @{}
            if ($Fields) { $queryParams.fields = $Fields }
            Invoke-XurrentRestMethod -Method GET -Resource $resource -QueryParameters $queryParams
        }
        else {
            $queryParams = @{ per_page = $PerPage.ToString() }
            if ($Fields)  { $queryParams.fields = $Fields }
            if ($Filter) {
                foreach ($key in $Filter.Keys) {
                    $queryParams["filter[$key]"] = $Filter[$key]
                }
            }
            Invoke-XurrentRestMethod -Method GET -Resource 'requests' -QueryParameters $queryParams -AllPages:$AllPages
        }
    }
}
