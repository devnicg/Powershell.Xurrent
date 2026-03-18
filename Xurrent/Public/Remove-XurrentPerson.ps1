function Remove-XurrentPerson {
    <#
    .SYNOPSIS
        Deletes a Xurrent person record.
    .DESCRIPTION
        Permanently deletes the person with the given ID.
    .PARAMETER Id
        The numeric ID of the person to delete. Required.
    .EXAMPLE
        Remove-XurrentPerson -Id 42
    .OUTPUTS
        None.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int] $Id
    )

    process {
        if ($PSCmdlet.ShouldProcess($Id, 'Delete Xurrent person')) {
            Invoke-XurrentRestMethod -Method DELETE -Resource "people/$Id"
        }
    }
}
