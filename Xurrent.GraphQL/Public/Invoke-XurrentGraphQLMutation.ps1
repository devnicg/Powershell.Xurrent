function Invoke-XurrentGraphQLMutation {
    <#
    .SYNOPSIS
        Executes an arbitrary GraphQL mutation against the Xurrent API.
    .DESCRIPTION
        Sends a custom GraphQL mutation to the Xurrent GraphQL endpoint. Use this
        for mutations not covered by dedicated cmdlets, or when you need full
        control over the mutation structure. The mutation input should be passed
        via the Variables parameter.
    .PARAMETER Mutation
        The GraphQL mutation string.
    .PARAMETER Variables
        Optional hashtable of GraphQL variables referenced in the mutation.
    .EXAMPLE
        $mutation = @'
        mutation($input: RequestCreateInput!) {
            requestCreate(input: $input) {
                errors { path message }
                request { id requestId subject }
            }
        }
        '@
        Invoke-XurrentGraphQLMutation -Mutation $mutation -Variables @{
            input = @{ subject = 'New request'; category = 'other' }
        }
    .OUTPUTS
        PSCustomObject representing the GraphQL mutation response data.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Mutation,

        [Parameter()]
        [hashtable] $Variables
    )

    if ($PSCmdlet.ShouldProcess('Xurrent GraphQL API', 'Execute mutation')) {
        $params = @{ Query = $Mutation }
        if ($Variables) { $params.Variables = $Variables }

        $result = Invoke-XurrentGraphQLRequest @params

        # Check for mutation-level errors in the response
        if ($result) {
            $mutationKey = $result.PSObject.Properties | Select-Object -First 1 -ExpandProperty Name
            if ($mutationKey -and $result.$mutationKey.errors -and $result.$mutationKey.errors.Count -gt 0) {
                $errorMessages = ($result.$mutationKey.errors | ForEach-Object {
                    "$($_.path -join '.'): $($_.message)"
                }) -join '; '
                Write-Warning "Xurrent GraphQL mutation errors: $errorMessages"
            }
        }

        return $result
    }
}
