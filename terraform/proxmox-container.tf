resource "proxmox_lxc" "container-instance" {
  for_each      = var.containers
  target_node   = each.value.target_node
  vmid          = each.value.vmid
  hostname      = each.value.hostname
  ostemplate    = lookup(var.lxc_template, each.value.template)
  password      = data.sops_file.tfvars.data["root_password"]
  unprivileged  = true
  cores         = each.value.cores
  memory        = each.value.memory
  swap          = each.value.swap
  nameserver    = "${var.default_nameserver.primary} ${var.default_nameserver.secondary}"
  searchdomain  = var.default_searchdomain
  onboot        = each.value.onboot 
  start         = each.value.start
  ssh_public_keys = file(var.ssh_provisioning_key_path.public_key)

  rootfs {
    storage = "local-zfs"
    size    = each.value.size
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = each.value.ip
    gw     = var.default_gw
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file(var.ssh_provisioning_key_path.private_key)
      host        = element(split("/", each.value.ip), 0)
    }
    inline = [
    "useradd -m -s /bin/bash ${data.sops_file.tfvars.data["default_user.username"]}",
    "echo '${data.sops_file.tfvars.data["default_user.username"]}:${data.sops_file.tfvars.data["default_user.password"]}' | chpasswd",
    "usermod -aG sudo ${data.sops_file.tfvars.data["default_user.username"]}",
    "mkdir -p /home/${data.sops_file.tfvars.data["default_user.username"]}/.ssh",
    "echo '${data.sops_file.tfvars.data["default_user.ssh_public_key"]}' > /home/${data.sops_file.tfvars.data["default_user.username"]}/.ssh/authorized_keys",
    "chown -R ${data.sops_file.tfvars.data["default_user.username"]}:${data.sops_file.tfvars.data["default_user.username"]} /home/${data.sops_file.tfvars.data["default_user.username"]}/.ssh",
    "chmod 600 /home/${data.sops_file.tfvars.data["default_user.username"]}/.ssh/authorized_keys"
    ]
  }
  provisioner "local-exec" {
    command = <<EOT
  ansible-playbook \
    -i '${element(split("/", each.value.ip), 0)},' \
    -u ${data.sops_file.tfvars.data["default_user.username"]} \
    --private-key ${var.ssh_provisioning_key_path.private_key} \
    --extra-vars "ansible_become_pass='$BECOME_PASSWORD'" \
    ../ansible/bootstrap.yml
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
      onboot
    ]
  }
}