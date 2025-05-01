# Example of pod running on the host networking

```bash
# start container
kubectl apply -f networkaccess.yaml

# exec into container
kubectl exec -it hostnetwork-pod -- sh

# check the network stack
ip link
exit

# Stop container
kubectl delete -f networkaccess.yaml
```