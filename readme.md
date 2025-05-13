# Toolkit

## Base OS Setup (Single node)

```bash
cd bin
bash ./install.sh
```

### Remove

```bash
sudo /usr/bin/rke2-uninstall.sh
rm -rf ~/.kube/
sudo rm -rf /var/lib/rancher/
sudo rm -rf /usr/local/bin/kubectlo
sudo rm "/etc/yum.repos.d/rancher-rke2-*"
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


# if kubectl is not working

```bash
/var/lib/rancher/rke2/bin/crictl --runtime-endpoint unix:///run/k3s/containerd/containerd.sock ps
```

# Get all images from a namespace
```bash 
kubectl --namespace gitlab-system describe pods | grep 'Image:' | awk '{print $2}' | sort | uniq
```