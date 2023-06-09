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