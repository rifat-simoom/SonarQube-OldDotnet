# SonarQube-OldDotnet

Minimal .NET solution intended to exercise a Windows GitHub Actions Sonar workflow:

- Installs JDK 17 (Temurin) for `dotnet-sonarscanner`
- Builds with MSBuild
- Runs tests via `vstest.console.exe` by scanning `bin` for `*.Test(s).dll` (excluding `*CoreTests*`)
- Produces TRX output for Sonar (`**/TestResults/*.trx`)
- Contains `Migrations/` and `packages/` folders to validate Sonar exclusions

## Configure GitHub Actions (SonarCloud)

Repository **Secrets**:

- `SONAR_TOKEN` (required)
- `DSSL_USERNAME` / `DSSL_TOKEN` (required if you want to exercise the GitHub Packages NuGet source step; otherwise you can remove/skip that step)

Repository **Variables**:

- `SONAR_PROJECT_KEY` (required)
- `SONAR_PROJECT_NAME` (required)
- `SONAR_ORGANIZATION` (required)
- `SONAR_COVERAGE_EXCLUSIONS` (optional)
- `SONAR_CPD_EXCLUSIONS` (optional)

## Run analysis locally

```powershell
$env:SONAR_TOKEN="..."
$env:SONAR_HOST_URL="https://sonarcloud.io"
$env:SONAR_PROJECT_KEY="..."
$env:SONAR_PROJECT_NAME="..."
$env:SONAR_ORGANIZATION="..."

.\Tools\run-sonar-local.ps1
```
