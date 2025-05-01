#!/bin/bash

sudo mkdir /etc/k0s
# Config
sudo cp base.yaml /etc/k0s/k0s.yaml
# sudo cp containerd.toml /etc/k0s/containerd.toml
# manifests
sudo mkdir -p /var/lib/k0s/manifests
sudo cp -r manifests /var/lib/k0s
# Enable Single node controller and worker
sudo k0s install controller -c /etc/k0s/k0s.yaml --single
sudo k0s start
sleep 5

sudo k0s status
sudo k0s kubectl get nodes

mkdir ~/.kube
sudo cp /var/lib/k0s/pki/admin.conf ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
