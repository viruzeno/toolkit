# Apply the Operator
```bash
kubectl apply -f a-common.yaml --server-side
kubectl apply -f a-crds.yaml --server-side
kubectl apply -f a-operator.yaml --server-side
kubectl apply -f b-cluster.yaml --server-side
kubectl apply -f c-storageclass.yaml --server-side

kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

# Remove

```bash
kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

kubectl delete -f c-storageclass.yaml
kubectl delete -f b-cluster.yaml
kubectl delete -f a-operator.yaml
kubectl delete -f a-crds.yaml
kubectl delete -f a-common.yaml
```

# On issues

```bash
kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get --show-kind --ignore-not-found -n rook-ceph
```

```bash
kubectl patch cephobjectstore.ceph.rook.io ceph-objectstore -n rook-ceph -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch cephfilesystem.ceph.rook.io ceph-filesystem -n rook-ceph -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch secret rook-ceph-mon -n rook-ceph -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch configmap rook-ceph-mon-endpoints -n rook-ceph -p '{"metadata":{"finalizers":[]}}' --type=merge
```

```bash
NAMESPACE="rook-ceph"
kubectl delete namespace ${NAMESPACE}

kubectl get namespace "${NAMESPACE}" -o json \
  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
  | kubectl replace --raw /api/v1/namespaces/${NAMESPACE}/finalize -f -
```