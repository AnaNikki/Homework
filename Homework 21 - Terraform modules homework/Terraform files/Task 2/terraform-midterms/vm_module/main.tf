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
  vm_name = "${var.base_name}-vm"
}

# create resource group
resource "azurerm_resource_group" "vm" {
  name     = "${local.vm_name}-rg"
  location = var.location
}

# create public ip
resource "azurerm_public_ip" "vm" {
  name                = "${local.vm_name}-pip"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location
  allocation_method   = "Static"
}

# create network interface
resource "azurerm_network_interface" "vm" {
  name                = "${local.vm_name}-nic"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location

  ip_configuration {
    name                          = "external"
    subnet_id                     = var.vms_subnet_id ##
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

# create network security group
resource "azurerm_network_security_group" "vm" {
  name                = "${azurerm_network_interface.vm.name}-nsg"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location

  # security rule No.1
  security_rule {
    name                       = "allow_ssh_from_my_ip"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "22"
    source_address_prefix      = var.my_public_ip
    destination_address_prefix = "*"
    source_port_range          = "*"
  }

  # security rule No.2
  security_rule {
    name                       = "allow_http_from_my_ip"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "80"
    source_address_prefix      = var.my_public_ip
    destination_address_prefix = "*"
    source_port_range          = "*"
  }
}

## associate the network interface and the network security group 
resource "azurerm_network_interface_security_group_association" "vm_nsg_to_vm_nic" {
  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

# create virtual machine
resource "azurerm_linux_virtual_machine" "web_srv" {
  name                            = local.vm_name
  resource_group_name             = azurerm_resource_group.vm.name
  location                        = azurerm_resource_group.vm.location
  size                            = "Standard_B2s"
  admin_username                  = "adminuser"
  admin_password                  = var.my_password
  network_interface_ids           = [azurerm_network_interface.vm.id]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


