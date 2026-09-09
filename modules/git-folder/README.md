# Git folder

This directory is the direct Terraform root for one Databricks Git folder. It
contains the repository resource, workspace provider, required inputs, outputs,
version pin, and a sanitized input template. It is not a reusable child module
or wrapper/example project.

The root expects the pre-existing Git credential for the same service principal
and the provider's default credential selection. It does not create or replace
credentials, service principals, groups, jobs, or any other directories. The
Git folder has no folder-to-job dependency.

Before planning, confirm that the selected OAuth service principal can access
the existing workspace, that the approved parent workspace path exists and is
permitted for the caller, and that `tenant_reader_group` already exists. The
remaining live inputs are the approved branch, absolute folder path, and tenant
reader group. The Git-ignored `global.auto.tfvars` already has the same approved
local OAuth values as the credential root; the remaining inputs are blank.
For a new checkout use the sanitized template; never put secrets in the example
or in chat.

The Terraform-controlled branch is the checkout managed by this root. A
separate developer working copy or branch is independent and should not be
assumed to follow this folder's branch.

Run from this directory:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Review the plan and obtain the required approval before `apply`. No live plan
or apply is performed as part of preparing this root. Expected first plan:
**2 to add, 0 to change, 0 to destroy** (Git folder + ACL).

## Permission and lifecycle boundaries

The ACL resource owns this repository's direct permissions; do not manage the
same ACL through another Terraform state. Out-of-band grants can be overwritten.
The provider retains the authenticated principal's management rights and admins'
access. Parent-folder grants still affect effective access: `CAN_READ` here does
not downgrade inherited `CAN_EDIT` or `CAN_MANAGE`. Use an approved parent with
suitable inherited permissions before testing excluded users.

This is an SP-managed checkout with tenant read access, not a collaborative
developer folder. Keep personal editing/push/pull in a separate working copy.
Tracking a branch does not promise automatic synchronization after every remote
push; verify the checkout commit and explicitly approve refresh/update actions.

References: [Git folder resource](https://registry.terraform.io/providers/databricks/databricks/1.128.0/docs/resources/repo),
[authoritative permissions](https://registry.terraform.io/providers/databricks/databricks/1.128.0/docs/resources/permissions).

## Inputs and outputs

All inputs are required strings with no defaults.

| Input | Meaning |
|---|---|
| `workspace_host` | Existing Databricks workspace HTTPS URL. |
| `databricks_client_id` | Selected Databricks OAuth service-principal application ID. |
| `databricks_client_secret` | Sensitive OAuth secret for that service principal. |
| `git_url` | Approved HTTPS repository URL without embedded credentials, query, or fragment. |
| `git_provider` | `gitHub` or `gitHubEnterprise`. |
| `git_branch` | Approved nonempty branch managed by this root. |
| `git_folder_path` | Absolute approved workspace path under an existing permitted parent. |
| `tenant_reader_group` | Existing approved group receiving `CAN_READ` on the repository. |

Outputs are `repo_id`, `path`, and `checkout_commit`. No secrets or credential
values are output.
