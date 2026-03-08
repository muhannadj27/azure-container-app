# -------------------------------------------------------
# Resource Group
# -------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# -------------------------------------------------------
# Azure Container Registry (ACR)
# This is where your Docker image gets stored
# Think of it like a private Docker Hub for your images
# -------------------------------------------------------
resource "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = var.tags
}

# -------------------------------------------------------
# Log Analytics Workspace
# This collects logs from your container app
# -------------------------------------------------------
resource "azurerm_log_analytics_workspace" "logs" {
  name                = "log-container-app-dev"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# -------------------------------------------------------
# Container Apps Environment
# This is the hosting environment for your container apps
# Think of it like a mini Kubernetes cluster managed by Azure
# -------------------------------------------------------
resource "azurerm_container_app_environment" "env" {
  name                       = var.container_app_env_name
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
  tags                       = var.tags
}

# -------------------------------------------------------
# Container App
# This is your actual running API
# -------------------------------------------------------
resource "azurerm_container_app" "app" {
  name                         = var.container_app_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  tags                         = var.tags

  # Tell Container Apps how to pull from your private registry
  registry {
    server               = azurerm_container_registry.acr.login_server
    username             = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  # Store the registry password as a secret
  secret {
    name  = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }

  # Configure the container
  template {
    container {
      name   = "todo-api"
      image  = "${azurerm_container_registry.acr.login_server}/todo-api:v1"
      cpu    = 0.25
      memory = "0.5Gi"
    }

    min_replicas = 0
    max_replicas = 1
  }

  # Make the API accessible from the internet
  ingress {
    external_enabled = true
    target_port      = 8000

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}