![Ansible](https://img.shields.io/badge/Ansible-000000?style=for-the-badge&logo=ansible&logoColor=white)

# Ansible Automation Environment

This repository is used to configure and maintain my home lab.

## Inventory

I prefer to use **.ini** formatting. Update the inventory as needed in [`inventory/hosts.ini`](inventory/hosts.ini).

## Playbooks

- **[`tools.yml`](tools.yml)**: Collection of tools used to manage the environment.
- **[`bootstrap.yml`](bootstrap.yml)**: Run against all hosts to bootstrap them with all requirements.
- **[`dns.yml`](dns.yml)**: Configures a Bind9 server for local domain name resolution.
- **[`zabbix.yml`](zabbix.yml)**: Configures a Zabbix monitoring system for the hosts within the lab network.
- **[`docker.yml`](docker.yml)**: Sets up a standalone Docker host and provisions containers within the role.

## Example Playbook Call

To install packages for all hosts in the group 'dns':

```sh
ansible-playbook -K --limit dns bootstrap.yml --tags packages
```
Deploy a container using its tag against the docker playbook (use --limit if targeting):

```sh
ansible-playbook -K docker.yml --tags jellyfin,prowlarr,radarr,sonarr
```

## Encrypted secrets
I have chosen to use SOPS as it works well with both Ansible and Terraform.\
See [here](../README.md#using-sops-to-protect-secrets) for more information on how to configure the encryption.

See the SOPS configuration file in *.sops.yaml*.  The plugin needs to be enabled with:

`vars_plugins_enabled = host_group_vars,community.sops.sops`

The SOPS plugin will encrypt/decrypt files that have **.sops.yaml** file suffix (as it is a *yaml* file suffix you can ommit the "---" inside the file).  If the there are variables that have a suffix `__enc` then only those variables are encrypted, otherwise the whole file will be encrypted.

__Although only the secret variables are encrypted you must not edit any variables, if you do you can expect a MAC mismatch error.__

To decrypt or encrypt:

    # In-place decrypt
    sops -d -i group_vars/zabbix.sops.yaml

    # In-place encrypt
    sops -e -i group_vars/zabbix.sops.yaml

VSCode has plugins which auto decrypt/encrypt the sops files so you don't have to worry about this, for example: SOPS Easy Edit

## Tools

A collection of tools used to help manage the PVE infrastructure,  call these by using the --tags option and/or use the --limit option.
List of available tags:

- `ping`:  standard ping and response to check host is online
- `facts`:  show the facts of a host
- `provision_template_script`:  copies the provion-template.sh script to the PVE host
    -   to auto run the script combine with `--extra-vars="run_provision_template_script=true"`
- `show_instances`: shows the containers and virtual machine instances running on the PVE host

---

Back to [main](../README.md) page
