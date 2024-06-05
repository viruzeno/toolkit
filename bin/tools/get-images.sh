#!/bin/bash

images=()
images+=("quay.io/k0sproject/calico-cni:v3.27.3-0")
# images+=("quay.io/k0sproject/calico-kube-controllers:v3.27.3-0")
# images+=("quay.io/k0sproject/calico-node:v3.27.3-0")
images+=("quay.io/k0sproject/coredns:1.11.3")
# images+=("quay.io/k0sproject/apiserver-network-proxy-agent:v0.30.3")
images+=("quay.io/k0sproject/kube-proxy:v1.30.0")
images+=("quay.io/k0sproject/kube-router:v2.1.0-iptables1.8.9-0")
images+=("quay.io/k0sproject/cni-node:1.3.0-k0s.0")
images+=("registry.k8s.io/metrics-server/metrics-server:v0.7.1")
images+=("registry.k8s.io/pause:3.9")
images+=("docker.io/kubernetesui/dashboard:v2.0.0")
images+=("docker.io/kubernetesui/metrics-scraper:v1.0.4")
images+=("docker.io/library/httpd:2.4.53-alpine")
# images+=("docker.io/nginx:latest")
# images+=("quay.io/metallb/controller:v0.14.5")
# images+=("quay.io/metallb/speaker:v0.14.5")
images+=("docker.io/rook/ceph:v1.7.11")
images+=("quay.io/ceph/ceph:v16.2.6")

# sudo ctr --namespace k8s.io --address /run/k0s/containerd.sock image pull ${images[*]}
# sudo ctr --namespace k8s.io --address /run/k0s/containerd.sock images export bundle_file ${images[*]}


k0s airgap list-images | xargs -I{} docker pull {}
docker image save $(k0s airgap list-images | xargs) -o bundle_file

# sudo mkdir -p /var/lib/k0s/images
# sudo mv bundle_file /var/lib/k0s/images/bundle_file