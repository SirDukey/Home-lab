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
    storage     = string  # Which disk id to use
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
      memory      = 1024
      swap        = 512
      size        = "4G"
      storage     = "local-zfs"
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
      memory      = 512
      swap        = 256
      size        = "4G"
      storage     = "local-zfs"
      onboot      = true
      start       = true
    }
    fluentd = {
      target_node = "pve-node-01"
      vmid        = 202
      hostname    = "fluentd"
      template    = "ubuntu_24_04"
      ip          = "192.168.1.54/24"
      cores       = 1
      memory      = 1024
      swap        = 256
      size        = "10G"
      storage     = "local-zfs"
      onboot      = true
      start       = true
    }
    grafana = {
      target_node = "pve-node-02"
      vmid        = 203
      hostname    = "grafana"
      template    = "ubuntu_24_04"
      ip          = "192.168.1.59/24"
      cores       = 1
      memory      = 1024
      swap        = 256
      size        = "10G"
      storage     = "local-zfs"
      onboot      = true
      start       = true
    }
    wazuh = {
      target_node = "pve-node-01"
      vmid        = 204
      hostname    = "wazuh"
      template    = "ubuntu_24_04"
      ip          = "192.168.1.60/24"
      cores       = 4
      memory      = 4098
      swap        = 1024
      size        = "40G"
      storage     = "local-zfs"
      onboot      = true
      start       = true
    }
    ollama = {
      target_node = "pve-node-01"
      vmid        = 205
      hostname    = "ollama"
      template    = "ubuntu_24_04"
      ip          = "192.168.1.61/24"
      cores       = 1
      memory      = 2048
      swap        = 0
      size        = "40G"
      storage     = "local-zfs"
      onboot      = true
      start       = true
    }
  }
}