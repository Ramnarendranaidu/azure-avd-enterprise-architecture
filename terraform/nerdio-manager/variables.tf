variable "environment" {
  description = "Deployment environment (e.g. dev, uat, prod)"
  type        = string
}

variable "location" {
  description = "Azure region for the NME control plane"
  type        = string
  default     = "East US 2"
}

variable "unique_suffix" {
  description = "Short unique suffix for globally-unique resource names (storage, key vault)"
  type        = string
}

variable "tenant_id" {
  description = "Entra ID tenant ID"
  type        = string
}

variable "app_service_sku" {
  description = "App Service Plan SKU hosting the NME control plane"
  type        = string
  default     = "P1v3"
}

variable "avd_resource_group_id" {
  description = "Resource ID of the AVD resource group NME will manage"
  type        = string
}

variable "nme_managed_identity_principal_id" {
  description = "Object ID of the NME control plane's system-assigned managed identity"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Workload  = "Nerdio-Manager"
  }
}
