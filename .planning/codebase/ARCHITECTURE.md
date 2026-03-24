# Architecture

**Analysis Date:** 2026-03-24

## Pattern Overview

**Overall:** Single-file CLI script implementing an external protocol

**Key Characteristics:**
- Self-contained Bash script with no dependencies beyond `security(1)` (macOS built-in) and `jq`
- Implements the [Terraform credentials helper protocol](https://developer.hashicorp.com/terraform/internals/credentials-helpers)
- Invoked by Terraform CLI as a subprocess; communicates via stdin/stdout/exit codes
- No persistent state of its own — all storage is delegated to macOS Keychain

## Layers

**Argument Parsing:**
- Purpose: Validate and bind positional arguments
- Location: `terraform-credentials-keychain` (lines 27–33)
- Contains: Arity check, `COMMAND` and `TFE_HOSTNAME` variable assignment
- Depends on: Bash built-ins only
- Used by: Command dispatch (case statement)

**Command Dispatch:**
- Purpose: Route to the correct operation based on the first argument
- Location: `terraform-credentials-keychain` (lines 35–87)
- Contains: `case` statement with `get`, `store`, `forget`, and fallthrough-to-usage branches
- Depends on: Argument parsing layer
- Used by: Terraform CLI (external caller)

**Keychain I/O:**
- Purpose: Read/write/delete tokens in macOS Keychain
- Location: `terraform-credentials-keychain` (lines 39, 70, 76)
- Contains: `security` CLI invocations for `find-generic-password`, `add-generic-password`, `delete-generic-password`
- Depends on: macOS `security(1)` command
- Used by: Each command branch

## Data Flow

**get flow:**

1. Terraform CLI invokes `terraform-credentials-keychain get <hostname>`
2. Script calls `security find-generic-password -s terraform-credentials -a <hostname> -w`
3. If exit code 44 (not found): print `{}` and exit 0 (per protocol — empty credentials)
4. If any other non-zero exit: forward error to stderr and exit with original code
5. If success: emit `{ "token": "<value>" }` JSON to stdout for Terraform to consume

**store flow:**

1. Terraform CLI invokes `terraform-credentials-keychain store <hostname>` and pipes `{"token": "..."}` to stdin
2. Script reads stdin via `jq -r 'if keys == ["token"] then .token else empty end'`
3. If token extraction yields empty string: exit 2 with error message
4. If token present: call `security add-generic-password -U` to upsert the entry

**forget flow:**

1. Terraform CLI invokes `terraform-credentials-keychain forget <hostname>`
2. Script calls `security delete-generic-password -s terraform-credentials -a <hostname>`
3. Exit code 44 (not found) is silently swallowed — idempotent delete
4. Any other non-zero exit is propagated

## Key Abstractions

**Keychain namespace (`SERVICE`):**
- Purpose: Isolate Terraform tokens from other Keychain entries
- Value: `terraform-credentials` (hardcoded constant at line 19)
- Pattern: All `security` calls pass `-s "${SERVICE}"` as the service name

**Hostname as account key:**
- Purpose: Uniquely identify a credential per Terraform registry/enterprise hostname
- Pattern: Passed as `-a "${TFE_HOSTNAME}"` in every `security` invocation

## Entry Points

**Main script:**
- Location: `terraform-credentials-keychain`
- Triggers: Called by Terraform CLI when a credentials helper is configured in `~/.terraformrc`
- Responsibilities: Parse arguments, dispatch to `get`/`store`/`forget`, translate between Terraform JSON protocol and macOS Keychain API

## Error Handling

**Strategy:** Explicit exit-code inspection per `security(1)` call; `set -euo pipefail` for all other errors

**Patterns:**
- Exit code 44 (`errSecItemNotFound`) is treated as a non-error in both `get` and `forget`
- `get` and `forget` use a `ret` variable to capture exit code before `set -e` can abort the script
- Unknown credentials format in `store` exits with code 2
- All other `security` errors are forwarded to stderr with original exit code

## Cross-Cutting Concerns

**Logging:** All error messages written to stderr with `echo "..." >&2`
**Validation:** Argument count enforced at startup; JSON format validated via `jq` in `store`
**Authentication:** None — the script IS the authentication bridge; macOS Keychain handles access control

---

*Architecture analysis: 2026-03-24*
