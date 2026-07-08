output "host_pool_id" {
  description = "Resource ID of the AVD host pool"
  value       = azurerm_virtual_desktop_host_pool.this.id
}

output "host_pool_registration_token" {
  description = "Registration token used by session hosts joining this host pool"
  value       = azurerm_virtual_desktop_host_pool_registration_info.this.token
  sensitive   = true
}

output "workspace_id" {
  description = "Resource ID of the AVD workspace"
  value       = azurerm_virtual_desktop_workspace.this.id
}

output "application_group_id" {
  description = "Resource ID of the desktop application group"
  value       = azurerm_virtual_desktop_application_group.desktop.id
}

output "resource_group_name" {
  description = "Resource group containing all AVD control plane objects"
  value       = azurerm_resource_group.avd.name
}
