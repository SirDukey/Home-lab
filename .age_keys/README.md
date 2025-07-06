## AGE Keys folder

This is a backup folder containing the AGE keys created for use with SOPS.

Generate a key with this command:

`age-keygen -o age.key`


I have chosen to use SOPS as it works well with both Ansible and Terraform.\
See [here](../README.md#using-sops-to-protect-secrets) for more information on how to configure the encryption.

Back to [main](../README.md) page