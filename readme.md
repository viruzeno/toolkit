# toolkit

## Base OS Setup (Single node)

```bash
# Install K0s
sudo apt install curl
sudo bash install-k0s.sh

# Install Kubectl
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo mv kubectl /usr/local/bin/kubectl
sudo chmod 755 /usr/local/bin/kubectl

wget https://github.com/k0sproject/k0sctl/releases/download/v0.17.8/k0sctl-linux-x64
sudo mv k0sctl-linux-x64 /usr/local/bin/k0sctl
sudo chmod 755 /usr/local/bin/k0sctl
```

<!-- ## Prepare image bundle

```bash
k0s airgap list-images | xargs -I{} docker pull {}
docker image save $(k0s airgap list-images | xargs) -o bundle_file

sudo mkdir -p /var/lib/k0s/images
sudo cp bundle_file /var/lib/k0s/images/bundle_file
``` -->

## Bootstrap Single node

```bash
sudo mkdir /etc/k0s
# Config
sudo cp base.yaml /etc/k0s/k0s.yaml
# manifests
sudo mkdir -p /var/lib/k0s/manifests
sudo cp -r manifests /var/lib/k0s
# Enable Single node controller and worker
sudo k0s install controller -c /etc/k0s/k0s.yaml --single
sudo k0s start
sudo k0s status
sudo k0s kubectl get nodes
```

## Configure kubectl

```bash
mkdir ~/.kube
sudo cp /var/lib/k0s/pki/admin.conf ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
```

## Access Dashbaord

```bash
kubectl proxy &
kubectl -n kubernetes-dashboard create token admin-user
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
```

```bash
kubectl get pods --all-namespaces
kubectl get all --all-namespaces
```

## Gitlab

```bash
kubectl -n gitlab-system apply -f gitlab.yaml
```

# Mark as default stoagre 
```bash
kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## Deploy Rook

https://docs.k0sproject.io/stable/examples/rook-ceph/#6-deploy-rook

```bash
# https://github.com/rook/rook/tree/release-1.14/deploy/examples
kubectl apply -f manifests/ceph/a-crds.yaml -f manifests/ceph/a-common.yaml -f manifests/ceph/a-operator.yaml
kubectl apply -f manifests/ceph/b-cluster.yaml
kubectl apply -f manifests/ceph/c-storageclass.yaml

kubectl apply -f mongo-pvc.yaml
```

### Fault find rook

```bash
kubectl create -f development/toolbox.yaml
kubectl -n rook-ceph rollout status deploy/rook-ceph-tools
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash

ceph status
ceph osd status
ceph df
rados df

kubectl -n rook-ceph delete deploy/rook-ceph-tools
```

## Cleanup

```bash
sudo k0s stop
sudo k0s reset
```

## Load balancer Setup

- https://docs.k0sproject.io/stable/examples/metallb-loadbalancer/
- https://docs.k0sproject.io/stable/examples/nginx-ingress/#install-nginx-using-loadbalancer

Metal LB is used to get IPs on a specific range
Nginx is then used to link into interal services

```bash
curl -H 'Host: web.example.com' http://192.168.1.170
```