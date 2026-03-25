#!/bin/bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/langburd/terraform-credentials-keychain/master"
PLUGIN_DIR="${HOME}/.terraform.d/plugins"
PLUGIN_NAME="terraform-credentials-keychain"
TERRAFORMRC="${HOME}/.terraformrc"

# Preflight — macOS check
os="$(uname -s)"
if [[ "${os}" != "Darwin" ]]; then
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
if [[ -f "${PLUGIN_NAME}" ]]; then
	cp "${PLUGIN_NAME}" "${PLUGIN_DIR}/${PLUGIN_NAME}"
else
	echo "Downloading ${PLUGIN_NAME}..."
	curl -fsSL "${REPO_RAW}/${PLUGIN_NAME}" -o "${PLUGIN_DIR}/${PLUGIN_NAME}"
fi
chmod +x "${PLUGIN_DIR}/${PLUGIN_NAME}"
echo "Installed ${PLUGIN_DIR}/${PLUGIN_NAME}"

# Patch ~/.terraformrc idempotently
if [[ -f "${TERRAFORMRC}" ]] && grep -qF 'credentials_helper "keychain"' "${TERRAFORMRC}"; then
	echo "credentials_helper already configured in ${TERRAFORMRC}, skipping."
else
	[[ -s "${TERRAFORMRC}" ]] && printf '\n' >>"${TERRAFORMRC}"
	printf 'credentials_helper "keychain" {}\n' >>"${TERRAFORMRC}"
	echo "Patched ${TERRAFORMRC}."
fi

echo "Done. Run 'terraform login <hostname>' to store credentials."
