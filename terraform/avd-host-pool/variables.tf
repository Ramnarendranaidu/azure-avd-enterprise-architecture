variable "environment" {
  description = "Deployment environment (e.g. dev, uat, prod)"
  type        = string
}

variable "region_short" {
  description = "Short region code used in naming (e.g. eus2, cus)"
  type        = string
  default     = "eus2"
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "East US 2"
}

variable "workload_name" {
  description = "Short workload identifier, e.g. 'finance' or 'callcenter'"
  type        = string
}

variable "workspace_friendly_name" {
  description = "Friendly name shown in the AVD client / Remote Desktop feed"
  type        = string
}

variable "host_pool_type" {
  description = "Pooled or Personal"
  type        = string
  default     = "Pooled"

  validation {
    condition     = contains(["Pooled", "Personal"], var.host_pool_type)
    error_message = "host_pool_type must be either 'Pooled' or 'Personal'."
  }
}

variable "load_balancer_type" {
  description = "BreadthFirst, DepthFirst, or Persistent (Personal pools)"
  type        = string
  default     = "BreadthFirst"
}

variable "max_sessions_per_host" {
  description = "Maximum concurrent sessions per session host (Pooled only)"
  type        = number
  default     = 8
}

variable "start_vm_on_connect" {
  description = "Enable start-VM-on-connect for cost optimization"
  type        = bool
  default     = true
}

variable "validate_environment" {
  description = "Mark this host pool as a validation/canary ring"
  type        = bool
  default     = false
}

variable "timezone" {
  description = "IANA/Windows timezone for scaling plan schedules"
  type        = string
  default     = "Eastern Standard Time"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Workload  = "AVD"
  }
}
