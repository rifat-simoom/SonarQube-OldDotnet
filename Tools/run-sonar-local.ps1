param(
    [Parameter(Mandatory = $false)]
    [string] $SonarToken = $env:SONAR_TOKEN,

    [Parameter(Mandatory = $false)]
    [string] $SonarHostUrl = $(if ([string]::IsNullOrWhiteSpace($env:SONAR_HOST_URL)) { "https://sonarcloud.io" } else { $env:SONAR_HOST_URL }),

    [Parameter(Mandatory = $false)]
    [string] $ProjectKey = $env:SONAR_PROJECT_KEY,

    [Parameter(Mandatory = $false)]
    [string] $ProjectName = $env:SONAR_PROJECT_NAME,

    [Parameter(Mandatory = $false)]
    [string] $Organization = $env:SONAR_ORGANIZATION,

    [Parameter(Mandatory = $false)]
    [string] $CoverageExclusions = $env:SONAR_COVERAGE_EXCLUSIONS,

    [Parameter(Mandatory = $false)]
    [string] $CpdExclusions = $env:SONAR_CPD_EXCLUSIONS
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($SonarToken)) { throw "SONAR_TOKEN is required." }
if ([string]::IsNullOrWhiteSpace($SonarHostUrl)) { throw "SONAR_HOST_URL is required (e.g. https://sonarcloud.io)." }
if ([string]::IsNullOrWhiteSpace($ProjectKey)) { throw "SONAR_PROJECT_KEY is required." }
if ([string]::IsNullOrWhiteSpace($ProjectName)) { $ProjectName = $ProjectKey }
if ([string]::IsNullOrWhiteSpace($Organization)) { throw "SONAR_ORGANIZATION is required for SonarCloud." }

try {
    dotnet tool update --global dotnet-sonarscanner | Out-Host
}
catch {
    dotnet tool install --global dotnet-sonarscanner | Out-Host
}
$env:PATH += ";$env:USERPROFILE\.dotnet\tools"

$beginArgs = @(
    "sonarscanner", "begin",
    "/k:$ProjectKey",
    "/n:$ProjectName",
    "/o:$Organization",
    "/d:sonar.token=$SonarToken",
    "/d:sonar.host.url=$SonarHostUrl",
    "/d:sonar.cs.vstest.reportsPaths=**/TestResults/*.trx",
    "/d:sonar.exclusions=**/Migrations/**,**/packages/**"
)

if (-not [string]::IsNullOrWhiteSpace($CoverageExclusions)) {
    $beginArgs += "/d:sonar.coverage.exclusions=$CoverageExclusions"
}

if (-not [string]::IsNullOrWhiteSpace($CpdExclusions)) {
    $beginArgs += "/d:sonar.cpd.exclusions=$CpdExclusions"
}

dotnet @beginArgs | Out-Host

dotnet build .\SonarOldDotnet.sln -c Release | Out-Host

New-Item -ItemType Directory -Force .\TestResults | Out-Null

$tests = Get-ChildItem -Recurse -Filter *.dll |
    Where-Object { $_.Name -match '(.Test|.Tests).dll$' -and $_.FullName -match '\\bin\\' -and $_.Name -notmatch 'CoreTests' }

if ($tests.Count -eq 0) { throw "No test DLLs found." }

foreach ($dll in $tests) {
    Write-Host "Running tests in $($dll.FullName)"
    dotnet vstest "$($dll.FullName)" --logger:trx --ResultsDirectory:"$PWD\\TestResults" | Out-Host
}

dotnet sonarscanner end "/d:sonar.token=$SonarToken" | Out-Host
