#!/bin/sh
# Install Helm K8s package manager
# Operating System: Ubuntu 18 Bionic 
snap install helm --classic
helm init
# kubectl apply -f rbac-config.yaml
