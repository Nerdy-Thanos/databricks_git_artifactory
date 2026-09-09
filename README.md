# databricks_git_artifactory
This repo is for integrating Git and Artifactory with Databricks

## Current implementation

The first Terraform root, [git-credential](modules/git-credential/README.md),
registers a Git credential for an application service principal in the existing
workspace. Run Terraform directly from `modules/git-credential`; its resource,
provider, inputs, outputs and version lock are all there. There is no separate
example or wrapper module. It does not create a workspace, identity or networking.

The Git configurations are implemented locally:

| Directory / file | Purpose |
|---|---|
| [git-credential](modules/git-credential/README.md) | Register the automation SP's Git credential. |
| [git-folder](modules/git-folder/README.md) | Create a branch-based workspace Git folder and tenant read permission. |
| [serverless-git-job](modules/serverless-git-job/README.md) | Create a commit-pinned Python job and tenant run permission. |
| [python-package-repository](modules/python-package-repository/README.md) | Configure workspace Python package defaults for an existing Artifactory service; local checks only. |
| [git_smoke.py](workloads/git_smoke.py) | Create a DataFrame with 10 records and display it in task logs. |

Each module directory is an independent Terraform root. The job reads directly
from Git; it does not depend on the Git folder. The Python package-repository root
is the fourth capability. Platform authors it; one designated workspace-owning
tenant-admin pipeline manages the workspace-wide defaults. Artifactory remains
code/design only until access is available; no live configuration is applied.

See the [Artifactory root](modules/python-package-repository/README.md) for its
input template, ownership modes, certificate handling and lifecycle warnings,
plus the [design](docs/artifactory-design.md) and
[future live handoff](docs/artifactory-validation.md). It manages the fixed
`databricks-package-management` scope, two ACL entries, and optional secret values.
It does not create Artifactory, change networking or install packages.

See the [approved Git plan](docs/superpowers/plans/2026-09-08-git-sandbox-enablement.md),
[runbook](docs/git-runbook.md) and [evidence record](docs/git-evidence.md).
Development proceeds one approval gate at a time; no live apply is automatic.

## Local checks

From the repository root:

```bash
cd modules/git-credential
terraform init
terraform fmt -check
terraform validate
```

Use the same commands in `modules/git-folder` or `modules/serverless-git-job` to
check that root. Local initialization and validation have passed for all three.
For `modules/python-package-repository`, use `terraform init -backend=false`,
`terraform fmt -check` and `terraform validate`. Those local checks also passed;
Artifactory runtime authentication, TLS and package downloads remain untested.
After supplying local inputs and approving the live steps, run `terraform plan`
and `terraform apply` from the selected directory, not the repository root.

These checks do not prove Git access or a successful job run. The script has not
been committed or pushed, so it cannot yet be fetched by a remote Git job.
All four roots pin Databricks provider 1.128.0. Keep their dependency lock files
in version control. The new package root ignores its local tfvars; the existing
repository ignore rules currently do not ignore the Git roots' tfvars. Check
`git status` carefully before committing and never publish real credentials.
Environment files, saved plans and state remain ignored. Sensitive Terraform
inputs still enter state and saved plans.
