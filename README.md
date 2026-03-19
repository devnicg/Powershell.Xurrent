# Powershell.Xurrent

A PowerShell module for querying and managing the [Xurrent REST API](https://developer.xurrent.com/v1/).  
Provides complete CRUD support for Requests, People, Teams, Organizations, Services, Service Instances, Tasks, Changes, Problems, Sites, and Time Entries.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Getting Started](#getting-started)
  - [Connecting](#connecting)
  - [Disconnecting](#disconnecting)
- [Cmdlet Reference](#cmdlet-reference)
  - [Connection](#connection)
  - [Requests](#requests)
  - [Notes](#notes)
  - [People](#people)
  - [Teams](#teams)
  - [Organizations](#organizations)
  - [Services](#services)
  - [Service Instances](#service-instances)
  - [Tasks](#tasks)
  - [Changes](#changes)
  - [Problems](#problems)
  - [Sites](#sites)
  - [Time Entries](#time-entries)
  - [Generic Query](#generic-query)
- [Advanced Usage](#advanced-usage)
  - [Filtering Results](#filtering-results)
  - [Pagination](#pagination)
  - [Selecting Fields](#selecting-fields)
  - [Custom Fields](#custom-fields)
  - [Pipeline Support](#pipeline-support)
  - [WhatIf and Confirm](#whatif-and-confirm)
- [Contributing](#contributing)
- [License](#license)

---

## Requirements

- PowerShell **7.0** or later
- A valid Xurrent API token and account identifier

---

## Installation

### From the PowerShell Gallery (recommended)

```powershell
Install-Module -Name Xurrent
```

### Manual installation

1. Clone or download this repository.
2. Copy the `Xurrent/` folder to a directory in your `$env:PSModulePath`.
3. Import the module:

```powershell
Import-Module Xurrent
```

---

## Getting Started

### Connecting

Before using any other cmdlet, establish a connection with `Connect-Xurrent`.

```powershell
# Connect to the EU region (default)
Connect-Xurrent -ApiToken 'your-api-token' -Account 'your-account'

# Connect to a specific region
Connect-Xurrent -ApiToken 'your-api-token' -Account 'your-account' -Region 'US'

# Connect using a custom base URI (on-premises / sandbox)
Connect-Xurrent -ApiToken 'your-api-token' -Account 'your-account' -BaseUri 'https://sandbox.example.com/v1'
```

Supported regions: `EU` (default), `US`, `AU`, `UK`, `CH`, `QA`.

> **Security tip:** Avoid storing your API token in plain text. Use `Read-Host -AsSecureString` or a secrets manager to retrieve it at runtime.

### Disconnecting

```powershell
Disconnect-Xurrent
```

Clears the stored connection context. Subsequent cmdlet calls will fail until you call `Connect-Xurrent` again.

---

## Cmdlet Reference

### Connection

| Cmdlet | Description |
|--------|-------------|
| `Connect-Xurrent` | Stores API credentials for all subsequent calls |
| `Disconnect-Xurrent` | Clears the stored connection context |

---

### Requests

Manage service requests, incidents, RFCs, RFIs, complaints, and compliments.

#### `Get-XurrentRequest`

```powershell
# List the first page of requests
Get-XurrentRequest

# Retrieve a single request by ID
Get-XurrentRequest -Id 12345

# Filter requests and retrieve all pages
Get-XurrentRequest -Filter @{ status = 'in_progress'; category = 'incident' } -AllPages

# Control page size
Get-XurrentRequest -PerPage 50
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Id` | `int` | ID of a specific request. Accepts pipeline input. |
| `-Filter` | `hashtable` | Key/value pairs mapped to `filter[key]=value` query parameters. |
| `-Fields` | `string` | Comma-separated list of fields to return (e.g. `'id,subject,status'`). |
| `-PerPage` | `int` | Records per page (1–100, default 25). |
| `-AllPages` | `switch` | Follow pagination and return all matching records. |

#### `New-XurrentRequest`

```powershell
# Minimal request
New-XurrentRequest -Subject 'Email not working' -Category 'incident'

# Request with assignment and impact
New-XurrentRequest -Subject 'New laptop' -Category 'rfc' -Impact 'medium' -TeamId 101

# Request with a template and custom fields
New-XurrentRequest -Subject 'Onboarding' -TemplateId 42 -CustomFields @{
    first_name = 'Howard'
    last_name  = 'Tanner'
    start_date = '2026-04-01'
}
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Subject` | `string` | **(Required)** Request subject / title. |
| `-Category` | `string` | `incident` (default), `rfc`, `rfi`, `complaint`, `compliment`, `other`. |
| `-Impact` | `string` | `top`, `high`, `medium`, `low`, `none`. |
| `-Status` | `string` | Initial status (e.g. `new`, `assigned`, `in_progress`). |
| `-Note` | `string` | Text of an initial note. |
| `-ServiceInstanceId` | `int` | ID of the service instance to associate. |
| `-TeamId` | `int` | ID of the team to assign. |
| `-MemberId` | `int` | ID of the person to assign. |
| `-RequestedById` | `int` | ID of the person on whose behalf the request is submitted. |
| `-TemplateId` | `int` | ID of a request template to apply. |
| `-CustomFields` | `hashtable` | Custom field values (see [Custom Fields](#custom-fields)). |
| `-AdditionalProperties` | `hashtable` | Any other API fields not covered by explicit parameters. |

#### `Set-XurrentRequest`

```powershell
# Update status
Set-XurrentRequest -Id 12345 -Status 'solved'

# Reassign and change impact
Set-XurrentRequest -Id 12345 -TeamId 202 -Impact 'high'

# Update custom fields
Set-XurrentRequest -Id 12345 -CustomFields @{ badge = 'VIP' }
```

Accepts the same optional parameters as `New-XurrentRequest` (except `-Note` and `-RequestedById`), plus `-Subject`. Only the fields you provide are changed (PATCH semantics).

#### `Remove-XurrentRequest`

```powershell
Remove-XurrentRequest -Id 12345
```

---

### Notes

#### `Add-XurrentNote`

```powershell
# Public note (visible to requester)
Add-XurrentNote -RequestId 12345 -Text 'Working on this now.'

# Internal note (visible to agents only)
Add-XurrentNote -RequestId 12345 -Text 'Escalated to L2.' -Internal
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `-RequestId` | `int` | **(Required)** ID of the request to add the note to. |
| `-Text` | `string` | **(Required)** Note content. |
| `-Internal` | `switch` | When set, the note is internal (not visible to the requester). |

---

### People

```powershell
# List all people
Get-XurrentPerson -AllPages

# Get a specific person
Get-XurrentPerson -Id 99

# Create a person
New-XurrentPerson -PrimaryEmail 'bob@example.com' -Name 'Bob Smith' `
    -JobTitle 'Engineer' -OrganizationId 5 -TimeZone 'Europe/Amsterdam'

# Update a person
Set-XurrentPerson -Id 99 -JobTitle 'Senior Engineer'

# Delete a person
Remove-XurrentPerson -Id 99
```

`New-XurrentPerson` parameters: `-PrimaryEmail` (required), `-Name` (required), `-JobTitle`, `-OrganizationId`, `-SiteId`, `-TimeZone`, `-Language`, `-AdditionalProperties`.

---

### Teams

```powershell
Get-XurrentTeam
Get-XurrentTeam -Id 10
New-XurrentTeam -Name 'Service Desk' -ManagerId 42
Set-XurrentTeam -Id 10 -Name 'IT Service Desk'
```

`New-XurrentTeam` parameters: `-Name` (required), `-ManagerId`, `-AdditionalProperties`.

---

### Organizations

```powershell
Get-XurrentOrganization
Get-XurrentOrganization -Id 5
New-XurrentOrganization -Name 'Acme Corp' -ManagerId 1
Set-XurrentOrganization -Id 5 -Name 'Acme Corporation'
```

`New-XurrentOrganization` parameters: `-Name` (required), `-ManagerId`, `-ParentId`, `-AdditionalProperties`.

---

### Services

```powershell
Get-XurrentService
Get-XurrentService -Id 7
New-XurrentService -Name 'Email' -ServiceOwnerId 42
Set-XurrentService -Id 7 -Name 'Corporate Email'
```

`New-XurrentService` parameters: `-Name` (required), `-ServiceOwnerId`, `-AdditionalProperties`.

---

### Service Instances

```powershell
Get-XurrentServiceInstance
Get-XurrentServiceInstance -Id 20
New-XurrentServiceInstance -Name 'Email - Production' -ServiceId 7 -Status 'operational'
Set-XurrentServiceInstance -Id 20 -Status 'degraded'
```

`New-XurrentServiceInstance` parameters: `-Name` (required), `-ServiceId` (required), `-Status` (`operational`, `degraded`, `disrupted`, `unavailable`), `-AdditionalProperties`.

---

### Tasks

```powershell
Get-XurrentTask
Get-XurrentTask -Id 55
New-XurrentTask -Subject 'Backup database' -WorkflowId 300 -TeamId 10
Set-XurrentTask -Id 55 -Status 'completed'
```

`New-XurrentTask` parameters: `-Subject` (required), `-WorkflowId` (required), `-AssignedToId`, `-TeamId`, `-Status`, `-AdditionalProperties`.

---

### Changes

```powershell
Get-XurrentChange
Get-XurrentChange -Id 200
New-XurrentChange -Subject 'Deploy new firewall' -Category 'standard' -Impact 'medium'
Set-XurrentChange -Id 200 -Status 'in_progress'
```

`New-XurrentChange` parameters: `-Subject` (required), `-Category` (`standard`, `non_standard`, `emergency`, `expedited`), `-Impact`, `-Status`, `-ManagerId`, `-AdditionalProperties`.

---

### Problems

```powershell
Get-XurrentProblem
Get-XurrentProblem -Id 88
New-XurrentProblem -Subject 'Recurring login failures' -Impact 'high' -TeamId 10
Set-XurrentProblem -Id 88 -Status 'change_requested'
```

`New-XurrentProblem` parameters: `-Subject` (required), `-Impact`, `-Status`, `-ManagerId`, `-TeamId`, `-AdditionalProperties`.

---

### Sites

```powershell
Get-XurrentSite
Get-XurrentSite -Id 3
New-XurrentSite -Name 'New York Office' -Country 'US' -TimeZone 'America/New_York'
```

`New-XurrentSite` parameters: `-Name` (required), `-Country` (ISO 3166-1 alpha-2), `-TimeZone` (IANA), `-AdditionalProperties`.

---

### Time Entries

```powershell
Get-XurrentTimeEntry
Get-XurrentTimeEntry -Id 500
New-XurrentTimeEntry -PersonId 42 -TimeSpent 60 -RequestId 12345 -Note 'Investigation'
Set-XurrentTimeEntry -Id 500 -TimeSpent 90
```

`New-XurrentTimeEntry` parameters: `-PersonId` (required), `-TimeSpent` (required, minutes), `-Date` (yyyy-MM-dd, defaults to today), `-RequestId`, `-Note`, `-AdditionalProperties`.

---

### Generic Query

Use `Invoke-XurrentQuery` to call any Xurrent API endpoint not covered by a dedicated cmdlet.

```powershell
# GET request with query parameters
Invoke-XurrentQuery -Resource 'requests' -QueryParameters @{ per_page = 10 }

# POST with a request body
Invoke-XurrentQuery -Resource 'requests' -Method POST -Body @{
    subject  = 'New request'
    category = 'incident'
}

# Retrieve all records from a custom endpoint
Invoke-XurrentQuery -Resource 'requests/12345/notes' -AllPages
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Resource` | `string` | **(Required)** API resource path relative to the base URI. |
| `-Method` | `string` | HTTP method: `GET` (default), `POST`, `PATCH`, `DELETE`. |
| `-QueryParameters` | `hashtable` | Query string parameters. |
| `-Body` | `hashtable` | Request body (serialised to JSON). |
| `-AllPages` | `switch` | Follow pagination and return all records. |

---

## Advanced Usage

### Filtering Results

All `Get-*` cmdlets accept a `-Filter` hashtable. Keys correspond to the Xurrent API filter names.

```powershell
# Open high-impact incidents assigned to a specific team
Get-XurrentRequest -Filter @{
    status   = 'in_progress'
    category = 'incident'
    impact   = 'high'
    team_id  = 10
}
```

### Pagination

By default, cmdlets return the first page of results (25 records). Use `-AllPages` to automatically fetch every page.

```powershell
# Retrieve all requests
Get-XurrentRequest -AllPages

# Control how many records are fetched per API call
Get-XurrentRequest -AllPages -PerPage 100
```

### Selecting Fields

Use `-Fields` to limit the response to specific fields, which reduces payload size and speeds up requests.

```powershell
Get-XurrentRequest -Fields 'id,subject,status,team' -AllPages
```

### Custom Fields

When creating or updating requests that use a UI Extension, pass custom field values as a hashtable to `-CustomFields`. The module converts the hashtable to the JSON array format required by the Xurrent API.

```powershell
New-XurrentRequest -Subject 'New employee onboarding' -TemplateId 42 -CustomFields @{
    first_name  = 'Jane'
    last_name   = 'Doe'
    start_date  = '2026-06-01'
    department  = 'Engineering'
}
```

This is equivalent to the API payload:

```json
"custom_fields": [
  { "id": "first_name", "value": "Jane" },
  { "id": "last_name",  "value": "Doe" },
  { "id": "start_date", "value": "2026-06-01" },
  { "id": "department", "value": "Engineering" }
]
```

### Pipeline Support

Most `Get-*` and `Set-*` cmdlets accept `-Id` from the pipeline.

```powershell
# Resolve all in-progress requests
Get-XurrentRequest -Filter @{ status = 'in_progress' } -AllPages |
    Set-XurrentRequest -Status 'solved'

# Add a note to multiple requests
@(1001, 1002, 1003) | Add-XurrentNote -Text 'Scheduled maintenance window'
```

### WhatIf and Confirm

All creation, update, and deletion cmdlets support PowerShell's standard `-WhatIf` and `-Confirm` parameters.

```powershell
# Preview what would be created without actually creating it
New-XurrentRequest -Subject 'Test request' -WhatIf

# Prompt for confirmation before deleting
Remove-XurrentRequest -Id 12345 -Confirm
```

---

## Contributing

Contributions are welcome. Please open an issue or submit a pull request on [GitHub](https://github.com/devnicg/Powershell.Xurrent).

---

## License

This project is licensed under the terms described in the [LICENSE](https://github.com/devnicg/Powershell.Xurrent/blob/master/LICENSE) file.
