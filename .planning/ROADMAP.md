# Roadmap: terraform-credentials-keychain (fork)

## Overview

The script improvements are already done. The remaining work — license attribution, install script, README, and pre-commit hooks — completes everything needed to release a polished, installable fork. All of it ships in a single phase.

## Phases

- [x] **Phase 1: Release Packaging** - License, install script, README, and quality gates — everything to make the fork releasable (completed 2026-03-24)

## Phase Details

### Phase 1: Release Packaging
**Goal**: A developer can install the tool in one command and the project is ready to accept contributions
**Depends on**: Nothing (first phase)
**Requirements**: LIC-01, LIC-02, INST-01, INST-02, INST-03, INST-04, INST-05, DOC-01, DOC-02, DOC-03, DOC-04, QA-01, QA-02, QA-03, QA-04
**Success Criteria** (what must be TRUE):
  1. Running `bash install.sh` on a clean macOS machine installs the credentials helper and configures `~/.terraformrc` without manual steps
  2. Running `install.sh` a second time completes without error or side effects
  3. LICENSE.md shows both the original copyright (Alisdair McDiarmid, 2020) and the fork author (Avi Langburd, 2026)
  4. README.md clearly identifies the fork, documents `install.sh` as the install method, and lists dependencies
  5. `pre-commit run --all-files` passes with shellcheck and shfmt hooks on the current codebase
**Plans**: 3 plans

Plans:
- [x] 01-01-PLAN.md — Update LICENSE.md (dual-copyright) and create install.sh
- [x] 01-02-PLAN.md — Rewrite README.md for fork identity and install documentation
- [x] 01-03-PLAN.md — Create .pre-commit-config.yaml and verify all hooks pass

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Release Packaging | 3/3 | Complete   | 2026-03-24 |
