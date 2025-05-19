#!/bin/bash 

# Add RKE2 Repo
# NOTE: Check the release page at https://github.com/rancher/rke2/releases to get the Version infomation
export RKE2_MAJOR=1
export RKE2_MINOR=32
export RKE2_INCREMENT=4
# The is the version of Enterprise Linux (Oracle/Rhel Version)
export LINUX_MAJOR=9
# This must be the IP of the server, used for TLS Certs etc `ip a` to find this out.
export SERVER_IP="192.168.1.10"

# NOTE: The RPMS installed below will need to be embedded into a offline repo (install media?)
cat << EOF > latest.repo
[rancher-rke2-common-latest]
name=Rancher RKE2 Common Latest
baseurl=https://rpm.rancher.io/rke2/latest/common/centos/${LINUX_MAJOR}/noarch
enabled=1
gpgcheck=1
gpgkey=https://rpm.rancher.io/public.key

[rancher-rke2-${RKE2_MAJOR}-${RKE2_MINOR}-latest]
name=Rancher RKE2 ${RKE2_MAJOR}.${RKE2_MINOR} Latest
baseurl=https://rpm.rancher.io/rke2/latest/${RKE2_MAJOR}.${RKE2_MINOR}/centos/${LINUX_MAJOR}/x86_64
enabled=1
gpgcheck=1
gpgkey=https://rpm.rancher.io/public.key
EOF
sudo mv latest.repo /etc/yum.repos.d/rancher-rke2-${RKE2_MAJOR}-${RKE2_MINOR}-latest.repo

# Podman is only used on Developer machine for pulling images (may be useful as it's compatable with the RKE2 runtime)
sudo yum install -y podman zstd

# Nice to have devel stuff
sudo yum install -y oracle-epel-release-el9.x86_64
sudo yum install htop btop ranger ncdu

# Install from RKE2
sudo yum install -y curl wireguard-tools container-selinux iptables libnetfilter_conntrack libnfnetlink libnftnl policycoreutils-python-utils rke2-common rke2-server rke2-selinux

# Download files for offline use
curl -L "https://github.com/rancher/rke2/releases/download/v${RKE2_MAJOR}.${RKE2_MINOR}.${RKE2_INCREMENT}%2Brke2r1/rke2-images-canal.linux-amd64.tar.zst" -o outputs/rke2-images-canal.linux-amd64.tar.zst
curl -L "https://github.com/rancher/rke2/releases/download/v${RKE2_MAJOR}.${RKE2_MINOR}.${RKE2_INCREMENT}%2Brke2r1/rke2-images-core.linux-amd64.tar.zst" -o outputs/rke2-images-core.linux-amd64.tar.zst
curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o outputs/kubectl
curl -L https://github.com/derailed/k9s/releases/download/v0.50.4/k9s_linux_amd64.rpm -o ./outputs/k9s_linux_amd64.rpm
curl -L https://get.helm.sh/helm-v3.17.3-linux-amd64.tar.gz -o outputs/helm.tgz
tar xzf outputs/helm.tgz -C outputs/
mv outputs/linux-amd64/helm outputs
rm -rf outputs/linux-amd64
rm -rf outputs/helm.tgz
curl -L "https://raw.githubusercontent.com/rancher/local-path-provisioner/refs/heads/master/deploy/local-path-storage.yaml" -o outputs/local-path-storage.yaml

## Download Images and TAR them up
declare -A images
# Splunk
images["splunk-operator"]="docker.io/splunk/splunk-operator:2.8.0"
images["kube-rbac-proxy"]="gcr.io/kubebuilder/kube-rbac-proxy:v0.13.1"
images["splunk"]="docker.io/splunk/splunk:9.4"
images["splunk-universalforwarder"]="docker.io/splunk/universalforwarder:9.4"
# GitLab Cert Manager
images["cert-manager-cainjector"]="quay.io/jetstack/cert-manager-cainjector:v1.17.2"
images["cert-manager-controller"]="quay.io/jetstack/cert-manager-controller:v1.17.2"
images["cert-manager-webhook"]="quay.io/jetstack/cert-manager-webhook:v1.17.2"
# GitLab
images["postgres-exporter"]="docker.io/bitnami/postgres-exporter:0.14.0-debian-11-r2"
images["postgresql"]="docker.io/bitnami/postgresql:14.8.0"
images["redis"]="docker.io/bitnami/redis:7.2.4-debian-12-r9"
images["redis-exporter"]="docker.io/bitnami/redis-exporter:1.58.0-debian-12-r4"
images["configmap-reload"]="jimmidyson/configmap-reload:v0.5.0"
images["mc"]="minio/mc:RELEASE.2018-07-13T00-53-22Z"
images["minio"]="minio/minio:RELEASE.2017-12-28T01-21-00Z"
images["prometheus"]="quay.io/prometheus/prometheus:v2.38.0"
images["gitlab-certificates"]="registry.gitlab.com/gitlab-org/build/cng/certificates:v17.11.2"
images["gitlab-gitaly"]="registry.gitlab.com/gitlab-org/build/cng/gitaly:v17.11.2"
images["gitlab-base"]="registry.gitlab.com/gitlab-org/build/cng/gitlab-base:v17.11.2"
images["gitlab-container-registry"]="registry.gitlab.com/gitlab-org/build/cng/gitlab-container-registry:v4.19.0-gitlab"
images["gitlab-exporter"]="registry.gitlab.com/gitlab-org/build/cng/gitlab-exporter:15.3.0"
images["gitlab-kas"]="registry.gitlab.com/gitlab-org/build/cng/gitlab-kas:v17.11.2"
images["gitlab-shell"]="registry.gitlab.com/gitlab-org/build/cng/gitlab-shell:v14.41.0"
images["gitlab-sidekiq"]="registry.gitlab.com/gitlab-org/build/cng/gitlab-sidekiq-ee:v17.11.2"
images["gitlab-toolbox"]="registry.gitlab.com/gitlab-org/build/cng/gitlab-toolbox-ee:v17.11.2"
images["gitlab-webservice"]="registry.gitlab.com/gitlab-org/build/cng/gitlab-webservice-ee:v17.11.2"
images["gitlab-workhorse"]="registry.gitlab.com/gitlab-org/build/cng/gitlab-workhorse-ee:v17.11.2"
images["gitlab-kubectl"]="registry.gitlab.com/gitlab-org/build/cng/kubectl:v17.11.2"
images["gitlab-operator"]="registry.gitlab.com/gitlab-org/cloud-native/gitlab-operator:1.12.2"
# Utility
images["nginx"]="docker.io/nginx:1.28.0-alpine-perl"
images["nginx-unprivileged"]="docker.io/nginxinc/nginx-unprivileged:alpine3.21-perl"
# Storage Class
images["local-path-provisioner"]="rancher/local-path-provisioner:v0.0.31"
images["busybox"]="docker.io/busybox:stable-glibc"
# Test
images["rancher-demo"]="docker.io/bashofmann/rancher-demo:1.0.0"
# images["nginx-controller"]="registry.k8s.io/ingress-nginx/controller:v1.12.2"
# images["kube-webhook-certgen"]="registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.5.3"
images["nginx-test"]="docker.io/httpd:2.4.53-alpine"
images["dashboard-metrics"]="docker.io/kubernetesui/metrics-scraper:v1.0.8"
images["dashboard"]="docker.io/kubernetesui/dashboard:v2.7.0"

# Download images for offline use
for image in ${!images[@]}; do 
    podman pull ${images[$image]}
    podman save ${images[$image]} -o ./outputs/${image}.tar
    zstd -c -T0 --ultra -20 ./outputs/${image}.tar -o ./outputs/${image}.tar.zst
    rm ./outputs/${image}.tar
done

# NOTE: The following is the setup, and is fully offline.
# --------------------------

# Disable FirewallD - https://docs.rke2.io/known_issues#firewalld-conflicts-with-default-networking
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl mask firewalld

# Disable Network Manager on canal subinterfaces to prevent it messing up the routing
cat << EOF > rke2-canal.conf
[keyfile]
unmanaged-devices=interface-name:flannel*;interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico;interface-name:vxlan-v6.calico;interface-name:wireguard.cali;interface-name:wg-v6.cali
EOF
sudo mv rke2-canal.conf /etc/NetworkManager/conf.d/rke2-canal.conf

# Images
sudo mkdir -p /var/lib/rancher/rke2/agent/images/
sudo cp outputs/rke2-images-canal.linux-amd64.tar.zst /var/lib/rancher/rke2/agent/images/rke2-images-canal.linux-amd64.tar.zst
sudo cp outputs/rke2-images-core.linux-amd64.tar.zst /var/lib/rancher/rke2/agent/images/rke2-images-core.linux-amd64.tar.zst
# Load other container images into internal registry # NOTE: must use 'imagePullPolicy: IfNotPresent'
for image in ${!images[@]}; do sudo cp outputs/${image}.tar.zst /var/lib/rancher/rke2/agent/images/${image}.tar.zst; done

# Hardening for CIS mode
sudo cp -f /usr/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf
sudo systemctl restart systemd-sysctl
sudo useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U

# Hosts file for hostname
cat << EOF > hosts
127.0.0.1   localhost server server.local
::1         localhost server server.local
EOF
sudo mv hosts /etc/hosts

# Config file
cat << EOF > config.yaml
bind-address:
  - "${SERVER_IP}"
tls-san:
  - "server.local"
tls-san-security: false
cluster-cidr:
  - "10.42.0.0/16"
service-cidr:
  - "10.43.0.0/16"
service-node-port-range:
  - "30000-32767"
cluster-dns:
  - "10.43.0.10"
cluster-domain:
  - "server.local"
write-kubeconfig-mode: "0640"
cni: 
  - "canal"
selinux: true
enable-servicelb: true
#profile:
#    - "cis"
kubelet-arg:
  - "--cpu-manager-policy=static"
  - "--cpu-manager-policy-options=full-pcpus-only=true"
  - "--cpu-manager-reconcile-period=0s"
  - "--kube-reserved=cpu=1"
  - "--system-reserved=cpu=1"
EOF
sudo mv config.yaml /etc/rancher/rke2/

# Start RKE2
sudo systemctl enable rke2-server.service
sudo systemctl start rke2-server.service

# Install k9s
sudo yum install -y outputs/k9s_linux_amd64.rpm

# Kubectl
sudo rm /usr/local/bin/kubectl
sudo cp outputs/kubectl /usr/local/bin/kubectl
sudo chmod 750 /usr/local/bin/kubectl
sudo chown ${USER}:${USER} /usr/local/bin/kubectl

# Helm
sudo rm /usr/local/bin/helm
sudo cp outputs/helm /usr/local/bin/helm
sudo chmod 750 /usr/local/bin/helm
sudo chown ${USER}:${USER} /usr/local/bin/helm

# Bash Profile (needs reboot to apply)
export KUBECONFIG=${HOME}/.kube/config
echo "export KUBECONFIG=${HOME}/.kube/config" >> ${HOME}/.bash_profile
source <(kubectl completion bash)
echo 'source <(kubectl completion bash)' >> ${HOME}/.bash_profile

# k3s config into user folder
mkdir ${HOME}/.kube
sudo cat /etc/rancher/rke2/rke2.yaml > ${HOME}/.kube/config
sudo chown ${USER}:${USER} ${HOME}/.kube/config

# Allow ingres as we are in CIS mode - https://docs.rke2.io/known_issues#ingress-in-cis-mode
cat << EOF > ingress.conf
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ingress-to-backends
spec:
  podSelector: {}
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          app.kubernetes.io/name: rke2-ingress-nginx
  policyTypes:
  - Ingress
EOF
kubectl apply -f ingress.conf
rm ingress.conf

# Storage Class for Local Storage
kubectl apply -f outputs/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
sudo mkdir /opt/local-path-provisioner
sudo chcon -R -t svirt_sandbox_file_t -l s0 /opt/local-path-provisioner

# Selinux Policy for Local Storage
cat << EOF > localpathpolicy.te
module localpathpolicy 1.0;

require {
    type usr_t;
    type init_t;
    type container_t;
    type container_var_lib_t;
    class dir { search write add_name create remove_name rmdir setattr getattr };
    class file { create open write append read unlink setattr getattr };
}

#============= container_t ==============
allow container_t container_var_lib_t:file { create open write append read setattr getattr unlink };
allow container_t container_var_lib_t:dir { add_name create remove_name rmdir setattr write search };
allow container_t init_t:dir search;
allow container_t usr_t:dir { add_name create remove_name rmdir setattr getattr write };
allow container_t usr_t:file { create unlink write setattr getattr };
allow container_t init_t:file { read open };
EOF

checkmodule -M -m -o localpathpolicy.mod localpathpolicy.te
semodule_package -o localpathpolicy.pp -m localpathpolicy.mod
sudo semodule -i localpathpolicy.pp
sudo semanage fcontext -a -t container_file_t "/opt/local-path-provisioner(/.*)?"
sudo restorecon -R -v /opt/local-path-provisioner
rm localpathpolicy.*
