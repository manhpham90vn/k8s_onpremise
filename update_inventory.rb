#!/usr/bin/env ruby

require 'json'

def wait_for_vm(vm_name)
  max_attempts = 30
  attempt = 0
  
  while attempt < max_attempts
    status = `vagrant status #{vm_name} --machine-readable`
    if status.include?("running")
      return true
    end
    attempt += 1
    sleep 2
  end
  false
end

def get_vm_ips
  # Get VM information using vagrant status --machine-readable
  status = `vagrant status --machine-readable`
  vms = {}
  
  status.split("\n").each do |line|
    parts = line.split(',')
    if parts[2] == 'metadata' && parts[3] == 'provider'
      vm_name = parts[1]
      provider = parts[4]
      vms[vm_name] = { provider: provider }
    end
  end

  # Wait for all VMs to be ready
  vms.each do |vm_name, info|
    unless wait_for_vm(vm_name)
      puts "Error: VM #{vm_name} failed to start"
      exit 1
    end
  end

  # Get IP addresses for each VM
  vms.each do |vm_name, info|
    # Get all IPs and filter for the bridge interface IP (192.168.1.x)
    ips = `vagrant ssh #{vm_name} -c "ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print \\$2}' | cut -d/ -f1"`.strip.split("\n")
    bridge_ip = ips.find { |ip| ip.start_with?('192.168.1.') }
    vms[vm_name][:ip] = bridge_ip
  end

  vms
end

def update_inventory(vms)
  inventory_content = []
  
  # Add controlplane section
  inventory_content << "[controlplane]"
  inventory_content << "#{vms['controlplane'][:ip]} ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/controlplane/virtualbox/private_key ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
  inventory_content << ""
  
  # Add workers section
  inventory_content << "[workers]"
  vms.each do |vm_name, info|
    if vm_name.start_with?('worker-')
      inventory_content << "#{info[:ip]} ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/#{vm_name}/virtualbox/private_key ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
    end
  end

  # Write to inventory.ini
  File.write('inventory.ini', inventory_content.join("\n"))
end

def update_hosts(vms)
  hosts_content = []
  
  # Add localhost entries
  hosts_content << "127.0.0.1 localhost"
  hosts_content << "::1 localhost ip6-localhost ip6-loopback"
  hosts_content << "ff02::1 ip6-allnodes"
  hosts_content << "ff02::2 ip6-allrouters"
  hosts_content << ""
  
  # Add VM entries
  hosts_content << "# Kubernetes cluster nodes"
  vms.each do |vm_name, info|
    hosts_content << "#{info[:ip]} #{vm_name}"
  end

  # Write to hosts file
  File.write('hosts', hosts_content.join("\n"))
end

# Main execution
vms = get_vm_ips
update_inventory(vms)
update_hosts(vms)
puts "Inventory and hosts files have been updated successfully!" 