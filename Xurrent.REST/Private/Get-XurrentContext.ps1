function Get-XurrentContext {
    <#
    .SYNOPSIS
        Returns the current Xurrent connection context.
    .DESCRIPTION
        Returns the module-level connection context that was established by Connect-Xurrent.
        Throws an error if no connection has been established.
    .OUTPUTS
        PSCustomObject with connection details (ApiToken, Account, BaseUri).
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    if (-not $Script:XurrentContext) {
        throw 'No Xurrent connection found. Please run Connect-Xurrent first.'
    }

    return $Script:XurrentContext
}
