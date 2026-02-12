# -*- mode: ruby -*-
# vi: set ft=ruby :

# Quantum Security Project - Infrastructure Automation
# VirtualBox + Vagrant Configuration
# 
# Usage:
#   vagrant up              # Start all VMs
#   vagrant up spire-server # Start only SPIRE server
#   vagrant ssh spire-server # SSH into SPIRE server
#   vagrant halt            # Stop all VMs
#   vagrant destroy -f      # Destroy all VMs

Vagrant.configure("2") do |config|
  # Base box for all VMs
  config.vm.box = "ubuntu/jammy64"  # Ubuntu 22.04 LTS
  config.vm.box_version = "~> 20230616.0.0"
  
  # Global provisioning settings
  config.vm.provision "shell", inline: <<-SHELL
    # Update system
    apt-get update
    apt-get install -y curl wget git vim htop net-tools
    
    # Install OpenSSL 3.x (already in Ubuntu 22.04)
    openssl version
    
    # Set timezone
    timedatectl set-timezone Europe/Zurich
  SHELL
  
  #############################################################################
  # VM1: SPIRE Server (Control Plane)
  #############################################################################
  config.vm.define "spire-server", primary: true do |server|
    server.vm.hostname = "spire-server"
    server.vm.network "private_network", ip: "10.0.0.10"
    
    # Port forwarding for external access
    server.vm.network "forwarded_port", guest: 8081, host: 8081, host_ip: "127.0.0.1"
    
    server.vm.provider "virtualbox" do |vb|
      vb.name = "quantum-spire-server"
      vb.memory = "2048"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end
    
    server.vm.provision "shell", path: "scripts/setup-spire-server.sh"
  end
  
  #############################################################################
  # VM2: Backend Service (Workload 1)
  #############################################################################
  config.vm.define "backend" do |backend|
    backend.vm.hostname = "backend-service"
    backend.vm.network "private_network", ip: "10.0.0.20"
    
    # Port forwarding for HTTPS mTLS
    backend.vm.network "forwarded_port", guest: 8443, host: 8443, host_ip: "127.0.0.1"
    
    backend.vm.provider "virtualbox" do |vb|
      vb.name = "quantum-backend"
      vb.memory = "2048"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end
    
    backend.vm.provision "shell", path: "scripts/setup-workload.sh"
    backend.vm.provision "shell", inline: <<-SHELL
      echo "export WORKLOAD_NAME=backend" >> /home/vagrant/.bashrc
      echo "export SPIRE_SERVER=10.0.0.10" >> /home/vagrant/.bashrc
    SHELL
  end
  
  #############################################################################
  # VM3: Frontend Service (Workload 2)
  #############################################################################
  config.vm.define "frontend" do |frontend|
    frontend.vm.hostname = "frontend-service"
    frontend.vm.network "private_network", ip: "10.0.0.30"
    
    # Port forwarding for HTTPS mTLS
    frontend.vm.network "forwarded_port", guest: 8444, host: 8444, host_ip: "127.0.0.1"
    
    frontend.vm.provider "virtualbox" do |vb|
      vb.name = "quantum-frontend"
      vb.memory = "2048"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end
    
    frontend.vm.provision "shell", path: "scripts/setup-workload.sh"
    frontend.vm.provision "shell", inline: <<-SHELL
      echo "export WORKLOAD_NAME=frontend" >> /home/vagrant/.bashrc
      echo "export SPIRE_SERVER=10.0.0.10" >> /home/vagrant/.bashrc
    SHELL
  end
  
  #############################################################################
  # VM4: Kubernetes (k3s) - Optional, not started by default
  #############################################################################
  config.vm.define "k3s", autostart: false do |k3s|
    k3s.vm.hostname = "k3s-cluster"
    k3s.vm.network "private_network", ip: "10.0.0.40"
    
    # Port forwarding for kubectl access
    k3s.vm.network "forwarded_port", guest: 6443, host: 6443, host_ip: "127.0.0.1"
    k3s.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
    k3s.vm.network "forwarded_port", guest: 443, host: 8443, host_ip: "127.0.0.1"
    
    k3s.vm.provider "virtualbox" do |vb|
      vb.name = "quantum-k3s"
      vb.memory = "4096"
      vb.cpus = 4
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end
    
    k3s.vm.provision "shell", path: "scripts/setup-k3s.sh"
  end
  
  #############################################################################
  # Global VM Settings
  #############################################################################
  
  # Sync project folder (optional, can be commented out)
  config.vm.synced_folder ".", "/vagrant", disabled: false
  
  # SSH settings
  config.ssh.insert_key = true
  config.ssh.forward_agent = true
  
  # VirtualBox global settings
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.linked_clone = true  # Faster VM creation
  end
end

# Post-provision message
class CustomPlugin < Vagrant.plugin("2")
  name "Custom post-up message"

  action_hook(:custom_message, :machine_action_up) do |hook|
    hook.after(Vagrant::Action::Builtin::WaitForCommunicator, lambda do |env|
      env[:ui].info <<-MSG

╔════════════════════════════════════════════════════════════════════╗
║                   QUANTUM SECURITY PROJECT                         ║
║                  Infrastructure Ready! 🚀                          ║
╚════════════════════════════════════════════════════════════════════╝

VMs started successfully!

📡 Network Configuration:
   • SPIRE Server : 10.0.0.10  (http://localhost:8081)
   • Backend      : 10.0.0.20  (https://localhost:8443)
   • Frontend     : 10.0.0.30  (https://localhost:8444)

🔐 SSH Access:
   vagrant ssh spire-server
   vagrant ssh backend
   vagrant ssh frontend

📝 Next Steps:
   1. SSH into SPIRE server: vagrant ssh spire-server
   2. Check SPIRE status: sudo systemctl status spire-server
   3. View logs: sudo journalctl -u spire-server -f
   4. Start Lab 1.1: cd /vagrant/labs/openssl

📚 Documentation:
   • Architecture: docs/ARCHITECTURE_VIRTUALBOX.md
   • Quick Start: QUICKSTART.md
   • Action Plan: docs/PLAN_ACTION.md

💡 Useful Commands:
   vagrant status          # Check VM status
   vagrant halt            # Stop all VMs
   vagrant snapshot save   # Create snapshot
   vagrant destroy -f      # Destroy all VMs

Happy hacking! 🔬
      MSG
    end)
  end
end
