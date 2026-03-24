function Set-XurrentChange {
    <#
    .SYNOPSIS
        Updates an existing Xurrent change.
    .PARAMETER Id
        The numeric ID of the change to update. Required.
    .PARAMETER Subject
        Updated subject.
    .PARAMETER Status
        Updated status.
    .PARAMETER Impact
        Updated impact.
    .PARAMETER ManagerId
        Updated change manager ID.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields to update.
    .EXAMPLE
        Set-XurrentChange -Id 300 -Status 'approved'
    .OUTPUTS
        PSCustomObject representing the updated change.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int] $Id,

        [Parameter()]
        [string] $Subject,

        [Parameter()]
        [string] $Status,

        [Parameter()]
        [ValidateSet('top', 'high', 'medium', 'low', 'none')]
        [string] $Impact,

        [Parameter()]
        [int] $ManagerId,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('Subject'))   { $body.subject  = $Subject }
        if ($PSBoundParameters.ContainsKey('Status'))    { $body.status   = $Status }
        if ($PSBoundParameters.ContainsKey('Impact'))    { $body.impact   = $Impact }
        if ($PSBoundParameters.ContainsKey('ManagerId')) { $body.manager  = @{ id = $ManagerId } }

        if ($AdditionalProperties) {
            foreach ($key in $AdditionalProperties.Keys) {
                $body[$key] = $AdditionalProperties[$key]
            }
        }

        if ($body.Count -eq 0) {
            Write-Warning 'No update properties specified for change.'
            return
        }

        if ($PSCmdlet.ShouldProcess($Id, 'Update Xurrent change')) {
            Invoke-XurrentRestMethod -Method PATCH -Resource "changes/$Id" -Body $body
        }
    }
}
