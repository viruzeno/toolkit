
# Install kyverno 
```bash
kubectl apply -f install.yaml --server-side
```

# Apply Policy files
```bash
kubectl apply -f *-policy.yaml
```

## Remove
```bash
kubectl delete -f *-policy.yaml
kubectl delete -f install.yaml
```

