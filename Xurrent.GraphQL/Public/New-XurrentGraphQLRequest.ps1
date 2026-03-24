function New-XurrentGraphQLRequest {
    <#
    .SYNOPSIS
        Creates a new Xurrent request via the GraphQL API.
    .DESCRIPTION
        Executes a requestCreate mutation against the Xurrent GraphQL API.
    .PARAMETER Subject
        The subject / title of the request. Required.
    .PARAMETER Category
        The category of the request (e.g. 'incident', 'rfc', 'rfi', 'complaint',
        'compliment', 'other').
    .PARAMETER Impact
        Impact level (e.g. 'top', 'high', 'medium', 'low', 'none').
    .PARAMETER Status
        Initial status of the request.
    .PARAMETER TeamId
        Node ID of the team to assign the request to.
    .PARAMETER MemberId
        Node ID of the person to assign the request to.
    .PARAMETER RequestedForId
        Node ID of the person the request is on behalf of.
    .PARAMETER TemplateId
        Node ID of the request template to apply.
    .PARAMETER CustomFields
        Array of custom field input hashtables, e.g.
        @(@{ id = 'field1'; value = 'val1' }, @{ id = 'field2'; value = 'val2' })
    .PARAMETER AdditionalInput
        Hashtable of additional input fields not covered by explicit parameters.
    .PARAMETER Fields
        The GraphQL fields to return on the created request.
        Defaults to 'id requestId subject status category'.
    .EXAMPLE
        New-XurrentGraphQLRequest -Subject 'Email not working' -Category 'incident'
    .EXAMPLE
        New-XurrentGraphQLRequest -Subject 'New laptop' -Category 'rfc' -TeamId 'NG1lLTEwMQ'
    .OUTPUTS
        PSCustomObject representing the mutation response.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Subject,

        [Parameter()]
        [string] $Category = 'incident',

        [Parameter()]
        [string] $Impact,

        [Parameter()]
        [string] $Status,

        [Parameter()]
        [string] $TeamId,

        [Parameter()]
        [string] $MemberId,

        [Parameter()]
        [string] $RequestedForId,

        [Parameter()]
        [string] $TemplateId,

        [Parameter()]
        [array] $CustomFields,

        [Parameter()]
        [hashtable] $AdditionalInput,

        [Parameter()]
        [string] $Fields = 'id requestId subject status category'
    )

    $input = @{
        subject  = $Subject
        category = $Category
    }

    if ($Impact)         { $input.impact         = $Impact }
    if ($Status)         { $input.status          = $Status }
    if ($TeamId)         { $input.teamId          = $TeamId }
    if ($MemberId)       { $input.memberId        = $MemberId }
    if ($RequestedForId) { $input.requestedForId  = $RequestedForId }
    if ($TemplateId)     { $input.templateId       = $TemplateId }
    if ($CustomFields)   { $input.customFields     = $CustomFields }

    if ($AdditionalInput) {
        foreach ($key in $AdditionalInput.Keys) {
            $input[$key] = $AdditionalInput[$key]
        }
    }

    $mutation = @"
mutation(`$input: RequestCreateInput!) {
    requestCreate(input: `$input) {
        errors { path message }
        request { $Fields }
    }
}
"@

    if ($PSCmdlet.ShouldProcess($Subject, 'Create Xurrent request via GraphQL')) {
        Invoke-XurrentGraphQLRequest -Query $mutation -Variables @{ input = $input }
    }
}
