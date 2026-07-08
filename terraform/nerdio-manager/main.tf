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
# Resource Group for Nerdio Manager for Enterprise (NME) control plane
# ---------------------------------------------------------------------------
resource "azurerm_resource_group" "nme" {
  name     = "rg-${var.environment}-nme-controlplane"
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------------------------
# App Service Plan + App Service hosting the NME control plane
# (NME deploys as an Azure Marketplace app; this represents the
#  underlying compute/hosting resources it provisions into a
#  dedicated subscription or resource group per Nerdio's reference architecture)
# ---------------------------------------------------------------------------
resource "azurerm_service_plan" "nme" {
  name                = "asp-${var.environment}-nme"
  resource_group_name = azurerm_resource_group.nme.name
  location            = azurerm_resource_group.nme.location
  os_type             = "Windows"
  sku_name            = var.app_service_sku

  tags = var.tags
}

resource "azurerm_key_vault" "nme_secrets" {
  name                       = "kv-${var.environment}-nme-${var.unique_suffix}"
  resource_group_name        = azurerm_resource_group.nme.name
  location                   = azurerm_resource_group.nme.location
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Storage account backing NME automation logs / scripted actions output
# ---------------------------------------------------------------------------
resource "azurerm_storage_account" "nme_logs" {
  name                     = "stnme${var.environment}${var.unique_suffix}"
  resource_group_name      = azurerm_resource_group.nme.name
  location                 = azurerm_resource_group.nme.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Role assignment: NME managed identity gets Contributor scoped to the
# AVD workload subscription/resource groups it manages (least-privilege
# custom role is recommended over subscription Contributor in production;
# see README for the RBAC hardening note)
# ---------------------------------------------------------------------------
resource "azurerm_role_assignment" "nme_avd_scope" {
  scope                = var.avd_resource_group_id
  role_definition_name = "Desktop Virtualization Contributor"
  principal_id         = var.nme_managed_identity_principal_id
}
