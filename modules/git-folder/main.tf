resource "databricks_repo" "this" {
  provider = databricks.workspace

  url          = var.git_url
  git_provider = var.git_provider
  branch       = var.git_branch
}

resource "databricks_permissions" "this" {
  provider = databricks.workspace

  repo_id = databricks_repo.this.id

  access_control {
    group_name       = "account users"
    permission_level = "CAN_READ"
  }
}
