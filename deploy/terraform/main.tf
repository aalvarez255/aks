locals {
  nodepools = {}
}

resource "azurerm_resource_group" "rg" {
  name     = "aks-cluster"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-dns"

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_B2s"
    enable_auto_scaling = false
  }
  
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "nodepools" {
  for_each              = local.nodepools
  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  enable_auto_scaling   = true
  min_count             = each.value.min-count
  max_count             = each.value.max-count
  node_taints           = each.value.node_taints
  vm_size               = each.value.vm_size
}

resource "azurerm_container_registry" "acr" {
  name                          = "akscontainerregistry001"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  sku                           = "Basic"
  admin_enabled                 = false
}