output "job_id" {
  description = "Databricks job ID for the serverless Git-backed job."
  value       = databricks_job.this.id
}

output "job_url" {
  description = "Workspace URL for the Databricks job metadata page."
  value       = format("%s/#job/%s", trimsuffix(var.workspace_host, "/"), databricks_job.this.id)
}
