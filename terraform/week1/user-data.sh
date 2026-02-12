#!/bin/bash
# User Data Script pour EC2 Instance - Week 1
# Ce script s'exécute automatiquement au premier boot

set -e

# Log vers fichier
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "Starting User Data Script - Week 1"
echo "Time: $(date)"
echo "=========================================="

# Mise à jour système
echo "Updating system..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Installer outils de base
echo "Installing base tools..."
apt-get install -y \
    curl wget git vim nano \
    htop tree net-tools dnsutils \
    build-essential ca-certificates \
    software-properties-common \
    apt-transport-https \
    gnupg lsb-release \
    jq unzip

# Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu
rm get-docker.sh

# Docker Compose
echo "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION="2.24.0"
curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# OpenSSL (devrait déjà être installé)
apt-get install -y openssl libssl-dev

# Créer marker pour indiquer que user-data est terminé
touch /home/ubuntu/user-data-complete
chown ubuntu:ubuntu /home/ubuntu/user-data-complete

echo "=========================================="
echo "User Data Script Complete!"
echo "Time: $(date)"
echo "=========================================="
