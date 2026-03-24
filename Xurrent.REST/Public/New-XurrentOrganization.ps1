function New-XurrentOrganization {
    <#
    .SYNOPSIS
        Creates a new organization in Xurrent.
    .PARAMETER Name
        The organization name. Required.
    .PARAMETER ManagerId
        ID of the manager for this organization.
    .PARAMETER ParentId
        ID of the parent organization.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields.
    .EXAMPLE
        New-XurrentOrganization -Name 'Acme Corp'
    .OUTPUTS
        PSCustomObject representing the newly created organization.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter()]
        [int] $ManagerId,

        [Parameter()]
        [int] $ParentId,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    $body = @{ name = $Name }
    if ($ManagerId) { $body.manager = @{ id = $ManagerId } }
    if ($ParentId)  { $body.parent  = @{ id = $ParentId } }

    if ($AdditionalProperties) {
        foreach ($key in $AdditionalProperties.Keys) {
            $body[$key] = $AdditionalProperties[$key]
        }
    }

    if ($PSCmdlet.ShouldProcess($Name, 'Create Xurrent organization')) {
        Invoke-XurrentRestMethod -Method POST -Resource 'organizations' -Body $body
    }
}
