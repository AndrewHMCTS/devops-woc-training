resource "azurerm_role_assignment" "webapp_kv_access" {
  for_each = local.webapps

  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.apps[each.key].identity[0].principal_id

  depends_on = [azurerm_linux_web_app.apps]
}

resource "azurerm_role_assignment" "kv_admin_self" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

locals {
  acr_roles = [
    "Container Registry Repository Writer",
    "Container Registry Repository Reader",
    "Container Registry Contributor and Data Access Configuration Administrator",
    "AcrPull",
    "AcrPush",
    "SQL DB Contributor",
    "Key Vault Secrets User"
  ]
}

# For webapps MI
resource "azurerm_role_assignment" "webapp_acr_roles" {
  for_each = {
    for pair in setproduct(keys(local.webapps), local.acr_roles) :
    "${pair[0]}-${pair[1]}" => {
      webapp = pair[0]
      role   = pair[1]
    }
  }

  scope                = azurerm_container_registry.acr.id
  role_definition_name = each.value.role
  principal_id         = azurerm_linux_web_app.apps[each.value.webapp].identity[0].principal_id

  depends_on = [azurerm_linux_web_app.apps]
}

#For SP
resource "azurerm_role_assignment" "sp_acr_roles" {
  for_each = toset(local.acr_roles)

  scope                = azurerm_container_registry.acr.id
  role_definition_name = each.value
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "sp_webapp_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Website Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "sp_contributor_rg" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_access_policy" "webapp_kv" {
  for_each = local.webapps

  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.apps[each.key].identity[0].principal_id

  secret_permissions = ["Get", "List"]
}