#!/usr/bin/env bash
 
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

apt-get update

apt-get install -y apt-rdepends dpkg-dev gzip