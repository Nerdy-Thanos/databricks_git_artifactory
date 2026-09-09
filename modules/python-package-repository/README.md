# Python package repository defaults

This directory is a directly runnable Terraform root. The platform team authors
it; one designated workspace-owning tenant-admin pipeline applies it once per workspace.
Other applications consume the resulting workspace defaults rather than applying
this root themselves.

The root can create the fixed Databricks-backed secret scope
`databricks-package-management`, manage the documented `admins` and `users` ACLs,
and optionally manage the package-index secrets used by serverless workloads. It
does not install packages or configure Artifactory, networking, classic clusters,
JAR/Maven/npm repositories, Databricks Apps, or a Vault/broker integration.

## Local structural checks

Run these commands from this directory:

```bash
terraform init -backend=false
terraform fmt -check
terraform validate
```

These checks do not contact Artifactory or prove that a repository, credential,
certificate chain, network route, or package download works. No live integration
has been verified because Artifactory access is unavailable.

Do not run `terraform plan` or `terraform apply` until the designated pipeline has
real, approved workspace and package-repository inputs. Use
`terraform.tfvars.example` only as a sanitized template; local `*.tfvars` and
`*.tfvars.json` files are ignored in this root.

## Inputs and secret keys

The provider authenticates to the existing workspace with explicit OAuth M2M
values: `workspace_host`, `databricks_client_id`, and sensitive
`databricks_client_secret`. Terraform does not create this service principal.

The default `manage_secret_values = false` is metadata-only mode. It manages the
scope and ACL metadata but does not configure package authentication. When secret
management is explicitly enabled, the following keys can be owned by this state:

| Secret key | Input | Behavior |
|---|---|---|
| `pip-index-url` | `index_url` | Required whenever `manage_secret_values = true`. |
| `pip-extra-index-urls` | `extra_index_urls` | Optional; enabled by `configure_extra_indexes` and joined with one space. |
| `pip-cert` | `ca_certificate_pem` | Optional; enabled by `configure_ca_certificate`; contains raw CA PEM content, not a path or private key. |

Databricks permits all three Python fields to be optional. Requiring a primary
index in value-managed mode is this module's narrower Artifactory-default policy.
For a new scope, metadata-only mode manages 3 resources (scope and two ACLs).
Value-managed mode adds the primary secret, plus up to two enabled optional keys,
for 4–6 resources. Consuming an existing scope subtracts the scope resource only.

A complete PyPI URL has this structural form:

```text
https://HOST/artifactory/api/pypi/REPOSITORY/simple/
```

Credential-bearing URLs may use encoded username/token user information. Use a
download-only identity with no publishing or repository-administration token.
There is no implicit public extra-index fallback. Transitive downloads, caller
overrides, and egress must be controlled separately; workspace defaults are
overrideable configuration, not egress enforcement.

Sensitive variables suppress routine display but their values can still enter
Terraform state and saved plans. Protect state, plan files, variable files, and
pipeline logs accordingly. Outputs expose only the fixed scope name, managed key
names, ownership booleans, and ACL metadata; they never expose secret values or
URLs.

## ACL and ownership boundaries

The root always manages these two scope ACL resources:

- `admins`: `MANAGE`
- `users`: `READ`

Scope-level reader access includes access to the credentials stored in the scope.
The two ACL resources do not clear other existing grants.

Set `create_scope = false` only when adopting an existing fixed scope. This mode is
not read-only: Terraform still writes both ACLs and therefore requires explicit
ACL-ownership approval. Before adoption, inventory the scope and import any keys
that this state is authorized to adopt. If another state owns them, arrange the
ownership handoff first; never import them into two active states. Keep one state
for this root per workspace. Secret creation can overwrite an existing scope/key,
so an absent resource in this state is not proof that its key is unused.

The lifecycle toggles are ownership switches, not handoff mechanisms. Turning
`manage_secret_values`, `create_scope`, or either optional configuration flag off
after an apply can delete the corresponding Terraform-managed resources. Deleting
the scope deletes every key in it, including keys owned by a broker or another
system. A future broker migration requires a separately reviewed state handoff;
this root provides no executable migration recipe.

After changing these defaults, serverless users must reattach the notebook or
rerun the job for the new settings to take effect.

Certificate validation here checks PEM markers and rejects private-key material;
it does not verify the actual chain, expiry or server hostname. Keep HTTPS/TLS
verification enabled. Do not use `trusted-host` as a workaround. A custom CA is
optional if the repository is already trusted by the normal trust store.

References: [Databricks default package repositories](https://docs.databricks.com/aws/en/admin/workspace-settings/default-package-repositories),
[secret scope resource](https://registry.terraform.io/providers/databricks/databricks/1.128.0/docs/resources/secret_scope),
[secret ACL resource](https://registry.terraform.io/providers/databricks/databricks/1.128.0/docs/resources/secret_acl),
and [secret resource](https://registry.terraform.io/providers/databricks/databricks/1.128.0/docs/resources/secret).
