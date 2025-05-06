#!/bin/bash

# Turn off all swap devices
swapoff -a

# Comment out the swap entry in /etc/fstab to prevent swap from being enabled on boot
sed -i '/swap/s/^/#/' /etc/fstab

# Remount all filesystems as specified in /etc/fstab
mount -a

# Display memory usage, including swap (which should be off)
free -h

# Show the contents of /etc/fstab to verify that swap is commented out
cat /etc/fstab
