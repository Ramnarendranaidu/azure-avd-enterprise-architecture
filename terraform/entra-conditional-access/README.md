# Entra ID Conditional Access — AVD Zero Trust Perimeter

Codifies the Conditional Access policies that make **AVD the enforced trust boundary** for contractor and unmanaged-device access, rather than the corporate network.

## Design philosophy

Traditional VPN-based contractor access extends the corporate network perimeter to an unmanaged device. This policy set inverts that: contractors authenticate directly into a Conditional-Access-gated AVD session, and the AVD session — not the device or the network — is what's trusted.

| Policy | Purpose |
|---|---|
| `CA-AVD-Contractor-ZeroTrust-Perimeter` | Requires MFA + compliant device for AVD sign-in; re-evaluates the session every 4 hours rather than trusting a long-lived token |
| `CA-Global-Block-LegacyAuthentication` | Closes the legacy-auth MFA bypass gap tenant-wide |
| `CA-AdminPortal-RequireCompliantDevice` | Extends compliant-device enforcement to privileged Azure management access, not just AVD |

## Why `sign_in_frequency` matters here

A 4-hour re-authentication window on the contractor policy is a deliberate trade-off: short enough that a compromised or offboarded contractor session doesn't persist for a full working day, long enough not to generate MFA fatigue during normal use. This value should be tuned against your organization's offboarding SLA — if contractor access is revoked same-day, a shorter window closes that gap faster.

## Usage

```hcl
module "avd_conditional_access" {
  source = "./terraform/entra-conditional-access"

  policy_state                       = "enabledForReportingButNotEnforced" # start in report-only
  avd_enterprise_app_id              = var.avd_enterprise_app_id
  azure_management_app_id            = "797f4846-ba00-4fd7-ba43-dac1f8f63013" # Microsoft Azure Management
  contractor_group_object_id         = var.contractor_group_id
  full_time_employee_group_object_id = var.fte_group_id
  privileged_role_template_ids       = var.privileged_role_ids
}
```

**Rollout recommendation:** deploy every new Conditional Access policy in `enabledForReportingButNotEnforced` first, review sign-in logs for a full business cycle (minimum one week including a Monday), then flip to `enabled`. Skipping report-only mode is the single most common cause of CA-related lockout incidents.
