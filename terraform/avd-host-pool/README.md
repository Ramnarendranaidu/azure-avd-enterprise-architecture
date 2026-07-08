# AVD Host Pool Module

Provisions a complete AVD control-plane unit: host pool, registration token, workspace, application group, and (for pooled workloads) a business-hours auto-scaling plan.

## What this deploys

- Resource group scoped to a single workload
- Host pool (`Pooled` or `Personal`), with scheduled agent updates
- Workspace + Desktop application group, associated together
- Business-hours scaling plan (pooled host pools only) — ramps up at 06:00, peaks at 08:00, ramps down at 18:00, off-peak at 20:00

## Usage

```hcl
module "finance_avd" {
  source = "./terraform/avd-host-pool"

  environment              = "prod"
  workload_name            = "finance"
  workspace_friendly_name  = "Finance Desktop"
  host_pool_type           = "Pooled"
  max_sessions_per_host    = 6
  location                 = "East US 2"

  tags = {
    CostCenter = "Finance"
    Owner      = "cloud-infra-team"
  }
}
```

## Notes

- Session host VMs, NICs, and domain/Entra join are intentionally out of scope for this module — they're provisioned by a separate compute module so host pool lifecycle and compute lifecycle can scale independently (a lesson learned from watching a monolithic module become unmanageable at ~200 session hosts).
- `start_vm_on_connect` defaults to `true` for personal pools to control idle compute cost.
- The registration token has a 48-hour expiration by design — long enough for a pipeline run, short enough to limit exposure if leaked.
