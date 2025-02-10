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
