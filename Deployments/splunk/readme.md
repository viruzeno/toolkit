
# Apply the Operator
kubectl apply -f operator.yaml --server-side

# Create an instance
kubectl apply -n splunk-operator -f environment.yaml

# Create ingress
kubectl apply -n splunk-operator -f ingress.yaml


# Remove
kubectl delete -n splunk-operator -f ingress.yaml
kubectl delete -n splunk-operator -f environment.yaml
kubectl delete -f operator.yaml
