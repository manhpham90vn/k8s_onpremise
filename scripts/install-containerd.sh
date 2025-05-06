#!/bin/bash

# Load the necessary kernel modules for container support
modprobe overlay
modprobe br_netfilter

# Create a configuration file to load the kernel modules on boot
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# Configure sysctl settings for Kubernetes networking
tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1  # Enable IPv6 packet filtering for bridge
net.bridge.bridge-nf-call-iptables = 1   # Enable IPv4 packet filtering for bridge
net.ipv4.ip_forward = 1                   # Enable IP forwarding
EOF

# Apply the sysctl settings
sysctl --system

# Install curl to fetch Docker's GPG key and repository
sudo apt install curl -y

# Add Docker's official GPG key to verify package authenticity
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Add Docker's APT repository to the sources list
echo "y" | sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the apt package list
sudo apt update -y

# Install containerd (Docker's container runtime)
sudo apt install -y containerd.io

# Create the containerd configuration directory if it doesn't exist
mkdir -p /etc/containerd

# Generate the default containerd configuration file and save it
containerd config default | sudo tee /etc/containerd/config.toml

# Modify the config.toml file to enable systemd as the cgroup driver
sed -i '/SystemdCgroup/s/=.*/= true/' /etc/containerd/config.toml

# Restart containerd to apply changes
sudo systemctl restart containerd

# Verify that the configuration was applied correctly
cat /etc/containerd/config.toml | grep SystemdCgroup

# Check the status of the containerd service to ensure it's running
sudo systemctl status containerd
