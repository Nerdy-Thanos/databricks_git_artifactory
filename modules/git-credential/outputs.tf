output "credential_id" {
  description = "ID of the Git credential registered under the provider-authenticated identity."
  value       = databricks_git_credential.this.id
}
