# Entra ID → Tanium Cloud SCIM Provisioning

Design and configuration reference for provisioning **Tanium Cloud** access and RBAC entirely from **Microsoft Entra ID**, with no manual role assignment inside Tanium.

## Goal

Every Tanium Cloud user account, role assignment, and computer-group scope should trace back to Entra group membership. Onboarding, role changes, and offboarding all happen through Entra group management — never through the Tanium console directly.

## Setup sequence

1. **Add the Tanium Cloud gallery application** in Entra ID (Enterprise Applications → New Application → search "Tanium").
2. **Generate a SCIM provisioning token** from the Tanium Cloud console (Administration → Provisioning → SCIM) and register it as the SCIM endpoint credential on the Entra Enterprise App's Provisioning tab.
3. **Define attribute mappings** between Entra user/group schema and Tanium's SCIM schema — critically, map Entra group `displayName` to the Tanium role-scoping custom attribute so group membership drives RBAC scope, not just account existence.
4. **Scope provisioning** to a single pilot Entra security group first (`sg-tanium-pilot-users`) rather than "all users" — this is the single highest-leverage risk control in the whole setup, since a misconfigured attribute mapping applied tenant-wide is a bad afternoon.
5. **Validate RBAC mapping** against a test account: confirm the account lands in the correct Tanium role and Computer Group scope before expanding provisioning scope.
6. **Phase expansion** by adding additional Entra groups to the SCIM sync scope in waves, validating after each wave.

## RBAC mapping pattern

| Entra Security Group | Tanium Role | Computer Group Scope |
|---|---|---|
| `sg-tanium-admins` | Tanium Administrator | All Computers |
| `sg-tanium-soc-analysts` | Read-Only + Threat Response | All Computers |
| `sg-tanium-endpoint-eng` | Content + Package Admin | Non-Production |
| `sg-tanium-pilot-users` | Read-Only | Pilot Scope (single business unit) |

## Attribute mapping notes

- SCIM sync interval is Entra's standard ~40-minute cycle — role changes are not instantaneous. Document this expectation for the SOC team so an urgent access change doesn't get treated as a broken pipeline.
- Deprovisioning on group removal should be set to **disable**, not delete, the Tanium account — preserves audit trail continuity for compliance reporting.
- Token rotation: SCIM tokens should be rotated on a defined cadence (90 days is a reasonable default for a financial services environment) and rotation should be a documented runbook step, not an ad hoc action.

## Migration context

This SCIM/RBAC pattern is part of a broader phased migration moving endpoint visibility and management from a legacy tool to Tanium Cloud — Entra-driven provisioning was prioritized first specifically so that identity governance doesn't lag behind the endpoint tooling migration itself.
