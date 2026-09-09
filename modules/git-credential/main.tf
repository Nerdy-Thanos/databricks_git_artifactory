resource "databricks_git_credential" "this" {
  provider = databricks.workspace

  git_provider          = var.git_provider
  git_username          = var.git_username
  git_email             = var.git_email
  personal_access_token = var.git_pat

  # A conflicting credential requires an explicit ownership decision.
  force = false
}
