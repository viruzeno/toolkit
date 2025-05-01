#!/bin/bash 

# Install K3s
sudo yum install curl nginx
# Podman is only used on Developer machine for pulling images
sudo yum install podman

# Download files for offline use
curl -L https://github.com/k3s-io/k3s-selinux/releases/download/v1.4.stable.1/k3s-selinux-1.4-1.el8.noarch.rpm -o outputs/k3s-selinux-1.4-1.el8.noarch.rpm
curl -L https://github.com/k3s-io/k3s/releases/download/v1.32.3%2Bk3s1/k3s-airgap-images-amd64.tar.zst -o outputs/k3s-airgap-images-amd64.tar.zst
curl -L https://github.com/k3s-io/k3s/releases/download/v1.32.3%2Bk3s1/k3s -o outputs/k3s
curl -L https://get.k3s.io/ -o outputs/install.sh
curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o outputs/kubectl

declare -A images
images["rancher-demo"]="docker.io/bashofmann/rancher-demo:1.0.0"
images["busybox"]="docker.io/busybox:stable-glibc"

# Download images for offline use
for image in ${!images[@]}; do 
    podman pull ${images[$image]}
    podman save ${images[$image]} -o ./outputs/${image}.tar
done

# Install (on remote host with the above files)
# SElinux
sudo yum install -y ./outputs/k3s-selinux-1.4-1.el8.noarch.rpm

# Images
sudo mkdir -p /var/lib/rancher/k3s/agent/images/
sudo cp outputs/k3s-airgap-images-amd64.tar.zst /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.zst
# Load other container images into internal registry # NOTE: must use 'imagePullPolicy: IfNotPresent'
for image in ${!images[@]}; do sudo cp outputs/${image}.tar /var/lib/rancher/k3s/agent/images/${image}.tar; done

# K3s
sudo cp outputs/k3s /usr/local/bin/k3s
sudo chmod 750 /usr/local/bin/k3s
sudo chown ${USER}:${USER} /usr/local/bin/k3s
# Disable traefik (As it uses an online helm chart)
# sudo mkdir -p /var/lib/rancher/k3s/server/manifests/
# sudo touch /var/lib/rancher/k3s/server/manifests/traefik.yaml.skip
# Compleyte install
export INSTALL_K3S_EXEC="--disable=traefik --embedded-registry --selinux"
export INSTALL_K3S_SKIP_DOWNLOAD=true
bash ./outputs/install.sh

# Kubectl
# k3s makes a simlink from k3s to kubectl, we need to remove it
sudo rm /usr/local/bin/kubectl
sudo cp outputs/kubectl /usr/local/bin/kubectl
sudo chmod 750 /usr/local/bin/kubectl
sudo chown ${USER}:${USER} /usr/local/bin/kubectl

# Bash Profile (needs reboot to apply)
export KUBECONFIG=${HOME}/.kube/config
echo "export KUBECONFIG=${HOME}/.kube/config" >> ${HOME}/.bash_profile
source <(kubectl completion bash)
echo 'source <(kubectl completion bash)' >> ${HOME}/.bash_profile

# k3s config into user folder
mkdir ${HOME}/.kube
sudo cat /etc/rancher/k3s/k3s.yaml > ${HOME}/.kube/config
sudo chown ${USER}:${USER} ${HOME}/.kube/config
