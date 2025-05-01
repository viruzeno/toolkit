#!/bin/bash 

# Install K0s
sudo yum install curl

# Download files for offline use
curl -L https://github.com/k3s-io/k3s-selinux/releases/download/v1.4.stable.1/k3s-selinux-1.4-1.el8.noarch.rpm -o outputs/k3s-selinux-1.4-1.el8.noarch.rpm
curl -L https://github.com/k3s-io/k3s/releases/download/v1.32.3%2Bk3s1/k3s-airgap-images-amd64.tar.zst -o outputs/k3s-airgap-images-amd64.tar.zst
curl -L https://github.com/k3s-io/k3s/releases/download/v1.32.3%2Bk3s1/k3s -o outputs/k3s
curl -L https://get.k3s.io/ -o outputs/install.sh
curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o outputs/kubectl

# Install (on remote host with the above files)
# SElinux
sudo yum install -y ./outputs/k3s-selinux-1.4-1.el8.noarch.rpm

# Images
sudo mkdir -p /var/lib/rancher/k3s/agent/images/
sudo cp outputs/k3s-airgap-images-amd64.tar.zst /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.zst

# K3s
sudo cp outputs/k3s /usr/local/bin/k3s
sudo chmod 750 /usr/local/bin/k3s
sudo chown ${USER}:${USER} /usr/local/bin/k3s
INSTALL_K3S_SKIP_DOWNLOAD=true bash ./outputs/install.sh

# Kubectl
sudo cp outputs/kubectl /usr/local/bin/kubectl
sudo chmod 750 /usr/local/bin/kubectl
sudo chown ${USER}:${USER} /usr/local/bin/kubectl

# Bash Profile (needs reboot to apply)
export KUBECONFIG=${HOME}/.kube/config
echo "export KUBECONFIG=${HOME}/.kube/config" >> ${HOME}/.bash_profile
source <(kubectl completion bash)
echo 'source <(kubectl completion bash)' >> ${HOME}/.bash_profile

# k3s config into user folder
sudo cat /etc/rancher/k3s/k3s.yaml > ${HOME}/.kube/config
sudo chown ${USER}:${USER} ${HOME}/.kube/config
