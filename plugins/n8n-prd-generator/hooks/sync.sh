#!/usr/bin/env bash
# Auto-update n8n-prd-generator plugin skills on session start.
# Clones/pulls the toolkit repo into persistent plugin data, then copies
# fresh skill files into the plugin runtime directory.

set -euo pipefail

PLUGIN_NAME="n8n-prd-generator"
REPO_URL="https://github.com/jonmcgee37/n8n-automations-toolkit.git"
REPO_DIR="${CLAUDE_PLUGIN_DATA}/repo"
SKILLS_SRC="${REPO_DIR}/plugins/${PLUGIN_NAME}/skills"
SKILLS_DST="${CLAUDE_PLUGIN_ROOT}/skills"

# Clone or pull
if [ ! -d "${REPO_DIR}/.git" ]; then
  git clone --quiet --depth 1 "${REPO_URL}" "${REPO_DIR}" 2>/dev/null || {
    echo "[n8n-toolkit] ${PLUGIN_NAME}: could not clone (offline?)"
    exit 0
  }
else
  git -C "${REPO_DIR}" pull --quiet --depth 1 2>/dev/null || {
    echo "[n8n-toolkit] ${PLUGIN_NAME}: could not pull (offline?)"
    exit 0
  }
fi

# Copy updated skills into plugin runtime
if [ -d "${SKILLS_SRC}" ]; then
  rm -rf "${SKILLS_DST}"
  cp -R "${SKILLS_SRC}" "${SKILLS_DST}"
  echo "[n8n-toolkit] ${PLUGIN_NAME} skills updated to latest"
else
  echo "[n8n-toolkit] ${PLUGIN_NAME}: skills source not found in repo"
fi

exit 0
