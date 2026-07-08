terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

# ---------------------------------------------------------------------------
# Azure Files Premium — FSLogix profile container backend
# ---------------------------------------------------------------------------
resource "azurerm_storage_account" "fslogix" {
  name                     = "st${var.workload_name}fsl${var.unique_suffix}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Premium"
  account_kind             = "FileStorage"
  account_replication_type = "ZRS"
  min_tls_version          = "TLS1_2"

  # AD/Entra Kerberos auth for FSLogix, not storage account key auth
  azure_files_authentication {
    directory_type = var.directory_type # "AADKERBEROS" or "AD"
  }

  tags = var.tags
}

resource "azurerm_storage_share" "profiles" {
  name                 = "fslogix-profiles"
  storage_account_id  = azurerm_storage_account.fslogix.id
  quota                = var.profile_share_quota_gb
  enabled_protocol     = "SMB"
}

resource "azurerm_storage_share" "office_containers" {
  name                 = "fslogix-odfc"
  storage_account_id  = azurerm_storage_account.fslogix.id
  quota                = var.odfc_share_quota_gb
  enabled_protocol     = "SMB"
}

# ---------------------------------------------------------------------------
# NTFS-equivalent share permissions applied via RBAC (Storage File Data
# SMB Share Contributor scoped to the AVD session host / user group)
# ---------------------------------------------------------------------------
resource "azurerm_role_assignment" "profile_share_contributor" {
  scope                = azurerm_storage_share.profiles.resource_manager_id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = var.fslogix_user_group_object_id
}
