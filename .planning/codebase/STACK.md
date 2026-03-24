# Technology Stack

**Analysis Date:** 2026-03-24

## Languages

**Primary:**
- Bash (shell script) - Single executable script: `terraform-credentials-keychain`

**Secondary:**
- HCL (HashiCorp Configuration Language) - Referenced in README for Terraform CLI config (consumer-side only, not in repo)

## Runtime

**Environment:**
- macOS only (explicit dependency on macOS Keychain via `security` CLI)
- Bash (any version supporting `set -euo pipefail` and `[[ ]]` syntax)

**Package Manager:**
- None - single-file script with no build or dependency management

## Frameworks

**Core:**
- None - plain Bash script

**Testing:**
- Not detected

**Build/Dev:**
- Not detected

## Key Dependencies

**Runtime (system tools, must be present on macOS):**
- `security` (macOS built-in) - Reads and writes macOS Keychain via `find-generic-password`, `add-generic-password`, `delete-generic-password` subcommands
- `jq` (external CLI tool) - Parses JSON from stdin during the `store` operation; must be installed separately (e.g., via Homebrew)

**Protocol:**
- Terraform credentials helper protocol - Defines the `get`, `store`, `forget` interface; implemented by this script
  - Reference: https://developer.hashicorp.com/terraform/internals/credentials-helpers

## Configuration

**Environment:**
- No environment variables read
- No `.env` files

**Runtime parameters:**
- Positional arguments only: `<get|store|forget> <hostname>`
- Keychain service namespace hardcoded as `SERVICE="terraform-credentials"` in `terraform-credentials-keychain`

**Build:**
- None

## Platform Requirements

**Development:**
- macOS (required — `security` command is macOS-only)
- `jq` installed

**Production:**
- macOS
- `jq` installed
- Script placed at `~/.terraform.d/plugins/terraform-credentials-keychain` (per README)
- Terraform CLI config (`~/.terraformrc`) referencing `credentials_helper "keychain" {}`

---

*Stack analysis: 2026-03-24*
