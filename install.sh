#!/bin/bash
set -euo pipefail

PLUGIN_DIR="${HOME}/.terraform.d/plugins"
PLUGIN_NAME="terraform-credentials-keychain"
TERRAFORMRC="${HOME}/.terraformrc"

# Preflight — macOS check
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: This script requires macOS." >&2
  exit 1
fi

# Preflight — macOS security CLI check
if ! command -v security >/dev/null 2>&1; then
  echo "Error: macOS 'security' CLI not found." >&2
  exit 1
fi

# Preflight — jq dependency check
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: 'jq' is required. Install via: brew install jq" >&2
  exit 1
fi

# Install the credentials helper
mkdir -p "${PLUGIN_DIR}"
cp "${PLUGIN_NAME}" "${PLUGIN_DIR}/${PLUGIN_NAME}"
chmod +x "${PLUGIN_DIR}/${PLUGIN_NAME}"
echo "Installed ${PLUGIN_DIR}/${PLUGIN_NAME}"

# Patch ~/.terraformrc idempotently
if [[ -f "${TERRAFORMRC}" ]] && grep -qF 'credentials_helper "keychain"' "${TERRAFORMRC}"; then
  echo "credentials_helper already configured in ${TERRAFORMRC}, skipping."
else
  printf '\ncredentials_helper "keychain" {}\n' >> "${TERRAFORMRC}"
  echo "Patched ${TERRAFORMRC}."
fi

echo "Done. Run 'terraform login <hostname>' to store credentials."
