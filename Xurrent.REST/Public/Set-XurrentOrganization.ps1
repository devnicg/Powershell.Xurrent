function Set-XurrentOrganization {
    <#
    .SYNOPSIS
        Updates an existing Xurrent organization.
    .PARAMETER Id
        The numeric ID of the organization to update. Required.
    .PARAMETER Name
        Updated organization name.
    .PARAMETER ManagerId
        ID of the new manager.
    .PARAMETER ParentId
        ID of the parent organization.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields to update.
    .EXAMPLE
        Set-XurrentOrganization -Id 5 -Name 'Acme Corporation'
    .OUTPUTS
        PSCustomObject representing the updated organization.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int] $Id,

        [Parameter()]
        [string] $Name,

        [Parameter()]
        [int] $ManagerId,

        [Parameter()]
        [int] $ParentId,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('Name'))      { $body.name    = $Name }
        if ($PSBoundParameters.ContainsKey('ManagerId')) { $body.manager = @{ id = $ManagerId } }
        if ($PSBoundParameters.ContainsKey('ParentId'))  { $body.parent  = @{ id = $ParentId } }

        if ($AdditionalProperties) {
            foreach ($key in $AdditionalProperties.Keys) {
                $body[$key] = $AdditionalProperties[$key]
            }
        }

        if ($body.Count -eq 0) {
            Write-Warning 'No update properties specified for organization.'
            return
        }

        if ($PSCmdlet.ShouldProcess($Id, 'Update Xurrent organization')) {
            Invoke-XurrentRestMethod -Method PATCH -Resource "organizations/$Id" -Body $body
        }
    }
}
