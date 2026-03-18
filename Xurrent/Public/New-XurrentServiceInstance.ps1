function New-XurrentServiceInstance {
    <#
    .SYNOPSIS
        Creates a new service instance in Xurrent.
    .PARAMETER Name
        The service instance name. Required.
    .PARAMETER ServiceId
        ID of the service this instance belongs to. Required.
    .PARAMETER Status
        Status of the service instance. Common values: 'operational',
        'degraded', 'disrupted', 'unavailable'.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields.
    .EXAMPLE
        New-XurrentServiceInstance -Name 'Email - Production' -ServiceId 7
    .OUTPUTS
        PSCustomObject representing the newly created service instance.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory)]
        [int] $ServiceId,

        [Parameter()]
        [ValidateSet('operational', 'degraded', 'disrupted', 'unavailable')]
        [string] $Status,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    $body = @{
        name    = $Name
        service = @{ id = $ServiceId }
    }
    if ($Status) { $body.status = $Status }

    if ($AdditionalProperties) {
        foreach ($key in $AdditionalProperties.Keys) {
            $body[$key] = $AdditionalProperties[$key]
        }
    }

    if ($PSCmdlet.ShouldProcess($Name, 'Create Xurrent service instance')) {
        Invoke-XurrentRestMethod -Method POST -Resource 'service_instances' -Body $body
    }
}
