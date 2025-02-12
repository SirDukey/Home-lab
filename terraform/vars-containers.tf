variable "containers" {
  description = "Map of container configurations"
  type = map(object({
    target_node = string  # The Proxmox node to host the container 
    vmid        = number  # The unique VM ID for the containter on Proxmox
    hostname    = string  # The name of the instance
    template    = string  # The name of the template to clone.  Key lookup from var.lxc_template
    ip          = string  # Ip address and subnet
    cores       = number  # Amount of CPU cores
    memory      = number  # Memory size
    swap        = number  # Allocate swap space
    size        = string  # Allocate disk space
    onboot      = bool    # Automatically start the container when the node starts
    start       = bool    # Start the container after it is created
  }))
  
  default = {
    zabbix = {
      target_node = "pve-node-02"
      vmid        = 200
      hostname    = "zabbix"
      template    = "ubuntu_24_04"
      ip          = "192.168.1.51/24"
      cores       = 2
      memory      = 1536
      swap        = 512
      size        = "4G"
      onboot      = true
      start       = true
    }
    nameserver = {
      target_node = "pve-node-02"
      vmid        = 201
      hostname    = "nameserver"
      template    = "ubuntu_24_04"
      ip          = "192.168.1.53/24"
      cores       = 1
      memory      = 1024
      swap        = 256
      size        = "4G"
      onboot      = true
      start       = true
    }
  }
}