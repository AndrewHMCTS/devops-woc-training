locals {
  webapps = {
    frontend = {
      name  = "devopswoc-frontend"
      image = "devopswoc-frontend:latest"
      port  = "3000"
    }
    backend = {
      name  = "devopswoc-backend"
      image = "devopswoc-backend:latest"
      port  = "8000"
    }
  }
}

resource "azurerm_linux_web_app" "apps" {
  for_each            = local.webapps
  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.appplan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      docker_image_name = "${azurerm_container_registry.acr.login_server}/${each.key}:latest"
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
    }
    container_registry_use_managed_identity = true
  }

  app_settings = {
    AZURE_STORAGE_ACCOUNT_NAME = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.storage_account_name.id})"
    AZURE_STORAGE_ACCOUNT_KEY  = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.storage_account_key.id})"
    AZURE_CONTAINER_NAME       = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.container_name.id})"
    DB_USER                    = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.pg_user.id})"
    DB_PASSWORD                = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.pg_password.id})"
    DB_HOST                    = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.db_host.id})"
    DB_NAME                    = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.db_name.id})"
    DB_PORT                    = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.db_port.id})"
    DATABASE_URL               = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.database_url.id})"
    SECRET_KEY                 = azurerm_key_vault_secret.secret_key.value
    WEBSITES_PORT              = each.value.port
  }

  lifecycle {
    ignore_changes = [
      identity
    ]
  }
}

# resource "azurerm_app_service_virtual_network_swift_connection" "apps_vnet" {
#   for_each = azurerm_linux_web_app.apps

#   app_service_id = each.value.id
#   subnet_id      = azurerm_subnet.snet_appservice.id

#   depends_on = [azurerm_linux_web_app.apps]
# }