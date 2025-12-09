resource "random_password" "pg_password" {
  length           = 16
  special          = true
  override_special = "!@#$%&*()-_=+"
}

resource "azurerm_postgresql_flexible_server" "pg" {
  name                   = "devopswoc-db-${var.env}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "15"
  administrator_login    = "pgadmin"
  administrator_password = random_password.pg_password.result
  sku_name               = "GP_Standard_D4s_v3"
  storage_mb             = 32768
  backup_retention_days  = 7
  zone                   = "2"
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = "filevault_db"
  server_id = azurerm_postgresql_flexible_server.pg.id
  charset   = "UTF8"
  collation = "en_US.utf8"
  lifecycle {
    prevent_destroy = true
  }
}