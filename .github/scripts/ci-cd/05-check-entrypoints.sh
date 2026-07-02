#!/usr/bin/env bash

# ==============================================================================
# Script Name: 04-check-entrypoints.sh
# Description: Evaluates the project entrypoints manifest data layer to determine 
#              if the architecture compiles as a binary package application or 
#              operates strictly as a reusable downstream library core.
# ==============================================================================

set -euo pipefail

ENTRY_FILE=".github/entrypoints.txt"
HAS_MAIN="false"

echo "================================================================================"
echo "[RUN] Initializing application entrypoints evaluation gate..."
echo "================================================================================"

# Step 1: Structural existence and data pattern payload validation
if [ -f "$ENTRY_FILE" ]; then
  echo "  [ . ] Structural manifest detected at $ENTRY_FILE. Analyzing active paths..."
  
  # Strip comment references and blank space line elements to isolate structural data
  CLEANED_PATHS=$(grep -v '^#' "$ENTRY_FILE" | grep -v '^[[:space:]]*$' || true)
  
  if [ -n "$CLEANED_PATHS" ]; then
    echo "  [ v ] Active application entrypoint path arrays mapped successfully:"
    while read -r target_path; do
      echo "        -> Compiled Application Target: $target_path"
    done <<< "$CLEANED_PATHS"
    
    HAS_MAIN="true"
  else
    echo "  [ . ] Manifest sheet context is empty or contains only comments."
  fi
else
  echo "  [ ! ] Warning: Architectural manifest file ($ENTRY_FILE) is missing."
fi

# Step 2: Strategy execution dispatch logs
if [ "$HAS_MAIN" = "true" ]; then
  echo "  [ . ] Strategy Decision: Enabling downstream GoReleaser artifact compilation engines."
else
  echo "  [ . ] Strategy Decision: Treating repository strictly as a library. Skipping binary packaging."
fi

# Step 3: Stream integration context states to the active GitHub Runner channel
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "has_main=$HAS_MAIN" >> "$GITHUB_OUTPUT"
  echo "  [ v ] Pipeline variable payload 'has_main=$HAS_MAIN' broadcasted to GITHUB_OUTPUT."
fi

echo "================================================================================"
echo "[OKK] Application entrypoints evaluation sequence completed."
echo "================================================================================"
exit 0
