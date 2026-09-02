# ==============================================================================
# Script Name: 02-run-tests.ps1
# Description: Recursively discovers Go modules and runs test suites,
#              consolidating coverage profiling data inside .github/ directory.
# ==============================================================================

# Ensure execution halts on critical script errors
$ErrorActionPreference = "Stop"

Write-Host "================================================================================"
Write-Host "[RUN] Initializing automated test suite discovery phase..."
Write-Host "================================================================================"

# Resolve the project root dynamically based on GitHub pipeline environments
$WorkspaceRoot = $env:GITHUB_WORKSPACE
if (-not $WorkspaceRoot) {
    $WorkspaceRoot = Get-Location
}

# Define and guarantee the structural existence of the target .github layout
$TargetDirectory = Join-Path $WorkspaceRoot ".github"
if (-not (Test-Path $TargetDirectory)) {
    New-Item -ItemType Directory -Force -Path $TargetDirectory | Out-Null
}

# Define the absolute target path to the unified coverage data payload
$CoveragePath = Join-Path $TargetDirectory "coverage.out"

# Clean up residual coverage profiles from prior pipeline executions if present
if (Test-Path $CoveragePath) {
    Remove-Item $CoveragePath -Force
    Write-Host "  [ . ] Removed residual coverage file profiles from prior executions."
}

# Scan the workspace tree recursively to capture every independent module descriptor
$ModuleFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Filter "go.mod"

if ($ModuleFiles.Count -eq 0) {
    Write-Error "  [ x ] Critical Failure: No module descriptors (go.mod) encountered in this tree."
    Write-Host "================================================================================"
    Write-Host "[ERR] Test matrix suite discovery execution failed."
    Write-Host "================================================================================"
    exit 1
}

foreach ($Module in $ModuleFiles) {
    $ModuleDirectory = $Module.DirectoryName

    Write-Host "`n"
    Write-Host "================================================================================"
    Write-Host "  [RUN] Executing testing matrix target module: $ModuleDirectory"
    Write-Host "================================================================================"

    # Safely step into the active module folder context
    Set-Location $ModuleDirectory

    # Execute native framework tests and stream profiling logs directly to the target output channel
    go test -v -race "-coverprofile=$CoveragePath" -covermode atomic ./...

    # Safely restore execution context back to the project architectural root
    Set-Location $WorkspaceRoot
}

Write-Host "`n"
Write-Host "================================================================================"
Write-Host "[OKK] Automated test suite matrix executions completed successfully."
Write-Host "================================================================================"
exit 0
