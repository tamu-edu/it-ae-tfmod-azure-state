terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.26.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = var.resource_provider_registrations
  features {}
  client_id       = var.client_id
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  storage_use_azuread = true
}


resource "random_string" "storage_account_name" {
  length  = 14
  special = false
  upper   = false
}

locals {
  storage_account_name = var.storage_account_name == null ? "tfstate00${random_string.storage_account_name.result}" : var.storage_account_name
}

data "azurerm_client_config" "current" {
}


resource "azurerm_resource_group" "tfstate" {
  count =   var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

data "azurerm_resource_group" "tfstate" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

resource "azurerm_storage_account" "tfstate" {
  name                     = local.storage_account_name

  # --- Conditional Attributes ---
  # If create_resource_group is true, use the name from the created resource (at index 0).
  # Otherwise, use the name from the data source (at index 0).
  resource_group_name    = var.create_resource_group ? azurerm_resource_group.tfstate[0].name : data.azurerm_resource_group.tfstate[0].name

  # If create_resource_group is true, use the location from the created resource (at index 0).
  # Otherwise, use the location from the data source (at index 0).
  location               = var.create_resource_group ? azurerm_resource_group.tfstate[0].location : data.azurerm_resource_group.tfstate[0].location
  # --- End Conditional Attributes ---
  account_tier             = "Standard"
  account_replication_type = "GRS"

  shared_access_key_enabled = false

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_storage_account_network_rules" "tfstate_acl" {
  count = var.tfstate_acl ? 1 : 0
  storage_account_id = azurerm_storage_account.tfstate.id
  # ---- (Required) Specifies the default action of allow or deny when no other rules match. Valid options are Deny or Allow.
  default_action     = var.tfstate_acl_default_action
  # ----  (Optional) List of public IP or IP ranges in CIDR Format. Only IPv4 addresses are allowed. Private IP address ranges (as defined in RFC 1918) are not allowed.
  ip_rules           = var.tfstate_acl_ip_rule
  # ---- (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None. Defaults to ["AzureServices"].
  bypass             = var.tfstate_acl_bypass
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "tfstate_role_assignment" {
  scope               = azurerm_storage_container.tfstate.id
  role_definition_name  = "Storage Blob Data Owner"
  principal_id        = data.azurerm_client_config.current.object_id
}

resource "terraform_data" "always_run" {
  input = timestamp()
}

resource "null_resource" "sanitize_state" {

  count = var.remove_secrets_from_state ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      # Check if jq is installed
      if ! command -v jq &> /dev/null; then
        echo "jq is required but was not found. Please install jq to continue and then re-run apply."
        exit 1
      fi
      
      # Sanitize the state file of private access keys:
      jq 'del(.resources[].instances[].attributes [
        "primary_access_key",
        "primary_connection_string",
        "primary_blob_connection_string",
        "secondary_access_key",
        "secondary_connection_string",
        "secondary_blob_connection_string"
      ])' terraform.tfstate > sanitized.tfstate
      mv sanitized.tfstate terraform.tfstate
    EOT
  }

  depends_on = [azurerm_storage_container.tfstate]


  lifecycle {
    replace_triggered_by = [ terraform_data.always_run ]
  }
}

locals {
  backend = <<BACKENDCONFIG
  terraform {
    backend "azurerm" {
      use_cli              = true                                                       # Can also be set via `ARM_USE_CLI` environment variable.
      use_azuread_auth     = true                                                       # Can also be set via `ARM_USE_AZUREAD` environment variable.
      tenant_id            = "${data.azurerm_client_config.current.tenant_id}"          # Can also be set via `ARM_TENANT_ID` environment variable. Azure CLI will fallback to use the connected tenant ID if not supplied.
      storage_account_name = "${azurerm_storage_account.tfstate.name}"                  # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
      container_name       = "${azurerm_storage_container.tfstate.name}"                # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
      key                  = "<name key according to Azure blob naming rules>.tfstate"  # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }
  BACKENDCONFIG
}
