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

variable "git_provider" {
  description = "Git provider identifier: gitHub for GitHub.com or gitHubEnterprise for the approved enterprise host."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["gitHub", "gitHubEnterprise"], var.git_provider)
    error_message = "Use gitHub or gitHubEnterprise for this module."
  }
}

variable "git_username" {
  description = "Git provider username associated with the repository-scoped token; not the Databricks application ID."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.git_username)) > 0
    error_message = "Supply the Git provider username."
  }
}

variable "git_email" {
  description = "Approved Git author email associated with this credential; does not grant repository access."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.git_email)) > 0
    error_message = "Supply the approved Git email."
  }
}

variable "git_pat" {
  description = "Repository-scoped Git personal access token. Sensitive output masking does not remove the token from Terraform state."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(trimspace(var.git_pat)) > 0
    error_message = "Supply an explicit non-empty Git token; environment-token fallback is not intended."
  }
}
