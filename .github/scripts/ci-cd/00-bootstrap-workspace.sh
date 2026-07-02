#!/usr/bin/env bash

# ==============================================================================
# Script Name: 00-bootstrap-workspace.sh
# Description: Dynamically provisions central automation components or validates
#              local decoupled directory layouts transparently.
# ==============================================================================

set -euo pipefail

# Infrastructure path pointers
TARGET_SCRIPTS_DIR=".github/scripts/ci-cd"
TARGET_RELEASE_DIR=".github/release"
TEMP_SOURCE_DIR=".github-central-scripts"

echo "================================================================================"
echo "[RUN] Initializing workspace environment evaluation..."
echo "================================================================================"

# DETECTOR STEP: Check if we are running in Centralized or Decoupled mode
if [ ! -d "$TEMP_SOURCE_DIR" ]; then
  echo "  [ . ] Decoupled Execution Detected: Local .github workspace layout is already present."
  echo "  [ v ] Skipping dynamic injection phase safely."
  echo "================================================================================"
  echo "[END] Workspace environment validation finished."
  echo "================================================================================"
  exit 0
fi

echo "  [ . ] Centralized Execution Detected: Dynamic injection phase initialized."

# Step 1: Ensure localized destination layout exists in the active runner
mkdir -p "$TARGET_SCRIPTS_DIR"
mkdir -p "$TARGET_RELEASE_DIR"

# Step 2: Provision scripts payload
if [ -d "$TEMP_SOURCE_DIR/.github/scripts/ci-cd" ]; then
  cp -r "$TEMP_SOURCE_DIR/.github/scripts/ci-cd/"* "$TARGET_SCRIPTS_DIR/"
  echo "  [ v ] Core execution scripts successfully injected into $TARGET_SCRIPTS_DIR/"
else
  echo "  [ x ] Error: Upstream scripts payload missing in temporary space." >&2
  echo "================================================================================"
  echo "[ERR] Workspace bootstrap execution sequence failed."
  echo "================================================================================"
  exit 1
fi

# Step 3: Provision GoReleaser static profiles
if [ -f "$TEMP_SOURCE_DIR/.github/release/config.yaml" ]; then
  cp "$TEMP_SOURCE_DIR/.github/release/config.yaml" "$TARGET_RELEASE_DIR/config.yaml"
  echo "  [ v ] GoReleaser static configuration sheets injected into $TARGET_RELEASE_DIR/"
fi

# Step 4: Cleanup workspace metadata footprints
rm -rf "$TEMP_SOURCE_DIR"

echo "================================================================================"
echo "[OKK] Environment bootstrap sequence completed successfully."
echo "================================================================================"
exit 0
