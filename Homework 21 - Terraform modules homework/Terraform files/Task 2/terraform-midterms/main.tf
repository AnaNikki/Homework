terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.36.0"
    }
  }

  #backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

provider "azurerm" {
  # Configuration options
  features {}
}

locals {
  base_name         = "${var.my_name}-${var.environment}"
  network_base_name = "${local.base_name}-ntwrk"
}

# create resource group
resource "azurerm_resource_group" "general_network" {
  name     = "${local.network_base_name}-rg"
  location = var.location
}

# create virtual network
resource "azurerm_virtual_network" "general_network" {
  name                = "${local.network_base_name}-vnet"
  resource_group_name = azurerm_resource_group.general_network.name
  location            = azurerm_resource_group.general_network.location
  address_space       = ["10.0.0.0/16"]
}

# create subnet
resource "azurerm_subnet" "general_network_vms" {
  name                 = "${azurerm_virtual_network.general_network.name}-vms-snet"
  resource_group_name  = azurerm_resource_group.general_network.name
  virtual_network_name = azurerm_virtual_network.general_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "vm" {
  source        = "./vm_module"
  base_name     = local.base_name
  location      = var.location
  vms_subnet_id = azurerm_subnet.general_network_vms.id
  my_public_ip  = var.my_public_ip
  my_password   = var.my_password
}
