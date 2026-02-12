param(
    [Parameter(Mandatory = $false)]
    [string] $Owner = $env:GITHUB_OWNER,

    [Parameter(Mandatory = $false)]
    [string] $Token = $(if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_PACKAGES_TOKEN)) { $env:GITHUB_PACKAGES_TOKEN } else { $env:DSSL_TOKEN }),

    [Parameter(Mandatory = $false)]
    [string] $Version = $env:NUGET_VERSION,

    [Parameter(Mandatory = $false)]
    [string] $Configuration = "Release"
)

$ErrorActionPreference = "Stop"

function Get-GitHubOwnerFromOrigin {
    $origin = git remote get-url origin 2>$null
    if ([string]::IsNullOrWhiteSpace($origin)) { return $null }

    if ($origin -match "github\.com[:/](?<owner>[^/]+)/(?<repo>[^/]+?)(\.git)?$") {
        return $Matches["owner"]
    }

    return $null
}

if ([string]::IsNullOrWhiteSpace($Owner)) {
    $Owner = Get-GitHubOwnerFromOrigin
}

if ([string]::IsNullOrWhiteSpace($Owner)) {
    throw "Owner is required (set -Owner or GITHUB_OWNER)."
}

if ([string]::IsNullOrWhiteSpace($Token)) {
    throw "Token is required (set -Token or GITHUB_PACKAGES_TOKEN / DSSL_TOKEN). Token must have write:packages."
}

if ([string]::IsNullOrWhiteSpace($Version)) {
    $Version = (Get-Date).ToString("yyyy.MM.dd.HHmmss")
}

$source = "https://nuget.pkg.github.com/$Owner/index.json"

Write-Host "Packing LegacyLib version $Version..."
dotnet pack .\src\LegacyLib\LegacyLib.csproj -c $Configuration -p:PackageVersion=$Version | Out-Host

$nupkgs = Get-ChildItem -Recurse -Filter *.nupkg .\src\LegacyLib\bin\$Configuration | Where-Object { $_.Name -notlike "*.symbols.nupkg" }
if ($nupkgs.Count -eq 0) { throw "No .nupkg found under src\\LegacyLib\\bin\\$Configuration." }

foreach ($pkg in $nupkgs) {
    Write-Host "Pushing $($pkg.FullName) to $source"
    dotnet nuget push "$($pkg.FullName)" --source "$source" --api-key "$Token" --skip-duplicate | Out-Host
}

