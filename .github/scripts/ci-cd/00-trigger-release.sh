#!/usr/bin/env bash

# ==============================================================================
# Script Name: trigger-release.sh
# Description: Triggers the GitHub Actions CI/CD pipeline by pushing an empty 
#              commit to the main branch. Supports both automatic semantic 
#              incrementing and explicit manual version targeting.
# ==============================================================================

# Exit immediately if any command fails or if an uninitialized variable is used
set -euo pipefail

echo "================================================================================"
echo "[RUN] Initializing pipeline release sequence trigger..."
echo "================================================================================"

# ------------------------------------------------------------------------------
# Configuration & Safety Checks
# ------------------------------------------------------------------------------
TARGET_BRANCH="main"

# Ensure the execution happens from within a Git repository root
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "  [ x ] Error: This script must be executed inside a Git repository." >&2
  echo "================================================================================"
  echo "[ERR] Release sequence aborted due to environment mismatch."
  echo "================================================================================"
  exit 1
fi

# Ensure the local repository is currently on the targeted main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$TARGET_BRANCH" ]; then
  echo "  [ x ] Error: You are on branch '$CURRENT_BRANCH'." >&2
  echo "        Switch to '$TARGET_BRANCH' before triggering a release." >&2
  echo "================================================================================"
  echo "[ERR] Release sequence aborted due to incorrect target branch."
  echo "================================================================================"
  exit 1
fi

# Check if there are any uncommitted local architectural changes
if ! git diff-index --quiet HEAD --; then
  echo "  [ x ] Error: You have uncommitted modifications in your workspace." >&2
  echo "        Stash or commit them before triggering a release sequence." >&2
  echo "================================================================================"
  echo "[ERR] Release sequence aborted due to dirty working tree."
  echo "================================================================================"
  exit 1
fi

# ------------------------------------------------------------------------------
# Version Logic Processing
# ------------------------------------------------------------------------------
# If an argument is provided (e.g., ./trigger-release.sh v1.2.0), use it as manual override.
# Otherwise, create a technical standard commit to let the pipeline handle automatic incrementing (+1 patch).
if [ $# -gt 0 ]; then
  VERSION_INPUT="$1"
  
  # Enforce standard formatting for safety (ensures input starts with v followed by a number)
  if [[ ! "$VERSION_INPUT" =~ ^v[0-9]+ ]]; then
    echo "  [ x ] Error: Invalid version format structure." >&2
    echo "        Example usage configuration: $0 v1.0.0" >&2
    echo "================================================================================"
    echo "[ERR] Release sequence aborted due to semantic versioning validation failure."
    echo "================================================================================"
    exit 1
  fi
  
  COMMIT_MSG="release: $VERSION_INPUT"
  echo "  [ . ] Preparing manual targeted release: $VERSION_INPUT"
else
  COMMIT_MSG="chore: trigger automatic release pipeline"
  echo "  [ . ] Preparing automated semantic patch increment (+1)..."
fi

# ------------------------------------------------------------------------------
# Execution Phase
# ------------------------------------------------------------------------------
echo "  [ . ] Creating empty infrastructure deployment commit..."
git commit --allow-empty -m "$COMMIT_MSG" --quiet

echo "  [ . ] Uploading trigger upstream to remote targets (origin/$TARGET_BRANCH)..."
git push origin "$TARGET_BRANCH" --quiet

echo "================================================================================"
echo "[OKK] The remote CI/CD workflow pipeline has been successfully triggered."
echo "================================================================================"
exit 0
