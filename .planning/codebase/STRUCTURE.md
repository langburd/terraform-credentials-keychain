# Codebase Structure

**Analysis Date:** 2026-03-24

## Directory Layout

```
terraform-credentials-keychain/   # Project root
├── terraform-credentials-keychain # Executable Bash script (the entire program)
├── README.md                      # Usage instructions and setup guide
├── LICENSE.md                     # MIT license
└── .planning/
    └── codebase/                  # GSD mapping documents
```

## Directory Purposes

**Project root:**
- Purpose: Contains the entire deliverable — one executable script
- Contains: The script, docs, and license
- Key files: `terraform-credentials-keychain`

**.planning/codebase/:**
- Purpose: GSD codebase analysis documents
- Contains: Architecture, structure, stack, and other analysis docs
- Generated: Yes (by GSD map-codebase)
- Committed: No convention established yet

## Key File Locations

**Entry Points:**
- `terraform-credentials-keychain`: The sole executable; implements the full Terraform credentials helper protocol

**Documentation:**
- `README.md`: Installation and configuration instructions
- `LICENSE.md`: MIT license

## Naming Conventions

**Files:**
- Script matches its own name exactly: `terraform-credentials-keychain` (kebab-case, no extension)
- Documentation files use Title Case with `.md` extension

**Variables:**
- Constants: `SCREAMING_SNAKE_CASE` (e.g., `SERVICE`, `COMMAND`, `TFE_HOSTNAME`)
- Local temporaries: lowercase (e.g., `ret`, `token`)

**Functions:**
- One helper function defined: `usage()` — lowercase with parentheses

## Where to Add New Code

**New command (e.g., `list`):**
- Add a new `case` branch inside the existing `case "${COMMAND}" in` block in `terraform-credentials-keychain`
- Update `usage()` message to include the new command

**New validation logic:**
- Add before the `case` statement, after the argument-count check (lines 27–33)

**Refactor into multiple files:**
- Not applicable — this is an intentionally single-file POSIX-style tool. Keep it as one script.

## Special Directories

**.git/:**
- Purpose: Git repository metadata
- Generated: Yes
- Committed: No

**.planning/:**
- Purpose: GSD planning and analysis artifacts
- Generated: Yes (by GSD commands)
- Committed: Convention not established; treat as non-source

---

*Structure analysis: 2026-03-24*
