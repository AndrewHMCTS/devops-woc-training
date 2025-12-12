# # Virtual Network
# resource "azurerm_virtual_network" "vnet" {
#   name                = "devops00-vnet-${var.env}"
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# # Subnet for App Service VNet Integration
# resource "azurerm_subnet" "snet_appservice" {
#   name                 = "snet-appservice"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.1.0/24"]

#   delegation {
#     name = "webapp-delegation"
#     service_delegation {
#       name    = "Microsoft.Web/serverFarms"
#       actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
#     }
#   }
# }

# # Subnet for PostgreSQL Flexible Server (private)
# resource "azurerm_subnet" "snet_postgresql" {
#   name                 = "snet-postgresql"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.2.0/24"]

#   delegation {
#     name = "postgresql-delegation"
#     service_delegation {
#       name = "Microsoft.DBforPostgreSQL/flexibleServers"
#       actions = [
#         "Microsoft.Network/virtualNetworks/subnets/join/action"
#       ]
#     }
#   }
# }

# # Subnet for Private Endpoints (currently empty; we will not use PE for Key Vault)
# # resource "azurerm_subnet" "snet_private_endpoints" {
# #   name                 = "snet-private-endpoints"
# #   resource_group_name  = azurerm_resource_group.rg.name
# #   virtual_network_name = azurerm_virtual_network.vnet.name
# #   address_prefixes     = ["10.0.3.0/24"]
# # }

# # Private DNS Zone for PostgreSQL
# resource "azurerm_private_dns_zone" "pg" {
#   name                = "privatelink.postgres.database.azure.com"
#   resource_group_name = azurerm_resource_group.rg.name
# }

# # resource "azurerm_public_ip" "example" {
# #   name                = "pubIP-${var.env}"
# #   location            = azurerm_resource_group.rg.location
# #   resource_group_name = azurerm_resource_group.rg.name
# #   allocation_method   = "Static"
# #   sku                 = "Standard"
# # }

# # ip config for our internal IP (webapp) and external for eg kv
# # resource "azurerm_network_interface" "example" {
# #   name                = "nic-${var.env}"
# #   location            = azurerm_resource_group.rg.location
# #   resource_group_name = azurerm_resource_group.rg.name

# #   ip_configuration {
# #     name                          = "internal"
# #     subnet_id                     = azurerm_subnet.snet_appservice.id
# #     private_ip_address_allocation = "Dynamic"
# #     public_ip_address_id          = azurerm_public_ip.example.id
# #   }
# # }

# #firewall rules
# # resource "azurerm_network_security_group" "example" {
# #     name                = "nsg-${var.env}"
# #     location            = azurerm_resource_group.rg.location
# #     resource_group_name = azurerm_resource_group.rg.name

# #     security_rule {
# #         name                       = "AllowPostgreSQL"
# #         priority                   = 100
# #         direction                  = "Inbound"
# #         access                     = "Allow"
# #         protocol                   = "Tcp"
# #         source_port_range          = "*"
# #         destination_port_range     = "5432"
# #         source_address_prefix      = "*"
# #         destination_address_prefix = "*"
# #     }
# # }


# # Link PostgreSQL DNS Zone to VNet
# # resource "azurerm_private_dns_zone_virtual_network_link" "pg_link" {
# #   name                  = "pg-dns-link-${var.env}"
# #   resource_group_name   = azurerm_resource_group.rg.name
# #   virtual_network_id    = azurerm_virtual_network.vnet.id
# #   private_dns_zone_name = azurerm_private_dns_zone.pg.name
# # }

# # resource "azurerm_private_endpoint" "pg_pe" {
# #   name                = "pg-pe"
# #   location            = azurerm_resource_group.rg.location
# #   resource_group_name = azurerm_resource_group.rg.name
# #   subnet_id           = azurerm_subnet.snet_postgresql.id

# #   private_service_connection {
# #     name                           = "pg-psc"
# #     private_connection_resource_id = azurerm_postgresql_flexible_server.pg.id
# #     subresource_names              = ["postgresqlServer"]
# #     is_manual_connection           = false
# #   }
# # }

# # resource "azurerm_private_dns_a_record" "pg_record" {
# #   name                = azurerm_postgresql_flexible_server.pg.name
# #   zone_name           = azurerm_private_dns_zone.pg.name
# #   resource_group_name = azurerm_resource_group.rg.name
# #   ttl                 = 300
# #   records             = [azurerm_private_endpoint.pg_pe.private_service_connection[0].private_ip_address]
# # }

# # resource "azurerm_private_dns_zone_virtual_network_link" "link" {
# #   name                  = "pg-dns-link"
# #   resource_group_name   = azurerm_resource_group.rg.name
# #   virtual_network_id    = azurerm_virtual_network.vnet.id
# #   private_dns_zone_name = azurerm_private_dns_zone.pg.name
# # }