function New-XurrentGraphQLPerson {
    <#
    .SYNOPSIS
        Creates a new Xurrent person via the GraphQL API.
    .DESCRIPTION
        Executes a personCreate mutation against the Xurrent GraphQL API.
    .PARAMETER PrimaryEmail
        The primary email address for the person. Required.
    .PARAMETER Name
        The full name of the person. Required.
    .PARAMETER JobTitle
        The person's job title.
    .PARAMETER OrganizationId
        Node ID of the person's organization.
    .PARAMETER SiteId
        Node ID of the person's site.
    .PARAMETER AdditionalInput
        Hashtable of additional input fields.
    .PARAMETER Fields
        The GraphQL fields to return. Defaults to 'id name primaryEmail'.
    .EXAMPLE
        New-XurrentGraphQLPerson -PrimaryEmail 'bob@example.com' -Name 'Bob Smith'
    .OUTPUTS
        PSCustomObject representing the mutation response.
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
        [string] $OrganizationId,

        [Parameter()]
        [string] $SiteId,

        [Parameter()]
        [hashtable] $AdditionalInput,

        [Parameter()]
        [string] $Fields = 'id name primaryEmail'
    )

    $input = @{
        primaryEmail = $PrimaryEmail
        name         = $Name
    }

    if ($JobTitle)       { $input.jobTitle       = $JobTitle }
    if ($OrganizationId) { $input.organizationId = $OrganizationId }
    if ($SiteId)         { $input.siteId         = $SiteId }

    if ($AdditionalInput) {
        foreach ($key in $AdditionalInput.Keys) {
            $input[$key] = $AdditionalInput[$key]
        }
    }

    $mutation = @"
mutation(`$input: PersonCreateInput!) {
    personCreate(input: `$input) {
        errors { path message }
        person { $Fields }
    }
}
"@

    if ($PSCmdlet.ShouldProcess($Name, 'Create Xurrent person via GraphQL')) {
        Invoke-XurrentGraphQLRequest -Query $mutation -Variables @{ input = $input }
    }
}
