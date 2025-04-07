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

resource "azurerm_resource_group" "tfstate" {
  count =   try(var.create_resource_group ? 1 : 0, 0) 
  name     = var.resource_group_name
  location = var.location

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

data "azurerm_resource_group" "tfstate" {
  count =   try(var.create_resource_group ? 0 : 1, 1) 
  name     = var.resource_group_name
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

resource "azurerm_storage_container" "tfstate" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
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

output "resource_group_name" {
  value    = var.create_resource_group ? azurerm_resource_group.tfstate[0].name : data.azurerm_resource_group.tfstate[0].name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}
