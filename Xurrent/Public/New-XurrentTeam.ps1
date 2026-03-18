function New-XurrentTeam {
    <#
    .SYNOPSIS
        Creates a new team in Xurrent.
    .PARAMETER Name
        The team name. Required.
    .PARAMETER ManagerId
        ID of the person who manages this team.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields.
    .EXAMPLE
        New-XurrentTeam -Name 'Service Desk'
    .OUTPUTS
        PSCustomObject representing the newly created team.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter()]
        [int] $ManagerId,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    $body = @{ name = $Name }
    if ($ManagerId) { $body.manager = @{ id = $ManagerId } }

    if ($AdditionalProperties) {
        foreach ($key in $AdditionalProperties.Keys) {
            $body[$key] = $AdditionalProperties[$key]
        }
    }

    if ($PSCmdlet.ShouldProcess($Name, 'Create Xurrent team')) {
        Invoke-XurrentRestMethod -Method POST -Resource 'teams' -Body $body
    }
}
