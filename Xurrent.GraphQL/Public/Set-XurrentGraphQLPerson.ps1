function Set-XurrentGraphQLPerson {
    <#
    .SYNOPSIS
        Updates an existing Xurrent person via the GraphQL API.
    .DESCRIPTION
        Executes a personUpdate mutation against the Xurrent GraphQL API.
    .PARAMETER Id
        The node ID of the person to update. Required.
    .PARAMETER Name
        Updated name.
    .PARAMETER JobTitle
        Updated job title.
    .PARAMETER OrganizationId
        Node ID of the updated organization.
    .PARAMETER SiteId
        Node ID of the updated site.
    .PARAMETER AdditionalInput
        Hashtable of additional input fields.
    .PARAMETER Fields
        The GraphQL fields to return. Defaults to 'id name primaryEmail'.
    .EXAMPLE
        Set-XurrentGraphQLPerson -Id 'NG1lLTk5' -JobTitle 'Senior Engineer'
    .OUTPUTS
        PSCustomObject representing the mutation response.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Id,

        [Parameter()]
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

    process {
        $input = @{ id = $Id }

        if ($PSBoundParameters.ContainsKey('Name'))     { $input.name           = $Name }
        if ($PSBoundParameters.ContainsKey('JobTitle')) { $input.jobTitle       = $JobTitle }
        if ($OrganizationId) { $input.organizationId = $OrganizationId }
        if ($SiteId)         { $input.siteId         = $SiteId }

        if ($AdditionalInput) {
            foreach ($key in $AdditionalInput.Keys) {
                $input[$key] = $AdditionalInput[$key]
            }
        }

        if ($input.Count -le 1) {
            Write-Warning 'No update properties specified. Provide at least one property to update.'
            return
        }

        $mutation = @"
mutation(`$input: PersonUpdateInput!) {
    personUpdate(input: `$input) {
        errors { path message }
        person { $Fields }
    }
}
"@

        if ($PSCmdlet.ShouldProcess("Person $Id", 'Update Xurrent person via GraphQL')) {
            Invoke-XurrentGraphQLRequest -Query $mutation -Variables @{ input = $input }
        }
    }
}
