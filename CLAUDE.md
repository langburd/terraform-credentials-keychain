# CLAUDE.md — terraform-credentials-keychain (fork)

## Project Context

Single-file Bash credentials helper for macOS Keychain + Terraform. Fork of Alisdair McDiarmid's original.

- Main script: `terraform-credentials-keychain`
- Planning: `.planning/PROJECT.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`
- Codebase map: `.planning/codebase/`

## GSD Workflow

This project uses the GSD planning framework.

- Check project state: `/gsd:progress`
- Plan next phase: `/gsd:plan-phase 1`
- Execute phase: `/gsd:execute-phase 1`

## Code Conventions

- Bash strict mode: `set -euo pipefail`
- Use `[[ ]]` for conditionals (not `[ ]`)
- Quote all variables: `${var}` not `$var`
- Use named variables instead of positional `$1`, `$2`

## Do Not

- Add platform support beyond macOS
- Add dependencies beyond `jq` and macOS built-ins
- Modify credential storage format (must stay Terraform protocol-compatible)
