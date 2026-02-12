#!/bin/bash
# Script d'installation automatique pour Dev Workstation
# Pour: quantum-security-project
# VM: dev-workstation (192.168.56.103)

set -e  # Exit on error

echo "=============================================="
echo "  QUANTUM SECURITY - DEV STATION SETUP"
echo "=============================================="
echo ""

# Couleurs pour output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
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

print_status "OS détecté: Ubuntu $VERSION"
echo ""

# Mise à jour système
echo "=== Mise à jour du système ==="
sudo apt update
sudo apt upgrade -y
print_status "Système à jour"
echo ""

# Outils de base
echo "=== Installation outils de base ==="
sudo apt install -y \
    curl wget git vim nano \
    net-tools dnsutils htop tree \
    build-essential ca-certificates \
    gnupg lsb-release \
    software-properties-common \
    apt-transport-https \
    jq yq
print_status "Outils de base installés"
echo ""

# Docker
echo "=== Installation Docker ==="
if command -v docker &> /dev/null; then
    print_warning "Docker déjà installé"
    docker --version
else
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    print_status "Docker installé"
fi
echo ""

# Docker Compose
echo "=== Installation Docker Compose ==="
if command -v docker-compose &> /dev/null; then
    print_warning "Docker Compose déjà installé"
else
    DOCKER_COMPOSE_VERSION="2.24.0"
    sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_status "Docker Compose installé"
fi
echo ""

# OpenSSL
echo "=== Vérification OpenSSL ==="
sudo apt install -y openssl libssl-dev
OPENSSL_VERSION=$(openssl version | awk '{print $2}')
print_status "OpenSSL version: $OPENSSL_VERSION"
echo ""

# Python et Qiskit
echo "=== Installation Python + Qiskit ==="
sudo apt install -y \
    python3 python3-pip python3-venv \
    python3-dev
pip3 install --user --upgrade pip

print_status "Installation Qiskit..."
pip3 install --user \
    qiskit \
    qiskit-aer \
    matplotlib \
    jupyter \
    numpy \
    scipy \
    pandas

print_status "Python et Qiskit installés"
python3 --version
pip3 list | grep qiskit || true
echo ""

# liboqs (Post-Quantum Crypto Library)
echo "=== Installation liboqs ==="
if [ -d "/usr/local/include/oqs" ]; then
    print_warning "liboqs déjà installé"
else
    print_status "Compilation liboqs (peut prendre 5-10 min)..."
    
    # Dépendances
    sudo apt install -y cmake ninja-build
    
    # Clone et build
    cd ~
    if [ -d "liboqs" ]; then
        rm -rf liboqs
    fi
    
    git clone --depth 1 --branch main https://github.com/open-quantum-safe/liboqs.git
    cd liboqs
    mkdir build && cd build
    cmake -GNinja .. \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DBUILD_SHARED_LIBS=ON
    ninja
    sudo ninja install
    sudo ldconfig
    
    cd ~
    
    # Vérification
    if [ -f "/usr/local/lib/liboqs.so" ]; then
        print_status "liboqs installé avec succès"
    else
        print_error "Erreur lors de l'installation liboqs"
    fi
fi
echo ""

# Nginx
echo "=== Installation Nginx ==="
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl stop nginx  # On ne le démarre pas tout de suite
print_status "Nginx installé"
echo ""

# Wireshark (pour analyse réseau)
echo "=== Installation Wireshark ==="
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt install -y wireshark tshark
sudo usermod -aG wireshark $USER
print_status "Wireshark installé"
echo ""

# Git configuration
echo "=== Configuration Git ==="
if [ -z "$(git config --global user.name)" ]; then
    git config --global user.name "Quantum Security Researcher"
    git config --global user.email "quantum@security.lab"
    git config --global init.defaultBranch main
    print_status "Git configuré"
else
    print_warning "Git déjà configuré"
    git config --global user.name
    git config --global user.email
fi
echo ""

# Créer structure de dossiers
echo "=== Création structure projet ==="
mkdir -p ~/workspace
mkdir -p ~/labs/{openssl,liboqs,spiffe,qkd}
mkdir -p ~/certs
print_status "Dossiers créés"
echo ""

# Cloner le projet (si pas déjà fait)
echo "=== Configuration projet ==="
if [ ! -d ~/workspace/quantum-security-project ]; then
    print_status "Prêt pour cloner le projet Git"
    echo "    cd ~/workspace"
    echo "    git clone <repository-url>"
else
    print_warning "Projet déjà cloné"
fi
echo ""

# Bash aliases utiles
echo "=== Configuration Bash aliases ==="
cat >> ~/.bashrc << 'EOF'

# Quantum Security Project Aliases
alias lab='cd ~/workspace/quantum-security-project/labs'
alias docs='cd ~/workspace/quantum-security-project/docs'
alias proj='cd ~/workspace/quantum-security-project'
alias ll='ls -lah'
alias ports='sudo netstat -tulpn'

# Docker shortcuts
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline -10'

EOF
print_status "Aliases ajoutés à ~/.bashrc"
echo ""

# Informations finales
echo "=============================================="
echo "  ✅ INSTALLATION TERMINÉE"
echo "=============================================="
echo ""
echo "Composants installés:"
echo "  ✓ Docker + Docker Compose"
echo "  ✓ OpenSSL $(openssl version | awk '{print $2}')"
echo "  ✓ Python $(python3 --version | awk '{print $2}')"
echo "  ✓ Qiskit (pour simulation quantique)"
echo "  ✓ liboqs (cryptographie post-quantique)"
echo "  ✓ Nginx (serveur web)"
echo "  ✓ Wireshark (analyse réseau)"
echo "  ✓ Git + outils développement"
echo ""
echo "⚠️  IMPORTANT: Redémarrer votre session pour activer:"
echo "   - Docker (groupe docker)"
echo "   - Wireshark (groupe wireshark)"
echo "   - Bash aliases"
echo ""
echo "Commandes pour redémarrer:"
echo "   exit"
echo "   ssh quantum@192.168.56.103"
echo ""
echo "Prochaines étapes:"
echo "   1. Redémarrer session"
echo "   2. Cloner projet: cd ~/workspace && git clone <url>"
echo "   3. Commencer Lab 1.1: cd quantum-security-project/labs/openssl"
echo ""
print_status "Prêt pour le développement! 🚀"
echo "=============================================="
