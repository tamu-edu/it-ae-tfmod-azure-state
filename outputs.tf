
output "backend_config" {
  description = "Will contain a block of Terraform code that can be used to consume the created backend config."
  value = local.backend
}

output "resource_group_name" {
  description = "Will output the name of the resource group"
  value    = var.create_resource_group ? azurerm_resource_group.tfstate[0].name : data.azurerm_resource_group.tfstate[0].name
}

output "storage_account_id" {
  description = "ID of the tfstate storage account suitable for very broad scope string building (see container_role_access_scope)"
  value = azurerm_storage_account.tfstate.id
}

output "storage_account_name" {
  description = "Will output the storage account name"
  value = azurerm_storage_account.tfstate.name
}

output "container_id" {
  description = "Will output the tfstate storage container id"
  value = azurerm_storage_container.tfstate.id
}

output "container_name" {
  description = "Will output the tfstate storage container name"
  value = azurerm_storage_container.tfstate.name
}

output "container_role_access_scope" {
  description = "Complete scope string down to the tfstate storage container"
  value = azurerm_role_assignment.tfstate_role_assignment.scope
}
