output "name" {
  value = var.name
}

output "zone" {
  value = var.zone
}

output "ip_address" {
  value = azurerm_network_interface.vm.private_ip_address
}

output "output" {
  value = {
    "name"       = var.name
    "zone"       = var.zone
    "ip_address" = azurerm_network_interface.vm.private_ip_address
  }
}
