terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53"
    }
  }
}

# ---------------------------------------------------------------------------
# Conditional Access: AVD is the trust boundary for contractor / BYOD access
#
# Design intent: unmanaged and contractor devices are never granted network
# trust. Instead, they are permitted to authenticate ONLY into a scoped
# Conditional Access session that terminates inside AVD, with a Continuous
# Access Evaluation-friendly session lifetime and no persistent browser
# session outside the AVD client.
# ---------------------------------------------------------------------------
resource "azuread_conditional_access_policy" "avd_contractor_zero_trust" {
  display_name = "CA-AVD-Contractor-ZeroTrust-Perimeter"
  state        = var.policy_state # "enabled", "disabled", or "enabledForReportingButNotEnforced"

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = [var.avd_enterprise_app_id]
    }

    users {
      included_groups = [var.contractor_group_object_id]
    }

    devices {
      filter {
        mode = "exclude"
        rule = "device.trustType -eq \"AzureAD\""
      }
    }
  }

  grant_controls {
    operator          = "AND"
    built_in_controls = ["mfa", "compliantDevice"]
  }

  session_controls {
    sign_in_frequency         = 4
    sign_in_frequency_period  = "hours"
    cloud_app_security_policy = "monitorOnly"
  }
}

# ---------------------------------------------------------------------------
# Conditional Access: block legacy authentication tenant-wide
# (baseline hygiene policy — legacy auth bypasses MFA entirely)
# ---------------------------------------------------------------------------
resource "azuread_conditional_access_policy" "block_legacy_auth" {
  display_name = "CA-Global-Block-LegacyAuthentication"
  state        = var.policy_state

  conditions {
    client_app_types = ["exchangeActiveSync", "other"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_groups = [var.contractor_group_object_id, var.full_time_employee_group_object_id]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

# ---------------------------------------------------------------------------
# Conditional Access: require compliant device for full-time employee
# access to management/administrative Azure resources
# ---------------------------------------------------------------------------
resource "azuread_conditional_access_policy" "require_compliant_device_admin" {
  display_name = "CA-AdminPortal-RequireCompliantDevice"
  state        = var.policy_state

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = [var.azure_management_app_id]
    }

    users {
      included_roles = var.privileged_role_template_ids
    }
  }

  grant_controls {
    operator          = "AND"
    built_in_controls = ["mfa", "compliantDevice"]
  }
}
