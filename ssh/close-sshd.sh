#!/bin/bash

# close sshd service

sudo systemctl stop ssh

# sudo systemctl disable ssh

# # config ufw
# sudo ufw deny ssh
# sudo ufw deny proto tcp from ${venus#*@} to any port 22
# sudo ufw disable

# ## delete rules
# sudo ufw status numbered
# sudo ufw delete 1  # e.g. 1 for number of rule to delete