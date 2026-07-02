#!/usr/bin/env bash

# ==============================================================================
# Script Name: 01-load-metadata.sh
# Description: Dynamically extracts application environment metrics and ingests
#              localized configuration parameters safely into GITHUB_ENV.
# ==============================================================================

set -euo pipefail

echo "================================================================================"
echo "[RUN] Initializing project metadata ingestion phase..."
echo "================================================================================"

# Step 1: Automated extraction of ecosystem baseline configurations from go.mod
if [ -f "go.mod" ]; then
  MODULE_PREFIX=$(awk '/^module / {print $2}' go.mod)
  GO_VERSION=$(awk '/^go / {print $2}' go.mod | cut -d. -f1,2)
  
  echo "MODULE_PREFIX=$MODULE_PREFIX" >> "$GITHUB_ENV"
  echo "GO_VERSION=$GO_VERSION" >> "$GITHUB_ENV"
  echo "  [ v ] Metadata parsed successfully: Module=$MODULE_PREFIX, Go=$GO_VERSION"
else
  echo "  [ x ] Error: Standard framework descriptor (go.mod) not found at root level." >&2
  echo "================================================================================"
  echo "[ERR] Metadata ingestion phase aborted due to missing go.mod descriptor."
  echo "================================================================================"
  exit 1
fi

# Step 2: Ingestion of localized project-specific configurations sheets
CONFIG_FILE=".github/config.txt"

if [ -f "$CONFIG_FILE" ]; then
  echo "  [ . ] Localized configuration sheet found at $CONFIG_FILE. Parsing parameters..."
  while IFS= read -r line || [ -n "$line" ]; do
    # Strip comments and empty structural spacer lines cleanly
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line//[:space:]/}" ]] && continue
    
    echo "$line" >> "$GITHUB_ENV"
    echo "  [ v ] Variable registered in environment: $line"
  done < "$CONFIG_FILE"
else
  echo "  [ ! ] Warning: Localized configuration file ($CONFIG_FILE) is missing."
  echo "  [ . ] Applying global fallback baseline pipeline metrics."
  echo "COVERAGE_THRESHOLD=80" >> "$GITHUB_ENV"
fi

echo "================================================================================"
echo "[OKK] Project metadata and configuration properties loaded successfully."
echo "================================================================================"
exit 0
