locals {
  scope_name = "databricks-package-management"
}

resource "databricks_secret_scope" "this" {
  provider = databricks.workspace
  count    = var.create_scope ? 1 : 0

  name = local.scope_name
}

resource "databricks_secret_acl" "admins" {
  provider = databricks.workspace

  scope      = local.scope_name
  principal  = "admins"
  permission = "MANAGE"

  depends_on = [databricks_secret_scope.this]
}

resource "databricks_secret_acl" "users" {
  provider = databricks.workspace

  scope      = local.scope_name
  principal  = "users"
  permission = "READ"

  depends_on = [databricks_secret_scope.this]
}

resource "databricks_secret" "index" {
  provider = databricks.workspace
  count    = var.manage_secret_values ? 1 : 0

  scope        = local.scope_name
  key          = "pip-index-url"
  string_value = var.index_url

  lifecycle {
    precondition {
      condition     = try(can(regex("^https://[^/?#\\s]+[^\\s]*$", var.index_url)), false)
      error_message = "When secret-value management is enabled, index_url must be a nonempty HTTPS URL with a nonempty authority and no raw whitespace."
    }
  }

  depends_on = [databricks_secret_scope.this]
}

resource "databricks_secret" "extra_indexes" {
  provider = databricks.workspace
  count    = var.manage_secret_values && var.configure_extra_indexes ? 1 : 0

  scope        = local.scope_name
  key          = "pip-extra-index-urls"
  string_value = join(" ", var.extra_index_urls)

  lifecycle {
    precondition {
      condition = length(var.extra_index_urls) > 0 && alltrue([
        for url in var.extra_index_urls : can(regex("^https://[^/?#\\s]+[^\\s]*$", url))
      ])
      error_message = "When extra indexes are enabled, extra_index_urls must contain at least one HTTPS URL; every URL must have a nonempty authority and no raw whitespace."
    }
  }

  depends_on = [databricks_secret_scope.this]
}

resource "databricks_secret" "certificate" {
  provider = databricks.workspace
  count    = var.manage_secret_values && var.configure_ca_certificate ? 1 : 0

  scope        = local.scope_name
  key          = "pip-cert"
  string_value = var.ca_certificate_pem

  lifecycle {
    precondition {
      condition = try(
        strcontains(var.ca_certificate_pem, "-----BEGIN CERTIFICATE-----") &&
        strcontains(var.ca_certificate_pem, "-----END CERTIFICATE-----") &&
        !strcontains(var.ca_certificate_pem, "PRIVATE KEY"),
        false
      )
      error_message = "When CA certificate configuration is enabled, ca_certificate_pem must contain CERTIFICATE PEM markers and must not contain a PRIVATE KEY marker."
    }
  }

  depends_on = [databricks_secret_scope.this]
}
