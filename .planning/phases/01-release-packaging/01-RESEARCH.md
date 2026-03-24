# Phase 1: Release Packaging - Research

**Researched:** 2026-03-24
**Domain:** Bash script packaging — MIT fork licensing, install.sh, pre-commit hooks, README
**Confidence:** HIGH

## Summary

This phase packages a single-file Bash Terraform credentials helper for release. All four work areas (license, install script, documentation, pre-commit quality gates) are well-understood, low-risk tasks with clear correct answers.

The MIT dual-copyright pattern for forks is a settled convention: retain the original copyright line and append a second copyright line for the fork author. The `~/.terraformrc` `credentials_helper` stanza is documented by HashiCorp with a single authoritative format. The pre-commit ecosystem has stable, versioned hooks for shellcheck and shfmt. The install.sh pattern for a single-file Terraform plugin is straightforward.

**Primary recommendation:** Follow exact HashiCorp naming and placement conventions; use the koalaman/shellcheck-precommit and scop/pre-commit-shfmt hooks pinned to current releases.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| LIC-01 | LICENSE.md retains original copyright (Alisdair McDiarmid, 2020) | MIT fork dual-copyright pattern documented below |
| LIC-02 | LICENSE.md adds fork author copyright (Avi Langburd, 2026) | MIT fork dual-copyright pattern documented below |
| INST-01 | install.sh checks for macOS and `security` CLI before proceeding | Preflight check pattern in Architecture Patterns |
| INST-02 | install.sh copies `terraform-credentials-keychain` to `~/.terraform.d/plugins/` | HashiCorp docs confirm this as the correct default search location |
| INST-03 | install.sh makes the installed script executable (`chmod +x`) | Standard install pattern |
| INST-04 | install.sh patches `~/.terraformrc` to add `credentials_helper "keychain" {}` block | Exact stanza documented below; idempotency guard required |
| INST-05 | install.sh is idempotent (safe to run multiple times) | Grep-before-append pattern documented in Architecture Patterns |
| DOC-01 | README.md clearly identifies this as a fork and links to upstream | README structure documented below |
| DOC-02 | README.md documents install.sh as the recommended installation method | README structure documented below |
| DOC-03 | README.md includes manual installation steps as fallback | README structure documented below |
| DOC-04 | README.md documents dependencies (jq, macOS) | Stack documented in STACK.md; included in README section |
| QA-01 | `.pre-commit-config.yaml` includes `shellcheck` hook | Hook ID and rev documented below |
| QA-02 | `.pre-commit-config.yaml` includes `shfmt` hook | Hook ID and rev documented below |
| QA-03 | `.pre-commit-config.yaml` includes standard hooks (trailing whitespace, EOF fixer, etc.) | pre-commit/pre-commit-hooks v6.0.0 documented below |
| QA-04 | All hooks pass on the current codebase | Current script already has set -euo pipefail and proper quoting; shfmt may require minor formatting fixes |
</phase_requirements>

## Standard Stack

### Core

| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| pre-commit framework | latest (pip install pre-commit) | Hook runner | Industry standard for git hooks |
| koalaman/shellcheck-precommit | v0.11.0 | Shell script linting | Official ShellCheck pre-commit integration |
| scop/pre-commit-shfmt | v3.13.0-1 | Shell formatting | Most widely used shfmt pre-commit hook |
| pre-commit/pre-commit-hooks | v6.0.0 | General quality hooks | Universal quality hooks by pre-commit team |

### Supporting

| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| shellcheck (system) | any | ShellCheck binary | Required by shellcheck hook if not using prebuilt |
| shfmt (system) | any | shfmt binary | The scop hook bundles a prebuilt binary — no system install needed |

**Installation (developer machine):**
```bash
pip install pre-commit
pre-commit install
```

**Version verification (confirmed 2026-03-24):**
- shellcheck-precommit: v0.11.0 (latest tag on koalaman/shellcheck-precommit)
- pre-commit-shfmt: v3.13.0-1 (latest tag on scop/pre-commit-shfmt)
- pre-commit-hooks: v6.0.0 (latest release on pre-commit/pre-commit-hooks)

## Architecture Patterns

### Recommended Project Structure (after this phase)

```
terraform-credentials-keychain/   # repo root
├── terraform-credentials-keychain   # the Bash script (already exists)
├── install.sh                       # new: installation script
├── LICENSE.md                       # updated: dual-copyright MIT
├── README.md                        # updated: fork identity + install.sh docs
└── .pre-commit-config.yaml          # new: shellcheck + shfmt + standard hooks
```

### Pattern 1: MIT Fork Dual-Copyright

**What:** Append a second copyright line below the original. The full license body (permissions, conditions, disclaimer) is shared and not duplicated.

**When to use:** Any MIT-licensed fork where you want to retain upstream attribution and add your own.

**Example:**
```
MIT License

Copyright (c) 2020 Alisdair McDiarmid
Copyright (c) 2026 Avi Langburd

Permission is hereby granted, free of charge, to any person obtaining a copy
...
```

Source: OSI MIT license specification + common open-source fork practice (HIGH confidence — this is the near-universal convention).

### Pattern 2: Terraform credentials_helper Stanza

**What:** The exact block to add to `~/.terraformrc` to activate a credentials helper named "keychain".

**When to use:** INST-04 — the install.sh must patch ~/.terraformrc with exactly this block.

**Example:**
```hcl
credentials_helper "keychain" {}
```

The label `"keychain"` maps to the binary name `terraform-credentials-keychain` (prefix `terraform-credentials-` is stripped). The block body can be empty `{}` — the `args` key is optional and not needed here.

Source: https://developer.hashicorp.com/terraform/cli/config/config-file#credentials-helpers (HIGH confidence — official HashiCorp docs)

### Pattern 3: Terraform Plugin Naming Convention

**What:** Credentials helper binaries must be named `terraform-credentials-NAME` and placed in `~/.terraform.d/plugins/`.

- Binary name: `terraform-credentials-keychain`
- Install path: `~/.terraform.d/plugins/terraform-credentials-keychain`
- The `credentials_helper "keychain" {}` block in `.terraformrc` resolves to this binary by stripping the prefix.

Source: https://developer.hashicorp.com/terraform/internals/credentials-helpers (HIGH confidence — official HashiCorp docs)

### Pattern 4: Idempotent ~/.terraformrc Patch

**What:** Before appending the `credentials_helper` block, grep for its presence. Only append if absent.

**When to use:** INST-05 — prevents duplicate blocks if install.sh is run multiple times.

**Example:**
```bash
TERRAFORMRC="${HOME}/.terraformrc"
STANZA='credentials_helper "keychain" {}'

if [[ -f "${TERRAFORMRC}" ]] && grep -qF 'credentials_helper "keychain"' "${TERRAFORMRC}"; then
  echo "credentials_helper already configured in ${TERRAFORMRC}, skipping."
else
  printf '\ncredentials_helper "keychain" {}\n' >> "${TERRAFORMRC}"
  echo "Patched ${TERRAFORMRC}."
fi
```

### Pattern 5: Preflight Dependency Check in install.sh

**What:** Check macOS platform and required CLIs before doing anything destructive.

**When to use:** INST-01 — fail fast with a clear message rather than a confusing mid-install error.

**Example:**
```bash
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: This script requires macOS." >&2
  exit 1
fi

if ! command -v security >/dev/null 2>&1; then
  echo "Error: macOS 'security' CLI not found. This should not happen on macOS." >&2
  exit 1
fi
```

Note: `security` is a macOS built-in — the check for it is a safety belt. The `jq` check is not part of INST-01 but is worth documenting as a known dependency gap (see CONCERNS.md).

### Pattern 6: .pre-commit-config.yaml for a Bash Project

**What:** Minimal, correct pre-commit config covering shell linting, formatting, and general quality.

**Example:**
```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: mixed-line-ending

  - repo: https://github.com/koalaman/shellcheck-precommit
    rev: v0.11.0
    hooks:
      - id: shellcheck

  - repo: https://github.com/scop/pre-commit-shfmt
    rev: v3.13.0-1
    hooks:
      - id: shfmt
```

Source: Official hook repos and pre-commit docs (HIGH confidence — verified against release tags 2026-03-24).

### Anti-Patterns to Avoid

- **Duplicate copyright blocks:** Don't copy the full MIT license text twice. One block with two copyright lines is correct.
- **`credentials_helper "keychain" { args = [] }` with empty args array:** The `args = []` is noise when empty. Use `{}` — both are valid but `{}` is cleaner for zero-args case.
- **Patching ~/.terraformrc unconditionally:** Without idempotency guard, repeated install runs will add duplicate `credentials_helper` blocks, which Terraform will reject (block may only appear once).
- **Using shfmt-src hook:** Requires Go installed on developer machine. Use `shfmt` (prebuilt) hook instead.
- **Not pinning pre-commit hook revs to tags:** Floating `rev: main` is fragile. Always pin to a release tag.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Shell linting | Custom lint script | shellcheck hook | ShellCheck covers 200+ error patterns, SC codes, dialect detection |
| Shell formatting | Manual style rules | shfmt hook | Handles indentation, spacing, redirect styles consistently |
| General file quality | Custom checks | pre-commit/pre-commit-hooks | Trailing whitespace, EOF, YAML validity are solved problems |

**Key insight:** Pre-commit hooks for shellcheck and shfmt are mature, zero-config tools that will catch real bugs. The current script will likely pass shellcheck clean given the existing quality, but shfmt may reformat spacing or indentation.

## Common Pitfalls

### Pitfall 1: ~/.terraformrc Already Has Content

**What goes wrong:** A user has an existing `~/.terraformrc` with provider mirrors, credentials blocks, or other config. A naive `echo >> ~/.terraformrc` appends correctly, but could place the `credentials_helper` block inside another block if the file has unclosed HCL (unlikely but possible with hand-edited files).

**Why it happens:** HCL is not line-oriented. Appending to a file doesn't guarantee syntactic correctness of the result.

**How to avoid:** Append only a standalone block with surrounding newlines. The grep-before-append idempotency check (Pattern 4) prevents duplication. For the install script, appending `\ncredentials_helper "keychain" {}\n` at the end of the file is safe for all standard `.terraformrc` shapes.

**Warning signs:** If Terraform reports "Invalid block definition" after installation, the `.terraformrc` likely has a formatting issue.

### Pitfall 2: shfmt Reformats the Script

**What goes wrong:** `shfmt` may reformat `terraform-credentials-keychain` (e.g., heredoc indentation, spacing around `||`, case statement indentation). QA-04 requires all hooks pass — if shfmt rewrites things, the script diff must be reviewed and accepted.

**Why it happens:** shfmt enforces consistent formatting that may differ from the current style.

**How to avoid:** Run `shfmt -d terraform-credentials-keychain` before committing the pre-commit config to preview changes. Accept or adjust. The script's logic is unchanged by formatting.

**Warning signs:** QA-04 pre-commit run fails with shfmt showing a diff.

### Pitfall 3: credentials_helper Block Appears More Than Once

**What goes wrong:** Terraform CLI rejects a `.terraformrc` with duplicate `credentials_helper` blocks: "The credentials_helper block may be specified at most once."

**Why it happens:** Running install.sh twice without an idempotency guard.

**How to avoid:** Pattern 4 (grep-before-append). This is why INST-05 exists as a hard requirement.

**Warning signs:** `terraform login` fails with a config parse error.

### Pitfall 4: README Deprecation Notice Left In

**What goes wrong:** The current README tells users to switch to `bendrucker/terraform-credentials-helper`. Leaving this in a fork README is self-defeating.

**Why it happens:** Inherited from upstream without modification.

**How to avoid:** DOC-01 explicitly covers this: README must identify this as an active maintained fork. Remove the deprecation notice and replace with attribution to the original and the fork relationship.

### Pitfall 5: install.sh Breaks if ~/.terraform.d/plugins/ Does Not Exist

**What goes wrong:** `cp` fails if the destination directory doesn't exist.

**Why it happens:** A fresh macOS environment may not have `~/.terraform.d/plugins/` created yet.

**How to avoid:** `mkdir -p "${HOME}/.terraform.d/plugins"` before copying. This is idempotent.

## Code Examples

### Complete .pre-commit-config.yaml

```yaml
# Source: Official hook repos, verified rev tags 2026-03-24
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: mixed-line-ending

  - repo: https://github.com/koalaman/shellcheck-precommit
    rev: v0.11.0
    hooks:
      - id: shellcheck

  - repo: https://github.com/scop/pre-commit-shfmt
    rev: v3.13.0-1
    hooks:
      - id: shfmt
```

### Complete install.sh Structure

```bash
#!/bin/bash
# install.sh: Install terraform-credentials-keychain on macOS.
set -euo pipefail

PLUGIN_DIR="${HOME}/.terraform.d/plugins"
PLUGIN_NAME="terraform-credentials-keychain"
TERRAFORMRC="${HOME}/.terraformrc"

# Preflight: macOS only
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: This script requires macOS." >&2
  exit 1
fi

# Preflight: security CLI (macOS built-in, should always be present)
if ! command -v security >/dev/null 2>&1; then
  echo "Error: macOS 'security' CLI not found." >&2
  exit 1
fi

# INST-02 + INST-03: Copy script and make executable
mkdir -p "${PLUGIN_DIR}"
cp "${PLUGIN_NAME}" "${PLUGIN_DIR}/${PLUGIN_NAME}"
chmod +x "${PLUGIN_DIR}/${PLUGIN_NAME}"
echo "Installed ${PLUGIN_DIR}/${PLUGIN_NAME}"

# INST-04 + INST-05: Patch .terraformrc idempotently
if [[ -f "${TERRAFORMRC}" ]] && grep -qF 'credentials_helper "keychain"' "${TERRAFORMRC}"; then
  echo "credentials_helper already configured in ${TERRAFORMRC}, skipping."
else
  printf '\ncredentials_helper "keychain" {}\n' >> "${TERRAFORMRC}"
  echo "Patched ${TERRAFORMRC}."
fi

echo "Done. Run 'terraform login <hostname>' to store credentials."
```

### MIT Dual-Copyright Block (LIC-01 + LIC-02)

```
MIT License

Copyright (c) 2020 Alisdair McDiarmid
Copyright (c) 2026 Avi Langburd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### README Recommended Structure

```markdown
# terraform-credentials-keychain

A macOS Keychain-backed Terraform credentials helper. Stores tokens for
Terraform Enterprise / HCP Terraform hostnames in the macOS Keychain instead
of plain-text `~/.terraform.d/credentials.tfrc.json`.

**Fork of [alisdair/terraform-credentials-keychain](https://github.com/alisdair/terraform-credentials-keychain)
(original by Alisdair McDiarmid, MIT licensed).**

## Requirements

- macOS (uses the built-in `security` CLI)
- `jq` (for the `store` command — install via `brew install jq`)
- Terraform CLI

## Installation

### Recommended: install.sh

    git clone https://github.com/langburd/terraform-credentials-keychain.git
    cd terraform-credentials-keychain
    ./install.sh

This copies the script to `~/.terraform.d/plugins/` and patches `~/.terraformrc`
to enable the credentials helper.

### Manual Installation

1. Copy `terraform-credentials-keychain` to `~/.terraform.d/plugins/`
2. `chmod +x ~/.terraform.d/plugins/terraform-credentials-keychain`
3. Add to `~/.terraformrc`:
   credentials_helper "keychain" {}

## Usage

After installation, use `terraform login <hostname>` to store credentials
and `terraform logout <hostname>` to remove them.
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `credentials "registry.terraform.io" {}` empty block required | Still recommended but not strictly required in modern Terraform | ~TF 1.0 | Can be included as a safety measure; README should mention it |
| Manual script copy | install.sh pattern | N/A (this phase) | Zero-friction onboarding |

**Deprecated/outdated:**
- The existing README's `bendrucker/terraform-credentials-helper` redirect notice: This was the upstream author's own deprecation notice. Remove in the fork's README; the fork IS the maintained version.
- Old Terraform docs URL `terraform.io/docs/internals/credentials-helpers.html`: Updated to `developer.hashicorp.com/terraform/internals/credentials-helpers`.

## Open Questions

1. **Should install.sh also check for `jq`?**
   - What we know: INST-01 only specifies macOS + `security` checks. `jq` is needed only for `store`. CONCERNS.md notes the missing `jq` preflight as a fragile area.
   - What's unclear: Whether a `jq` check is in scope for this phase or deferred.
   - Recommendation: Add a `jq` check to install.sh as a warning (not a fatal error), since `jq` is only needed at runtime for `store`. Or make it fatal since the tool is broken without it.

2. **Should the README include the `credentials "registry.terraform.io" {}` empty block advice?**
   - What we know: The upstream README recommends this to prevent the credentials helper from being invoked for public registry calls.
   - What's unclear: Whether this is still necessary in current Terraform versions.
   - Recommendation: Include it as a cautionary note in the manual installation steps (DOC-03). It does no harm.

## Sources

### Primary (HIGH confidence)

- https://developer.hashicorp.com/terraform/internals/credentials-helpers — Plugin naming convention (`terraform-credentials-NAME`), default search locations
- https://developer.hashicorp.com/terraform/cli/config/config-file#credentials-helpers — `credentials_helper "keychain" {}` exact HCL syntax
- https://github.com/koalaman/shellcheck-precommit — Hook ID `shellcheck`, rev `v0.11.0` (verified against GitHub tags)
- https://github.com/scop/pre-commit-shfmt — Hook ID `shfmt`, rev `v3.13.0-1` (verified against GitHub tags)
- https://github.com/pre-commit/pre-commit-hooks — Standard hooks, rev `v6.0.0` (verified against GitHub releases)

### Secondary (MEDIUM confidence)

- OSI MIT license text + common open-source fork practice — Dual-copyright format (two Copyright lines, one license body)

### Tertiary (LOW confidence)

- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all hook versions verified against GitHub tags 2026-03-24
- Architecture: HIGH — HashiCorp docs are authoritative; pre-commit patterns are well-established
- Pitfalls: HIGH — all derived from direct reading of the codebase and verified tool behavior

**Research date:** 2026-03-24
**Valid until:** 2026-06-24 (stable tools; hook versions may update but patterns are stable)
