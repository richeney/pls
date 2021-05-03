terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.51.0"
    }
  }
}

resource "azurerm_network_interface" "vm" {
  name                = "${var.name}-nic"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_application_security_group_association" "pls" {
  network_interface_id          = azurerm_network_interface.vm.id
  application_security_group_id = var.asg_id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  computer_name                   = var.name
  admin_username                  = "azureuser"
  disable_password_authentication = true
  size                            = "Standard_A1_v2"

  network_interface_ids = [azurerm_network_interface.vm.id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.name}-os"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  // custom_data = base64encode(templatefile("${path.module}/cloud-init.tpl", { hostname = var.name, zone = var.zone }))
  custom_data = filebase64("${path.module}/cloud-init")

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.admin_ssh_public_key
  }
}
