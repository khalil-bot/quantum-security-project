#!/bin/bash
# User Data Script - Phase 1 Learning Instance
# Auto-executed on first boot

set -e

# Logging
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "Starting User Data - Phase 1"
echo "Project: ${project_name}"
echo "Time: $(date)"
echo "=========================================="

# Update system
echo ">>> Updating system..."
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y

# Install base tools
echo ">>> Installing base tools..."
apt-get install -y \
    curl wget git vim nano htop tree \
    net-tools dnsutils iputils-ping \
    build-essential ca-certificates \
    software-properties-common \
    apt-transport-https gnupg \
    jq unzip zip

# Docker
echo ">>> Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu
rm get-docker.sh
systemctl enable docker
systemctl start docker

# Docker Compose
echo ">>> Installing Docker Compose..."
DOCKER_COMPOSE_VERSION="2.24.0"
curl -L "https://github.com/docker/compose/releases/download/v$${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# OpenSSL (usually pre-installed, but ensure latest)
echo ">>> Installing OpenSSL..."
apt-get install -y openssl libssl-dev

# Python tools
echo ">>> Installing Python..."
apt-get install -y python3 python3-pip python3-venv python3-dev

# Nginx
echo ">>> Installing Nginx..."
apt-get install -y nginx
systemctl enable nginx
systemctl stop nginx  # Don't start yet, will configure in labs

# Git configuration
echo ">>> Configuring Git..."
sudo -u ubuntu git config --global user.name "Quantum Security Researcher"
sudo -u ubuntu git config --global user.email "quantum@research.lab"
sudo -u ubuntu git config --global init.defaultBranch main

# Create workspace structure
echo ">>> Creating workspace..."
sudo -u ubuntu mkdir -p /home/ubuntu/workspace
sudo -u ubuntu mkdir -p /home/ubuntu/labs/{openssl,liboqs,spiffe,qkd}
sudo -u ubuntu mkdir -p /home/ubuntu/certs

# Create Phase 1 setup script
echo ">>> Creating setup script..."
cat > /home/ubuntu/setup-phase1.sh << 'SETUP_EOF'
#!/bin/bash
# Phase 1 Complete Setup Script
# Run this after first login

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "$${BLUE}========================================$${NC}"
echo -e "$${BLUE}  Quantum Security - Phase 1 Setup$${NC}"
echo -e "$${BLUE}========================================$${NC}"
echo ""

# Python packages
echo -e "$${GREEN}Installing Python packages...$${NC}"
pip3 install --user --upgrade pip
pip3 install --user \
    qiskit \
    qiskit-aer \
    matplotlib \
    jupyter \
    numpy \
    scipy \
    pandas

# liboqs (Post-Quantum Crypto)
echo -e "$${GREEN}Installing liboqs (10-15 min)...$${NC}"
sudo apt-get install -y cmake ninja-build

cd ~
if [ -d "liboqs" ]; then
    rm -rf liboqs
fi

git clone --depth 1 --branch main https://github.com/open-quantum-safe/liboqs.git
cd liboqs
mkdir build && cd build
cmake -GNinja .. \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DBUILD_SHARED_LIBS=ON \
    -DOQS_USE_OPENSSL=ON
ninja
sudo ninja install
sudo ldconfig

cd ~
echo -e "$${GREEN}✓ liboqs installed$${NC}"

# Wireshark
echo -e "$${GREEN}Installing Wireshark...$${NC}"
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y wireshark tshark
sudo usermod -aG wireshark ubuntu

# Bash aliases
if ! grep -q "# Quantum Security Aliases" ~/.bashrc; then
    cat >> ~/.bashrc << 'ALIASES_EOF'

# Quantum Security Aliases
alias proj='cd ~/workspace/quantum-security-project'
alias lab='cd ~/workspace/quantum-security-project/labs'
alias docs='cd ~/workspace/quantum-security-project/docs'
alias ll='ls -lah'
alias dps='docker ps'
alias di='docker images'
alias gs='git status'
alias gl='git log --oneline -10'
ALIASES_EOF
fi

# Create completion marker
touch ~/setup-phase1-complete
echo "$(date)" > ~/setup-phase1-complete

echo ""
echo -e "$${GREEN}========================================$${NC}"
echo -e "$${GREEN}  ✅ Setup Complete!$${NC}"
echo -e "$${GREEN}========================================$${NC}"
echo ""
echo "Installed:"
echo "  ✓ Docker $(docker --version | awk '{print $3}')"
echo "  ✓ OpenSSL $(openssl version | awk '{print $2}')"
echo "  ✓ Python $(python3 --version | awk '{print $2}')"
echo "  ✓ Qiskit (quantum computing)"
echo "  ✓ liboqs (post-quantum crypto)"
echo "  ✓ Wireshark (network analysis)"
echo ""
echo "⚠️  IMPORTANT: Restart your session:"
echo "   exit"
echo "   ssh -i ~/.ssh/quantum-key-phase1.pem ubuntu@$(ec2metadata --public-ipv4 2>/dev/null || echo '<IP>')"
echo ""
echo "Next steps:"
echo "  1. Clone project: cd ~/workspace && git clone <url>"
echo "  2. Start Lab 1.1: cd quantum-security-project/labs/openssl"
echo "  3. Read guide: cat LAB-1.1-Certificates.md"
echo ""

SETUP_EOF

chown ubuntu:ubuntu /home/ubuntu/setup-phase1.sh
chmod +x /home/ubuntu/setup-phase1.sh

# Completion marker
touch /home/ubuntu/user-data-complete
chown ubuntu:ubuntu /home/ubuntu/user-data-complete

echo "=========================================="
echo "User Data Complete!"
echo "Time: $(date)"
echo "=========================================="
echo ""
echo "Next: SSH into instance and run ~/setup-phase1.sh"
