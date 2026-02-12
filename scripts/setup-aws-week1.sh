#!/bin/bash
# Installation complète pour AWS EC2 Instance - Week 1
# Quantum Security Project
#
# Ce script installe TOUS les outils nécessaires pour la Semaine 1 :
# - OpenSSL
# - liboqs (Post-Quantum Crypto)
# - Python + Qiskit
# - Nginx
# - Outils de développement

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Vérifier qu'on est sur Ubuntu
if [ ! -f /etc/os-release ]; then
    print_error "Ce script nécessite Ubuntu"
    exit 1
fi

source /etc/os-release
if [ "$ID" != "ubuntu" ]; then
    print_error "Ce script nécessite Ubuntu (détecté: $ID)"
    exit 1
fi

print_header "Quantum Security - AWS Week 1 Setup"
echo "OS: Ubuntu $VERSION"
echo "Instance: $(ec2metadata --instance-type 2>/dev/null || echo 'Unknown')"
echo "Region: $(ec2metadata --availability-zone 2>/dev/null || echo 'Unknown')"
echo ""

# Mise à jour système
print_header "1/8 Mise à jour du système"
sudo apt-get update
sudo apt-get upgrade -y
print_success "Système à jour"
echo ""

# Outils de base
print_header "2/8 Installation outils de base"
sudo apt-get install -y \
    curl wget git vim nano \
    htop tree net-tools dnsutils \
    build-essential ca-certificates \
    software-properties-common \
    apt-transport-https gnupg lsb-release \
    jq unzip zip \
    python3-pip python3-venv

print_success "Outils de base installés"
echo ""

# Docker (devrait déjà être installé par user-data)
print_header "3/8 Vérification Docker"
if command -v docker &> /dev/null; then
    print_success "Docker déjà installé: $(docker --version)"
else
    print_warning "Docker non installé, installation..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    print_success "Docker installé"
fi

# Docker Compose
if command -v docker-compose &> /dev/null; then
    print_success "Docker Compose déjà installé: $(docker-compose --version)"
else
    print_warning "Docker Compose non installé, installation..."
    DOCKER_COMPOSE_VERSION="2.24.0"
    sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installé"
fi
echo ""

# OpenSSL
print_header "4/8 Vérification OpenSSL"
sudo apt-get install -y openssl libssl-dev
OPENSSL_VERSION=$(openssl version | awk '{print $2}')
print_success "OpenSSL $OPENSSL_VERSION"
echo ""

# Python + Qiskit
print_header "5/8 Installation Python + Qiskit"
sudo apt-get install -y python3 python3-pip python3-venv python3-dev
pip3 install --user --upgrade pip

print_warning "Installation Qiskit... (peut prendre 2-3 min)"
pip3 install --user \
    qiskit \
    qiskit-aer \
    matplotlib \
    jupyter \
    numpy \
    scipy \
    pandas

# Ajouter ~/.local/bin au PATH
if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

print_success "Python $(python3 --version | awk '{print $2}')"
print_success "Qiskit installé"
echo ""

# liboqs (Post-Quantum Crypto Library)
print_header "6/8 Installation liboqs"
if [ -d "/usr/local/include/oqs" ]; then
    print_warning "liboqs déjà installé"
else
    print_warning "Compilation liboqs... (peut prendre 5-10 min)"
    
    # Dépendances
    sudo apt-get install -y cmake ninja-build libssl-dev
    
    # Clone
    cd ~
    if [ -d "liboqs" ]; then
        rm -rf liboqs
    fi
    
    git clone --depth 1 --branch main https://github.com/open-quantum-safe/liboqs.git
    cd liboqs
    mkdir build && cd build
    
    # Configure et build
    cmake -GNinja .. \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DBUILD_SHARED_LIBS=ON \
        -DOQS_USE_OPENSSL=ON
    
    ninja
    sudo ninja install
    sudo ldconfig
    
    cd ~
    
    # Vérification
    if [ -f "/usr/local/lib/liboqs.so" ]; then
        print_success "liboqs installé: $(ls -lh /usr/local/lib/liboqs.so | awk '{print $5}')"
    else
        print_error "Erreur installation liboqs"
        exit 1
    fi
fi
echo ""

# Nginx
print_header "7/8 Installation Nginx"
sudo apt-get install -y nginx
sudo systemctl enable nginx
sudo systemctl stop nginx  # On ne le démarre pas pour l'instant
print_success "Nginx installé"
echo ""

# Configuration finale
print_header "8/8 Configuration finale"

# Git config
if [ -z "$(git config --global user.name)" ]; then
    git config --global user.name "Quantum Security Researcher"
    git config --global user.email "quantum@aws.lab"
    git config --global init.defaultBranch main
    print_success "Git configuré"
fi

# Créer structure dossiers
mkdir -p ~/workspace
mkdir -p ~/labs/{openssl,liboqs,spiffe,qkd}
mkdir -p ~/certs
print_success "Dossiers créés"

# Bash aliases
if ! grep -q "# Quantum Security Aliases" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# Quantum Security Aliases
alias proj='cd ~/workspace/quantum-security-project'
alias lab='cd ~/workspace/quantum-security-project/labs'
alias docs='cd ~/workspace/quantum-security-project/docs'
alias ll='ls -lah'
alias ports='sudo netstat -tulpn'

# Docker
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gl='git log --oneline -10'
alias gp='git push'

# AWS
alias myip='curl -s ifconfig.me'
alias myinstance='ec2metadata --instance-id'
EOF
    print_success "Aliases ajoutés"
fi

# Wireshark (pour analyse réseau)
print_warning "Installation Wireshark..."
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y wireshark tshark
sudo usermod -aG wireshark $USER
print_success "Wireshark installé"

echo ""

# Résumé final
print_header "✅ Installation Terminée!"
echo ""
echo "Composants installés:"
echo "  ✓ Docker $(docker --version | awk '{print $3}')"
echo "  ✓ Docker Compose $(docker-compose --version | awk '{print $4}')"
echo "  ✓ OpenSSL $OPENSSL_VERSION"
echo "  ✓ Python $(python3 --version | awk '{print $2}')"
echo "  ✓ Qiskit (quantum computing)"
echo "  ✓ liboqs (post-quantum crypto)"
echo "  ✓ Nginx (web server)"
echo "  ✓ Wireshark (network analysis)"
echo "  ✓ Git + outils développement"
echo ""
echo "Dossiers créés:"
echo "  ~/workspace/          - Projets"
echo "  ~/labs/               - Laboratoires"
echo "  ~/certs/              - Certificats"
echo ""
echo "⚠️  IMPORTANT: Redémarrer session pour:"
echo "   - Activer groupe docker"
echo "   - Activer groupe wireshark"
echo "   - Charger nouveaux aliases"
echo ""
echo "Commandes:"
echo "   exit"
echo "   ssh -i ~/.ssh/quantum-security-key.pem ubuntu@\$(terraform output -raw public_ip)"
echo ""
echo "Prochaines étapes:"
echo "   1. Redémarrer session (exit + reconnexion)"
echo "   2. Cloner projet: cd ~/workspace && git clone <url>"
echo "   3. Commencer Lab 1.1: cd quantum-security-project/labs/openssl"
echo ""
print_success "Prêt pour le développement! 🚀"
print_header "========================================="

# Créer fichier marker
touch ~/setup-week1-complete
echo "Setup completed at: $(date)" > ~/setup-week1-complete

exit 0
