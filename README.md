# it-ae-tfmod-azure-state

This is a terraform module for initializing a terraform state backend in Azure.
By default, it creates a resource group named `terraform-state`, a storage account with a unique name, and a container named "terraform-state". It outputs a template string for a terraform backend configuration that you can use to create your backend block file.

## Example usage

A common pattern for using this module is to create a folder within your terraform IaC project for setting up your environment, such as `/environments/{env_name}/setup`, containing a `main.tf` like:

```terraform
locals {
  tenant_id         = "your-tenant-id"
  subscription_id   = "your-subscription-id"
  environment       = "prod"
}

module "state_backend" {
  source = "github.com/tamu-edu/it-ae-tfmod-azure-state?ref=v0.3"

  container_name      = "tfstate"
  location            = "southcentralus"
  resource_group_name = "myproject-prod-tfstate"
  tenant_id           = local.tenant_id
  subscription_id     = local.subscription_id
}

# This stores this [setup] module's state file at "terraform-state/bootstrap/prod.tfstate"
resource "local_file" "write_setup_backend_config" {
  content = templatestring(module.state_backend.terraform_backend_template, {
    key = "terraform-state/bootstrap/${local.environment}.tfstate"
  })
  filename = "./backend.tf"
}

# This stores the parent module's state file at "terraform-state/env/prod.tfstate"
resource "local_file" "write_parent_backend_config" {
  content = templatestring(module.state_backend.terraform_backend_template, {
    key = "terraform-state/env/${local.environment}.tfstate"
  })
  filename = "../backend.tf"
}
```


To execute, first `az login` with an appropriately permissioned Azure account using the Azure CLI. Once logged in, run command `terraform init`. Then, run `terraform plan` to see what will be created. If satisfied with the results, run command `terraform apply`. This will create the appropriate Azure Blob Storage for holding state files for the main project.

Once created, run `terraform init -migrate-state` to migrate the local state to the new remote backend.

```bash
$ az login
$ terraform init
$ terraform plan
$ terraform apply
$ terraform init -migrate-state # moves the local state to the new remote backend
```

> [!WARNING]
> It is highly recommended to move this module's terraform state to the new backend with `terraform init -migrate-state`. This ensures that any resources created by this module are tracked in the same backend as the rest of your project and allows for easier collaboration with other team members, and eventual cleanup of the resources.
> 
> Do not commit this module's state file to source control as Azure storage account resources contain access keys that would be a security risk to commit.


## Granting Access

> [!NOTE]
> When a storage account is created outside the Azure portal, full access is not automatically granted to the creator.

This module will grant the calling principal (i.e. a `User`) the "Storage Blob Data Owner" role on the storage account. This allows the creator to manage the storage account itself, and access the data plane of the storage account (i.e. the blob storage).

To grant access to someone or something else (such as a service principal) you will need to add additional role assignments.

```hcl
resource "azurerm_role_assignment" "tfstate_role_assignment" {
  scope                = module.state_backend.container_role_access_scope
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = "<object id of principal you need to grant access to>"
}
```


[//]: # (This document is generated with the command `terraform-docs markdown . --output-file README.md`)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>4.31.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.tfstate_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.tfstate_acl](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [random_string.storage_account_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | The client ID to use for authenticating to Azure. Terraform authentication will overwrite this. | `string` | `null` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The name of the storage container to use for the Terraform state | `string` | `"terraform-state"` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Whether to create or to attach to an existing resource group. See `resource_group_name`. Defaults to true. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The location to use for the Terraform state | `string` | `"centralus"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to use for the Terraform state. If `create_resource_group` is true, this will be the name of the created resource group. If `create_resource_group` is false, this module will find the existing resource group by that name. | `string` | `"terraform-state"` | no |
| <a name="input_resource_provider_registrations"></a> [resource\_provider\_registrations](#input\_resource\_provider\_registrations) | Set to 'none' if using a limited user without permission to do provider registrations | `string` | `null` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the storage account to use for the Terraform state. Leave blank to let Terraform manage a globally unique name to fit Azure constraints. | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The subscription ID to use for the Terraform state | `string` | `null` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The tenant ID to use for the Terraform state | `string` | `null` | no |
| <a name="input_tfstate_acl_bypass"></a> [tfstate\_acl\_bypass](#input\_tfstate\_acl\_bypass) | Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None. | `list(string)` | <pre>[<br/>  "AzureServices"<br/>]</pre> | no |
| <a name="input_tfstate_acl_default_action"></a> [tfstate\_acl\_default\_action](#input\_tfstate\_acl\_default\_action) | Specifies the default action of allow or deny when no other rules match. Valid options are Deny or Allow. | `string` | `"Deny"` | no |
| <a name="input_tfstate_acl_enable"></a> [tfstate\_acl\_enable](#input\_tfstate\_acl\_enable) | Enables or Disabled the setup of an ACL for the blob storage account being created. | `bool` | `false` | no |
| <a name="input_tfstate_acl_ip_rule"></a> [tfstate\_acl\_ip\_rule](#input\_tfstate\_acl\_ip\_rule) | List of public IP or IP ranges in CIDR Format. Only IPv4 addresses are allowed. Private IP address ranges (as defined in RFC 1918) are not allowed. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | Will output the tfstate storage container id |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | Will output the tfstate storage container name |
| <a name="output_container_role_access_scope"></a> [container\_role\_access\_scope](#output\_container\_role\_access\_scope) | Complete scope string down to the tfstate storage container |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Will output the name of the resource group |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | ID of the tfstate storage account suitable for very broad scope string building (see container\_role\_access\_scope) |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Will output the storage account name |
| <a name="output_terraform_backend_template"></a> [terraform\_backend\_template](#output\_terraform\_backend\_template) | A string containing a partial terraform backend specification with a placeholder for the key (i.e. path inside the container). |
<!-- END_TF_DOCS -->

These output values will serve as your terraform IaC project inputs.
