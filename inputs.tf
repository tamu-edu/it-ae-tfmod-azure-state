variable "storage_account_name" {
  type        = string
  description = "The name of the storage account to use for the Terraform state"
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
  description = "The client ID to use for authenticating to Azure"
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
