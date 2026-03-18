function New-XurrentService {
    <#
    .SYNOPSIS
        Creates a new service in Xurrent.
    .PARAMETER Name
        The service name. Required.
    .PARAMETER ServiceOwnerId
        ID of the person who owns this service.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields.
    .EXAMPLE
        New-XurrentService -Name 'Email'
    .OUTPUTS
        PSCustomObject representing the newly created service.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter()]
        [int] $ServiceOwnerId,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    $body = @{ name = $Name }
    if ($ServiceOwnerId) { $body.service_owner = @{ id = $ServiceOwnerId } }

    if ($AdditionalProperties) {
        foreach ($key in $AdditionalProperties.Keys) {
            $body[$key] = $AdditionalProperties[$key]
        }
    }

    if ($PSCmdlet.ShouldProcess($Name, 'Create Xurrent service')) {
        Invoke-XurrentRestMethod -Method POST -Resource 'services' -Body $body
    }
}
