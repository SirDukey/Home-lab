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
      target_node = "pve"
      vmid        = 300
      name        = "docker"
      ip          = "192.168.1.52/24"
      cores       = 4
      memory      = 2048
      size        = "20G"
      onboot      = false
      state       = "started"
      template    = "template-ubuntu-20-04-cloud"
      full_clone  = true
    }
  }
}
