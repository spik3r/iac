output "resource_group_name" {
  description = "Name of the resource group containing the Terraform state"
  value       = azurerm_resource_group.terraform_state.name
}

output "storage_account_name" {
  description = "Name of the storage account for Terraform state"
  value       = azurerm_storage_account.terraform_state.name
}

output "container_name" {
  description = "Name of the blob container for Terraform state"
  value       = azurerm_storage_container.terraform_state.name
}

output "backend_config" {
  description = "Backend configuration for use in other Terraform configurations"
  value = {
    resource_group_name  = azurerm_resource_group.terraform_state.name
    storage_account_name = azurerm_storage_account.terraform_state.name
    container_name       = azurerm_storage_container.terraform_state.name
  }
}