terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

# ---------------------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------------------
resource "azurerm_resource_group" "avd" {
  name     = "rg-${var.environment}-avd-${var.region_short}"
  location = var.location

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Host Pool
# ---------------------------------------------------------------------------
resource "azurerm_virtual_desktop_host_pool" "this" {
  name                = "hp-${var.environment}-${var.workload_name}"
  resource_group_name = azurerm_resource_group.avd.name
  location            = azurerm_resource_group.avd.location

  type                    = var.host_pool_type # "Pooled" or "Personal"
  load_balancer_type      = var.load_balancer_type
  maximum_sessions_allowed = var.host_pool_type == "Pooled" ? var.max_sessions_per_host : null
  start_vm_on_connect     = var.start_vm_on_connect
  validate_environment    = var.validate_environment

  scheduled_agent_updates {
    enabled  = true
    timezone = var.timezone

    schedule {
      day_of_week = "Sunday"
      hour_of_day = 3
    }
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Registration Info (short-lived token for session host join)
# ---------------------------------------------------------------------------
resource "azurerm_virtual_desktop_host_pool_registration_info" "this" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.this.id
  expiration_date = timeadd(timestamp(), "48h")
}

# ---------------------------------------------------------------------------
# Workspace + Application Group
# ---------------------------------------------------------------------------
resource "azurerm_virtual_desktop_workspace" "this" {
  name                = "ws-${var.environment}-${var.workload_name}"
  resource_group_name = azurerm_resource_group.avd.name
  location            = azurerm_resource_group.avd.location
  friendly_name       = var.workspace_friendly_name

  tags = var.tags
}

resource "azurerm_virtual_desktop_application_group" "desktop" {
  name                = "dag-${var.environment}-${var.workload_name}"
  resource_group_name = azurerm_resource_group.avd.name
  location            = azurerm_resource_group.avd.location
  host_pool_id        = azurerm_virtual_desktop_host_pool.this.id
  type                = "Desktop"
  friendly_name       = "${var.workspace_friendly_name} - Full Desktop"

  tags = var.tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "this" {
  workspace_id         = azurerm_virtual_desktop_workspace.this.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop.id
}

# ---------------------------------------------------------------------------
# Scaling Plan (business-hours ramp for pooled workloads)
# ---------------------------------------------------------------------------
resource "azurerm_virtual_desktop_scaling_plan" "this" {
  count               = var.host_pool_type == "Pooled" ? 1 : 0
  name                = "sp-${var.environment}-${var.workload_name}"
  resource_group_name = azurerm_resource_group.avd.name
  location            = azurerm_resource_group.avd.location
  friendly_name       = "Business Hours Auto-scale"
  time_zone           = var.timezone

  schedule {
    name                                 = "weekdays"
    days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    ramp_up_start_time                   = "06:00"
    ramp_up_load_balancing_algorithm     = "BreadthFirst"
    ramp_up_minimum_hosts_percent        = 20
    ramp_up_capacity_threshold_percent   = 60
    peak_start_time                      = "08:00"
    peak_load_balancing_algorithm        = "DepthFirst"
    ramp_down_start_time                 = "18:00"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = 10
    ramp_down_capacity_threshold_percent = 90
    ramp_down_force_logoff_users         = false
    ramp_down_wait_time_minutes          = 30
    ramp_down_notification_message       = "This session will be logged off in 30 minutes to conserve resources. Save your work."
    off_peak_start_time                  = "20:00"
    off_peak_load_balancing_algorithm    = "DepthFirst"
  }

  host_pool {
    hostpool_id          = azurerm_virtual_desktop_host_pool.this.id
    scaling_plan_enabled = true
  }

  tags = var.tags
}
