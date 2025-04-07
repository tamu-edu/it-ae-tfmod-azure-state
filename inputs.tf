variable "storage_account_name" {
  type        = string
  description = "The name of the storage account to use for the Terraform state. Leave blank to let Terraform manage a globally unique name to fit Azure constraints."
  default     = null
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to use for the Terraform state"
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
  description = "Set to 'false' if using a limited user without permission to create a resource group. If false, assumes the resource group already exists and will read data instead of creating."
  default     = true
}