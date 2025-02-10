# Ansible automation environment

This is used to configure and maintain my home lab.

## Inventory
I prefer to use **.ini** formatting.  Update the inventory as needed in `inventory/hosts.ini`

## Playbooks
- **tools.yml**     - Collection of tools used to management the environment
- **bootstrap.yml** - Run against all hosts to bootstrap them with all requirements
- **dns.yml**       - Configures a Bind9 server for local domain name resolution
- **zabbix.yml**    - Configures a Zabbix monitoring system for the hosts within the lab network
- **docker.yml**    - Setup a standalone docker host, also provisions containers within the role

## Example playbook call to install packages for all hosts in the group 'dns'
`ansible-playbook -K --limit dns bootstrap --tags packages`

## Encrypted secrets
I have chosen to use SOPS as it works well with both Ansible and Terraform.\
See [here](../README.md#using-sops-to-protect-secrets) for more information on how to configure the encryption.

See the SOPS configuration file in *.sops.yaml*.  The plugin needs to be enabled with `vars_plugins_enabled = community.sops.sops`

The SOPS plugin will encrypt/decrypt files that have **.sops.yaml** file suffix (as it is a *yaml* file suffix you can ommit the "---" inside the file).\
If the there are variables that have a prefix *secret__* then only those variables are encrypted, otherwise the whole file will be encrypted.\
Although you only the secret variables are encrypted you must not edit variables, if you do you can expect a MAC mismatch error.

To decrypt or encrypt:

    # inplace decrypt
    sops -d -i group_vars/zabbix.sops.yaml

    # inplace encrypt
    sops -e -i group_vars/zabbix.sops.yaml