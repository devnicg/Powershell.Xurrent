function New-XurrentPerson {
    <#
    .SYNOPSIS
        Creates a new person (user account) in Xurrent.
    .DESCRIPTION
        Creates a new person record. At minimum, a PrimaryEmail and Name are required.
    .PARAMETER PrimaryEmail
        The person's primary e-mail address. Required.
    .PARAMETER Name
        The person's full name. Required.
    .PARAMETER JobTitle
        The person's job title.
    .PARAMETER OrganizationId
        ID of the organization to associate the person with.
    .PARAMETER SiteId
        ID of the site to associate the person with.
    .PARAMETER TimeZone
        IANA time zone name for the person (e.g. 'Europe/Amsterdam').
    .PARAMETER Language
        Two-letter ISO 639-1 language code (e.g. 'en', 'nl').
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields.
    .EXAMPLE
        New-XurrentPerson -PrimaryEmail 'bob@example.com' -Name 'Bob Smith'
    .OUTPUTS
        PSCustomObject representing the newly created person.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $PrimaryEmail,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter()]
        [string] $JobTitle,

        [Parameter()]
        [int] $OrganizationId,

        [Parameter()]
        [int] $SiteId,

        [Parameter()]
        [string] $TimeZone,

        [Parameter()]
        [string] $Language,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    $body = @{
        primary_email = $PrimaryEmail
        name          = $Name
    }

    if ($JobTitle)      { $body.job_title    = $JobTitle }
    if ($OrganizationId){ $body.organization = @{ id = $OrganizationId } }
    if ($SiteId)        { $body.site         = @{ id = $SiteId } }
    if ($TimeZone)      { $body.time_zone    = $TimeZone }
    if ($Language)      { $body.language     = $Language }

    if ($AdditionalProperties) {
        foreach ($key in $AdditionalProperties.Keys) {
            $body[$key] = $AdditionalProperties[$key]
        }
    }

    if ($PSCmdlet.ShouldProcess($PrimaryEmail, 'Create Xurrent person')) {
        Invoke-XurrentRestMethod -Method POST -Resource 'people' -Body $body
    }
}
