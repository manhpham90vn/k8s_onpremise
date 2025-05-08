NUM_WORKER_NODES = 2

module OS
    def OS.windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end
  
    def OS.mac?
      (/darwin/ =~ RUBY_PLATFORM) != nil
    end
  
    def OS.unix?
      !OS.windows?
    end
  
    def OS.linux?
      OS.unix? and not OS.mac?
    end
  
    def OS.jruby?
      RUBY_ENGINE == "jruby"
    end
end

def get_bridge_adapter()
    if OS.windows?
      return %x{powershell -Command "Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Get-NetAdapter | Select-Object -ExpandProperty InterfaceDescription"}.chomp
    elsif OS.linux?
      return %x{ip route | grep default | awk '{ print $5 }'}.chomp
    elsif OS.mac?
      return %x{mac/mac-bridge.sh}.chomp
    end
end

Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/jammy64"
    config.vm.box_check_update = false

    config.vm.define "controlplane" do |node|
        node.vm.hostname = "controlplane"
        node.vm.network "public_network", bridge: get_bridge_adapter()

        node.vm.provider "virtualbox" do |vb|
            vb.name = "controlplane"
            vb.memory = "2048"
            vb.cpus = 2
        end
    end    

    NUM_WORKER_NODES.times do |i|
        config.vm.define "worker-#{i}" do |node|
            node.vm.hostname = "worker-#{i}"
            node.vm.network "public_network", bridge: get_bridge_adapter()

            node.vm.provider "virtualbox" do |vb|
                vb.name = "worker-#{i}"
                vb.memory = "2048"
                vb.cpus = 2
            end
        end
    end

    # Add trigger to update inventory after all VMs are up
    config.trigger.after :up do |trigger|
        trigger.run = {inline: "/bin/bash -c 'ruby update_inventory.rb'"}
    end
end