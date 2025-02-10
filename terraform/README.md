# Terraform provisioning environment

## Quick start

**1. Create a user, role, permissions and a token in Proxmvox. Read [Proxmox API](#proxmox-api) for details on how I configure the API access.**

**2. Create a `secrets.enc.yaml` file and populate it with the following:**

    pm_api_token_id: "your_api_token_id"
    pm_api_token_secret: "your_api_token_secret"
    root_password: "your_root_password"
    default_user:
      username: "your_user"
      password: "your_password"
      ssh_public_key: "your_user_ssh_public_key"

  *Replace the values for the with your own values (see [SSH Keys](#ssh-keys) below for more explanation on the ssh key)*

**3. Encrypt the file with `sops -e -i secrets.enc.yaml`**

**4. Terraform will automatically pick up the secret variables from secrets.enc.yaml and apply it when running commands like:**

    terraform plan
    terraform apply

  Individual instance provisioning can also be done, for example:

    terraform plan -target='proxmox_lxc.container-instance["dns_server"]'
    terraform apply -target='proxmox_lxc.container-instance["dns_server"]'


## How to provision containers

First download the template into Proxmox local storage, templates. `vars.tf` has a lookup configured to map the template location to a key.

Use the file `vars-containers.tf` to configure containers.
Add a new mapping in the file as follows:

    zabbix = {                         <- Resource name used in the terraform plan
      target_node = "pve-M910q-01"     <- The proxmox node which will host the container
      hostname    = "zabbix"           <- The hostname of the container
      template    = "ubuntu_24_04"     <- The template to clone from 
      ip          = "192.168.1.51/24"  <- The ip address and subnet mask
      memory      = 1024               <- Memory allocation in GB
      swap        = 256                <- Swap file allocation in GB
      size        = "4G"               <- Disk size allocation in GB
      onboot      = true               <- Start the container when Proxmox starts
      start       = true               <- Start the container after it has been provisioned
    }

The file `containers.tf` implements an each loop over the containers variable from `var-containers.tf`.
After a container is provisioned a remote execution is using the root account.  It creates the following:\
 - *default user*
 - *home directory*
 - *shell*
 - *sudo privileges*
 - *copies the public ssh key for direct access*

## How to provision virtual machines

A template is required to setup a VM, the process has a few steps to get a template ready.

1. Download a [cloud image](https://cloud-images.ubuntu.com/) into Proxmox's ISO storage.
2. Create base VM
3. Import the cloud image to a disk and attach to the VM
4. Convert the VM to a template

*For convenience I have an ansible [role](../ansible/roles/proxmox-template) which I can run to make the template script on the Proxmox hypervisors.  Its a template version of these commands which you can run directly in the Proxmox shell:*

    qm create 9000 --name template-ubuntu-20-04-cloud --memory 1024 --net0 virtio,bridge=vmbr0
    qm importdisk 9000 /var/lib/vz/template/iso/noble-server-cloudimg-amd64.img local-lvm
    qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
    qm set 9000 --ide2 local-lvm:cloudinit
    qm set 9000 --boot c --bootdisk scsi0
    qm set 9000 --serial0 socket --vga serial0
    qm template 9000

Now that there is a template created use the file `vars-vms.tf` to configure virtual machines.
Add a new mapping in the file as follows:

    docker = {                                     <- Resource name for Terraform
      target_node = "pve"                          <- Hypervisor node
      vmid        = 300                            <- Unique VMID
      name        = "docker"                       <- The VM name
      ip          = "192.168.1.52/24"              <- IP address/subnet
      cores       = 4                              <- CPU cores
      memory      = 2048                           <- Memory size
      size        = "20G"                          <- Disk size
      onboot      = false                          <- Start when the PVE starts
      state       = "started"                      <- Start after creation
      template    = "template-ubuntu-20-04-cloud"  <- The template to clone from
      full_clone  = true                           <- true for full or false for linked

### Destroying a resource
 `terraform destroy -target='proxmox_vm_qemu.vm-container["zabbix"]'`



## Proxmox API
I use [Telmate](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs) as a provider for interacting 
with my Proxmox VE which uses an API key to connect.  To connecto to the Proxmox api you first need to create a user, role, permissions and finally a token.  See the guide 
[here](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs#creating-the-proxmox-user-and-role-for-terraform) for to read more about it from the provider.

From the PVE node shell I create a role, user and permissions (*Proxmox GUI > Datacenter > PVE > Shell*).  

    pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"

    pveum user add terraform-prov@pve --password <password>
    pveum aclmod / -user terraform-prov@pve -role TerraformProv

Then create the API key by navigating to *Proxmox GUI > Datacenter > Permissions > API Tokens*\
Click *Add* then choose the *User*, set a value for *Token ID* (I choose **terraform**)\
Uncheck *Privilege Seperation* (this means that the token will inheret the permission set from the user)

## SSH Keys
During provisioning, the *root* account uses a *private/public* key pair to ssh to the containers.\
The keys are stored in `data/keys/`.\
Go to the section [README](data/keys/README.md) for more information on this.

You would have set a user account within `secrets.enc.yaml`, this `ssh_public_key` is used to setup
a sudo user after the container is provisioned and this is the account you should use for admin access.

You can create a private/public key pair for your user account with:
`ssh-keygen -t rsa`

## Managing resources with Terraform

See the official [documentation](https://developer.hashicorp.com/terraform/cli/commands) for more information
    
    # Destroy VM instance
    terraform destroy -target='proxmox_vm_qemu.vm-instance["docker"]'

    # Destroy container instance 
    terraform destroy -target='proxmox_lxc.vm-instance["zabbix"]'
  
    # Dry run on your infrasctructure provisioning
    terraform plan

    # Apply the changes
    terraform apply
    
    # State Refresh: Ensure that the state file is up-to-date with the actual state of your infrastructure. You can use the -refresh-only flag to refresh the state without applying changes
    terraform apply -refresh-only

