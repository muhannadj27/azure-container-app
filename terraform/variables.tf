variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-container-app-dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westus3"
}

variable "container_registry_name" {
  description = "Name of the Azure Container Registry (must be globally unique, lowercase, no hyphens)"
  type        = string
  default     = "acrcontainerdev2026"
}

variable "container_app_name" {
  description = "Name of the container app"
  type        = string
  default     = "todo-api"
}

variable "container_app_env_name" {
  description = "Name of the Container Apps environment"
  type        = string
  default     = "cae-dev"
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "ContainerApp"
    ManagedBy   = "Terraform"
  }
}
