function Set-XurrentPerson {
    <#
    .SYNOPSIS
        Updates an existing Xurrent person record.
    .DESCRIPTION
        Updates the specified fields of a person identified by their ID.
    .PARAMETER Id
        The numeric ID of the person to update. Required.
    .PARAMETER Name
        Updated full name.
    .PARAMETER PrimaryEmail
        Updated primary e-mail address.
    .PARAMETER JobTitle
        Updated job title.
    .PARAMETER OrganizationId
        ID of the organization to associate the person with.
    .PARAMETER SiteId
        ID of the site to associate the person with.
    .PARAMETER TimeZone
        IANA time zone name.
    .PARAMETER Language
        Two-letter ISO 639-1 language code.
    .PARAMETER Disabled
        Set to $true to disable the person's account.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields to update.
    .EXAMPLE
        Set-XurrentPerson -Id 42 -JobTitle 'Senior Engineer'
    .OUTPUTS
        PSCustomObject representing the updated person.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int] $Id,

        [Parameter()]
        [string] $Name,

        [Parameter()]
        [string] $PrimaryEmail,

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
        [bool] $Disabled,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    process {
        $body = @{}

        if ($PSBoundParameters.ContainsKey('Name'))           { $body.name          = $Name }
        if ($PSBoundParameters.ContainsKey('PrimaryEmail'))   { $body.primary_email = $PrimaryEmail }
        if ($PSBoundParameters.ContainsKey('JobTitle'))       { $body.job_title     = $JobTitle }
        if ($PSBoundParameters.ContainsKey('OrganizationId')) { $body.organization  = @{ id = $OrganizationId } }
        if ($PSBoundParameters.ContainsKey('SiteId'))         { $body.site          = @{ id = $SiteId } }
        if ($PSBoundParameters.ContainsKey('TimeZone'))       { $body.time_zone     = $TimeZone }
        if ($PSBoundParameters.ContainsKey('Language'))       { $body.language      = $Language }
        if ($PSBoundParameters.ContainsKey('Disabled'))       { $body.disabled      = $Disabled }

        if ($AdditionalProperties) {
            foreach ($key in $AdditionalProperties.Keys) {
                $body[$key] = $AdditionalProperties[$key]
            }
        }

        if ($body.Count -eq 0) {
            Write-Warning 'No update properties specified for person.'
            return
        }

        if ($PSCmdlet.ShouldProcess($Id, 'Update Xurrent person')) {
            Invoke-XurrentRestMethod -Method PATCH -Resource "people/$Id" -Body $body
        }
    }
}
