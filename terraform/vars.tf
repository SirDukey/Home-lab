## Placeholders for variables that are stored in secrets.enc.yaml

variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = ""
}

variable "pm_api_token_id" {
  description = "Proxmox API Token ID"
  type        = string
  default     = ""
}

variable "pm_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  default     = ""
}

variable "root_password" {
  description = "Root password for the LXC containers"
  type        = string
  default     = ""
}

variable "default_user" {
  description = "Default user account for LXC containers"
  type = object({
    username       = string
    password       = string
    ssh_public_key = string
  })
  default = {
    username       = ""
    password       = ""
    ssh_public_key = ""
  }
}

## Globally accessible variables

variable "ssh_provisioning_key_path" {
  description = "Path to the SSH private key used for root access during provisioning"
  type = object({
    private_key = string
    public_key = string
  })
  default = {
    private_key = "data/keys/id_ed25519"
    public_key  = "data/keys/id_ed25519.pub"
  }
}

variable "lxc_template" {
    description = "LXC template"
    type        = object({
      ubuntu_24_04 = string
      arch         = string
      alpine_3_20  = string
    })
    default = {
      ubuntu_24_04 = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
      arch         = "local:vztmpl/archlinux-base_20240911-1_amd64.tar.zst"
      alpine_3_20  = "local:vztmpl/alpine-3.20-default_20240908_amd64.tar.xz"
    }
}

variable "default_gw" {
    description = "Default network gateway"
    type        = string
    default     = "192.168.1.1"
}

variable "default_nameserver" {
    description = "Default network nameserver"
    type        = object({
      primary   = string
      secondary = string 
    })
    default = {
      primary   = "192.168.1.53"
      secondary = "192.168.1.1"
    }
}

variable "default_searchdomain" {
    description = "Default network searchdomain"
    type        = string
    default     = "duke.lan"
}
