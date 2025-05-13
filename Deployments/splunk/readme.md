
# Apply the Operator
kubectl apply -f operator.yaml --server-side

# Create an instance
kubectl apply -n splunk-operator -f environment.yaml

# Create ingress
kubectl apply -n splunk-operator -f ingress.yaml