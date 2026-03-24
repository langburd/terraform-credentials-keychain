# Testing Patterns

**Analysis Date:** 2026-03-24

## Test Framework

**Runner:** None detected

No test framework, test runner config, or test files exist in the repository.

There is no `jest.config.*`, `vitest.config.*`, `bats.config`, `shunit2`, or any
equivalent test configuration.

**Run Commands:**
- Not applicable — no test suite exists.

## Test File Organization

No test files present. No `test/`, `tests/`, or `spec/` directories exist.

## Coverage

**Requirements:** None enforced

No coverage tooling or targets are configured.

## Test Types

**Unit Tests:** Not present
**Integration Tests:** Not present
**E2E Tests:** Not present

## Testing Gap

The sole source file `terraform-credentials-keychain` has no automated test coverage.
Manual testing against a live macOS Keychain is the only implied verification path.

**Testable behaviors that lack coverage:**

| Behavior | Command | Notes |
|---|---|---|
| Token retrieval | `get <hostname>` | Requires live `security` CLI |
| Not-found returns `{}` | `get <unknown-host>` | Exit code 44 path |
| Token storage | `store <hostname>` | Reads JSON from stdin |
| Invalid JSON object | `store <hostname>` | Expects exit code 2 |
| Token deletion | `forget <hostname>` | Normal path |
| Forget non-existent | `forget <unknown>` | Exit code 44 ignored |
| Wrong arg count | `<any>` | Expects usage + exit 1 |
| Unknown command | `<bad-cmd> <host>` | Expects usage + exit 1 |

## Recommended Framework

For a Bash script of this type, [bats-core](https://github.com/bats-core/bats-core)
is the standard choice. It supports mocking external commands (`security`, `jq`) via
PATH overrides, making it possible to test all branches without a live Keychain.

**Example pattern (not yet implemented):**

```bash
# test/get.bats
@test "get returns empty object when item not found" {
  # Override security to simulate errSecItemNotFound (exit 44)
  function security() { return 44; }
  export -f security

  run terraform-credentials-keychain get app.terraform.io
  [ "$status" -eq 0 ]
  [ "$output" = "{}" ]
}
```

---

*Testing analysis: 2026-03-24*
