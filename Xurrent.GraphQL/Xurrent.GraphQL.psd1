@{
    # Module metadata
    RootModule        = 'Xurrent.GraphQL.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'a3b8d4e1-7c2f-4a91-b5e6-9d1f3c8a2b7e'
    Author            = 'Xurrent Module Contributors'
    CompanyName       = 'Community'
    Copyright         = '(c) 2024. All rights reserved.'
    Description       = 'PowerShell module for querying and managing the Xurrent GraphQL API (https://developer.xurrent.com/graphql/). Part of the Powershell.Xurrent project.'
    PowerShellVersion = '7.0'

    # Functions to export
    FunctionsToExport = @(
        # Connection
        'Connect-XurrentGraphQL'
        'Disconnect-XurrentGraphQL'

        # Current user
        'Get-XurrentGraphQLMe'

        # Generic query / mutation
        'Invoke-XurrentGraphQLQuery'
        'Invoke-XurrentGraphQLMutation'

        # Requests
        'Get-XurrentGraphQLRequest'
        'New-XurrentGraphQLRequest'
        'Set-XurrentGraphQLRequest'

        # People
        'Get-XurrentGraphQLPerson'
        'New-XurrentGraphQLPerson'
        'Set-XurrentGraphQLPerson'

        # Teams
        'Get-XurrentGraphQLTeam'

        # Organizations
        'Get-XurrentGraphQLOrganization'

        # Services
        'Get-XurrentGraphQLService'

        # Service Instances
        'Get-XurrentGraphQLServiceInstance'

        # Tasks
        'Get-XurrentGraphQLTask'

        # Changes
        'Get-XurrentGraphQLChange'

        # Problems
        'Get-XurrentGraphQLProblem'

        # Sites
        'Get-XurrentGraphQLSite'

        # Time Entries
        'Get-XurrentGraphQLTimeEntry'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('Xurrent', 'ITSM', 'GraphQL', 'API', '4me', 'Xurrent.GraphQL')
            LicenseUri   = 'https://github.com/devnicg/Powershell.Xurrent/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/devnicg/Powershell.Xurrent'
            ReleaseNotes = 'Initial release: GraphQL API support for Requests, People, Teams, Organizations, Services, ServiceInstances, Tasks, Changes, Problems, Sites, and TimeEntries with cursor-based pagination.'
        }
    }
}
