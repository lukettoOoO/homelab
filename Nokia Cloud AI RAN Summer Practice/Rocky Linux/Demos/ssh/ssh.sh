# check ssh daemon (on remote server)
sudo systemctl status ssh

# hardening and securing the ssh server (on remote server)
sudo nano /etc/ssh/sshd_config # check that PasswordAuthentication is set to no and PermitRootLogin is set to no
sudo systemctl restart ssh # restart the ssh daemon

# create a key pair between ssh client and server (on client)
ssh-keygen # generate a key pair
ls -l ~/.ssh/ # list the key files
cat ~/.ssh/id_ed25519.pub # view the PUBLIC key
ssh-copy-id luca@100.80.227.117 # copy the public key to the remote host
ssh luca@100.80.227.117 # login to the remote host without a password
cat ~/.ssh/authorized_keys # view the public key on the remote host
