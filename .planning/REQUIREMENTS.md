# Requirements: terraform-credentials-keychain (fork)

**Defined:** 2026-03-24
**Core Value:** Secure, zero-friction Terraform credential storage on macOS — credentials stored in Keychain, not plaintext files.

## v1 Requirements

### Script

- [x] **SCRPT-01**: Script uses `set -euo pipefail` for strict error handling
- [x] **SCRPT-02**: Script uses `[[ ]]` conditionals and `${var}` quoting throughout
- [x] **SCRPT-03**: Script uses `TFE_HOSTNAME` variable to avoid shadowing bash built-in `$HOSTNAME`
- [x] **SCRPT-04**: `get` returns `{}` with exit 0 when credential not found (errSecItemNotFound)
- [x] **SCRPT-05**: `forget` exits successfully when credential not found (errSecItemNotFound)
- [x] **SCRPT-06**: Script has comprehensive header comments explaining purpose, protocol, usage

### License

- [x] **LIC-01**: LICENSE.md retains original copyright (Alisdair McDiarmid, 2020)
- [x] **LIC-02**: LICENSE.md adds fork author copyright (Avi Langburd, 2026)

### Installation

- [x] **INST-01**: install.sh checks for macOS and `security` CLI before proceeding
- [x] **INST-02**: install.sh copies `terraform-credentials-keychain` to `~/.terraform.d/plugins/`
- [x] **INST-03**: install.sh makes the installed script executable (`chmod +x`)
- [x] **INST-04**: install.sh patches `~/.terraformrc` to add `credentials_helper "keychain" {}` block
- [x] **INST-05**: install.sh is idempotent (safe to run multiple times)

### Documentation

- [x] **DOC-01**: README.md clearly identifies this as a fork and links to upstream
- [x] **DOC-02**: README.md documents install.sh as the recommended installation method
- [x] **DOC-03**: README.md includes manual installation steps as fallback
- [x] **DOC-04**: README.md documents dependencies (jq, macOS)

### Quality Gates

- [ ] **QA-01**: `.pre-commit-config.yaml` includes `shellcheck` hook for shell script linting
- [ ] **QA-02**: `.pre-commit-config.yaml` includes `shfmt` hook for shell formatting
- [ ] **QA-03**: `.pre-commit-config.yaml` includes standard hooks (trailing whitespace, end-of-file fixer, etc.)
- [ ] **QA-04**: All hooks pass on the current codebase

## v2 Requirements

### Installation

- **INST-V2-01**: Homebrew formula for `brew install`
- **INST-V2-02**: Uninstall script

## Out of Scope

| Feature | Reason |
|---------|--------|
| Linux/Windows support | macOS Keychain is the core dependency |
| Multiple credential backends | Single-purpose tool by design |
| CI/CD automated testing | No test framework; script is simple enough |
| OAuth/token refresh | Out of scope for credentials helper protocol |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| SCRPT-01 | Phase 1 | Complete |
| SCRPT-02 | Phase 1 | Complete |
| SCRPT-03 | Phase 1 | Complete |
| SCRPT-04 | Phase 1 | Complete |
| SCRPT-05 | Phase 1 | Complete |
| SCRPT-06 | Phase 1 | Complete |
| LIC-01 | Phase 1 | Complete |
| LIC-02 | Phase 1 | Complete |
| INST-01 | Phase 1 | Complete |
| INST-02 | Phase 1 | Complete |
| INST-03 | Phase 1 | Complete |
| INST-04 | Phase 1 | Complete |
| INST-05 | Phase 1 | Complete |
| DOC-01 | Phase 1 | Complete |
| DOC-02 | Phase 1 | Complete |
| DOC-03 | Phase 1 | Complete |
| DOC-04 | Phase 1 | Complete |
| QA-01 | Phase 1 | Pending |
| QA-02 | Phase 1 | Pending |
| QA-03 | Phase 1 | Pending |
| QA-04 | Phase 1 | Pending |

**Coverage:**
- v1 requirements: 21 total (6 already complete)
- Mapped to phases: 21
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-24*
*Last updated: 2026-03-24 after roadmap creation*
