output "vms" {
  value = [for name in ["web1", "web2", "web3"] :
    module.linux_vm[name].output
  ]
}
