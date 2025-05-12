#!/bin/bash 

# Install K3s
sudo yum install curl wireguard-tools
# Podman is only used on Developer machine for pulling images
sudo yum install podman

# Download files for offline use
curl -L https://github.com/k3s-io/k3s-selinux/releases/download/v1.4.stable.1/k3s-selinux-1.4-1.el8.noarch.rpm -o outputs/k3s-selinux-1.4-1.el8.noarch.rpm
curl -L https://github.com/k3s-io/k3s/releases/download/v1.32.3%2Bk3s1/k3s-airgap-images-amd64.tar.zst -o outputs/k3s-airgap-images-amd64.tar.zst
curl -L https://github.com/k3s-io/k3s/releases/download/v1.32.3%2Bk3s1/k3s -o outputs/k3s
curl -L https://get.k3s.io/ -o outputs/install.sh
curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o outputs/kubectl
curl -L https://github.com/derailed/k9s/releases/download/v0.50.4/k9s_linux_amd64.rpm -o ./outputs/k9s_linux_amd64.rpm

declare -A images
images["rancher-demo"]="docker.io/bashofmann/rancher-demo:1.0.0"
images["busybox"]="docker.io/busybox:stable-glibc"
images["nginx-controller"]="registry.k8s.io/ingress-nginx/controller:v1.12.2"
images["kube-webhook-certgen"]="registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.5.3"
images["nginx-test"]="docker.io/httpd:2.4.53-alpine"
images["dashboard-metrics"]="docker.io/kubernetesui/metrics-scraper:v1.0.8"
images["dashboard"]="docker.io/kubernetesui/dashboard:v2.7.0"

# Download images for offline use
for image in ${!images[@]}; do 
    podman pull ${images[$image]}
    podman save ${images[$image]} -o ./outputs/${image}.tar
done

# Install (on remote host with the above files)
# SElinux
sudo yum install -y ./outputs/k3s-selinux-1.4-1.el8.noarch.rpm

# Firewalld
sudo firewall-cmd --add-port=443/tcp --permanent    # nginx 
sudo firewall-cmd --add-port=10250/tcp --permanent  # Metrics Server

##TEMP
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# Images
sudo mkdir -p /var/lib/rancher/k3s/agent/images/
sudo cp outputs/k3s-airgap-images-amd64.tar.zst /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.zst
# Load other container images into internal registry # NOTE: must use 'imagePullPolicy: IfNotPresent'
for image in ${!images[@]}; do sudo cp outputs/${image}.tar /var/lib/rancher/k3s/agent/images/${image}.tar; done

# Pre System Hardening
sudo cp ./conf/90-kubelet.conf /etc/sysctl.d/90-kubelet.conf
sudo sysctl -p /etc/sysctl.d/90-kubelet.conf

# K3s
sudo cp outputs/k3s /usr/local/bin/k3s
sudo chmod 750 /usr/local/bin/k3s
sudo chown ${USER}:${USER} /usr/local/bin/k3s

# Create conf folder
sudo mkdir -p /var/lib/rancher/k3s/server/manifests/
# Install AdmissionConfiguration Hardening Policy
# sudo cp ./conf/psa/yaml /var/lib/rancher/k3s/server/psa.yaml
# Install Nginx Ingress Controller
sudo cp -r ../manifests/nginx /var/lib/rancher/k3s/server/manifests/
# Install Kuberneties Dashboard
# sudo cp -r ../manifests/dashboard /var/lib/rancher/k3s/server/manifests/

# Compleyte install
export INSTALL_K3S_EXEC="--disable=traefik,metrics-server --embedded-registry --cluster-cidr=10.42.0.0/16 --service-cidr=10.43.0.0/16 --flannel-backend=host-gw" # --selinux --flannel-backend=wireguard-native --tls-san 192.168.1.10 and --node-ip 192.168.1.10"   # "--kube-apiserver-arg="admission-control-config-file=/var/lib/rancher/k3s/server/psa.yaml"
export INSTALL_K3S_SKIP_DOWNLOAD=true
bash ./outputs/install.sh

# Install k9s
sudo yum install -y outputs/k9s_linux_amd64.rpm

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

# Post K3S Hardening
# kubectl apply -f ./conf/NetworkPolicy.yaml