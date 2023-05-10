terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.36.0"
    }
  }

  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

provider "azurerm" {
  # Configuration options
  features {}
}

locals {
  resource_prefix = "${var.my_name}${random_string.random.result}"
}

resource "random_string" "random" {
  length  = 8
  special = false
  lower   = true
  upper   = false
}

resource "azurerm_resource_group" "example" {
  name     = "${local.resource_prefix}-rg"
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = "${local.resource_prefix}sa"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  blob_properties {
    restore_policy {
      days = 7
    }

    delete_retention_policy {
      days = 8
    }

    versioning_enabled = true

    change_feed_enabled = true
  }

  tags = {
    environment = "staging"
  }
}

# creating storage container
resource "azurerm_storage_container" "example" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

# creating file in the storage container
resource "azurerm_storage_blob" "example" {
  name                   = "ana.tfstate"
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"
}

