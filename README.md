# it-ae-tfmod-azure-state
This is a terraform module for initializing a terraform state backend in Azure. 

By default, it creates a resource group named `terraform-state`, a storage account with a unique name, and a container named "terraform-state", 

Azure will not auto-assign sufficient access privilege to your az cli user running terraform automatically. Follow this environment backend module's apply with authenticated:
```
az role assignment create --assignee PRINCIPAL_ID --role "Storage Blob Data Contributor" --scope $(terraform output -raw storage_role_access_scope -state=PATH_TO_TFSTATE)
```
While the az role assignment is very quick, it may take up to ten minutes for your principal to gain role access to this resource (see [learn.microsoft.com/en-us/azure/storage/blobs/assign-azure-role-data-access](https://learn.microsoft.com/en-us/azure/storage/blobs/assign-azure-role-data-access?tabs=azure-cli#:~:text=When%20you%20assign%20roles%20or%20remove%20role%20assignments%2C%20it%20can%20take%20up%20to%2010%20minutes%20for%20changes%20to%20take%20effect.)).

<!-- BEGIN_TF_DOCS -->
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
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | The client ID to use for authenticating to Azure | `string` | `null` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The name of the storage container to use for the Terraform state | `string` | `"terraform-state"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location to use for the Terraform state | `string` | `"centralus"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to use for the Terraform state | `string` | `"terraform-state"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the storage account to use for the Terraform state | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The subscription ID to use for the Terraform state | `string` | `null` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The tenant ID to use for the Terraform state | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | n/a |
<!-- END_TF_DOCS -->