function Disconnect-Xurrent {
    <#
    .SYNOPSIS
        Clears the current Xurrent connection context.
    .DESCRIPTION
        Removes the module-scoped connection context that was created by
        Connect-Xurrent. After calling this function, all Xurrent commands
        will fail until Connect-Xurrent is called again.
    .EXAMPLE
        Disconnect-Xurrent
    .OUTPUTS
        None.
    #>
    [CmdletBinding()]
    param()

    $Script:XurrentContext = $null
    Write-Verbose 'Disconnected from Xurrent.'
}
