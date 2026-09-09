output "repo_id" {
  description = "ID of the Databricks Git folder repository."
  value       = databricks_repo.this.id
}

output "path" {
  description = "Workspace path of the Databricks Git folder."
  value       = databricks_repo.this.path
}

output "checkout_commit" {
  description = "Commit currently checked out by the Databricks Git folder."
  value       = databricks_repo.this.commit_hash
}
