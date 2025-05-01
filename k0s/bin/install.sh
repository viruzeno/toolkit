#!/bin/bash 

# Install K0s
sudo apt install curl
sudo bash ./tools/install-k0s.sh

# Install Kubectl
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo mv kubectl /usr/local/bin/kubectl
sudo chmod 755 /usr/local/bin/kubectl

wget https://github.com/k0sproject/k0sctl/releases/download/v0.17.8/k0sctl-linux-x64
sudo mv k0sctl-linux-x64 /usr/local/bin/k0sctl
sudo chmod 755 /usr/local/bin/k0sctl

curl -s https://fluxcd.io/install.sh | sudo bash

