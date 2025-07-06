
![Ansible](https://img.shields.io/badge/Ansible-000000?style=for-the-badge&logo=ansible&logoColor=white)![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)![Proxmox](https://img.shields.io/badge/Proxmox-E57000?style=for-the-badge&logo=proxmox&logoColor=white)![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=GNU%20Bash&logoColor=white)![VSCode](https://img.shields.io/badge/VSCode-0078D4?style=for-the-badge&logo=visual%20studio%20code&logoColor=white)![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)![Homebrew](https://img.shields.io/badge/homebrew-FBB040?style=for-the-badge&logo=homebrew&logoColor=white)

# Home lab automation

This repository is to support my home lab.\
I run a variety of hosts for my own learning purposes.

## Platform
I use a [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview) to host containers/virtual machines.

### _Provisioning_
[Terraform](./terraform/README.md) to provision the environment.

### _Configuration_
[Ansible](./ansible/README.md) to maintain the configuration of the hosts.

### _Secrets_
Secrets can be proctected in both Terrafrom and Ansible using [sops](https://getsops.io/)\
Although Ansible has a vault facility which is really nice I wanted something that would work for both tools which is why I chose to use SOPS.

## Setting up *sops* on mac

Install SOPS with homebrew `brew install sops`

Enrypt the secrets with either PGP or AGE keys.  AGE is easier to work with especially if you decide to use Terraform Cloud or CICD.

### PGP key

gpg can be used to generate keys for encrypting files, install gpg with homebrew `brew install gnupg`

Now generate a new key `gpg --full-generate-key`

Confirm with `gpg --list-keys` and you should see your key and ID

Create a file called `.sops.yaml` which contains the ID of the key (**sops** finds it using **yaml** extension and not **yml**):

    creation_rules:
    - path_regex: ".*"
      pgp: 1234567890987654321

*This should be present in both ansible/.sops.yaml and terraform/.sops.yaml which is useful as you can have different configurations*

**Replace the value with your own gpg key ID.** 

Add this to your environment file (mine is **zsh**) to tell GPG which terminal it needs to interact with for passphrase prompts 
if you chose to use a passphrase to protect your key

    echo 'export GPG_TTY=$(tty)' >> ~/.zshrc && source ~/.zshrc

Lastly, consider backing up your private and public keys (not really necessary for the public)

    gpg --export-secret-keys --armor 1234567890987654321 > private_key_backup.asc
    gpg --export --armor your_name@your_email.com > public_key_backup.asc

Restoring the keys can be done like this

    gpg --import private_key_backup.asc

### AGE key

An alternative to pgp is to use age, install with homebrew `brew install age`

Now generate a key file with `age-keygen -o age.key`

set the path to the keyfile for SOPS to locate it with 
    
    echo "export SOPS_AGE_KEY_FILE=<path>/age.key" >> ~/.zshrc
    source ~/.zshrc

Configure the `.sops.yaml` file with the AGE public key

    creation_rules:
    - path_regex: ".*"
      age: 1234567890987654321


## Using *sops* to protect secrets
Now that the keys are created and `.sops.yaml` config is in place you can encrypt/decrypt files with **sops**

- To encrypt a file: `sops encrypt secrets.yaml > secrets.enc.yaml`
- To decrypt a file:  `sops decrypt secrets.enc.yaml > secrets.yaml`

That method is useful when testing out the encryption but you can also encrypt/decrypt a file in place by passing in the `-i` option: 
    
    # In-place encrypt
    sops -e -i secrets.enc.yaml
    
    # In-place decrypt
    sops -d -i secrets.enc.yaml

**Terraform**: the file extenstion needs to be either `.yaml` or `.json` for it to automatically encrypt/decrypt with the provider.

**Ansible:** the file to be encrypted needs to have an extension `.sops.yml` or `.sops.yaml` for it to be automatically decrypted by the sops community plugin.

## Steps to rebuild entire home lab ##

1. install proxmox hypervisor on each node, set disk to `zfs`
2. login to each pve node and set repository from `enterprise-subscription` to `pve-no-subscription`, update & reboot
3. create cluster `pve-cluster` and join secondary node
4. download ct templates from the proxmox templates repo to match terraform spec on both nodes, cloud image file downloads are automated via the provision script
5. install **vim** and **sudo** via the shell on each node: `apt install -y vim sudo`
6. create your user account on each node: `useradd -m -s /bin/bash michael && usermod -aG sudo michael && passwd michael`
7. allow ssh key authentication on `/etc/ssh/sshd_config`
8. setup ssh key access to each node (your account and root with same pub key): `ssh-copy-id 192.168.1.40`
    - optional: disable password authentication in `sshd_config`
9. create `terraform-prov` user, role and api key, copy and paste the code from into a shell on a node from [here](./terraform/README.md#proxmox-api)
    - update terraform proxmox api connection details in terraform `terraform/secrets.enc.yaml` (remember to lock after)
10. run playbook to install provision template script: `ansible-playbook -K tool.yml --tags provision_template_script --extra-vars="run_provision_template_script=true"`
11. run **terraform plan** & **apply**
12. run bootstrap playbook on all hosts with `--skip-tags zabbix_agent,dns_record`
13. run **dns, docker, zabbix** playbooks, expect the zabbix playbook to take some time during the db schema import
14. visit zabbix url http://192.168.1.51:8080 and complete the installation
    - Zabbix db password from `ansible/group_vars/zabbix.sops.yaml`
    - Server name `Zabbix server`
    - Timezone as `Europe/Amsterdam`
15. create the zabbix api token and update it in `ansible/group_vars/all.sop.yaml`
16. re-run boostrap playbook `--tags zabbix_agent,dns_record`
17. Finally push the repository changes to github

Notes:
    - improve the process so as it does not take 17 steps to rebuild the infra
    - currently the process can take a 2-3 hours
    - consolodate the hypervisor shell tasks into a single script
