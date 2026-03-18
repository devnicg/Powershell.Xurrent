function Invoke-XurrentRestMethod {
    <#
    .SYNOPSIS
        Sends an HTTP request to the Xurrent REST API.
    .DESCRIPTION
        Internal helper that wraps Invoke-RestMethod with Xurrent-specific headers,
        base URL construction, and automatic pagination support. Returns all pages
        when the response contains a Link header with rel="next".
    .PARAMETER Method
        HTTP method to use (GET, POST, PATCH, DELETE).
    .PARAMETER Resource
        The API resource path, e.g. 'requests' or 'requests/1234'.
    .PARAMETER QueryParameters
        Optional hashtable of query string parameters.
    .PARAMETER Body
        Optional hashtable that will be serialised to JSON and sent as the request body.
    .PARAMETER AllPages
        When specified, automatically follows pagination and returns all records.
    .OUTPUTS
        PSCustomObject or array of PSCustomObject representing the API response.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('GET', 'POST', 'PATCH', 'DELETE')]
        [string] $Method,

        [Parameter(Mandatory)]
        [string] $Resource,

        [Parameter()]
        [hashtable] $QueryParameters,

        [Parameter()]
        [hashtable] $Body,

        [Parameter()]
        [switch] $AllPages
    )

    $context = Get-XurrentContext

    # Build query string
    $queryString = ''
    if ($QueryParameters -and $QueryParameters.Count -gt 0) {
        $parts = foreach ($key in $QueryParameters.Keys) {
            $encodedKey   = [System.Uri]::EscapeDataString($key)
            $encodedValue = [System.Uri]::EscapeDataString($QueryParameters[$key])
            "${encodedKey}=${encodedValue}"
        }
        $queryString = '?' + ($parts -join '&')
    }

    $uri = "$($context.BaseUri)$($Resource.TrimStart('/'))$queryString"

    $headers = @{
        Authorization     = "Bearer $($context.ApiToken)"
        'X-4me-Account'   = $context.Account
        'Content-Type'    = 'application/json'
        Accept            = 'application/json'
    }

    $invokeParams = @{
        Uri                  = $uri
        Method               = $Method
        Headers              = $headers
        ResponseHeadersVariable = 'responseHeaders'
        ErrorAction          = 'Stop'
    }

    if ($Body) {
        $invokeParams.Body = $Body | ConvertTo-Json -Depth 20
    }

    Write-Verbose "[$Method] $uri"

    $allResults = [System.Collections.Generic.List[object]]::new()

    do {
        try {
            $response = Invoke-RestMethod @invokeParams
        }
        catch {
            $statusCode = $null
            if ($_.Exception.Response) {
                $statusCode = [int]$_.Exception.Response.StatusCode
            }
            $message = "Xurrent API error ($statusCode): $($_.Exception.Message)"
            Write-Error $message
            return
        }

        if ($response -is [array]) {
            $allResults.AddRange($response)
        }
        elseif ($null -ne $response) {
            $allResults.Add($response)
        }

        # Check for next page via Link header
        $nextUri = $null
        if ($AllPages -and $responseHeaders -and $responseHeaders['Link']) {
            $linkHeader = $responseHeaders['Link'] -join ', '
            if ($linkHeader -match '<([^>]+)>;\s*rel="next"') {
                $nextUri = $Matches[1]
                $invokeParams.Uri = $nextUri
            }
        }
    } while ($AllPages -and $nextUri)

    return $allResults.ToArray()
}
