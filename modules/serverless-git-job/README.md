# Serverless Git-backed job

This directory is an independent Terraform root for one manually triggered,
serverless Python job. It has no child module, workspace Git folder, schedule,
classic cluster, libraries resource, or secret task parameters.

The job runs the repository-relative `workloads/git_smoke.py` file from an exact
full commit SHA. The script is expected to create 10 records and use `df.show()`
so its output appears in job logs. This root does not install PySpark; serverless
provides the runtime.

Run from this directory after the approved values are available:

```bash
terraform init
terraform validate
```

Do not run `terraform plan` or `terraform apply` until the identity, Git
credential, repository commit, serverless environment version, and tenant group
have each been confirmed. The actual script must be committed and pushed by the
user before `git_commit` is set. The same service-principal Git credential must
already exist and be selected for this repository; this root does not create or
replace it.

Jobs can use cached Git snapshots, so a local script alone is not live evidence
that the job clone or run succeeded. A successful run has not been claimed here.

The ignored local `global.auto.tfvars` has the same approved workspace and OAuth
values as the credential root. Fill the blank job name, full commit SHA, serverless
environment version and tenant runner group. Leave `dependencies = []` for this
demo. The sanitized example is for future checkouts, not a deployable configuration.

After live-step approval, run `terraform plan` from this directory. Expected first
plan: **2 to add, 0 to change, 0 to destroy** (job + ACL). Review it before an
approved `terraform apply`. Applying only creates the definition; manually run
the job afterward and inspect the Python task's logs for IDs 1–10 and names
`record-1` through `record-10` (display order is not guaranteed).

## Inputs and outputs

| Input | Meaning |
|---|---|
| `workspace_host` | Existing Databricks workspace HTTPS URL. |
| `databricks_client_id` | Selected Databricks automation service-principal application ID; it is also the job run-as identity and owner. |
| `databricks_client_secret` | Sensitive OAuth secret for that service principal. |
| `job_name` | Job display name. |
| `git_url` | HTTPS repository URL without embedded credentials or query/fragment. |
| `git_provider` | `gitHub` or `gitHubEnterprise`. |
| `git_commit` | Required full 40-character commit SHA. |
| `python_file` | Repository-relative `.py` path; defaults to `workloads/git_smoke.py`. |
| `task_key` | Single task key; defaults to `main`. |
| `serverless_environment_version` | Approved non-empty serverless environment version. |
| `tenant_runner_group` | Approved group granted `CAN_MANAGE_RUN`. |
| `dependencies` | Optional serverless environment dependency strings; defaults to empty. |

Outputs are metadata only: `job_id` and `job_url`. No credential or token is
output.

## Permissions and provider

The pinned Databricks provider is `1.128.0`. `databricks.workspace` uses OAuth
M2M with the selected service principal. That same principal is configured as
the job's `run_as` identity and `IS_OWNER`; the approved tenant group receives
`CAN_MANAGE_RUN`.

The job uses the `GIT` source for `spark_python_task` and the `python`
serverless environment. `max_concurrent_runs` is 1 and the timeout is 600
seconds. There is no schedule, so triggering remains a deliberate manual action.

Confirm the SP is active, can use this workspace and can create the job with the
specified Run as identity. Existing Databricks Git credentials, remote repository
access and applicable Git/network policies are separate prerequisites; this root
grants none of them. Unity Catalog and a supported serverless Python environment
must already be available.

The permissions resource is authoritative for this job's direct ACL. Do not let
another state or a manual process independently own it. Admin/default access is
not removed. Approve the runner group carefully: its members can trigger and
cancel runs under the SP's privileges, though this grant alone cannot edit the
job definition or ACL. Restrict who can change the Terraform checkout/inputs too.
Reusing the Federation SP is the explicit sandbox choice, not a production
least-privilege recommendation.

References: [Git-backed jobs](https://docs.databricks.com/aws/en/jobs/git),
[serverless jobs](https://docs.databricks.com/aws/en/jobs/run-serverless-jobs),
[job identity and permissions](https://docs.databricks.com/aws/en/jobs/privileges).
