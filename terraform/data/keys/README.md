The public and private keys in this directory are used to allow root ssh access to
the containers during provisioning.

They can be regenerated using (assuming your working directory is `terraform`):

`ssh-keygen -t rsa -b 2048 -f data/keys/id_rsa -N ""`


    -t rsa: Specifies the type of key to create (RSA).
    -b 2048: Specifies the number of bits in the key (2048 bits is a common choice).
    -f data/keys/id_rsa: Specifies the file in which to save the private key.
    -N "": Provides an empty passphrase, which means no passphrase will be set, and it will not prompt for one.

The keys are ignored by GIT for security reasons.

Back to main [README](../../README.md)