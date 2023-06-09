terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  client_id       = "5bfbb9da-9e56-4c19-912d-6cd356dd5c3a"
  client_secret   = BOv8Q~xuGsnYfnumX6RMkKflIW4aaakXRHhLxcFH
  subscription_id = "393e3de3-0900-4b72-8f1b-fb3b1d6b97f1"
  tenant_id       = "7349d3b2-951f-41be-877e-d8ccd9f3e73c"
}

resource "azurerm_resource_group" "exampleamina" {
  name     = "exampleamina-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "exampleamina" {
  name                = "exampleamina-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.exampleamina.location
  resource_group_name = azurerm_resource_group.exampleamina.name
}

resource "azurerm_subnet" "exampleamina" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.exampleamina.name
  virtual_network_name = azurerm_virtual_network.exampleamina.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "exampleamina" {
  name                = "exampleamina-nic"
  location            = azurerm_resource_group.exampleamina.location
  resource_group_name = azurerm_resource_group.exampleamina.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.exampleamina.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "exampleamina" {
  name                = "exampleamina-machine"
  resource_group_name = azurerm_resource_group.exampleamina.name
  location            = azurerm_resource_group.exampleamina.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.exampleamina.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }
}
