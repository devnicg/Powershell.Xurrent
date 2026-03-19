function Set-XurrentGraphQLRequest {
    <#
    .SYNOPSIS
        Updates an existing Xurrent request via the GraphQL API.
    .DESCRIPTION
        Executes a requestUpdate mutation against the Xurrent GraphQL API.
        Only the fields you specify are changed.
    .PARAMETER Id
        The node ID of the request to update. Required.
    .PARAMETER Subject
        Updated subject / title.
    .PARAMETER Category
        Updated category.
    .PARAMETER Impact
        Updated impact level.
    .PARAMETER Status
        Updated status.
    .PARAMETER TeamId
        Node ID of the new team assignment.
    .PARAMETER MemberId
        Node ID of the new person assignment.
    .PARAMETER TemplateId
        Node ID of a request template to apply.
    .PARAMETER CustomFields
        Array of custom field input hashtables.
    .PARAMETER AdditionalInput
        Hashtable of additional input fields.
    .PARAMETER Fields
        The GraphQL fields to return. Defaults to 'id requestId subject status category'.
    .EXAMPLE
        Set-XurrentGraphQLRequest -Id 'NG1lLTEyMzQ1' -Status 'in_progress'
    .OUTPUTS
        PSCustomObject representing the mutation response.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Id,

        [Parameter()]
        [string] $Subject,

        [Parameter()]
        [string] $Category,

        [Parameter()]
        [string] $Impact,

        [Parameter()]
        [string] $Status,

        [Parameter()]
        [string] $TeamId,

        [Parameter()]
        [string] $MemberId,

        [Parameter()]
        [string] $TemplateId,

        [Parameter()]
        [array] $CustomFields,

        [Parameter()]
        [hashtable] $AdditionalInput,

        [Parameter()]
        [string] $Fields = 'id requestId subject status category'
    )

    process {
        $input = @{ id = $Id }

        if ($PSBoundParameters.ContainsKey('Subject'))    { $input.subject      = $Subject }
        if ($PSBoundParameters.ContainsKey('Category'))   { $input.category     = $Category }
        if ($PSBoundParameters.ContainsKey('Impact'))     { $input.impact       = $Impact }
        if ($PSBoundParameters.ContainsKey('Status'))     { $input.status       = $Status }
        if ($TeamId)       { $input.teamId       = $TeamId }
        if ($MemberId)     { $input.memberId     = $MemberId }
        if ($TemplateId)   { $input.templateId   = $TemplateId }
        if ($CustomFields) { $input.customFields = $CustomFields }

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
mutation(`$input: RequestUpdateInput!) {
    requestUpdate(input: `$input) {
        errors { path message }
        request { $Fields }
    }
}
"@

        if ($PSCmdlet.ShouldProcess("Request $Id", 'Update Xurrent request via GraphQL')) {
            Invoke-XurrentGraphQLRequest -Query $mutation -Variables @{ input = $input }
        }
    }
}
