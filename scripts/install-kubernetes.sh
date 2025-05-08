#!/bin/bash

# Check if kubelet is already installed and running
if systemctl is-active --quiet kubelet; then
    echo "Kubelet is already installed and running."
    echo "Kubernetes version information:"
    kubectl version --client
    kubeadm version
    exit 0
fi

# Install curl to fetch the Kubernetes GPG key
sudo apt install curl gnupg -y

# Fetch the Kubernetes GPG key and save it in the apt keyring directory
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the Kubernetes APT repository to the system's sources list, specifying the keyring for authentication
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update the package list to include the Kubernetes repository
sudo apt update -y

# Install Kubernetes components: kubelet, kubeadm, kubectl
sudo apt install -y kubelet kubeadm kubectl

# Enable the kubelet service to start on boot
sudo systemctl enable kubelet

# Start the kubelet service
sudo systemctl start kubelet

# Check the status of the kubelet service to ensure it's running
sudo systemctl status kubelet

# Print the version of kubectl
kubectl version --client

# Print the version of kubeadm
kubeadm version
