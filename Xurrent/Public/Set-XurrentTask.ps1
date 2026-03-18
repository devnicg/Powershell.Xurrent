function Set-XurrentTask {
    <#
    .SYNOPSIS
        Updates an existing Xurrent task.
    .PARAMETER Id
        The numeric ID of the task to update. Required.
    .PARAMETER Subject
        Updated subject.
    .PARAMETER Status
        Updated status.
    .PARAMETER AssignedToId
        ID of the person to reassign to.
    .PARAMETER TeamId
        ID of the team to reassign to.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields to update.
    .EXAMPLE
        Set-XurrentTask -Id 200 -Status 'completed'
    .OUTPUTS
        PSCustomObject representing the updated task.
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
        [int] $AssignedToId,

        [Parameter()]
        [int] $TeamId,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('Subject'))      { $body.subject     = $Subject }
        if ($PSBoundParameters.ContainsKey('Status'))       { $body.status      = $Status }
        if ($PSBoundParameters.ContainsKey('AssignedToId')) { $body.assigned_to = @{ id = $AssignedToId } }
        if ($PSBoundParameters.ContainsKey('TeamId'))       { $body.team        = @{ id = $TeamId } }

        if ($AdditionalProperties) {
            foreach ($key in $AdditionalProperties.Keys) {
                $body[$key] = $AdditionalProperties[$key]
            }
        }

        if ($body.Count -eq 0) {
            Write-Warning 'No update properties specified for task.'
            return
        }

        if ($PSCmdlet.ShouldProcess($Id, 'Update Xurrent task')) {
            Invoke-XurrentRestMethod -Method PATCH -Resource "tasks/$Id" -Body $body
        }
    }
}
