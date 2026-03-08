output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.acr.login_server
}

output "app_url" {
  description = "URL of your running API"
  value       = "https://${azurerm_container_app.app.ingress[0].fqdn}"
}
