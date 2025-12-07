resource "azurerm_linux_web_app" "frontend" {
  name                = "devopswoc-frontend"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.appplan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      docker_image_name        = "${azurerm_container_registry.acr.login_server}/frontend:latest"
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }
  }

  app_settings = {
    WEBSITES_PORT = "80"
  }
}

resource "azurerm_linux_web_app" "backend" {
  name                = "myapp-backend"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.appplan.id

  site_config {
    application_stack {
      docker_image_name        = "${azurerm_container_registry.acr.login_server}/frontend:latest"
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    WEBSITES_PORT                   = "8080"
    DOCKER_REGISTRY_SERVER_URL      = azurerm_container_registry.acr.login_server
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.acr.admin_password
  }
}
