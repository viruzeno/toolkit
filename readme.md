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
NAMESPACE="web"
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


# SELINUX FAULT FINDING

## find recent issues
```bash
sudo ausearch -ts recent

# This shows runc, failing to get access to relable a file

# type=SYSCALL msg=audit(1747643817.490:13634): arch=c000003e syscall=250 success=no exit=-13 a0=6 a1=2a150a8c a2=7feb7e5a5050 a3=0 items=0 ppid=3663152 pid=3663176 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="runc:[2:INIT]" exe="/runc" subj=system_u:system_r:container_runtime_t:s0 key=(null)
# type=AVC msg=audit(1747643847.464:13648): avc:  denied  { search } for  pid=3665084 comm="runc:[2:INIT]" scontext=system_u:system_r:container_runtime_t:s0 tcontext=system_u:system_r:container_file_t:s0:c104,c106 tclass=key permissive=0
```

## Generate Policy based on a command

You may want to set `selinux enforce 0` to have selinux allow the action, but log it, so that you can capture the full list of features needed in one take.

sudo semanage permissive -a container_runtime_t

```bash
sudo ausearch -c "runc:[2:INIT]" --raw | audit2allow -M runc_keyring
```