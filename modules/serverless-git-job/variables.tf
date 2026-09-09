variable "workspace_host" {
  description = "Existing Databricks workspace HTTPS URL; not the account-console URL."
  type        = string
  nullable    = false

  validation {
    condition     = startswith(var.workspace_host, "https://") && !startswith(var.workspace_host, "https://accounts.")
    error_message = "Supply the existing workspace HTTPS URL, not an account-console URL."
  }
}

variable "databricks_client_id" {
  description = "Application/client ID of the Databricks automation service principal that owns and runs this job."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.databricks_client_id)) > 0
    error_message = "Supply the selected Databricks automation SP application ID."
  }
}

variable "databricks_client_secret" {
  description = "Databricks OAuth secret for the selected automation service principal."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(trimspace(var.databricks_client_secret)) > 0
    error_message = "Supply the selected automation SP OAuth secret."
  }
}

variable "job_name" {
  description = "Name of the manually triggered serverless Git-backed Python job."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.job_name)) > 0
    error_message = "Supply a non-empty job name."
  }
}

variable "git_url" {
  description = "HTTPS Git repository URL without embedded credentials, query strings, or fragments."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^https://[^/?#@[:space:]]+/[^?#[:space:]]+$", var.git_url)) && !strcontains(var.git_url, "@")
    error_message = "Supply an HTTPS Git URL without embedded credentials, a query string, or a fragment."
  }
}

variable "git_provider" {
  description = "Git provider identifier: gitHub for GitHub.com or gitHubEnterprise for the approved enterprise host."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["gitHub", "gitHubEnterprise"], var.git_provider)
    error_message = "Use gitHub or gitHubEnterprise for this job."
  }
}

variable "git_commit" {
  description = "Required full 40-character hexadecimal commit SHA to run from the Git snapshot."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F]{40}$", var.git_commit))
    error_message = "Supply the full 40-character hexadecimal Git commit SHA; branches and tags are not accepted."
  }
}

variable "python_file" {
  description = "Repository-relative Python file used by the Git-backed task."
  type        = string
  nullable    = false
  default     = "workloads/git_smoke.py"

  validation {
    condition = (
      length(trimspace(var.python_file)) > 0 &&
      !startswith(var.python_file, "/") &&
      !startswith(var.python_file, "\\") &&
      !strcontains(var.python_file, "\\") &&
      !can(regex("^[A-Za-z]:", var.python_file)) &&
      !strcontains(var.python_file, "\n") &&
      !strcontains(var.python_file, "\r") &&
      !contains(split("/", var.python_file), "..") &&
      endswith(var.python_file, ".py")
    )
    error_message = "python_file must be a non-empty repository-relative .py path without absolute or traversal segments."
  }
}

variable "task_key" {
  description = "Key for the single Python task in the job."
  type        = string
  nullable    = false
  default     = "main"

  validation {
    condition     = length(trimspace(var.task_key)) > 0
    error_message = "Supply a non-empty task key."
  }
}

variable "serverless_environment_version" {
  description = "Approved non-empty Databricks serverless environment version."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.serverless_environment_version)) > 0
    error_message = "Supply the approved serverless environment version."
  }
}

variable "tenant_runner_group" {
  description = "Approved tenant group allowed to manage job runs."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.tenant_runner_group)) > 0
    error_message = "Supply the approved tenant runner group."
  }
}

variable "dependencies" {
  description = "Optional serverless environment dependencies, such as approved PyPI package specifications."
  type        = list(string)
  nullable    = false
  default     = []
}
