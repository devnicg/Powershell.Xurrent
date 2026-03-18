function Set-XurrentService {
    <#
    .SYNOPSIS
        Updates an existing Xurrent service.
    .PARAMETER Id
        The numeric ID of the service to update. Required.
    .PARAMETER Name
        Updated service name.
    .PARAMETER ServiceOwnerId
        ID of the new service owner.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields to update.
    .EXAMPLE
        Set-XurrentService -Id 7 -Name 'Corporate Email'
    .OUTPUTS
        PSCustomObject representing the updated service.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int] $Id,

        [Parameter()]
        [string] $Name,

        [Parameter()]
        [int] $ServiceOwnerId,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('Name'))           { $body.name          = $Name }
        if ($PSBoundParameters.ContainsKey('ServiceOwnerId')) { $body.service_owner = @{ id = $ServiceOwnerId } }

        if ($AdditionalProperties) {
            foreach ($key in $AdditionalProperties.Keys) {
                $body[$key] = $AdditionalProperties[$key]
            }
        }

        if ($body.Count -eq 0) {
            Write-Warning 'No update properties specified for service.'
            return
        }

        if ($PSCmdlet.ShouldProcess($Id, 'Update Xurrent service')) {
            Invoke-XurrentRestMethod -Method PATCH -Resource "services/$Id" -Body $body
        }
    }
}
