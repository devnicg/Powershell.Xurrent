function New-XurrentChange {
    <#
    .SYNOPSIS
        Creates a new change (workflow) in Xurrent.
    .PARAMETER Subject
        The subject of the change. Required.
    .PARAMETER Category
        Category of the change. Common values: 'standard', 'non_standard',
        'emergency', 'expedited'.
    .PARAMETER Impact
        Impact of the change.
    .PARAMETER Status
        Initial status.
    .PARAMETER ManagerId
        ID of the change manager.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields.
    .EXAMPLE
        New-XurrentChange -Subject 'Deploy new firewall'
    .OUTPUTS
        PSCustomObject representing the newly created change.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Subject,

        [Parameter()]
        [ValidateSet('standard', 'non_standard', 'emergency', 'expedited')]
        [string] $Category,

        [Parameter()]
        [ValidateSet('top', 'high', 'medium', 'low', 'none')]
        [string] $Impact,

        [Parameter()]
        [string] $Status,

        [Parameter()]
        [int] $ManagerId,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    $body = @{ subject = $Subject }
    if ($Category)  { $body.category = $Category }
    if ($Impact)    { $body.impact   = $Impact }
    if ($Status)    { $body.status   = $Status }
    if ($ManagerId) { $body.manager  = @{ id = $ManagerId } }

    if ($AdditionalProperties) {
        foreach ($key in $AdditionalProperties.Keys) {
            $body[$key] = $AdditionalProperties[$key]
        }
    }

    if ($PSCmdlet.ShouldProcess($Subject, 'Create Xurrent change')) {
        Invoke-XurrentRestMethod -Method POST -Resource 'changes' -Body $body
    }
}
