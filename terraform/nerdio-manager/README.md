# Nerdio Manager for Enterprise — Control Plane

Provisions the supporting Azure resources for a **Nerdio Manager for Enterprise (NME)** deployment: dedicated resource group, App Service Plan, Key Vault for secrets, log storage, and a scoped role assignment granting NME's managed identity control over the target AVD resource group.

## Architecture note: NME vs NMM

- **Nerdio Manager for Enterprise (NME)** — self-hosted in the customer's own Azure subscription, full control-plane ownership, used here for enterprises requiring their own compliance/network boundary.
- **Nerdio Manager for MSP (NMM)** — Nerdio-hosted multi-tenant control plane for managed service providers running multiple client environments from one console.

This module targets **NME**, matching the single-tenant enterprise pattern.

## What this deploys

- Dedicated resource group for the NME control plane (kept separate from AVD workload resource groups by design — control plane lifecycle should never be coupled to workload lifecycle)
- Windows App Service Plan hosting the NME web application
- Key Vault (purge protection + 90-day soft delete) for API keys, Azure Automation credentials, and integration secrets
- Storage account for scripted action logs and automation output
- A **scoped** role assignment (Desktop Virtualization Contributor on the AVD resource group only — not subscription-wide Contributor)

## RBAC hardening note

Nerdio's default marketplace deployment often grants subscription-level Contributor to the managed identity for simplicity. In a regulated enterprise environment (insurance/financial services), that's broader than necessary. This module intentionally scopes the role assignment down to the specific AVD resource group NME needs to manage — apply the same pattern per-workload if NME manages multiple AVD deployments across resource groups.

## Usage

```hcl
module "nme_controlplane" {
  source = "./terraform/nerdio-manager"

  environment            = "prod"
  unique_suffix          = "g1001p01"
  tenant_id              = var.entra_tenant_id
  avd_resource_group_id  = module.finance_avd.resource_group_name
  nme_managed_identity_principal_id = var.nme_identity_object_id
}
```
