#!/bin/bash 
apk update
apk add bash curl iptables iproute2 ca-certificates openssl socat util-linux e2fsprogs
curl -sSLf https://get.k0s.sh | sh

# Enable cgroups
rc-service cgroups start
rc-update add cgroups

# Install
k0s install controller --single
service k0scontroller start

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
mv kubectl /usr/local/bin/kubectl
chmod 755 /usr/local/bin/kubectl

cp /var/lib/k0s/pki/admin.conf ~/.kube/config
chown $USER:$USER ~/.kube/config

kubectl get pods --all-namespaces