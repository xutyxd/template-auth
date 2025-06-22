#!/bin/bash
# Firewall rules
sudo ufw reset
sudo ufw default deny incoming
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable

# Docker security
echo '{
  "userns-remap": "default",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true
}' | sudo tee /etc/docker/daemon.json

sudo systemctl restart docker