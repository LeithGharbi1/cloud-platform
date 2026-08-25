#!/bin/bash

set -e

echo "Preparing Ansible controller..."

echo "Updating apt repositories..."

sudo apt update


echo "Installing system dependencies..."

sudo apt install -y \
    python3-pip \
    python3-venv \
    curl \
    ca-certificates \
    gnupg


echo "Installing Python packages..."

pip3 install -r requirements.txt


echo "Installing Ansible collections..."

ansible-galaxy collection install -r requirements.yml


echo "Installing kubectl..."

KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

rm kubectl


echo "Installing Helm..."

HELM_VERSION="v3.19.0"

curl -LO "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz"

tar -zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz

sudo mv linux-amd64/helm /usr/local/bin/helm

rm -rf linux-amd64 helm-${HELM_VERSION}-linux-amd64.tar.gz


echo "Verifying installations..."

ansible --version
kubectl version --client
helm version


echo "Bootstrap completed successfully"