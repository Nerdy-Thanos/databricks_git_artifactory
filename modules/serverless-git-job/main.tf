resource "databricks_job" "this" {
  provider = databricks.workspace

  name                = var.job_name
  max_concurrent_runs = 1
  timeout_seconds     = 600

  run_as {
    service_principal_name = var.databricks_client_id
  }

  git_source {
    url      = var.git_url
    provider = var.git_provider
    commit   = var.git_commit
  }

  environment {
    environment_key = "python"

    spec {
      environment_version = var.serverless_environment_version
      dependencies        = var.dependencies
    }
  }

  task {
    task_key        = var.task_key
    environment_key = "python"

    spark_python_task {
      python_file = var.python_file
      source      = "GIT"
    }
  }
}

resource "databricks_permissions" "this" {
  provider = databricks.workspace

  job_id = databricks_job.this.id

  access_control {
    service_principal_name = var.databricks_client_id
    permission_level       = "IS_OWNER"
  }

  access_control {
    group_name       = var.tenant_runner_group
    permission_level = "CAN_MANAGE_RUN"
  }
}
