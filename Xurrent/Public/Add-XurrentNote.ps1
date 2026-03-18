function Add-XurrentNote {
    <#
    .SYNOPSIS
        Adds a note to a Xurrent request.
    .DESCRIPTION
        Creates a note on the specified request. Notes can be internal
        (only visible to agents) or public (visible to the requester).
    .PARAMETER RequestId
        The numeric ID of the request to add the note to. Required.
    .PARAMETER Text
        The text content of the note. Required.
    .PARAMETER Internal
        When specified, the note is marked as internal (not visible to requester).
    .EXAMPLE
        Add-XurrentNote -RequestId 12345 -Text 'Working on this now.'
    .EXAMPLE
        Add-XurrentNote -RequestId 12345 -Text 'Internal remark' -Internal
    .OUTPUTS
        PSCustomObject representing the created note.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [int] $RequestId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Text,

        [Parameter()]
        [switch] $Internal
    )

    process {
        $body = @{
            text     = $Text
            internal = [bool]$Internal
        }

        if ($PSCmdlet.ShouldProcess($RequestId, 'Add note to Xurrent request')) {
            Invoke-XurrentRestMethod -Method POST -Resource "requests/$RequestId/notes" -Body $body
        }
    }
}
