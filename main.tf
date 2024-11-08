terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
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
  name     = var.resource_group_name
  location = var.location

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_storage_account" "tfstate" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
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
  value = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}
