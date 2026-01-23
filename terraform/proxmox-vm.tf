resource "proxmox_vm_qemu" "vm-instance" {
  for_each      = var.vms
  name          = each.value.hostname
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
    storage = each.value.storage
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

  provisioner "local-exec" {
    command = <<EOT
  if grep -iq "${each.value.hostname}" ../ansible/inventory/hosts.ini; then
    echo "Running bootstrap playbook for ${each.value.hostname}..."
    ansible-playbook \
      -i '${element(split("/", each.value.ip), 0)},' \
      -u ${data.sops_file.tfvars.data["default_user.username"]} \
      --private-key ${var.ssh_provisioning_key_path.private_key} \
      --extra-vars "ansible_become_pass=$BECOME_PASSWORD" \
      ../ansible/bootstrap.yml
  else
    echo "Host ${each.value.hostname} is not in the ansible inventory file, skipping bootstrap playbook."
  fi
  EOT

    environment = {
      BECOME_PASSWORD = data.sops_file.tfvars.data["default_user.password"]
      ANSIBLE_CONFIG = "../ansible/ansible.cfg"
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
    
    working_dir = "${path.module}"
  }

  lifecycle {
    ignore_changes = [
      default_ipv4_address,
      ssh_host,
      ssh_port,
      ipconfig0,
      disk,
      network,
      onboot,
      sshkeys
    ]
  }
}