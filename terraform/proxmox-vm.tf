resource "proxmox_vm_qemu" "vm-instance" {
  for_each      = var.vms
  name          = each.value.name
  target_node   = each.value.target_node
  vmid          = each.value.vmid
  clone         = each.value.template
  full_clone    = true
  agent         = 1
  os_type       = "cloud-init"
  cores         = each.value.cores
  memory        = each.value.memory
  hotplug       = each.value.hotplug
  numa          = each.value.numa
  nameserver    = "${var.default_nameserver.primary} ${var.default_nameserver.secondary}"
  searchdomain  = var.default_searchdomain
  onboot        = each.value.onboot
  vm_state      = each.value.state
  ciuser        = data.sops_file.tfvars.data["default_user.username"]
  cipassword    = data.sops_file.tfvars.data["default_user.password"]
  sshkeys       = data.sops_file.tfvars.data["default_user.ssh_public_key"]
  
  vga {
    type   = "virtio"  # serial0 or virtio
  }

  serial {
    id   = 0
    type = "socket"  # used when vga type == 'serial0'
  }

  scsihw = "virtio-scsi-pci"
  disk {
    size    = each.value.size
    type    = "disk"
    slot    = "scsi0"
    storage = "local-zfs"
    discard = true
  }
  disk {
    type    = "cloudinit"
    slot    = "ide2"
    storage = "local-zfs"
  }

  ipconfig0     = "ip=${each.value.ip},gw=${var.default_gw}"
  # network {
  #   id     = 0 # terraform-ls: ignore-line
  #   model  = "virtio"
  #   bridge = "vmbr0"
  # }

  lifecycle {
    ignore_changes = [
      default_ipv4_address,
      ssh_host,
      ssh_port,
      ipconfig0,
      disk,
      network,
      onboot
    ]
  }
}