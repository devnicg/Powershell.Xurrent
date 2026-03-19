function New-XurrentProblem {
    <#
    .SYNOPSIS
        Creates a new problem in Xurrent.
    .PARAMETER Subject
        The problem subject. Required.
    .PARAMETER Impact
        Impact of the problem.
    .PARAMETER Status
        Initial status. Common values: 'new', 'accepted', 'in_progress',
        'analyzed', 'change_requested', 'on_hold', 'solved', 'closed'.
    .PARAMETER ManagerId
        ID of the problem manager.
    .PARAMETER TeamId
        ID of the team assigned to the problem.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields.
    .EXAMPLE
        New-XurrentProblem -Subject 'Recurring login failures'
    .OUTPUTS
        PSCustomObject representing the newly created problem.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Subject,

        [Parameter()]
        [ValidateSet('top', 'high', 'medium', 'low', 'none')]
        [string] $Impact,

        [Parameter()]
        [string] $Status,

        [Parameter()]
        [int] $ManagerId,

        [Parameter()]
        [int] $TeamId,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    $body = @{ subject = $Subject }
    if ($Impact)    { $body.impact   = $Impact }
    if ($Status)    { $body.status   = $Status }
    if ($ManagerId) { $body.manager  = @{ id = $ManagerId } }
    if ($TeamId)    { $body.team     = @{ id = $TeamId } }

    if ($AdditionalProperties) {
        foreach ($key in $AdditionalProperties.Keys) {
            $body[$key] = $AdditionalProperties[$key]
        }
    }

    if ($PSCmdlet.ShouldProcess($Subject, 'Create Xurrent problem')) {
        Invoke-XurrentRestMethod -Method POST -Resource 'problems' -Body $body
    }
}
