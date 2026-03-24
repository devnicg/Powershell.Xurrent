function Invoke-XurrentGraphQLRequest {
    <#
    .SYNOPSIS
        Sends a GraphQL request to the Xurrent GraphQL API.
    .DESCRIPTION
        Internal helper that wraps Invoke-RestMethod with Xurrent GraphQL-specific
        headers and request formatting. Supports automatic cursor-based pagination
        when the response contains pageInfo with hasNextPage.
    .PARAMETER Query
        The GraphQL query or mutation string.
    .PARAMETER Variables
        Optional hashtable of GraphQL variables.
    .PARAMETER AllPages
        When specified, automatically follows cursor-based pagination and returns
        all records. Requires the query to include pageInfo { endCursor hasNextPage }
        and accept an $after variable.
    .OUTPUTS
        PSCustomObject representing the GraphQL response data.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Query,

        [Parameter()]
        [hashtable] $Variables,

        [Parameter()]
        [switch] $AllPages
    )

    $context = Get-XurrentGraphQLContext

    $headers = @{
        Authorization        = "Bearer $($context.ApiToken)"
        'X-Xurrent-Account'  = $context.Account
        'Content-Type'       = 'application/json'
    }

    $requestBody = @{ query = $Query }
    if ($Variables) {
        $requestBody.variables = $Variables
    }

    $invokeParams = @{
        Uri         = $context.BaseUri
        Method      = 'POST'
        Headers     = $headers
        Body        = $requestBody | ConvertTo-Json -Depth 20
        ErrorAction = 'Stop'
    }

    Write-Verbose "[GraphQL POST] $($context.BaseUri)"

    $allNodes = [System.Collections.Generic.List[object]]::new()
    $hasNextPage = $false

    do {
        try {
            $response = Invoke-RestMethod @invokeParams
        }
        catch {
            $statusCode = $null
            if ($_.Exception.Response) {
                $statusCode = [int]$_.Exception.Response.StatusCode
            }
            $message = "Xurrent GraphQL API error ($statusCode): $($_.Exception.Message)"
            Write-Error $message
            return
        }

        # Check for GraphQL-level errors
        if ($response.errors) {
            $errorMessages = ($response.errors | ForEach-Object { $_.message }) -join '; '
            Write-Error "Xurrent GraphQL error: $errorMessages"
            return
        }

        if (-not $AllPages) {
            return $response.data
        }

        # For pagination, extract nodes from the first collection found in data
        $hasNextPage = $false
        $data = $response.data

        if ($null -eq $data) { break }

        # Find the first property that contains a nodes array (connection pattern)
        $collectionKey = $data.PSObject.Properties |
            Where-Object { $_.Value -and $_.Value.PSObject.Properties['nodes'] } |
            Select-Object -First 1 -ExpandProperty Name

        if ($collectionKey) {
            $connection = $data.$collectionKey
            if ($connection.nodes) {
                $allNodes.AddRange(@($connection.nodes))
            }

            if ($connection.pageInfo -and $connection.pageInfo.hasNextPage) {
                $hasNextPage = $true
                $endCursor = $connection.pageInfo.endCursor

                # Update variables with the new cursor
                if (-not $Variables) { $Variables = @{} }
                $Variables['after'] = $endCursor
                $requestBody.variables = $Variables
                $invokeParams.Body = $requestBody | ConvertTo-Json -Depth 20
            }
        }
        else {
            # No connection pattern found, return data as-is
            return $data
        }
    } while ($hasNextPage)

    if ($AllPages -and $allNodes.Count -gt 0) {
        return $allNodes.ToArray()
    }
    elseif ($AllPages) {
        return $response.data
    }
}
