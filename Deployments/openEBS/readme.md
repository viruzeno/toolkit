
# Install the Operator
```bash
kubectl apply -f openebs-privileged-psp.yaml
kubectl apply -f operator.yaml
```

# Made the openebs-device the default storage device type
```bash
kubectl patch storageclass openebs-device -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## Remove
```bash
kubectl delete -f operator.yaml
kubectl delete -f openebs-privileged-psp.yaml
```






# Check for remaining items
```bash
kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n openebs

## Example
# kubectl patch blockdeviceclaim.openebs.io bdc-pvc-54b7ce54-612f-4865-8bc5-3a060fd198c4  -n openebs -p '{"metadata":{"finalizers":[]}}' --type=merge
# kubectl patch blockdevice.openebs.io blockdevice-269d0ded330bcec1496741aaa94297db  -n openebs -p '{"metadata":{"finalizers":[]}}' --type=merge
# kubectl patch blockdevice.openebs.io blockdevice-9e950444a40792331008f2329b2a044a  -n openebs -p '{"metadata":{"finalizers":[]}}' --type=merge
```

# Force Remove namespace (last resort)
```bash
NAMESPACE="openebs"
kubectl delete namespace ${NAMESPACE}

kubectl get namespace "${NAMESPACE}" -o json \
  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
  | kubectl replace --raw /api/v1/namespaces/${NAMESPACE}/finalize -f -
```
