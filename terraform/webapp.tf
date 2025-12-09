locals {
  webapps = {
    frontend = {
      name  = "devopswoc-frontend"
      image = "devopswoc-frontend:latest"
      port  = "80"
    }
    backend = {
      name  = "devopswoc-backend"
      image = "devopswoc-backend:latest"
      port  = "8080"
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
      docker_image_name   = "${azurerm_container_registry.acr.login_server}/${each.key}:${each.value.image}"
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
    }
  }

  app_settings = {
    DB_USER       = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.pg_user.id})"
    DB_PASSWORD   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.pg_password.id})"
    DB_HOST       = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.db_host.id})"
    DB_NAME       = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.db_name.id})"
    DB_PORT       = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.db_port.id})"
    DATABASE_URL  = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.database_url.id})"
    WEBSITES_PORT = each.value.port
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  for_each = local.webapps

  principal_id         = azurerm_linux_web_app.apps[each.key].identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}