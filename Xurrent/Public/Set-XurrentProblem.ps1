function Set-XurrentProblem {
    <#
    .SYNOPSIS
        Updates an existing Xurrent problem.
    .PARAMETER Id
        The numeric ID of the problem to update. Required.
    .PARAMETER Subject
        Updated subject.
    .PARAMETER Status
        Updated status.
    .PARAMETER Impact
        Updated impact.
    .PARAMETER ManagerId
        Updated manager ID.
    .PARAMETER TeamId
        Updated team ID.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields to update.
    .EXAMPLE
        Set-XurrentProblem -Id 400 -Status 'analyzed'
    .OUTPUTS
        PSCustomObject representing the updated problem.
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
        [int] $TeamId,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('Subject'))   { $body.subject  = $Subject }
        if ($PSBoundParameters.ContainsKey('Status'))    { $body.status   = $Status }
        if ($PSBoundParameters.ContainsKey('Impact'))    { $body.impact   = $Impact }
        if ($PSBoundParameters.ContainsKey('ManagerId')) { $body.manager  = @{ id = $ManagerId } }
        if ($PSBoundParameters.ContainsKey('TeamId'))    { $body.team     = @{ id = $TeamId } }

        if ($AdditionalProperties) {
            foreach ($key in $AdditionalProperties.Keys) {
                $body[$key] = $AdditionalProperties[$key]
            }
        }

        if ($body.Count -eq 0) {
            Write-Warning 'No update properties specified for problem.'
            return
        }

        if ($PSCmdlet.ShouldProcess($Id, 'Update Xurrent problem')) {
            Invoke-XurrentRestMethod -Method PATCH -Resource "problems/$Id" -Body $body
        }
    }
}
