function Set-XurrentRequest {
    <#
    .SYNOPSIS
        Updates an existing Xurrent request.
    .DESCRIPTION
        Updates the specified fields of a request identified by its ID.
        Only the fields you provide will be changed (PATCH semantics).
    .PARAMETER Id
        The numeric ID of the request to update. Required.
    .PARAMETER Subject
        Updated subject / title.
    .PARAMETER Category
        Updated category.
    .PARAMETER Impact
        Updated impact.
    .PARAMETER Status
        Updated status. Common values: 'new', 'assigned', 'in_progress',
        'waiting_for', 'on_hold', 'solved', 'declined'.
    .PARAMETER TeamId
        ID of the team to reassign the request to.
    .PARAMETER MemberId
        ID of the person to reassign the request to.
    .PARAMETER TemplateId
        ID of the request template to apply to the request.
    .PARAMETER CustomFields
        Hashtable of custom field values defined by the UI Extension linked
        to the request template.  Keys are the custom-field IDs and values
        are the field values.
    .PARAMETER AdditionalProperties
        Hashtable of additional API fields to update.
    .EXAMPLE
        Set-XurrentRequest -Id 12345 -Status 'solved'
    .EXAMPLE
        Set-XurrentRequest -Id 12345 -TeamId 202 -Impact 'high'
    .EXAMPLE
        Set-XurrentRequest -Id 12345 -CustomFields @{ badge = 'VIP' }
    .OUTPUTS
        PSCustomObject representing the updated request.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int] $Id,

        [Parameter()]
        [string] $Subject,

        [Parameter()]
        [ValidateSet('incident', 'rfc', 'rfi', 'complaint', 'compliment', 'other')]
        [string] $Category,

        [Parameter()]
        [ValidateSet('top', 'high', 'medium', 'low', 'none')]
        [string] $Impact,

        [Parameter()]
        [string] $Status,

        [Parameter()]
        [int] $TeamId,

        [Parameter()]
        [int] $MemberId,

        [Parameter()]
        [int] $TemplateId,

        [Parameter()]
        [hashtable] $CustomFields,

        [Parameter()]
        [hashtable] $AdditionalProperties
    )

    process {
        $body = @{}

        if ($PSBoundParameters.ContainsKey('Subject'))  { $body.subject  = $Subject }
        if ($PSBoundParameters.ContainsKey('Category')) { $body.category = $Category }
        if ($PSBoundParameters.ContainsKey('Impact'))   { $body.impact   = $Impact }
        if ($PSBoundParameters.ContainsKey('Status'))   { $body.status   = $Status }
        if ($PSBoundParameters.ContainsKey('TeamId'))   { $body.team     = @{ id = $TeamId } }
        if ($PSBoundParameters.ContainsKey('MemberId'))    { $body.member   = @{ id = $MemberId } }
        if ($PSBoundParameters.ContainsKey('TemplateId'))  { $body.template = @{ id = $TemplateId } }

        if ($PSBoundParameters.ContainsKey('CustomFields')) {
            $body.custom_fields = @(
                foreach ($key in $CustomFields.Keys) {
                    @{ id = $key; value = $CustomFields[$key] }
                }
            )
        }

        if ($AdditionalProperties) {
            foreach ($key in $AdditionalProperties.Keys) {
                $body[$key] = $AdditionalProperties[$key]
            }
        }

        if ($body.Count -eq 0) {
            Write-Warning 'No update properties specified for request.'
            return
        }

        if ($PSCmdlet.ShouldProcess($Id, 'Update Xurrent request')) {
            Invoke-XurrentRestMethod -Method PATCH -Resource "requests/$Id" -Body $body
        }
    }
}
