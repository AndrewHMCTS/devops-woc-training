# resource "azurerm_kubernetes_cluster" "aks" {
#   name                = "filevault-aks-${var.env}"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.rg.name
#   dns_prefix          = "filevault-aks-${var.env}-dns"

#   default_node_pool {
#     name       = "default"
#     node_count = 1
#     vm_size    = "standard_a2_v2"
#   }

#   identity {
#     type = "SystemAssigned"
#   }

#   network_profile {
#     network_plugin = "azure"
#   }
# }

# output "aks_kubeconfig" {
#   value     = azurerm_kubernetes_cluster.aks.kube_config_raw
#   sensitive = true
# }