#Requires -Module Pester

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..' 'Xurrent.GraphQL.psd1'
    Import-Module $modulePath -Force
}

Describe 'Connect-XurrentGraphQL' {
    BeforeEach {
        Disconnect-XurrentGraphQL
    }

    It 'Should store the connection context' {
        Connect-XurrentGraphQL -ApiToken 'testtoken' -Account 'myaccount'
        $ctx = & (Get-Module Xurrent.GraphQL) { $Script:XurrentGraphQLContext }
        $ctx | Should -Not -BeNullOrEmpty
        $ctx.ApiToken | Should -Be 'testtoken'
        $ctx.Account  | Should -Be 'myaccount'
    }

    It 'Should use Global GraphQL endpoint by default' {
        Connect-XurrentGraphQL -ApiToken 'testtoken' -Account 'myaccount'
        $ctx = & (Get-Module Xurrent.GraphQL) { $Script:XurrentGraphQLContext }
        $ctx.BaseUri | Should -Be 'https://graphql.xurrent.com/'
    }

    It 'Should use AU GraphQL endpoint when Region is AU' {
        Connect-XurrentGraphQL -ApiToken 'testtoken' -Account 'myaccount' -Region 'AU'
        $ctx = & (Get-Module Xurrent.GraphQL) { $Script:XurrentGraphQLContext }
        $ctx.BaseUri | Should -Be 'https://graphql.au.xurrent.com/'
    }

    It 'Should use QA GraphQL endpoint when Region is QA' {
        Connect-XurrentGraphQL -ApiToken 'testtoken' -Account 'myaccount' -Region 'QA'
        $ctx = & (Get-Module Xurrent.GraphQL) { $Script:XurrentGraphQLContext }
        $ctx.BaseUri | Should -Be 'https://graphql.xurrent.qa/'
    }

    It 'Should accept a custom base URI' {
        Connect-XurrentGraphQL -ApiToken 'testtoken' -Account 'myaccount' -BaseUri 'https://custom.graphql.example.com'
        $ctx = & (Get-Module Xurrent.GraphQL) { $Script:XurrentGraphQLContext }
        $ctx.BaseUri | Should -Be 'https://custom.graphql.example.com/'
    }

    It 'Should append trailing slash to BaseUri when missing' {
        Connect-XurrentGraphQL -ApiToken 'testtoken' -Account 'myaccount' -BaseUri 'https://custom.graphql.example.com'
        $ctx = & (Get-Module Xurrent.GraphQL) { $Script:XurrentGraphQLContext }
        $ctx.BaseUri | Should -Match '/$'
    }
}

Describe 'Disconnect-XurrentGraphQL' {
    It 'Should clear the connection context' {
        Connect-XurrentGraphQL -ApiToken 'testtoken' -Account 'myaccount'
        Disconnect-XurrentGraphQL
        $ctx = & (Get-Module Xurrent.GraphQL) { $Script:XurrentGraphQLContext }
        $ctx | Should -BeNullOrEmpty
    }
}

Describe 'Get-XurrentGraphQLContext (private)' {
    It 'Should throw when no connection exists' {
        Disconnect-XurrentGraphQL
        { & (Get-Module Xurrent.GraphQL) { Get-XurrentGraphQLContext } } | Should -Throw '*No Xurrent GraphQL connection*'
    }

    It 'Should return context when connected' {
        Connect-XurrentGraphQL -ApiToken 'tok' -Account 'acc'
        $ctx = & (Get-Module Xurrent.GraphQL) { Get-XurrentGraphQLContext }
        $ctx | Should -Not -BeNullOrEmpty
    }
}

Describe 'Invoke-XurrentGraphQLRequest (unit - mocked)' {
    BeforeAll {
        Connect-XurrentGraphQL -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should call Invoke-RestMethod with correct Authorization header' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {
            return [PSCustomObject]@{ data = [PSCustomObject]@{ me = [PSCustomObject]@{ id = '1'; name = 'Test' } } }
        }

        Invoke-XurrentGraphQLQuery -Query '{ me { id name } }'

        Should -Invoke -ModuleName Xurrent.GraphQL -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Headers['Authorization'] -eq 'Bearer mocktoken'
        }
    }

    It 'Should call Invoke-RestMethod with correct account header' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {
            return [PSCustomObject]@{ data = [PSCustomObject]@{ me = [PSCustomObject]@{ id = '1' } } }
        }

        Invoke-XurrentGraphQLQuery -Query '{ me { id } }'

        Should -Invoke -ModuleName Xurrent.GraphQL -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Headers['X-Xurrent-Account'] -eq 'mockaccount'
        }
    }

    It 'Should POST to the GraphQL endpoint' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {
            return [PSCustomObject]@{ data = [PSCustomObject]@{ me = [PSCustomObject]@{ id = '1' } } }
        }

        Invoke-XurrentGraphQLQuery -Query '{ me { id } }'

        Should -Invoke -ModuleName Xurrent.GraphQL -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $Uri -like '*graphql.xurrent.com*'
        }
    }

    It 'Should include query in request body' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {
            return [PSCustomObject]@{ data = [PSCustomObject]@{ me = [PSCustomObject]@{ id = '1' } } }
        }

        Invoke-XurrentGraphQLQuery -Query '{ me { id name } }'

        Should -Invoke -ModuleName Xurrent.GraphQL -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*me*' -and $Body -like '*query*'
        }
    }

    It 'Should include variables in request body when provided' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {
            return [PSCustomObject]@{ data = [PSCustomObject]@{ request = [PSCustomObject]@{ id = '1'; subject = 'Test' } } }
        }

        Invoke-XurrentGraphQLQuery -Query 'query($id: ID!) { request(id: $id) { id subject } }' -Variables @{ id = 'abc123' }

        Should -Invoke -ModuleName Xurrent.GraphQL -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*variables*' -and $Body -like '*abc123*'
        }
    }
}

Describe 'Get-XurrentGraphQLRequest' {
    BeforeAll {
        Connect-XurrentGraphQL -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should query for single request by ID' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {
            return [PSCustomObject]@{
                data = [PSCustomObject]@{
                    request = [PSCustomObject]@{ id = 'NG1lLTEyMzQ1'; subject = 'Test' }
                }
            }
        }

        Get-XurrentGraphQLRequest -Id 'NG1lLTEyMzQ1'

        Should -Invoke -ModuleName Xurrent.GraphQL -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*request*' -and $Body -like '*NG1lLTEyMzQ1*'
        }
    }

    It 'Should query for request list' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {
            return [PSCustomObject]@{
                data = [PSCustomObject]@{
                    requests = [PSCustomObject]@{
                        nodes = @(
                            [PSCustomObject]@{ id = '1'; subject = 'Request 1' }
                            [PSCustomObject]@{ id = '2'; subject = 'Request 2' }
                        )
                        pageInfo = [PSCustomObject]@{ endCursor = $null; hasNextPage = $false }
                    }
                }
            }
        }

        Get-XurrentGraphQLRequest

        Should -Invoke -ModuleName Xurrent.GraphQL -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*requests*' -and $Body -like '*nodes*'
        }
    }
}

Describe 'New-XurrentGraphQLRequest' {
    BeforeAll {
        Connect-XurrentGraphQL -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should execute requestCreate mutation' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {
            return [PSCustomObject]@{
                data = [PSCustomObject]@{
                    requestCreate = [PSCustomObject]@{
                        errors  = @()
                        request = [PSCustomObject]@{ id = '1'; requestId = 1001; subject = 'Email broken' }
                    }
                }
            }
        }

        New-XurrentGraphQLRequest -Subject 'Email broken' -Category 'incident'

        Should -Invoke -ModuleName Xurrent.GraphQL -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*requestCreate*' -and $Body -like '*Email broken*'
        }
    }
}

Describe 'Set-XurrentGraphQLRequest' {
    BeforeAll {
        Connect-XurrentGraphQL -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should execute requestUpdate mutation' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {
            return [PSCustomObject]@{
                data = [PSCustomObject]@{
                    requestUpdate = [PSCustomObject]@{
                        errors  = @()
                        request = [PSCustomObject]@{ id = 'NG1lLTEyMzQ1'; status = 'in_progress' }
                    }
                }
            }
        }

        Set-XurrentGraphQLRequest -Id 'NG1lLTEyMzQ1' -Status 'in_progress'

        Should -Invoke -ModuleName Xurrent.GraphQL -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*requestUpdate*' -and $Body -like '*in_progress*'
        }
    }

    It 'Should warn when no update properties are provided' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {}

        Set-XurrentGraphQLRequest -Id 'NG1lLTEyMzQ1' 3>&1 | Should -Match 'No update properties'
    }
}

Describe 'Get-XurrentGraphQLMe' {
    BeforeAll {
        Connect-XurrentGraphQL -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should query the me field' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {
            return [PSCustomObject]@{
                data = [PSCustomObject]@{
                    me = [PSCustomObject]@{ id = '1'; name = 'Admin'; primaryEmail = 'admin@example.com' }
                }
            }
        }

        Get-XurrentGraphQLMe

        Should -Invoke -ModuleName Xurrent.GraphQL -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*me*'
        }
    }
}

Describe 'Get-XurrentGraphQLPerson' {
    BeforeAll {
        Connect-XurrentGraphQL -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should query for person list' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {
            return [PSCustomObject]@{
                data = [PSCustomObject]@{
                    people = [PSCustomObject]@{
                        nodes = @([PSCustomObject]@{ id = '1'; name = 'Alice' })
                        pageInfo = [PSCustomObject]@{ endCursor = $null; hasNextPage = $false }
                    }
                }
            }
        }

        Get-XurrentGraphQLPerson

        Should -Invoke -ModuleName Xurrent.GraphQL -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*people*'
        }
    }

    It 'Should query for single person by ID' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {
            return [PSCustomObject]@{
                data = [PSCustomObject]@{
                    person = [PSCustomObject]@{ id = 'NG1lLTk5'; name = 'Bob' }
                }
            }
        }

        Get-XurrentGraphQLPerson -Id 'NG1lLTk5'

        Should -Invoke -ModuleName Xurrent.GraphQL -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*person*' -and $Body -like '*NG1lLTk5*'
        }
    }
}

Describe 'Get-XurrentGraphQLTeam' {
    BeforeAll {
        Connect-XurrentGraphQL -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should query for teams list' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {
            return [PSCustomObject]@{
                data = [PSCustomObject]@{
                    teams = [PSCustomObject]@{
                        nodes = @([PSCustomObject]@{ id = '10'; name = 'Service Desk' })
                        pageInfo = [PSCustomObject]@{ endCursor = $null; hasNextPage = $false }
                    }
                }
            }
        }

        Get-XurrentGraphQLTeam

        Should -Invoke -ModuleName Xurrent.GraphQL -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*teams*'
        }
    }
}

Describe 'Invoke-XurrentGraphQLMutation' {
    BeforeAll {
        Connect-XurrentGraphQL -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should send mutation to API' {
        Mock -ModuleName Xurrent.GraphQL Invoke-RestMethod {
            return [PSCustomObject]@{
                data = [PSCustomObject]@{
                    requestCreate = [PSCustomObject]@{
                        errors  = @()
                        request = [PSCustomObject]@{ id = '1'; subject = 'Test' }
                    }
                }
            }
        }

        $mutation = 'mutation($input: RequestCreateInput!) { requestCreate(input: $input) { errors { path message } request { id subject } } }'
        Invoke-XurrentGraphQLMutation -Mutation $mutation -Variables @{
            input = @{ subject = 'Test'; category = 'other' }
        }

        Should -Invoke -ModuleName Xurrent.GraphQL -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*requestCreate*'
        }
    }
}
