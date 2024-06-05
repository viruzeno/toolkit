# toolkit

## Base OS Setup (Single node)

bash ./bin/install.sh

## Bootstrap Single node

bash ./bin/configure.sh

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

bash ./bin/clear.s




## Load balancer Setup

- https://docs.k0sproject.io/stable/examples/metallb-loadbalancer/
- https://docs.k0sproject.io/stable/examples/nginx-ingress/#install-nginx-using-loadbalancer

Metal LB is used to get IPs on a specific range
Nginx is then used to link into interal services

```bash
curl -H 'Host: web.example.com' http://192.168.1.170
```
