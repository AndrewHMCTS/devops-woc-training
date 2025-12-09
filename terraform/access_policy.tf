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