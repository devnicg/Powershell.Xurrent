function New-XurrentSite {
    <#
    .SYNOPSIS
        Creates a new site in Xurrent.
    .PARAMETER Name
        The site name. Required.
    .PARAMETER Country
        ISO 3166-1 alpha-2 country code (e.g. 'US', 'NL').
    .PARAMETER TimeZone
        IANA time zone name.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields.
    .EXAMPLE
        New-XurrentSite -Name 'New York Office' -Country 'US' -TimeZone 'America/New_York'
    .OUTPUTS
        PSCustomObject representing the newly created site.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter()]
        [string] $Country,

        [Parameter()]
        [string] $TimeZone,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    $body = @{ name = $Name }
    if ($Country)  { $body.country   = $Country }
    if ($TimeZone) { $body.time_zone = $TimeZone }

    if ($AdditionalProperties) {
        foreach ($key in $AdditionalProperties.Keys) {
            $body[$key] = $AdditionalProperties[$key]
        }
    }

    if ($PSCmdlet.ShouldProcess($Name, 'Create Xurrent site')) {
        Invoke-XurrentRestMethod -Method POST -Resource 'sites' -Body $body
    }
}
