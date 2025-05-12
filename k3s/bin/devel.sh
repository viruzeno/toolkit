#!/bin/bash

# Install Krew (needs internet)
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# install the ingress-nginx kubectl plugin
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
# kubectl krew install ingress-nginx

kubectl krew index add ingress-manios https://github.com/manios/krew-ingress-nginx.git
kubectl krew install ingress-manios/ingress-nginx-cm 

# kubectl ingress-nginx-cm --namespace ingress-nginx ingresses
# kubectl ingress-nginx-cm --namespace ingress-nginx backends