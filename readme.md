# Toolkit

## Base OS Setup (Single node)

```bash
cd bin
bash ./install.sh
```

## Install manifests

### Dashboard

```bash
sudo cp -r manifests/dashboard/ /var/lib/rancher/k3s/server/manifests/dashboard/
# Browse to https://<serverip>:30001/#/login
## Generate Token
kubectl -n kubernetes-dashboard create token admin-user
```

## Deploy Deployments

```bash
kubectl apply -n test -f Deployments/networkaccess/pod.yaml
kubectl -n test get all
```


## Helpful commands

```bash
kubectl get pods --all-namespaces
kubectl get all --all-namespaces
```

### Force delete namespace that is stuck in terminating 

```bash
NAMESPACE="test"
kubectl delete namespace ${NAMESPACE}

kubectl get namespace "${NAMESPACE}" -o json \
  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
  | kubectl replace --raw /api/v1/namespaces/${NAMESPACE}/finalize -f -
```
