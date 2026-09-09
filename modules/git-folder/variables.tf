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
  description = "Application/client ID of the selected Databricks automation service principal with workspace access."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.databricks_client_id)) > 0
    error_message = "Supply the selected Databricks automation SP application ID."
  }
}

variable "databricks_client_secret" {
  description = "Databricks OAuth secret for the selected automation service principal. Not a GitHub token."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(trimspace(var.databricks_client_secret)) > 0
    error_message = "Supply the selected automation SP OAuth secret."
  }
}

variable "git_url" {
  description = "HTTPS Git repository URL without embedded userinfo, token, query, or fragment."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^https://[^/?#@[:space:]]+/[^?#[:space:]]+$", var.git_url)) && !strcontains(var.git_url, "@")
    error_message = "Supply an HTTPS Git URL without embedded userinfo, token, query, or fragment."
  }
}

variable "git_provider" {
  description = "Git provider identifier: gitHub or gitHubEnterprise."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["gitHub", "gitHubEnterprise"], var.git_provider)
    error_message = "Use gitHub or gitHubEnterprise."
  }
}

variable "git_branch" {
  description = "Branch checked out by the Databricks Git folder."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.git_branch)) > 0
    error_message = "Supply the approved nonempty Git branch."
  }
}
