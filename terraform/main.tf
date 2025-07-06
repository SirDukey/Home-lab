terraform {
  cloud {
    organization = "SirDukey"
    workspaces {
      name = "Home-lab"
    }
  }
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      #version = "2.9.14"
      version = "3.0.1-rc4"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.1.1"
    }
  }
}

provider "sops" {}

data "sops_file" "tfvars" {
  source_file = "secrets.enc.yaml"
}

provider "proxmox" {
  pm_api_url          = data.sops_file.tfvars.data["pm_api_url"]
  pm_api_token_id     = data.sops_file.tfvars.data["pm_api_token_id"]
  pm_api_token_secret = data.sops_file.tfvars.data["pm_api_token_secret"]
  pm_tls_insecure     = true
}

