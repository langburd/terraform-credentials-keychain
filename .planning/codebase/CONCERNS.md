# Codebase Concerns

**Analysis Date:** 2026-03-24

## Tech Debt

**Deprecated/unmaintained project:**
- Issue: README explicitly points users to a third-party replacement (`bendrucker/terraform-credentials-keychain`), signaling this project is not actively maintained
- Files: `README.md`
- Impact: Security fixes, protocol updates, or macOS API changes will not be addressed
- Fix approach: Either commit to maintenance or archive the repository and make the deprecation notice more prominent

**No tests:**
- Issue: Zero test coverage. No test framework, no test files, no CI pipeline
- Files: `terraform-credentials-keychain`
- Impact: Behavior changes (e.g., the exit-code-44 fix in commit `93d6c76`) cannot be verified automatically; regressions are undetectable
- Fix approach: Add a BATS (Bash Automated Testing System) test suite covering `get`, `store`, and `forget` commands including the not-found and error cases

**No CI/CD:**
- Issue: No `.github/workflows/`, no CI configuration of any kind
- Files: N/A
- Impact: No automated linting (`shellcheck`), no test gate on pull requests, no release automation
- Fix approach: Add a minimal GitHub Actions workflow running `shellcheck` and a BATS test suite

## Security Considerations

**Token value injected into heredoc without sanitization:**
- Risk: If a stored token somehow contains a shell-special sequence (e.g., backtick, `$(…)`), the heredoc in the `get` branch will not expand it — heredoc with unquoted delimiter is safe here — but the behavior relies on implicit assumption rather than explicit quoting. The token is passed via `-w` flag and read back as plain text; if Keychain is compromised the token is exposed in plaintext stdout.
- Files: `terraform-credentials-keychain` (line 53–57)
- Current mitigation: None explicit; heredoc does not perform variable expansion inside the content itself, so risk is low
- Recommendations: Add a comment documenting why the heredoc is safe; consider `printf '{"token": "%s"}\n' "${token}"` with explicit quoting for clarity

**Token passed as command-line argument to `security`:**
- Risk: The `store` command calls `security add-generic-password … -w "${token}"`, passing the token as a command-line argument. On a multi-user or audited system, command-line arguments are visible in process listings (`ps`) and audit logs while the process is running.
- Files: `terraform-credentials-keychain` (line 70)
- Current mitigation: Short-lived process; macOS keychain access controls provide defense in depth
- Recommendations: Use `security`'s stdin input mechanism if available, or document the accepted risk

**No input validation on `TFE_HOSTNAME`:**
- Risk: The hostname argument is passed directly as the `-a` account parameter to `security`. A maliciously crafted hostname value (e.g., containing shell metacharacters or newlines) could cause unexpected behavior.
- Files: `terraform-credentials-keychain` (line 33, lines 39/70/76)
- Current mitigation: Variable is double-quoted in all `security` invocations, which prevents word-splitting and glob expansion
- Recommendations: Add a regex guard validating the hostname is a valid DNS name before use

**Error message from `security` echoed to stderr without sanitization:**
- Risk: On a `get` failure (non-44 exit code), the raw `security` error output captured in `$token` is echoed to stderr. If the error message contains terminal escape sequences, a terminal injection is theoretically possible.
- Files: `terraform-credentials-keychain` (line 48)
- Current mitigation: `security` tool output is generally safe; risk is theoretical
- Recommendations: Quote the variable: `echo "${token}" >&2` (already done — no action needed; the quoting is correct on line 48)

## Fragile Areas

**macOS-only, no portability:**
- Files: `terraform-credentials-keychain`
- Why fragile: Hard dependency on `security(1)` CLI, which is macOS-exclusive. Running on Linux or in CI containers will fail silently or with unhelpful errors.
- Safe modification: Any change must be tested on macOS. Do not introduce Linux-compatible code paths without a full portability rewrite.
- Test coverage: None

**`jq` dependency assumed present but not verified:**
- Files: `terraform-credentials-keychain` (line 64)
- Why fragile: The `store` branch pipes stdin through `jq` with no check that `jq` is installed. If `jq` is absent, the error message (`command not found`) is confusing and the exit code is non-standard.
- Safe modification: Add a preflight check: `command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }`
- Test coverage: None

**`jq` format assumption is strict:**
- Files: `terraform-credentials-keychain` (line 64)
- Why fragile: The `jq` filter `if keys == ["token"] then .token else empty end` requires the JSON object to have exactly one key named `token`. Terraform currently only sends `{"token": "…"}`, but if the protocol is ever extended to include additional fields this will silently fail with "Unknown credentials object format".
- Safe modification: Relax to `.token // empty` and handle the empty case; update comment accordingly
- Test coverage: None

## Missing Critical Features

**No installation script or package distribution:**
- Problem: Users must manually download, chmod, and place the script. README instructions are minimal and do not cover Homebrew, `curl | bash`, or any package manager.
- Blocks: Broad adoption; easy onboarding

**No version identifier:**
- Problem: The script has no version string or `--version` flag. There is no way to confirm which version is installed.
- Blocks: Debugging and support; users cannot report a version when filing issues

## Test Coverage Gaps

**All code paths untested:**
- What's not tested: `get` (success), `get` (not found / exit 44), `get` (other error), `store` (valid token), `store` (invalid JSON format), `forget` (success), `forget` (not found), `forget` (other error), argument count validation
- Files: `terraform-credentials-keychain`
- Risk: Any change to the script can break any behavior unnoticed
- Priority: High

---

*Concerns audit: 2026-03-24*
