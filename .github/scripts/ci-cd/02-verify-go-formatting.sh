#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02-verify-go-formatting.sh  
# DESCRIPTION: Recursively audits the entire codebase directory using gofumpt layouts
# and executes semantic static analysis via golangci-lint.
# ==============================================================================

set -euo pipefail

echo "=========================================================================="
echo "[RUN] Auditing Go codebase formatting style and semantic rules..."
echo "=========================================================================="

# Ensure gofumpt formatting tool is provisioned on the runner execution context
if ! command -v gofumpt &> /dev/null; then
  echo "  [ . ] gofumpt missing from runner context. Installing latest..."
  go install mvdan.cc/gofumpt@latest
fi

# PHASE 1: Recursive structural formatting check via gofumpt
echo "  [ . ] Evaluating structural layouts against strict gofumpt standards..."
FORMAT_DIFF=$(gofumpt -d . || true)

if [ -n "$FORMAT_DIFF" ]; then
  echo "$FORMAT_DIFF"
  echo "=========================================================================="
  echo "  [ x ] Error: Unformatted Go file structures detected in this commit!"
  echo "        Please execute 'gofumpt -w .' locally to align your codebase."
  echo "=========================================================================="
  echo "[ERR] Quality gate denied: Code style non-compliance."
  echo "=========================================================================="
  exit 1
fi

echo "  [ v ] Success: All Go source files adhere to gofumpt standards."

# PHASE 2: Comprehensive semantic static analysis via golangci-lint
echo "  [ . ] Initializing deep analytical validation checks..."

# Dynamically resolve the structural location of the centralized linter configuration
CONFIG_PATH=".dev/linters/golinter.yaml"

if [ ! -f "$CONFIG_PATH" ]; then
  echo "=========================================================================="
  echo "  [ x ] Error: Centralized configuration file not found at: $CONFIG_PATH"
  echo "        Ensure the .dev submodule is properly initialized in the workspace."
  echo "=========================================================================="
  echo "[ERR] Quality gate denied: Infrastructure layout missing."
  echo "=========================================================================="
  exit 1
fi

# Define the target official version toolchain and binary path
TARGET_LINTER_VERSION="v2.13.2"
LINTER_BIN_DIR="$(go env GOPATH)/bin"
mkdir -p "${LINTER_BIN_DIR}"

# Step 1: Provision the official static binary version if missing
if ! command -v golangci-lint &> /dev/null; then
  echo "  [ . ] golangci-lint engine missing. Fetching official stable runner binary..."
  curl -sSfL https://golangci-lint.run/install.sh | sh -s -- -b "${LINTER_BIN_DIR}" "${TARGET_LINTER_VERSION}"
fi

# Step 2: Validate if the binary execution works or breaks due to Go version mismatch
echo "  [ . ] Validating linter runtime engine readiness..."
if ! golangci-lint linters --config="$CONFIG_PATH" &> /dev/null; then
  echo "  [ ! ] Warning: Static binary execution failed (Go version drift detected)."
  echo "        Activating emergency fallback: Compiling tag ${TARGET_LINTER_VERSION} natively..."
  
  # Remove the broken pre-compiled static binary
  rm -f "${LINTER_BIN_DIR}/golangci-lint"
  
  # Setup localized decoupled workspace for native fallback compilation
  mkdir -p .tmp_linter_build
  cd .tmp_linter_build
  go mod init tmp_linter
  
  # Execute clean native compilation using current compiler
  go get github.com/golangci/golangci-lint/v2@${TARGET_LINTER_VERSION}
  go install github.com/golangci/golangci-lint/cmd/golangci-lint
  
  # Purge localized build environments and step back into workspace
  cd ..
  rm -rf .tmp_linter_build
  echo "  [ v ] Fallback compilation completed successfully using local Go compiler."
fi

# Run the complete static analysis suite recursively from the repository root
if ! golangci-lint run --config="$CONFIG_PATH" ./...; then
  echo "=========================================================================="
  echo "  [ x ] Error: Static analysis or style guide violations discovered!"
  echo "        Review the pipeline log details above to resolve anomalies."
  echo "=========================================================================="
  echo "[ERR] Quality gate denied: Static analysis non-compliance."
  echo "=========================================================================="
  exit 1
fi

echo "=========================================================================="
echo "  [ v ] Success: Codebase complies with all style and semantic rules."
echo "=========================================================================="
echo "[OKK] Quality gate approved."
echo "=========================================================================="
exit 0
