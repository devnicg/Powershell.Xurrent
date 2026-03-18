function Set-XurrentTeam {
    <#
    .SYNOPSIS
        Updates an existing Xurrent team.
    .PARAMETER Id
        The numeric ID of the team to update. Required.
    .PARAMETER Name
        Updated team name.
    .PARAMETER ManagerId
        ID of the new manager.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields to update.
    .EXAMPLE
        Set-XurrentTeam -Id 10 -Name 'Level 2 Support'
    .OUTPUTS
        PSCustomObject representing the updated team.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int] $Id,

        [Parameter()]
        [string] $Name,

        [Parameter()]
        [int] $ManagerId,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('Name'))      { $body.name    = $Name }
        if ($PSBoundParameters.ContainsKey('ManagerId')) { $body.manager = @{ id = $ManagerId } }

        if ($AdditionalProperties) {
            foreach ($key in $AdditionalProperties.Keys) {
                $body[$key] = $AdditionalProperties[$key]
            }
        }

        if ($body.Count -eq 0) {
            Write-Warning 'No update properties specified for team.'
            return
        }

        if ($PSCmdlet.ShouldProcess($Id, 'Update Xurrent team')) {
            Invoke-XurrentRestMethod -Method PATCH -Resource "teams/$Id" -Body $body
        }
    }
}
