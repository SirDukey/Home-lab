variable "vms" {
  description = "Map of vm configurations"
  type = map(object({
    target_node = string # The Proxmox node to host the VM
    vmid        = number # The unique VM ID
    name        = string # The name of the instance
    ip          = string # Ip address and subnet
    cores       = number # How many cores to allocate the VM
    memory      = number # Memory size
    size        = string # The size of the disk
    onboot      = bool   # Automatically start the VM when the node starts
    state       = string # Can be "running", "started", "stopped". Option "started" will only start the vm on creation and won't fully manage the power state
    template    = string # The name of the template to clone
    full_clone  = bool   # true: an independant clone, false: a linked clone where a snapshot of the base vm is made
  }))
  default = {
    docker = {
      target_node = "pve-node-01"
      vmid        = 300
      name        = "docker"
      ip          = "192.168.1.52/24"
      cores       = 4
      memory      = 4096
      size        = "20G"
      onboot      = false
      state       = "started"
      template    = "template-ubuntu-24-04-cloud"
      full_clone  = true
    },
    elastic = {
      target_node = "pve-node-01"
      vmid        = 301
      name        = "elastic"
      ip          = "192.168.1.55/24"
      cores       = 4
      memory      = 8196
      size        = "20G"
      onboot      = false
      state       = "started"
      template    = "template-ubuntu-24-04-cloud"
      full_clone  = true
    }
    kube-01 = {
      target_node = "pve-node-01"
      vmid        = 302
      name        = "kube-01"
      ip          = "192.168.1.56/24"
      cores       = 2
      memory      = 2048
      size        = "10G"
      onboot      = false
      state       = "started"
      template    = "template-ubuntu-24-04-cloud"
      full_clone  = true
    }
    kube-02 = {
      target_node = "pve-node-01"
      vmid        = 303
      name        = "kube-02"
      ip          = "192.168.1.57/24"
      cores       = 2
      memory      = 2048
      size        = "10G"
      onboot      = false
      state       = "started"
      template    = "template-ubuntu-24-04-cloud"
      full_clone  = true
    }
    kube-03 = {
      target_node = "pve-node-01"
      vmid        = 304
      name        = "kube-03"
      ip          = "192.168.1.58/24"
      cores       = 2
      memory      = 2048
      size        = "10G"
      onboot      = false
      state       = "started"
      template    = "template-ubuntu-24-04-cloud"
      full_clone  = true
    }
  }
}
