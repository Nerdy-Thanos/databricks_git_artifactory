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
  description = "Application/client ID of the designated automation service principal with workspace-admin access for package-default configuration."
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

variable "create_scope" {
  description = "Whether Terraform creates the fixed Databricks-backed secret scope. ACL management remains active when false."
  type        = bool
  default     = true
  nullable    = false
}

variable "manage_secret_values" {
  description = "Whether Terraform owns the pip-index-url secret and enabled optional package-management secrets."
  type        = bool
  default     = false
  nullable    = false
}

variable "index_url" {
  description = "Complete credential-bearing HTTPS URL for the default Python package index. Stored in Terraform state when managed."
  type        = string
  default     = null
  sensitive   = true
}

variable "extra_index_urls" {
  description = "Complete credential-bearing HTTPS URLs for optional additional indexes. Stored space-separated when managed."
  type        = list(string)
  default     = []
  sensitive   = true
  nullable    = false
}

variable "ca_certificate_pem" {
  description = "Raw PEM content for the optional package-index CA certificate; not a file path or private key."
  type        = string
  default     = null
  sensitive   = true
}

variable "configure_ca_certificate" {
  description = "Whether Terraform manages pip-cert when secret-value management is enabled."
  type        = bool
  default     = false
  nullable    = false
}

variable "configure_extra_indexes" {
  description = "Whether Terraform manages pip-extra-index-urls when secret-value management is enabled."
  type        = bool
  default     = false
  nullable    = false
}
