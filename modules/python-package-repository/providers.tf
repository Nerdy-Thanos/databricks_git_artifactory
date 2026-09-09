provider "databricks" {
  alias         = "workspace"
  host          = var.workspace_host
  auth_type     = "oauth-m2m"
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}
