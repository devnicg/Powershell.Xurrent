function Remove-XurrentRequest {
    <#
    .SYNOPSIS
        Deletes a Xurrent request.
    .DESCRIPTION
        Permanently deletes the request with the given ID.
        Use with caution — this action cannot be undone.
    .PARAMETER Id
        The numeric ID of the request to delete. Required.
    .EXAMPLE
        Remove-XurrentRequest -Id 12345
    .EXAMPLE
        Get-XurrentRequest -Filter @{ status = 'declined' } | Remove-XurrentRequest
    .OUTPUTS
        None.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int] $Id
    )

    process {
        if ($PSCmdlet.ShouldProcess($Id, 'Delete Xurrent request')) {
            Invoke-XurrentRestMethod -Method DELETE -Resource "requests/$Id"
        }
    }
}
