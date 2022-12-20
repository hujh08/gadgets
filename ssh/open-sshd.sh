#!/bin/bash

# open sshd service

# # install
# sudo apt install openssh-server

# open sshd service

sudo systemctl enable ssh
sudo systemctl start ssh

# sudo systemctl restart ssh

# sudo systemctl status ssh

# configure ufw
# sudo ufw allow ssh
# sudo ufw allow proto tcp from xxx.xxx.xxx.xxx to any port 22 # only from xxx.xxx.xxx.xxx
sudo ufw allow proto tcp from ${venus#*@} to any port 22   # only allow access from venus
sudo ufw enable

# sudo ufw status