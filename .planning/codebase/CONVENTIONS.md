# Coding Conventions

**Analysis Date:** 2026-03-24

## Overview

The codebase is a single Bash script: `terraform-credentials-keychain`. All conventions
apply to shell scripting.

## Safety Flags

Every script must begin with strict mode:

```bash
set -euo pipefail
```

- `-e`: exit immediately on error
- `-u`: treat unbound variables as errors
- `-o pipefail`: propagate pipeline failures

## Naming Patterns

**Files:**
- Lowercase hyphen-separated: `terraform-credentials-keychain`
- No file extension on executable scripts

**Constants / Global Variables:**
- ALL_CAPS with underscores: `SERVICE`, `COMMAND`, `TFE_HOSTNAME`
- Defined at top-level scope before use

**Local / temporary variables:**
- Lowercase: `ret`, `token`
- Used inline within `case` blocks

**Functions:**
- Lowercase with underscores: `usage()`
- Defined before first use

## Variable Quoting

All variable references are double-quoted to prevent word splitting:

```bash
security -q find-generic-password -s "${SERVICE}" -a "${TFE_HOSTNAME}" -w
```

Use `${VAR}` brace syntax, not `$VAR`.

## Avoiding Bash Built-in Shadowing

When a variable name conflicts with a Bash built-in, use a descriptive prefix:

```bash
# "TFE_HOSTNAME" avoids shadowing bash's built-in $HOSTNAME
TFE_HOSTNAME="${2}"
```

Document the reason with a comment.

## Argument Validation

Validate argument count before parsing positional args:

```bash
if [[ ${#} -ne 2 ]]; then
  usage
fi
```

Use `[[ ]]` (double brackets) for conditionals, not `[ ]`.

## Command Dispatch

Use a `case` statement for command routing. Always include a `*` fallthrough that calls `usage`:

```bash
case "${COMMAND}" in
  get)    ... ;;
  store)  ... ;;
  forget) ... ;;
  *)      usage ;;
esac
```

## Error Handling

**Explicit return-code capture pattern** for commands that may fail non-fatally:

```bash
ret=0
some-command || ret=$?

if [[ ${ret} -eq <expected-code> ]]; then
  # handle expected non-fatal case
elif [[ ${ret} -ne 0 ]]; then
  # surface genuine error
  exit "${ret}"
fi
```

Never swallow unknown non-zero exit codes. Re-exit with the original code:

```bash
exit "${ret}"
```

**Stderr for errors:**

All error messages go to stderr:

```bash
echo "Unknown credentials object format" >&2
```

**Exit codes:**
- `0`: success
- `1`: usage error (wrong number of args, unknown command)
- `2`: input format error
- Passthrough: re-use the exit code from failed subcommands

## Output

**Stdout for protocol responses:**

JSON responses to stdout, using a heredoc for multi-line output:

```bash
cat <<EOF
{
    "token": "${token}"
}
EOF
```

JSON is indented with 4 spaces.

Empty/not-found responses return `{}` (empty object), not empty string.

## Subcommand Flags

Use `-q` (quiet) flag on `security(1)` calls to suppress default output; handle
output explicitly:

```bash
security -q find-generic-password -s "${SERVICE}" -a "${TFE_HOSTNAME}" -w 2>&1
```

Capture both stdout and stderr when the output is needed for re-display on error.

## Comments

- File-level header comment explains purpose, protocol reference, and usage.
- Inline comments explain non-obvious behavior (e.g., exit code meanings).
- Exit code semantics are documented at the point of use:

```bash
# Exit code 44 ("errSecItemNotFound") means no token is stored for this
# hostname. Respond with an empty credentials object per the protocol.
```

## External Tools

Only `jq` and `security` (macOS) are used as external dependencies. Their usage is
direct and minimal — no wrappers or abstraction layers.

---

*Convention analysis: 2026-03-24*
