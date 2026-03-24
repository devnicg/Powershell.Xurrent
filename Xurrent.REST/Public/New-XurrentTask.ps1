function New-XurrentTask {
    <#
    .SYNOPSIS
        Creates a new task in Xurrent.
    .PARAMETER Subject
        The task subject. Required.
    .PARAMETER WorkflowId
        ID of the workflow (change) to add this task to. Required.
    .PARAMETER AssignedToId
        ID of the person to assign the task to.
    .PARAMETER TeamId
        ID of the team to assign the task to.
    .PARAMETER Status
        Initial status. Common values: 'new', 'assigned', 'in_progress',
        'waiting_for', 'failed', 'completed'.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields.
    .EXAMPLE
        New-XurrentTask -Subject 'Backup database' -WorkflowId 300
    .OUTPUTS
        PSCustomObject representing the newly created task.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Subject,

        [Parameter(Mandatory)]
        [int] $WorkflowId,

        [Parameter()]
        [int] $AssignedToId,

        [Parameter()]
        [int] $TeamId,

        [Parameter()]
        [string] $Status,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    $body = @{
        subject  = $Subject
        workflow = @{ id = $WorkflowId }
    }
    if ($AssignedToId) { $body.assigned_to = @{ id = $AssignedToId } }
    if ($TeamId)       { $body.team        = @{ id = $TeamId } }
    if ($Status)       { $body.status      = $Status }

    if ($AdditionalProperties) {
        foreach ($key in $AdditionalProperties.Keys) {
            $body[$key] = $AdditionalProperties[$key]
        }
    }

    if ($PSCmdlet.ShouldProcess($Subject, 'Create Xurrent task')) {
        Invoke-XurrentRestMethod -Method POST -Resource 'tasks' -Body $body
    }
}
