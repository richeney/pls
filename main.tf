terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.51.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "pls" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_ssh_public_key" "pls" {
  name                = "sshPublicKey"
  resource_group_name = upper(azurerm_resource_group.pls.name)
  location            = azurerm_resource_group.pls.location
  public_key          = file(var.admin_ssh_key_file)
}

resource "azurerm_application_security_group" "linux" {
  name                = "applicationSecurityGroup"
  location            = azurerm_resource_group.pls.location
  resource_group_name = azurerm_resource_group.pls.name
}

resource "azurerm_network_security_group" "pls" {
  name                = "networkSecurityGroup"
  location            = azurerm_resource_group.pls.location
  resource_group_name = azurerm_resource_group.pls.name

  security_rule {
    name                                       = "nginx"
    priority                                   = 1003
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "Tcp"
    source_address_prefix                      = "*"
    source_port_range                          = "*"
    destination_application_security_group_ids = [azurerm_application_security_group.linux.id]
    destination_port_ranges                    = ["80", "443"]
  }
}

resource "azurerm_virtual_network" "pls" {
  name                = "virtualNetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.pls.location
  resource_group_name = azurerm_resource_group.pls.name

  subnet {
    name           = "saas"
    address_prefix = "10.0.1.0/24"
    security_group = azurerm_network_security_group.pls.id
  }
}

module "linux_vm" {
  source              = "./linux-vm"
  resource_group_name = azurerm_resource_group.pls.name
  location            = azurerm_resource_group.pls.location
  depends_on          = [azurerm_virtual_network.pls]

  for_each = toset(["web1", "web2", "web3"])

  name                 = each.value
  subnet_id            = azurerm_virtual_network.pls.subnet.*.id[0] // No idea why this is the syntax
  asg_id               = azurerm_application_security_group.linux.id
  admin_ssh_public_key = azurerm_ssh_public_key.pls.public_key
  zone                 = trimprefix(each.value, "web")
  ip_address           = cidrhost("10.0.1.0/24", trimprefix(each.value, "web") + 3)
}
