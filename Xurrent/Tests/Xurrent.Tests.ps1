#Requires -Module Pester

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..' 'Xurrent.psd1'
    Import-Module $modulePath -Force
}

Describe 'Connect-Xurrent' {
    BeforeEach {
        Disconnect-Xurrent
    }

    It 'Should store the connection context' {
        Connect-Xurrent -ApiToken 'testtoken' -Account 'myaccount'
        $ctx = & (Get-Module Xurrent) { $Script:XurrentContext }
        $ctx | Should -Not -BeNullOrEmpty
        $ctx.ApiToken | Should -Be 'testtoken'
        $ctx.Account  | Should -Be 'myaccount'
    }

    It 'Should use EU base URI by default' {
        Connect-Xurrent -ApiToken 'testtoken' -Account 'myaccount'
        $ctx = & (Get-Module Xurrent) { $Script:XurrentContext }
        $ctx.BaseUri | Should -Be 'https://api.xurrent.com/v1/'
    }

    It 'Should use US base URI when Region is US' {
        Connect-Xurrent -ApiToken 'testtoken' -Account 'myaccount' -Region 'US'
        $ctx = & (Get-Module Xurrent) { $Script:XurrentContext }
        $ctx.BaseUri | Should -Be 'https://api.xurrent.us/v1/'
    }

    It 'Should accept a custom base URI' {
        Connect-Xurrent -ApiToken 'testtoken' -Account 'myaccount' -BaseUri 'https://sandbox.example.com/v1'
        $ctx = & (Get-Module Xurrent) { $Script:XurrentContext }
        $ctx.BaseUri | Should -Be 'https://sandbox.example.com/v1/'
    }

    It 'Should append trailing slash to BaseUri when missing' {
        Connect-Xurrent -ApiToken 'testtoken' -Account 'myaccount' -BaseUri 'https://sandbox.example.com/v1'
        $ctx = & (Get-Module Xurrent) { $Script:XurrentContext }
        $ctx.BaseUri | Should -Match '/$'
    }
}

Describe 'Disconnect-Xurrent' {
    It 'Should clear the connection context' {
        Connect-Xurrent -ApiToken 'testtoken' -Account 'myaccount'
        Disconnect-Xurrent
        $ctx = & (Get-Module Xurrent) { $Script:XurrentContext }
        $ctx | Should -BeNullOrEmpty
    }
}

Describe 'Get-XurrentContext (private)' {
    It 'Should throw when no connection exists' {
        Disconnect-Xurrent
        { & (Get-Module Xurrent) { Get-XurrentContext } } | Should -Throw '*No Xurrent connection*'
    }

    It 'Should return context when connected' {
        Connect-Xurrent -ApiToken 'tok' -Account 'acc'
        $ctx = & (Get-Module Xurrent) { Get-XurrentContext }
        $ctx | Should -Not -BeNullOrEmpty
    }
}

Describe 'Invoke-XurrentRestMethod (unit - mocked)' {
    BeforeAll {
        Connect-Xurrent -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should call Invoke-RestMethod with correct Authorization header' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 1; subject = 'Test' }
        }

        Invoke-XurrentQuery -Resource 'requests'

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Headers['Authorization'] -eq 'Bearer mocktoken'
        }
    }

    It 'Should call Invoke-RestMethod with correct account header' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 1 }
        }

        Invoke-XurrentQuery -Resource 'people'

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Headers['X-4me-Account'] -eq 'mockaccount'
        }
    }

    It 'Should build correct URI' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 42 }
        }

        Invoke-XurrentQuery -Resource 'requests/42'

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Uri -like '*requests/42*'
        }
    }

    It 'Should send POST body as JSON' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 100 }
        }

        Invoke-XurrentQuery -Resource 'requests' -Method 'POST' -Body @{ subject = 'Test'; category = 'incident' }

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*incident*'
        }
    }
}

Describe 'Get-XurrentRequest' {
    BeforeAll {
        Connect-Xurrent -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should call correct resource path for list' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return @([PSCustomObject]@{ id = 1 }, [PSCustomObject]@{ id = 2 })
        }

        Get-XurrentRequest

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Uri -like '*requests*'
        }
    }

    It 'Should include ID in resource path for single record' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 12345; subject = 'Test request' }
        }

        Get-XurrentRequest -Id 12345

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Uri -like '*requests/12345*'
        }
    }

    It 'Should accept pipeline input for ID' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 99 }
        }

        99 | Get-XurrentRequest

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Uri -like '*requests/99*'
        }
    }
}

Describe 'New-XurrentRequest' {
    BeforeAll {
        Connect-Xurrent -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should POST to requests with subject in body' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 1001; subject = 'Email broken' }
        }

        New-XurrentRequest -Subject 'Email broken' -Category 'incident'

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $Uri -like '*requests*' -and $Body -like '*Email broken*'
        }
    }

    It 'Should include TeamId when specified' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 1002 }
        }

        New-XurrentRequest -Subject 'Test' -TeamId 55

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*55*'
        }
    }

    It 'Should include TemplateId when specified' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 1003 }
        }

        New-XurrentRequest -Subject 'Onboarding' -TemplateId 42

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*template*' -and $Body -like '*42*'
        }
    }

    It 'Should convert CustomFields hashtable to API array format' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 1004 }
        }

        New-XurrentRequest -Subject 'Test CF' -TemplateId 10 -CustomFields @{
            first_name = 'Howard'
            last_name  = 'Tanner'
        }

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*custom_fields*' -and $Body -like '*first_name*' -and $Body -like '*Howard*'
        }
    }
}

Describe 'Set-XurrentRequest' {
    BeforeAll {
        Connect-Xurrent -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should PATCH to requests/{id}' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 12345; status = 'solved' }
        }

        Set-XurrentRequest -Id 12345 -Status 'solved'

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Method -eq 'PATCH' -and $Uri -like '*requests/12345*'
        }
    }

    It 'Should warn when no update properties are provided' {
        Mock -ModuleName Xurrent Invoke-RestMethod {}

        Set-XurrentRequest -Id 12345 3>&1 | Should -Match 'No update properties'
    }

    It 'Should include TemplateId when specified' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 12345 }
        }

        Set-XurrentRequest -Id 12345 -TemplateId 99

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*template*' -and $Body -like '*99*'
        }
    }

    It 'Should include CustomFields when specified' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 12345 }
        }

        Set-XurrentRequest -Id 12345 -CustomFields @{ badge = 'VIP' }

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*custom_fields*' -and $Body -like '*badge*' -and $Body -like '*VIP*'
        }
    }
}

Describe 'Remove-XurrentRequest' {
    BeforeAll {
        Connect-Xurrent -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should DELETE to requests/{id}' {
        Mock -ModuleName Xurrent Invoke-RestMethod { return $null }

        Remove-XurrentRequest -Id 12345 -Confirm:$false

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Method -eq 'DELETE' -and $Uri -like '*requests/12345*'
        }
    }
}

Describe 'Add-XurrentNote' {
    BeforeAll {
        Connect-Xurrent -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should POST to requests/{id}/notes' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 9001; text = 'Working on it' }
        }

        Add-XurrentNote -RequestId 12345 -Text 'Working on it'

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $Uri -like '*requests/12345/notes*'
        }
    }

    It 'Should set internal=true when -Internal switch is used' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 9002 }
        }

        Add-XurrentNote -RequestId 12345 -Text 'Internal note' -Internal

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Body -like '*true*'
        }
    }
}

Describe 'Get-XurrentPerson' {
    BeforeAll {
        Connect-Xurrent -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should GET people list' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return @([PSCustomObject]@{ id = 1; name = 'Alice' })
        }

        Get-XurrentPerson

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Uri -like '*people*' -and $Method -eq 'GET'
        }
    }

    It 'Should GET single person by ID' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 42; name = 'Bob' }
        }

        Get-XurrentPerson -Id 42

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Uri -like '*people/42*'
        }
    }
}

Describe 'New-XurrentPerson' {
    BeforeAll {
        Connect-Xurrent -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should POST to people with email and name' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return [PSCustomObject]@{ id = 200 }
        }

        New-XurrentPerson -PrimaryEmail 'test@example.com' -Name 'Test User'

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $Body -like '*test@example.com*'
        }
    }
}

Describe 'Get-XurrentTeam' {
    BeforeAll {
        Connect-Xurrent -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should GET teams list' {
        Mock -ModuleName Xurrent Invoke-RestMethod {
            return @([PSCustomObject]@{ id = 10; name = 'Service Desk' })
        }

        Get-XurrentTeam

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Uri -like '*teams*'
        }
    }
}

Describe 'Invoke-XurrentQuery' {
    BeforeAll {
        Connect-Xurrent -ApiToken 'mocktoken' -Account 'mockaccount'
    }

    It 'Should default to GET method' {
        Mock -ModuleName Xurrent Invoke-RestMethod { return @() }

        Invoke-XurrentQuery -Resource 'services'

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Method -eq 'GET'
        }
    }

    It 'Should pass query parameters to the URI' {
        Mock -ModuleName Xurrent Invoke-RestMethod { return @() }

        Invoke-XurrentQuery -Resource 'requests' -QueryParameters @{ per_page = '10' }

        Should -Invoke -ModuleName Xurrent -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Uri -like '*per_page*'
        }
    }
}
