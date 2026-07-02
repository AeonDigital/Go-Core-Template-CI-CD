#!/usr/bin/env bash

# ==============================================================================
# Script Name: 03-pre-build-verify.sh
# Description: Recursively scans the project architecture to validate compilation
#              integrity across all discovered submodules before any release steps.
# ==============================================================================

set -euo pipefail

echo "================================================================================"
echo "[RUN] Initializing pre-flight compilation verification suite..."
echo "================================================================================"

# Target identification: Locate all module descriptors recursively
# Using a temporary file descriptor array to prevent pipeline variable isolation issues
MOD_FILES=$(find . -name "go.mod")

if [ -z "$MOD_FILES" ]; then
  echo "  [ x ] Critical Failure: No standard module descriptors (go.mod) found." >&2
  echo "================================================================================"
  echo "[ERR] Pre-flight compilation suite aborted due to missing code modules."
  echo "================================================================================"
  exit 1
fi

# Track execution state
COMPILATION_FAILED=0

# Iterate through every encountered module context directory
while read -r modfile; do
  # Skip blank streams safely
  [ -z "$modfile" ] && continue
  
  target_dir=$(dirname "$modfile")
  echo "  [ . ] Validating software compilation footprint in: $target_dir"
  
  # Context switch into the evaluated submodule tree directory safely
  # Subshell deployment ensures environment isolation without breaking sequential loops
  (
    cd "$target_dir"
    go build ./...
  ) || {
    echo "  [ x ] Error: Compilation build validation failed inside $target_dir" >&2
    COMPILATION_FAILED=1
  }

done <<< "$MOD_FILES"

# Evaluate global validation matrix pipeline gates
if [ "$COMPILATION_FAILED" -ne 0 ]; then
  echo "================================================================================"
  echo "[ERR] Integration Gate Denied: Architectural compilation errors encountered." >&2
  echo "================================================================================"
  exit 1
fi

echo "================================================================================"
echo "[OKK] Integration Gate Approved: All codebase module structures compiled successfully."
echo "================================================================================"
exit 0
