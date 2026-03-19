# Module-scoped connection context variable
$Script:XurrentContext = $null

# Dot-source all private functions
$privateFiles = Get-ChildItem -Path "$PSScriptRoot\Private" -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue
foreach ($file in $privateFiles) {
    . $file.FullName
}

# Dot-source all public functions
$publicFiles = Get-ChildItem -Path "$PSScriptRoot\Public" -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue
foreach ($file in $publicFiles) {
    . $file.FullName
}

# Export public functions only
Export-ModuleMember -Function ($publicFiles.BaseName)
