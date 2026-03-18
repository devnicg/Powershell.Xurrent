function New-XurrentRequest {
    <#
    .SYNOPSIS
        Creates a new Xurrent request (service request / incident).
    .DESCRIPTION
        Creates a new request in Xurrent with the specified properties.
        At minimum, a Subject is required.
    .PARAMETER Subject
        The subject / title of the request. Required.
    .PARAMETER Category
        The category of the request. Common values: 'incident', 'rfc', 'rfi',
        'complaint', 'compliment', 'other'.
    .PARAMETER Impact
        Impact of the request. Common values: 'top', 'high', 'medium', 'low',
        'none'.
    .PARAMETER Status
        Initial status. Common values: 'new', 'assigned', 'in_progress',
        'waiting_for', 'on_hold'.
    .PARAMETER Note
        Text of an initial note to attach to the request.
    .PARAMETER ServiceInstanceId
        ID of the service instance to associate the request with.
    .PARAMETER TeamId
        ID of the team to assign the request to.
    .PARAMETER MemberId
        ID of the person to assign the request to.
    .PARAMETER RequestedById
        ID of the person on whose behalf the request is submitted.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields to include in the request body.
        Useful for fields not covered by explicit parameters.
    .EXAMPLE
        New-XurrentRequest -Subject 'Email not working' -Category 'incident'
    .EXAMPLE
        New-XurrentRequest -Subject 'New laptop' -Category 'rfc' -Impact 'medium' -TeamId 101
    .OUTPUTS
        PSCustomObject representing the newly created request.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Subject,

        [Parameter()]
        [ValidateSet('incident', 'rfc', 'rfi', 'complaint', 'compliment', 'other')]
        [string] $Category = 'incident',

        [Parameter()]
        [ValidateSet('top', 'high', 'medium', 'low', 'none')]
        [string] $Impact,

        [Parameter()]
        [string] $Status,

        [Parameter()]
        [string] $Note,

        [Parameter()]
        [int] $ServiceInstanceId,

        [Parameter()]
        [int] $TeamId,

        [Parameter()]
        [int] $MemberId,

        [Parameter()]
        [int] $RequestedById,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    $body = @{ subject = $Subject; category = $Category }

    if ($Impact)            { $body.impact             = $Impact }
    if ($Status)            { $body.status             = $Status }
    if ($Note)              { $body.note               = $Note }
    if ($ServiceInstanceId) { $body.service_instance   = @{ id = $ServiceInstanceId } }
    if ($TeamId)            { $body.team               = @{ id = $TeamId } }
    if ($MemberId)          { $body.member             = @{ id = $MemberId } }
    if ($RequestedById)     { $body.requested_by       = @{ id = $RequestedById } }

    if ($AdditionalProperties) {
        foreach ($key in $AdditionalProperties.Keys) {
            $body[$key] = $AdditionalProperties[$key]
        }
    }

    if ($PSCmdlet.ShouldProcess($Subject, 'Create Xurrent request')) {
        Invoke-XurrentRestMethod -Method POST -Resource 'requests' -Body $body
    }
}
