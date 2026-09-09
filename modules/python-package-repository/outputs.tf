output "scope_name" {
  description = "Fixed Databricks secret scope used for default Python package repository settings."
  value       = local.scope_name
}

output "managed_secret_keys" {
  description = "Names of package-management secret keys owned by this Terraform state under the selected settings."
  value = var.manage_secret_values ? compact([
    "pip-index-url",
    var.configure_extra_indexes ? "pip-extra-index-urls" : "",
    var.configure_ca_certificate ? "pip-cert" : "",
  ]) : []
}

output "scope_managed_by_terraform" {
  description = "Whether this state owns creation and deletion of the fixed secret scope."
  value       = var.create_scope
}

output "secret_values_managed_by_terraform" {
  description = "Whether this state owns the configured package-management secret values."
  value       = var.manage_secret_values
}

output "acl_grants" {
  description = "Non-secret metadata for the two scope ACL grants managed by this root."
  value = {
    admins = "MANAGE"
    users  = "READ"
  }
}
