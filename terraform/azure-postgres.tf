resource "random_password" "pg_password" {
  length  = 16
  special = false
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
#   delegated_subnet_id    = azurerm_subnet.snet_postgresql.id
  #   private_dns_zone_id           = azurerm_private_dns_zone.pg.id
  public_network_access_enabled = true

  #   depends_on = [
  #     azurerm_private_dns_zone_virtual_network_link.pg_link
  #   ]
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = "filevault_db"
  server_id = azurerm_postgresql_flexible_server.pg.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}