variable "resource_group_name" {
  description = "Azure resource group name"
  default     = "privatelink-pls-microhack-rg"
}

variable "location" {
  description = "Azure region. Must support availability zones."
  default     = "West Europe"
}

variable "linux_size" {
  type    = string
  default = "Standard_A1_v2"
}

variable "admin_ssh_key_file" {
  default = "~/.ssh/id_rsa.pub"
}
