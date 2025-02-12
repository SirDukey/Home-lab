
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

1. install proxmox hypervisor on each node
2. login to each pve node and set repository from `enterprise-subscription` to `pve-no-subscription`
3. create cluster `pve-cluster` and join secondary node
4. create `terraform-prov` user, role and api key, copy and paste the code from into a shell on a node from [here](./terraform/README.md#proxmox-api)
5. update terraform proxmox api connection details in terraform `terraform/secrets.enc.yaml` (remember to lock after)
6. download ct templates from the proxmox templates repo and cloud image files from ubuntu cloud image site to match terraform spec on both nodes
7. install **vim** and **sudo** via the shell on each node: `apt install -y vim sudo`
8. create your user account on each node: `useradd michael; passwd michael; usermod -aG sudo michael`
9. allow ssh key authentication on `/etc/ssh/sshd_config`
10. setup ssh key access to each node (your account and root with same pub key): `ssh-copy-id 192.168.1.50`
11. disable password authentication in `sshd_config`
12. run playbook to install provision template script: `ansible-playbook -K tool.yml --tags provision_template_script`
13. run the script on each node bash `/var/lib/vz/snippets/provision-template.sh`
14. run **terraform plan** & **apply**
15. run bootstrap playbook on all hosts with `--skip-tags zabbix_agent,dns_record`
16. run **dns, docker, zabbix** playbooks, expect the zabbix playbook to take some time during the db schema import
17. visit zabbix url http://192.168.1.51:8080 and complete the installation
    - Zabbix db password from `ansible/group_vars/zabbix.sops.yaml`
    - Server name `Zabbix server`
    - Timezone as `Europe/Amsterdam`
18. create the zabbix api token and update it in `ansible/group_vars/all.sop.yaml`
19. re-run boostrap playbook `--tags zabbix_agent,dns_record`
20. Install the zabbix agent manually on each hypervisor node
21. Finally push the repository changes to github

Notes:
    - improve the process so as it does not take +- 20 steps to rebuild the infra
    - currently the process can take a few hours
    - consolodate the hypervisor shell tasks into a single script
