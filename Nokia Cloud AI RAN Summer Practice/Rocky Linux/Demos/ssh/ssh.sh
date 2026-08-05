ssh-keygen # generate a key pair
ssh-copy-id luca@100.80.227.117 # copy the public key to the remote host
ssh luca@100.80.227.117 # login to the remote host without a password
cat ~/.ssh/authorized_keys # view the public key
