# Powershell.Xurrent

PowerShell modules for querying and managing the [Xurrent](https://developer.xurrent.com/) platform. This project provides two separate modules:

- **Xurrent.REST** — Wraps the [Xurrent REST API](https://developer.xurrent.com/v1/) with full CRUD support.
- **Xurrent.GraphQL** — Wraps the [Xurrent GraphQL API](https://developer.xurrent.com/graphql/) with query, mutation, and cursor-based pagination support.

Both modules support Requests, People, Teams, Organizations, Services, Service Instances, Tasks, Changes, Problems, Sites, and Time Entries.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Xurrent.REST Module](#xurrentrest-module)
  - [Connecting (REST)](#connecting-rest)
  - [REST Cmdlet Reference](#rest-cmdlet-reference)
  - [REST Advanced Usage](#rest-advanced-usage)
- [Xurrent.GraphQL Module](#xurrentgraphql-module)
  - [Connecting (GraphQL)](#connecting-graphql)
  - [GraphQL Cmdlet Reference](#graphql-cmdlet-reference)
  - [GraphQL Advanced Usage](#graphql-advanced-usage)
- [Contributing](#contributing)
- [License](#license)

---

## Requirements

- PowerShell **7.0** or later
- A valid Xurrent API token (Personal Access Token or OAuth token) and account identifier

---

## Installation

### From the PowerShell Gallery (recommended)

```powershell
# Install the REST module
Install-Module -Name Xurrent.REST

# Install the GraphQL module
Install-Module -Name Xurrent.GraphQL
```

### Manual installation

1. Clone or download this repository.
2. Copy the `Xurrent.REST/` and/or `Xurrent.GraphQL/` folders to a directory in your `$env:PSModulePath`.
3. Import the module you need:

```powershell
Import-Module Xurrent.REST
# or
Import-Module Xurrent.GraphQL
```

---

## Xurrent.REST Module

The REST module provides full CRUD operations against the Xurrent REST API (`https://api.xurrent.com/v1/`).

### Connecting (REST)

```powershell
# Connect to the EU region (default)
Connect-Xurrent -ApiToken 'your-api-token' -Account 'your-account'

# Connect to a specific region
Connect-Xurrent -ApiToken 'your-api-token' -Account 'your-account' -Region 'US'

# Connect using a custom base URI (on-premises / sandbox)
Connect-Xurrent -ApiToken 'your-api-token' -Account 'your-account' -BaseUri 'https://sandbox.example.com/v1'

# Disconnect
Disconnect-Xurrent
```

Supported regions: `EU` (default), `US`, `AU`, `UK`, `CH`, `QA`.

> **Security tip:** Avoid storing your API token in plain text. Use `Read-Host -AsSecureString` or a secrets manager.

### REST Cmdlet Reference

| Cmdlet | Description |
|--------|-------------|
| `Connect-Xurrent` | Stores API credentials for all subsequent calls |
| `Disconnect-Xurrent` | Clears the stored connection context |
| `Invoke-XurrentQuery` | Execute any REST API call with full control |
| `Get-XurrentRequest` | List or retrieve requests |
| `New-XurrentRequest` | Create a new request |
| `Set-XurrentRequest` | Update an existing request |
| `Remove-XurrentRequest` | Delete a request |
| `Add-XurrentNote` | Add a note to a request |
| `Get-XurrentPerson` | List or retrieve people |
| `New-XurrentPerson` | Create a person |
| `Set-XurrentPerson` | Update a person |
| `Remove-XurrentPerson` | Delete a person |
| `Get-XurrentTeam` | List or retrieve teams |
| `New-XurrentTeam` | Create a team |
| `Set-XurrentTeam` | Update a team |
| `Get-XurrentOrganization` | List or retrieve organizations |
| `New-XurrentOrganization` | Create an organization |
| `Set-XurrentOrganization` | Update an organization |
| `Get-XurrentService` | List or retrieve services |
| `New-XurrentService` | Create a service |
| `Set-XurrentService` | Update a service |
| `Get-XurrentServiceInstance` | List or retrieve service instances |
| `New-XurrentServiceInstance` | Create a service instance |
| `Set-XurrentServiceInstance` | Update a service instance |
| `Get-XurrentTask` | List or retrieve tasks |
| `New-XurrentTask` | Create a task |
| `Set-XurrentTask` | Update a task |
| `Get-XurrentChange` | List or retrieve changes |
| `New-XurrentChange` | Create a change |
| `Set-XurrentChange` | Update a change |
| `Get-XurrentProblem` | List or retrieve problems |
| `New-XurrentProblem` | Create a problem |
| `Set-XurrentProblem` | Update a problem |
| `Get-XurrentSite` | List or retrieve sites |
| `New-XurrentSite` | Create a site |
| `Get-XurrentTimeEntry` | List or retrieve time entries |
| `New-XurrentTimeEntry` | Create a time entry |
| `Set-XurrentTimeEntry` | Update a time entry |

### REST Advanced Usage

#### Filtering

```powershell
Get-XurrentRequest -Filter @{ status = 'in_progress'; category = 'incident' } -AllPages
```

#### Pagination

```powershell
Get-XurrentRequest -AllPages -PerPage 100
```

#### Selecting Fields

```powershell
Get-XurrentRequest -Fields 'id,subject,status,team' -AllPages
```

#### Custom Fields

```powershell
New-XurrentRequest -Subject 'Onboarding' -TemplateId 42 -CustomFields @{
    first_name = 'Jane'
    last_name  = 'Doe'
    start_date = '2026-06-01'
}
```

#### Pipeline Support

```powershell
Get-XurrentRequest -Filter @{ status = 'in_progress' } -AllPages |
    Set-XurrentRequest -Status 'solved'
```

#### WhatIf and Confirm

```powershell
New-XurrentRequest -Subject 'Test request' -WhatIf
Remove-XurrentRequest -Id 12345 -Confirm
```

---

## Xurrent.GraphQL Module

The GraphQL module wraps the [Xurrent GraphQL API](https://developer.xurrent.com/graphql/) with cursor-based pagination, strongly-typed mutations, and flexible field selection.

### Connecting (GraphQL)

```powershell
# Connect to the global endpoint (default)
Connect-XurrentGraphQL -ApiToken 'your-api-token' -Account 'your-account'

# Connect to a specific region
Connect-XurrentGraphQL -ApiToken 'your-api-token' -Account 'your-account' -Region 'AU'

# Connect using a custom endpoint
Connect-XurrentGraphQL -ApiToken 'your-api-token' -Account 'your-account' -BaseUri 'https://custom.graphql.example.com'

# Disconnect
Disconnect-XurrentGraphQL
```

Supported regions: `Global` (default), `AU`, `QA`, `QA-AU`.

| Region | Endpoint |
|--------|----------|
| `Global` | `https://graphql.xurrent.com/` |
| `AU` | `https://graphql.au.xurrent.com/` |
| `QA` | `https://graphql.xurrent.qa/` |
| `QA-AU` | `https://graphql.au.xurrent.qa/` |

### GraphQL Cmdlet Reference

| Cmdlet | Description |
|--------|-------------|
| `Connect-XurrentGraphQL` | Stores API credentials for GraphQL calls |
| `Disconnect-XurrentGraphQL` | Clears the GraphQL connection context |
| `Get-XurrentGraphQLMe` | Get the current authenticated user |
| `Invoke-XurrentGraphQLQuery` | Execute any GraphQL query |
| `Invoke-XurrentGraphQLMutation` | Execute any GraphQL mutation |
| `Get-XurrentGraphQLRequest` | Query requests |
| `New-XurrentGraphQLRequest` | Create a request (requestCreate mutation) |
| `Set-XurrentGraphQLRequest` | Update a request (requestUpdate mutation) |
| `Get-XurrentGraphQLPerson` | Query people |
| `New-XurrentGraphQLPerson` | Create a person (personCreate mutation) |
| `Set-XurrentGraphQLPerson` | Update a person (personUpdate mutation) |
| `Get-XurrentGraphQLTeam` | Query teams |
| `Get-XurrentGraphQLOrganization` | Query organizations |
| `Get-XurrentGraphQLService` | Query services |
| `Get-XurrentGraphQLServiceInstance` | Query service instances |
| `Get-XurrentGraphQLTask` | Query tasks |
| `Get-XurrentGraphQLChange` | Query changes |
| `Get-XurrentGraphQLProblem` | Query problems |
| `Get-XurrentGraphQLSite` | Query sites |
| `Get-XurrentGraphQLTimeEntry` | Query time entries |

### GraphQL Advanced Usage

#### Current User

```powershell
Get-XurrentGraphQLMe
Get-XurrentGraphQLMe -Fields 'id name primaryEmail account { id name }'
```

#### Custom Queries

```powershell
Invoke-XurrentGraphQLQuery -Query '{ me { id name primaryEmail } }'

# Query with variables
Invoke-XurrentGraphQLQuery -Query 'query($id: ID!) { request(id: $id) { id subject status } }' `
    -Variables @{ id = 'NG1lLTEyMzQ1' }
```

#### Custom Mutations

```powershell
$mutation = @'
mutation($input: RequestCreateInput!) {
    requestCreate(input: $input) {
        errors { path message }
        request { id requestId subject }
    }
}
'@
Invoke-XurrentGraphQLMutation -Mutation $mutation -Variables @{
    input = @{ subject = 'New request'; category = 'other' }
}
```

#### Field Selection

All `Get-*` cmdlets accept a `-Fields` parameter to control which GraphQL fields are returned:

```powershell
Get-XurrentGraphQLRequest -Fields 'id requestId subject status team { name } member { name }'
Get-XurrentGraphQLPerson -Fields 'id name primaryEmail organization { name }'
```

#### Cursor-based Pagination

```powershell
# Automatic pagination - returns all results
Get-XurrentGraphQLRequest -AllPages

# Control page size
Get-XurrentGraphQLRequest -First 100 -AllPages

# Manual pagination with custom queries
$query = @'
query($first: Int, $after: String) {
    requests(first: $first, after: $after) {
        nodes { id subject status }
        pageInfo { endCursor hasNextPage }
    }
}
'@
Invoke-XurrentGraphQLQuery -Query $query -Variables @{ first = 100 } -AllPages
```

#### Creating Records

```powershell
# Create a request
New-XurrentGraphQLRequest -Subject 'Email not working' -Category 'incident'

# Create a request with team assignment
New-XurrentGraphQLRequest -Subject 'New laptop' -Category 'rfc' -TeamId 'NG1lLTEwMQ'

# Create a person
New-XurrentGraphQLPerson -PrimaryEmail 'bob@example.com' -Name 'Bob Smith' -JobTitle 'Engineer'
```

#### Updating Records

```powershell
# Update request status
Set-XurrentGraphQLRequest -Id 'NG1lLTEyMzQ1' -Status 'in_progress'

# Update a person
Set-XurrentGraphQLPerson -Id 'NG1lLTk5' -JobTitle 'Senior Engineer'
```

#### Pipeline Support

```powershell
Get-XurrentGraphQLRequest -Fields 'id' -AllPages |
    Set-XurrentGraphQLRequest -Status 'solved'
```

#### WhatIf and Confirm

All mutation cmdlets support `-WhatIf` and `-Confirm`:

```powershell
New-XurrentGraphQLRequest -Subject 'Test' -WhatIf
```

### Key Differences: REST vs GraphQL

| Feature | REST Module | GraphQL Module |
|---------|-------------|----------------|
| **IDs** | Numeric IDs (e.g. `12345`) | Node IDs (base64 strings, e.g. `'NG1lLTEyMzQ1'`) |
| **Field selection** | `-Fields 'id,subject,status'` (comma-separated) | `-Fields 'id subject status team { name }'` (GraphQL syntax) |
| **Pagination** | Link header-based (`-AllPages`) | Cursor-based (`first`/`after`, `-AllPages`) |
| **Filtering** | Query parameters (`-Filter @{}`) | GraphQL filter arguments (`-Filter @{}`) |
| **Nested data** | Separate API calls needed | Single query with nested fields |
| **Authentication header** | `X-4me-Account` | `X-Xurrent-Account` |

---

## Contributing

Contributions are welcome. Please open an issue or submit a pull request on [GitHub](https://github.com/devnicg/Powershell.Xurrent).

---

## License

This project is licensed under the terms described in the [LICENSE](https://github.com/devnicg/Powershell.Xurrent/blob/master/LICENSE) file.
