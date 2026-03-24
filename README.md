# terraform-credentials-keychain

A macOS Keychain-backed Terraform credentials helper. Stores tokens for
Terraform Enterprise / HCP Terraform hostnames in the macOS Keychain instead
of plain-text `~/.terraform.d/credentials.tfrc.json`.

**Fork of [alisdair/terraform-credentials-keychain](https://github.com/alisdair/terraform-credentials-keychain)
(original by Alisdair McDiarmid, MIT licensed). This fork is actively maintained.**

## Requirements

- macOS (uses the built-in `security` CLI)
- [`jq`](https://jqlang.org/) — required for the `store` command; install via `brew install jq`
- Terraform CLI

## Installation

### Recommended: one-liner

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/langburd/terraform-credentials-keychain/master/install.sh)
```

Or clone and run:

```bash
git clone https://github.com/langburd/terraform-credentials-keychain.git
cd terraform-credentials-keychain
bash install.sh
```

This copies the script to `~/.terraform.d/plugins/` and patches `~/.terraformrc` to enable the
credentials helper automatically. It is safe to run more than once.

### Manual Installation

1. Copy `terraform-credentials-keychain` to `~/.terraform.d/plugins/`
2. Make it executable: `chmod +x ~/.terraform.d/plugins/terraform-credentials-keychain`
3. Add the following block to `~/.terraformrc`:

   ```hcl
   credentials_helper "keychain" {}
   ```

4. Optionally, add an empty credentials block for the public registry to prevent the helper
   from being invoked for provider/module installs:

   ```hcl
   credentials "registry.terraform.io" {}
   ```

## Usage

After installation, use standard Terraform commands to manage credentials:

- `terraform login <hostname>` — store a token in the Keychain
- `terraform logout <hostname>` — remove a stored token

## License

MIT — see [LICENSE.md](LICENSE.md).
Original work Copyright (c) 2020 Alisdair McDiarmid. Fork Copyright (c) 2026 Avi Langburd.
