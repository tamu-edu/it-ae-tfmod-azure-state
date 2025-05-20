variable "storage_account_name" {
  type        = string
  description = "The name of the storage account to use for the Terraform state. Leave blank to let Terraform manage a globally unique name to fit Azure constraints."
  default     = null
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to use for the Terraform state. If `create_resource_group` is true, this will be the name of the created resource group. If `create_resource_group` is false, this module will find the existing resource group by that name."
  default     = "terraform-state"
}

variable "location" {
  type        = string
  description = "The location to use for the Terraform state"
  default     = "centralus"
}

variable "container_name" {
  type        = string
  description = "The name of the storage container to use for the Terraform state"
  default     = "terraform-state"
}

variable "client_id" {
  type        = string
  description = "The client ID to use for authenticating to Azure. Terraform authentication will overwrite this."
  default     = null
}

variable "subscription_id" {
  type        = string
  description = "The subscription ID to use for the Terraform state"
  default     = null
}

variable "tenant_id" {
  type        = string
  description = "The tenant ID to use for the Terraform state"
  default     = null
}

variable "remove_secrets_from_state" {
  type = bool
  description = "Whether to sanitize tfstate of access keys automatically created on created resources. Actual, assigned keys remain untouched on created assets."
  default = true
}

variable "resource_provider_registrations" {
  type        = string
  description = "Set to 'none' if using a limited user without permission to do provider registrations"
  default     = null
}

variable "create_resource_group" {
  type        = bool
  description = "Whether to create or to attach to an existing resource group. See `resource_group_name`. Defaults to true."
  default     = true
}

variable "tfstate_acl" {
  type = bool
  description = "Enables or Disabled the setup of an ACL for the blob storage account being created."
  default = false
}

variable "tfstate_acl_default_action" {
  type = string
  description = "(Required) Specifies the default action of allow or deny when no other rules match. Valid options are Deny or Allow."
  default = "Deny"
}

variable "tfstate_acl_ip_rule" {
  type = list(string)
  description = "(Optional) List of public IP or IP ranges in CIDR Format. Only IPv4 addresses are allowed. Private IP address ranges (as defined in RFC 1918) are not allowed."
  default = null
}

variable "tfstate_acl_bypass" {
  type = list(string)
  description = " (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None. Defaults to [\"AzureServices\"]."
  default = null
}