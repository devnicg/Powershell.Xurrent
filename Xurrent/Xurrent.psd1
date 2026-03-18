@{
    # Module metadata
    RootModule        = 'Xurrent.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '6f7cfaf2-f34c-4266-9e76-854e586f3b2b'
    Author            = 'Xurrent Module Contributors'
    CompanyName       = 'Community'
    Copyright         = '(c) 2024. All rights reserved.'
    Description       = 'PowerShell module for querying and managing the Xurrent REST API (https://developer.xurrent.com/v1/).'
    PowerShellVersion = '7.0'

    # Functions to export
    FunctionsToExport = @(
        # Connection
        'Connect-Xurrent'
        'Disconnect-Xurrent'

        # Generic query
        'Invoke-XurrentQuery'

        # Requests
        'Get-XurrentRequest'
        'New-XurrentRequest'
        'Set-XurrentRequest'
        'Remove-XurrentRequest'

        # Notes
        'Add-XurrentNote'

        # People
        'Get-XurrentPerson'
        'New-XurrentPerson'
        'Set-XurrentPerson'
        'Remove-XurrentPerson'

        # Teams
        'Get-XurrentTeam'
        'New-XurrentTeam'
        'Set-XurrentTeam'

        # Organizations
        'Get-XurrentOrganization'
        'New-XurrentOrganization'
        'Set-XurrentOrganization'

        # Services
        'Get-XurrentService'
        'New-XurrentService'
        'Set-XurrentService'

        # Service Instances
        'Get-XurrentServiceInstance'
        'New-XurrentServiceInstance'
        'Set-XurrentServiceInstance'

        # Tasks
        'Get-XurrentTask'
        'New-XurrentTask'
        'Set-XurrentTask'

        # Changes
        'Get-XurrentChange'
        'New-XurrentChange'
        'Set-XurrentChange'

        # Problems
        'Get-XurrentProblem'
        'New-XurrentProblem'
        'Set-XurrentProblem'

        # Sites
        'Get-XurrentSite'
        'New-XurrentSite'

        # Time Entries
        'Get-XurrentTimeEntry'
        'New-XurrentTimeEntry'
        'Set-XurrentTimeEntry'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('Xurrent', 'ITSM', 'REST', 'API', '4me')
            LicenseUri   = 'https://github.com/devnicg/Powershell.Xurrent/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/devnicg/Powershell.Xurrent'
            ReleaseNotes = 'Initial release: full CRUD support for Requests, People, Teams, Organizations, Services, ServiceInstances, Tasks, Changes, Problems, Sites, and TimeEntries.'
        }
    }
}
