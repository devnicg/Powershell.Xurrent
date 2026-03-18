function Invoke-XurrentQuery {
    <#
    .SYNOPSIS
        Sends a custom query to the Xurrent REST API.
    .DESCRIPTION
        Allows you to call any Xurrent API endpoint using any HTTP method.
        This is useful for resources that do not yet have a dedicated wrapper
        function, or when you need fine-grained control over the request.
    .PARAMETER Resource
        The API resource path relative to the base URI, e.g. 'requests' or
        'requests/1234/notes'.
    .PARAMETER Method
        HTTP method to use. Defaults to 'GET'.
    .PARAMETER QueryParameters
        Optional hashtable of query string parameters.
    .PARAMETER Body
        Optional hashtable that will be serialised to JSON as the request body.
    .PARAMETER AllPages
        When specified, automatically follows pagination and returns all records.
    .EXAMPLE
        Invoke-XurrentQuery -Resource 'requests' -QueryParameters @{ per_page = 10 }
    .EXAMPLE
        Invoke-XurrentQuery -Resource 'requests' -Method POST -Body @{ subject = 'New request'; category = 'incident' }
    .OUTPUTS
        PSCustomObject or array of PSCustomObject representing the API response.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Resource,

        [Parameter()]
        [ValidateSet('GET', 'POST', 'PATCH', 'DELETE')]
        [string] $Method = 'GET',

        [Parameter()]
        [hashtable] $QueryParameters,

        [Parameter()]
        [hashtable] $Body,

        [Parameter()]
        [switch] $AllPages
    )

    $params = @{
        Method   = $Method
        Resource = $Resource
        AllPages = $AllPages
    }

    if ($QueryParameters) {
        $params.QueryParameters = $QueryParameters
    }

    if ($Body) {
        $params.Body = $Body
    }

    Invoke-XurrentRestMethod @params
}
