
# Apply the Operator
```bash
kubectl apply -f operator.yaml --server-side
```

# Create an instance
```bash
kubectl apply -n splunk-operator -f environment.yaml
```

# Create ingress
```bash
kubectl apply -n splunk-operator -f ingress.yaml
```

# Remove
```bash
kubectl delete -n splunk-operator -f ingress.yaml
kubectl delete -n splunk-operator -f environment.yaml
# Force Remove operator elements
kubectl patch clustermanager.enterprise.splunk.com rke  -n splunk-operator -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch indexercluster.enterprise.splunk.com rke  -n splunk-operator -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch monitoringconsole.enterprise.splunk.com rke  -n splunk-operator -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch standalone.enterprise.splunk.com rke  -n splunk-operator -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl delete -f operator.yaml
```

# Check for remaining items
```bash
kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n splunk-operator
```

# Force Remove namespace (last resort)
```bash
NAMESPACE="splunk-operator"
kubectl delete namespace ${NAMESPACE}

kubectl get namespace "${NAMESPACE}" -o json \
  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
  | kubectl replace --raw /api/v1/namespaces/${NAMESPACE}/finalize -f -
```
