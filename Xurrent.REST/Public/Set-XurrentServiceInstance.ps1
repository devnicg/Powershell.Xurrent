function Set-XurrentServiceInstance {
    <#
    .SYNOPSIS
        Updates an existing Xurrent service instance.
    .PARAMETER Id
        The numeric ID of the service instance to update. Required.
    .PARAMETER Name
        Updated name.
    .PARAMETER Status
        Updated status.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields to update.
    .EXAMPLE
        Set-XurrentServiceInstance -Id 15 -Status 'degraded'
    .OUTPUTS
        PSCustomObject representing the updated service instance.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int] $Id,

        [Parameter()]
        [string] $Name,

        [Parameter()]
        [ValidateSet('operational', 'degraded', 'disrupted', 'unavailable')]
        [string] $Status,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('Name'))   { $body.name   = $Name }
        if ($PSBoundParameters.ContainsKey('Status')) { $body.status = $Status }

        if ($AdditionalProperties) {
            foreach ($key in $AdditionalProperties.Keys) {
                $body[$key] = $AdditionalProperties[$key]
            }
        }

        if ($body.Count -eq 0) {
            Write-Warning 'No update properties specified for service instance.'
            return
        }

        if ($PSCmdlet.ShouldProcess($Id, 'Update Xurrent service instance')) {
            Invoke-XurrentRestMethod -Method PATCH -Resource "service_instances/$Id" -Body $body
        }
    }
}
