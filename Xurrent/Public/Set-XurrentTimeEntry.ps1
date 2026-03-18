function Set-XurrentTimeEntry {
    <#
    .SYNOPSIS
        Updates an existing Xurrent time entry.
    .PARAMETER Id
        The numeric ID of the time entry to update. Required.
    .PARAMETER TimeSpent
        Updated time spent in minutes.
    .PARAMETER Note
        Updated note.
    .PARAMETER Date
        Updated date (yyyy-MM-dd).
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields to update.
    .EXAMPLE
        Set-XurrentTimeEntry -Id 500 -TimeSpent 90
    .OUTPUTS
        PSCustomObject representing the updated time entry.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int] $Id,

        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $TimeSpent,

        [Parameter()]
        [string] $Note,

        [Parameter()]
        [string] $Date,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('TimeSpent')) { $body.time_spent = $TimeSpent }
        if ($PSBoundParameters.ContainsKey('Note'))      { $body.note       = $Note }
        if ($PSBoundParameters.ContainsKey('Date'))      { $body.date       = $Date }

        if ($AdditionalProperties) {
            foreach ($key in $AdditionalProperties.Keys) {
                $body[$key] = $AdditionalProperties[$key]
            }
        }

        if ($body.Count -eq 0) {
            Write-Warning 'No update properties specified for time entry.'
            return
        }

        if ($PSCmdlet.ShouldProcess($Id, 'Update Xurrent time entry')) {
            Invoke-XurrentRestMethod -Method PATCH -Resource "time_entries/$Id" -Body $body
        }
    }
}
