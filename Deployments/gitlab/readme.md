# Create the namespace
kubectl apply -f namespace.yaml

# Install cert-manager
kubectl apply -f cert-manager.yaml

# Apply the Operator
kubectl apply -f operator.yaml --server-side

# Apply the environment
kubectl apply -n gitlab-system -f environment.yaml

