function New-XurrentTimeEntry {
    <#
    .SYNOPSIS
        Creates a new time entry in Xurrent.
    .PARAMETER PersonId
        ID of the person the time entry is for. Required.
    .PARAMETER TimeSpent
        Time spent in minutes. Required.
    .PARAMETER Date
        The date of the time entry (yyyy-MM-dd). Defaults to today.
    .PARAMETER RequestId
        ID of the request to link the time entry to.
    .PARAMETER Note
        Optional note for the time entry.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields.
    .EXAMPLE
        New-XurrentTimeEntry -PersonId 42 -TimeSpent 60 -RequestId 12345
    .OUTPUTS
        PSCustomObject representing the newly created time entry.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [int] $PersonId,

        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $TimeSpent,

        [Parameter()]
        [string] $Date,

        [Parameter()]
        [int] $RequestId,

        [Parameter()]
        [string] $Note,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    if (-not $Date) {
        $Date = (Get-Date).ToString('yyyy-MM-dd')
    }

    $body = @{
        person     = @{ id = $PersonId }
        time_spent = $TimeSpent
        date       = $Date
    }

    if ($RequestId) { $body.request = @{ id = $RequestId } }
    if ($Note)      { $body.note    = $Note }

    if ($AdditionalProperties) {
        foreach ($key in $AdditionalProperties.Keys) {
            $body[$key] = $AdditionalProperties[$key]
        }
    }

    if ($PSCmdlet.ShouldProcess("PersonId=$PersonId TimeSpent=$TimeSpent", 'Create Xurrent time entry')) {
        Invoke-XurrentRestMethod -Method POST -Resource 'time_entries' -Body $body
    }
}
