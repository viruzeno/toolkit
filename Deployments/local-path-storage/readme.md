
# Install the storage class
```bash
kubectl apply -f local-path-storage.yaml
```

# Made the local-path the default storage device type
```bash
kubectl get storageclass
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## Remove
```bash
kubectl delete -f local-path-storage.yaml
```

