# External Integrations

**Analysis Date:** 2026-03-24

## APIs & External Services

**Terraform / HCP Terraform (HashiCorp Cloud Platform):**
- Purpose: Stores and retrieves API tokens for Terraform Enterprise and HCP Terraform hostnames
- Integration type: Credentials helper (not a direct HTTP client — acts as a credential broker for the Terraform CLI)
- Protocol: Terraform credentials helper protocol (stdin/stdout JSON + exit codes)
  - Reference: https://developer.hashicorp.com/terraform/internals/credentials-helpers
- Auth: The script stores tokens for any hostname; typical target is `app.terraform.io`

## Data Storage

**Databases:**
- Not applicable

**File Storage:**
- macOS Keychain (system keychain via `security` CLI)
  - Service namespace: `terraform-credentials` (hardcoded in `terraform-credentials-keychain`)
  - Account key: the Terraform hostname (e.g., `app.terraform.io`)
  - Stored value: bearer token (password field in Keychain generic-password item)
  - Operations:
    - `get` → `security find-generic-password -w`
    - `store` → `security add-generic-password -U`
    - `forget` → `security delete-generic-password`

**Caching:**
- None

## Authentication & Identity

**Auth Provider:**
- macOS Keychain — tokens are protected by OS-level access controls
- No custom auth; the script acts as a storage bridge between Terraform CLI and the Keychain

## Monitoring & Observability

**Error Tracking:**
- None — errors are written to stderr and surfaced to the calling Terraform process

**Logs:**
- None — standard Bash stderr only

## CI/CD & Deployment

**Hosting:**
- Local user machine (not a deployed service)

**CI Pipeline:**
- Not detected

## Environment Configuration

**Required env vars:**
- None

**Secrets location:**
- macOS Keychain (service: `terraform-credentials`, account: hostname)

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- None — the script is invoked synchronously by the Terraform CLI process

---

*Integration audit: 2026-03-24*
