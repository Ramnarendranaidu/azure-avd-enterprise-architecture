variable "workload_name" {
  description = "Short workload identifier"
  type        = string
}

variable "unique_suffix" {
  description = "Short unique suffix for globally-unique storage account naming"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the FSLogix storage account"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "directory_type" {
  description = "AADKERBEROS (Entra ID Kerberos) or AD (traditional AD DS)"
  type        = string
  default     = "AADKERBEROS"
}

variable "profile_share_quota_gb" {
  description = "Quota in GB for the FSLogix profile container share"
  type        = number
  default     = 5120
}

variable "odfc_share_quota_gb" {
  description = "Quota in GB for the Office ODFC container share"
  type        = number
  default     = 2048
}

variable "fslogix_user_group_object_id" {
  description = "Entra security group object ID granted SMB share access for FSLogix"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
