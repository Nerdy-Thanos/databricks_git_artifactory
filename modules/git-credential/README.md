# Git credential

This directory is the Terraform root. It contains the resource, workspace
provider, variables, outputs, version pin, lock file and sanitized input template.
There is no child-module call or separate deployment example.

Creates one `databricks_git_credential` for the service principal authenticated by
`databricks.workspace`. It does not create a service principal, grant GitHub
access, create a Git folder or configure a job.

Run from this directory:

```bash
terraform init
terraform validate
```

Local `global.auto.tfvars` now contains the Federation Databricks OAuth values,
reused with explicit user approval for this sandbox. Terraform auto-loads this
Git-ignored file. Fill its blank GitHub username/email/token fields locally.
`global.auto.tfvars.example` remains a sanitized template without real values.
After identity/credential checks and approval, run `terraform plan`, then
`terraform apply`, from this same directory. No live apply has been performed.

## Inputs and output

All inputs are required strings with no defaults.

| Input | Meaning |
|---|---|
| `workspace_host` | Existing Databricks workspace HTTPS URL. |
| `databricks_client_id` | Selected Databricks service principal application ID. |
| `databricks_client_secret` | Sensitive Databricks OAuth secret for that principal. |
| `git_provider` | `gitHub` for the sandbox; `gitHubEnterprise` for an approved enterprise host. |
| `git_username` | Git provider account associated with the token. |
| `git_email` | Approved Git email used for commit identity and, where required, authentication; does not grant repository permissions. |
| `git_pat` | Sensitive Git token; use repository-scoped read access for automation. |

The only output is `credential_id`. No token or provider credential is output.

## Provider and ownership

`providers.tf` configures `databricks.workspace` with explicit OAuth M2M
authentication. Its Databricks client ID/secret authenticate Terraform to
Databricks; `git_pat` authenticates Databricks to GitHub. These are separate
credentials and identities. The resource explicitly selects this provider alias.

The sandbox uses the existing Federation SP, not a newly provisioned identity.
Its existing Git credentials must still be checked before apply; reusing OAuth
authentication does not authorize overwriting an existing Git credential.

The resource address is `databricks_git_credential.this`. No state migration was
needed when the original example wrapper was removed: it had not been applied.
See the [runbook](../../docs/git-runbook.md) for approval and verification steps.

## Lifecycle boundaries

- Inventory the selected identity's existing Git credentials before the first
  plan/apply. Do not manage the same credential from two Terraform states.
- `force = false` disables the provider's forced conflict-replacement path. It is
  not a rotation lock: changing a token on a Terraform-managed credential updates
  that credential. Reuse/import/rotation must be explicitly agreed first.
- No `principal_id` is supplied: the authenticated caller owns the credential.
  This is not admin-on-behalf-of credential provisioning.
- Databricks can allow multiple Git credentials. The first for a provider becomes
  its default, so inventory matters even when creation would not conflict.
- Token creation, scoping, expiry and revocation remain with the Git owner.
- `sensitive` masks routine output; the Git token can be stored in state and
  saved plans. Protect local files and production state access accordingly.
- A registered credential is not evidence of a successful Git clone or job.
- In provider 1.128.0, refresh reads back provider/username, not token/email/default
  changes. A clean plan alone does not prove no out-of-band credential changes.

Provider: Databricks pinned to `1.128.0` in this root.
Documentation: [provider resource](https://registry.terraform.io/providers/databricks/databricks/1.128.0/docs/resources/git_credential)
and [Databricks service-principal Git setup](https://docs.databricks.com/aws/en/repos/automate-with-sp).
