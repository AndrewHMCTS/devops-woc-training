data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                       = "devops00-kv-${var.env}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    virtual_network_subnet_ids = [
      azurerm_subnet.snet_pe.id
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge"
    ]

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Sign",
      "Verify",
      "WrapKey",
      "UnwrapKey",
    ]
  }
}

resource "azurerm_private_endpoint" "kv_pe" {
  name                = "kv-pe-${var.env}"
  location            = azurerm_resource_group.rg_sbox.location
  resource_group_name = azurerm_resource_group.rg_sbox.name
  subnet_id           = azurerm_subnet.snet_pe.id

  private_service_connection {
    name                           = "kv-psc"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}

resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "Set", "List"
  ]
}

resource "azurerm_key_vault_secret" "acr_user" {
  name         = "ACR-USERNAME"
  value        = azurerm_container_registry.acr.admin_username
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "acr_pass" {
  name         = "ACR-PASSWORD"
  value        = azurerm_container_registry.acr.admin_password
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "pg_user" {
  name         = "PG-USERNAME"
  value        = azurerm_postgresql_flexible_server.pg.administrator_login
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "pg_password" {
  name         = "PG-PASSWORD"
  value        = random_password.pg_password.result
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "db_host" {
  name         = "DB-HOST"
  value        = azurerm_postgresql_flexible_server.pg.fqdn
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "db_name" {
  name         = "DB-NAME"
  value        = azurerm_postgresql_flexible_server_database.db.name
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "db_port" {
  name         = "db-port"
  value        = "5432"
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "database_url" {
  name         = "DATABASE-URL"
  value        = "postgresql://${azurerm_postgresql_flexible_server.pg.administrator_login}:${random_password.pg_password.result}@${azurerm_postgresql_flexible_server.pg.fqdn}:5432/${azurerm_postgresql_flexible_server_database.db.name}?sslmode=require"
  key_vault_id = azurerm_key_vault.kv.id
}

resource "random_password" "secret_key" {
  length           = 64
  special          = true
  override_special = "!@#$%&*()-_=+"
}

resource "azurerm_key_vault_secret" "secret_key" {
  name         = "secret-key"
  value        = random_password.secret_key.result
  key_vault_id = azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}