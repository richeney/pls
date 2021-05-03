variable "name" {
  description = "Hostname for the VM."
  type        = string
}

variable "subnet_id" {
  description = "Resource ID for a subnet."
  type        = string
}

variable "zone" {
  description = "Availability zone number."
  type        = number
}

variable "admin_ssh_public_key" {
  description = "SSH public key. Has priority over the admin_ssh_public_key_file variable"
  type        = string
}

variable "asg_id" {
  description = "Optional resource ID for an application security group"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Name for the resource group. Required."
  type        = string
  default     = "arc-onprem-servers"
}

variable "location" {
  description = "Azure region."
  default     = "UK South"
}
