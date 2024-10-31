# it-ae-tfmod-azure-state
This is a terraform module for initializing a terraform state backend in Azure. 

By default, it creates a resource group named `terraform-state`, a storage account with a unique name, and a container named "terraform-state", 
<!-- BEGIN_TF_DOCS -->

## Example usage

A common pattern for using this is to create a folder within your terraform IaC project named `terraform-state` containing a `main.tf` like:

```
module "state_backend" {
  source = "github.com/tamu-edu/it-ae-tfmod-azure-state?ref=v0.1.1"

  container_name = "tfstate"
  location = "southcentralus"
  resource_group_name = "your-project-tfstate-dev"
  # storage_account_name = "LeaveBlankToAutoGen"
  subscription_id = "f5358b4a-0a02-4485-8157-367fc107a27d"
  tenant_id = "68f381e3-46da-47b9-ba57-6f322b8f0da1"
}

output "container_name" {
  value = module.state_backend.container_name
}
output "resource_group_name" {
  value = module.state_backend.resource_group_name
}
output "storage_account_name" {
  value = module.state_backend.storage_account_name
}
```

To execute, first `az login` with an appropriately permissioned Azure account using the Azure CLI. Once logged in, run command `terraform init` within the new `terraform-state` folder. Then, run `terraform plan` to see what will be created. If satisfied with the results, run command `terraform apply`. This will create the appropriate Azure Blob Storage for holding state files for the main project. Azure Blobs are semaphore-locked from concurrent writes automatically. The state file for this remote state terraform script will be stored on the file system. Be sure to capture the results of the output (run `terraform output` to see it again) and copy it into your main Terraform stack variables. It is recommended to alter the name of the key to fit the granularity of separation of concerns that you require.

Consider adding the following to your parent terraform IaC project `.gitignore` file:
```
# .tfstate files
*.tfstate
*.tfstate.*
!terraform-state/*.tfstate
!terraform-state/*.tfstate.*
```
This will ignore the `.tfstate` file in your project, which will use remote storage, but retain the `.tfstate` for the remote tfstate infrastructure.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [random_string.storage_account_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | The client ID to use for authenticating to Azure. Terraform authentication will overwrite this. | `string` | `null` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The name of the storage container to use for the Terraform state | `string` | `"terraform-state"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location to use for the Terraform state | `string` | `"centralus"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to use for the Terraform state | `string` | `"terraform-state"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the storage account to use for the Terraform state. Leave blank to let Terraform manage a globally unique name to fit Azure constraints. | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The subscription ID to use for the Terraform state | `string` | `null` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The tenant ID to use for the Terraform state | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | n/a |

These output values will serve as your terraform IaC project inputs.

<!-- END_TF_DOCS -->