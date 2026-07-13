# This creates and starts a container named mycontainer form an alpine image
# with an sh shell as its main process. The -d option sets the container to
# run in the background, in detached mode, with a pseudo-TTY attached (-t).
# The -i option is set to keep STDIN attached (-i), which prevents the sh process
# from exiting immediately.
sudo docker run --name dockerfile -d -i -t alpine /bin/sh

# This also runs in the backgorund
sudo docker exec -d dockerfile touch /tmp/execWorks

# This starts a new shell session in the container
sudo docker exec -it dockerfile sh

# Setting the environment variables
# These are available only for the started sh process and not to other processes
# running in the container.
sudo docker exec -e VAR_A=1 -e VAR_B=2 dockerfile env

# Setting the working directory for the exec process (--workdir, -w)
sudo docker exec -it dockerfile pwd
sudo docker exec -it -w /root dockerfile pwd



