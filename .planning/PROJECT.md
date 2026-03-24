# terraform-credentials-keychain (fork)

## What This Is

A maintained fork of Alisdair McDiarmid's terraform-credentials-keychain — a macOS Keychain-backed Terraform credentials helper. It implements the Terraform credentials helper protocol so tokens for Terraform Enterprise / HCP Terraform hostnames are stored securely in the macOS Keychain rather than in plain-text `~/.terraform.d/credentials.tfrc.json`.

## Core Value

Secure, zero-friction Terraform credential storage on macOS — credentials stored in Keychain, not plaintext files.

## Requirements

### Validated

- ✓ `get` command: retrieves token from Keychain and emits JSON credentials object — existing
- ✓ `get` command: returns `{}` when credential not found (exit 0) — existing
- ✓ `store` command: writes token to Keychain using `jq` to parse stdin JSON — existing
- ✓ `forget` command: removes token from Keychain, exits successfully if not found — existing
- ✓ Script robustness: `set -euo pipefail`, `[[ ]]` conditionals, `${var}` quoting, `TFE_HOSTNAME` var — staged

### Active

- [ ] Update LICENSE.md — keep original copyright + add Avi Langburd 2026
- [ ] Create install.sh — copy script to plugins dir, chmod +x, patch ~/.terraformrc, check deps
- [ ] Update README.md — reflect fork, document install.sh, update usage instructions
- [ ] Add .pre-commit-config.yaml — shellcheck, shfmt, and other suitable hooks for Bash project

### Out of Scope

- Windows/Linux support — macOS Keychain is the explicit platform dependency
- Multiple credential backends — single focused tool
- GUI/wrapper tooling — CLI only

## Context

- Fork of original repo (MIT license, Alisdair McDiarmid 2020)
- Single-file Bash script, no dependencies beyond `jq` and macOS `security` CLI
- Target audience: developers using Terraform Enterprise or HCP Terraform on macOS
- Codebase map: `.planning/codebase/`
- Script improvements already staged (robustness, comments, `TFE_HOSTNAME` variable naming, graceful `forget`)

## Constraints

- **Platform**: macOS only — relies on `security` CLI from macOS Keychain
- **Shell**: Bash — uses `[[ ]]` and other bashisms
- **Dependencies**: `jq` required for `store` command; `security` CLI is macOS built-in

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Keep original MIT copyright + add fork author | Correct attribution for MIT fork | — Pending |
| install.sh patches ~/.terraformrc automatically | Reduces manual setup steps to zero | — Pending |
| shellcheck + shfmt for pre-commit | Industry standard Bash quality gates | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? Move to Out of Scope with reason
2. Requirements validated? Move to Validated with phase reference
3. New requirements emerged? Add to Active
4. Decisions to log? Add to Key Decisions
5. "What This Is" still accurate? Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-03-24 after initialization*
