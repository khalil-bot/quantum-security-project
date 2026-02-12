# 🏗️ Architecture Infrastructure - Projet Sécurité Post-Quantique

## 🎯 Besoins du Projet

### Technologies à Déployer
1. **Cryptographie Classique** : OpenSSL, CA, certificats
2. **Post-Quantum Crypto** : liboqs, ML-KEM, ML-DSA
3. **Zero-Trust** : SPIFFE/SPIRE Server + Agents
4. **Microservices** : 2-3 services pour démo mTLS
5. **Kubernetes** : Orchestration (optionnel mais recommandé)
6. **QKD Simulation** : Python/Qiskit

### Contraintes
- Budget : Étudiant/académique
- Durée : 3 semaines d'apprentissage intensif
- Objectif : Labs pratiques + démos fonctionnelles
- Portabilité : Besoin de présenter à Prof. Schiller

---

## 📊 Comparaison : VirtualBox vs AWS

| Critère | VirtualBox (Local) | AWS (Cloud) |
|---------|-------------------|-------------|
| **Coût** | Gratuit ✅ | $50-150/mois 💰 |
| **Setup Initial** | 2-3h | 1-2h |
| **Performance** | Dépend de votre machine | Excellente ⚡ |
| **Portabilité** | OVA exportable ✅ | Accès web partout 🌐 |
| **Apprentissage** | Focus sur les technos | + Apprendre AWS |
| **Démos** | Sur votre laptop | URL partageable |
| **Destruction** | Snapshot facile | Attention aux coûts |
| **Réseautage** | Limité mais suffisant | Complet (VPC, SG) |
| **Stockage** | Limité par disque | Illimité ($$) |
| **Sauvegarde** | Manuelle | Automatisée |

---

## 🏆 RECOMMANDATION : Approche Hybride

### 💡 Solution Optimale : VirtualBox + AWS Free Tier (optionnel)

**Semaine 1-2 : VirtualBox (Local)**
- Setup rapide et gratuit
- Apprentissage focus sur crypto et SPIFFE
- Pas de distraction par le cloud
- Performances suffisantes

**Semaine 3 : Migration vers AWS (Optionnel)**
- Démo professionnelle dans le cloud
- Partage facile avec Prof. Schiller
- Expérience cloud en bonus
- Utiliser Free Tier (gratuit 12 mois)

---

## 🏗️ ARCHITECTURE VIRTUALBOX (RECOMMANDÉE)

### Configuration Matérielle Minimale
- **Hôte requis** : 
  - RAM : 16 GB minimum (32 GB idéal)
  - CPU : 4 cores minimum (8 cores idéal)
  - Disque : 100 GB libres
  - OS : Windows 10/11, macOS, ou Linux

### Diagramme Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    MACHINE HÔTE                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  VirtualBox Network: 192.168.56.0/24                  │  │
│  │                                                        │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │  │
│  │  │   VM1: K8s   │  │  VM2: SPIRE  │  │ VM3: Dev    │ │  │
│  │  │   Master     │  │   Server     │  │ Station     │ │  │
│  │  │              │  │              │  │             │ │  │
│  │  │ Ubuntu 22.04 │  │ Ubuntu 22.04 │  │ Ubuntu 22  │ │  │
│  │  │ 4GB RAM      │  │ 2GB RAM      │  │ 4GB RAM    │ │  │
│  │  │ 2 vCPU       │  │ 2 vCPU       │  │ 2 vCPU     │ │  │
│  │  │ 40GB Disk    │  │ 20GB Disk    │  │ 40GB Disk  │ │  │
│  │  │              │  │              │  │            │ │  │
│  │  │ K8s Control  │  │ SPIRE Server │  │ Dev Tools  │ │  │
│  │  │ Plane        │  │ PostgreSQL   │  │ Git, VSCode│ │  │
│  │  │ SPIRE Agent  │  │ Trust Bundle │  │ OpenSSL    │ │  │
│  │  │              │  │              │  │ liboqs     │ │  │
│  │  └──────────────┘  └──────────────┘  └─────────────┘ │  │
│  │           │                │                  │        │  │
│  │           └────────────────┴──────────────────┘        │  │
│  │                    Host-Only Network                   │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  Accès SSH depuis hôte: ssh user@192.168.56.10x            │
└─────────────────────────────────────────────────────────────┘
```

### Configuration Détaillée des VMs

#### VM1: Kubernetes Master (k8s-master)
- **OS** : Ubuntu 22.04 LTS Server
- **RAM** : 4 GB
- **CPU** : 2 vCPU
- **Disk** : 40 GB (dynamique)
- **IP** : 192.168.56.101
- **Services** :
  - Kubernetes control plane (kubeadm)
  - SPIRE Agent
  - kubectl, Helm
  - containerd
- **Quand** : Semaine 2-3

#### VM2: SPIRE Server (spire-server)
- **OS** : Ubuntu 22.04 LTS Server
- **RAM** : 2 GB
- **CPU** : 2 vCPU
- **Disk** : 20 GB (dynamique)
- **IP** : 192.168.56.102
- **Services** :
  - SPIRE Server
  - PostgreSQL (datastore)
  - CA racine pour tests
- **Quand** : Semaine 2

#### VM3: Dev Station (dev-workstation)
- **OS** : Ubuntu 22.04 LTS Server (ou Desktop)
- **RAM** : 4 GB
- **CPU** : 2 vCPU
- **Disk** : 40 GB (dynamique)
- **IP** : 192.168.56.103
- **Services** :
  - OpenSSL
  - liboqs
  - Python 3 + Qiskit
  - Git, VSCode
  - Docker
  - Nginx (pour mTLS)
- **Quand** : Semaine 1 (COMMENCER ICI)

### Configuration Réseau VirtualBox

**Network Adapter 1** : NAT
- Accès Internet pour downloads
- Utilisé pour apt-get, docker pull, etc.

**Network Adapter 2** : Host-Only Adapter (vboxnet0)
- Réseau privé 192.168.56.0/24
- Communication inter-VMs
- SSH depuis hôte

**Port Forwarding** (NAT - optionnel) :
```
Hôte:2201 → VM1:22 (SSH k8s-master)
Hôte:2202 → VM2:22 (SSH spire-server)
Hôte:2203 → VM3:22 (SSH dev-station)
Hôte:6443 → VM1:6443 (Kubernetes API)
Hôte:8081 → VM2:8081 (SPIRE Server API)
```

---

## 🏗️ ARCHITECTURE AWS (OPTIONNELLE)

### Diagramme AWS

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS VPC                              │
│                    10.0.0.0/16 (eu-west-1)                  │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Public Subnet (10.0.1.0/24)            │   │
│  │                                                      │   │
│  │  ┌────────────┐      ┌────────────┐               │   │
│  │  │ EC2        │      │ EC2 K3s    │               │   │
│  │  │ All-in-One │      │ (Optional) │               │   │
│  │  │ t3.small   │      │ t3.medium  │               │   │
│  │  │ Elastic IP │      │            │               │   │
│  │  │            │      │            │               │   │
│  │  │ - Dev Tools│      │ - K3s      │               │   │
│  │  │ - SPIRE    │      │ - SPIRE    │               │   │
│  │  │ - OpenSSL  │      │   Agent    │               │   │
│  │  │ - liboqs   │      │            │               │   │
│  │  └────────────┘      └────────────┘               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  Security Groups:                                            │
│  - SSH (22) from Your IP only                               │
│  - SPIRE (8081) from VPC only                              │
│  - K8s API (6443) from Your IP                             │
│  - HTTP/HTTPS (80/443) from anywhere (pour démos)          │
└─────────────────────────────────────────────────────────────┘
```

### Configuration AWS Minimale (Free Tier)

**Option All-in-One** : ~$0-15/mois
```
1x EC2 t2.micro (Free Tier eligible)
- Ubuntu 22.04 LTS
- 1 GB RAM, 1 vCPU
- 30 GB EBS (Free Tier)
- Elastic IP (gratuit si attaché)
- TOUT sur une machine :
  * Dev tools (OpenSSL, liboqs)
  * SPIRE Server
  * K3s (Kubernetes léger)
  * Services démo
```

**Option Standard** : ~$30-50/mois
```
1x EC2 t3.small (All-in-one)
- Ubuntu 22.04 LTS
- 2 GB RAM, 2 vCPU
- 50 GB EBS
- Elastic IP
- Meilleures performances
```

**Option Professionnelle** : ~$80-120/mois
```
1x EC2 t3.micro (Bastion)
2x EC2 t3.medium (K8s nodes avec EKS)
1x EC2 t3.small (SPIRE Server)
- VPC avec subnets public/private
- ALB pour load balancing
- RDS PostgreSQL (pour SPIRE)
```

---

## 🚀 GUIDE DE SETUP : VIRTUALBOX (RECOMMANDÉ)

### Étape 1 : Installation VirtualBox

#### Windows
```powershell
# Télécharger depuis https://www.virtualbox.org/
# Version 7.0+ recommandée
# Installer aussi Extension Pack (USB, RDP)
```

#### macOS
```bash
brew install --cask virtualbox
brew install --cask virtualbox-extension-pack
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install virtualbox virtualbox-ext-pack
```

### Étape 2 : Créer le Réseau Host-Only

```bash
# Méthode 1 : GUI
VirtualBox > Tools > Network Manager > Host-only Networks
Cliquer "Create"

# Configuration :
Name: vboxnet0
IPv4 Address: 192.168.56.1
IPv4 Network Mask: 255.255.255.0
DHCP Server: Désactivé

# Méthode 2 : CLI
VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1
```

### Étape 3 : Télécharger Ubuntu Server

```bash
# Ubuntu 22.04 LTS Server (Jammy)
wget https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso

# Ou télécharger via navigateur :
# https://ubuntu.com/download/server
```

### Étape 4 : Créer VM3 - Dev Workstation (COMMENCER ICI)

#### Configuration VM dans VirtualBox
```
1. Cliquer "New"
2. Nom: dev-workstation
3. Type: Linux
4. Version: Ubuntu (64-bit)
5. RAM: 4096 MB (4 GB)
6. Créer disque virtuel maintenant
7. VDI (VirtualBox Disk Image)
8. Dynamiquement alloué
9. 40 GB
```

#### Configuration Réseau
```
Settings > Network:

Adapter 1:
- Enable Network Adapter: ✓
- Attached to: NAT

Adapter 2:
- Enable Network Adapter: ✓
- Attached to: Host-only Adapter
- Name: vboxnet0
```

#### Configuration Système
```
Settings > System:

Processeur:
- Processors: 2 CPUs

Accélération:
- Enable VT-x/AMD-V: ✓
- Enable Nested Paging: ✓
```

#### Installation Ubuntu

```bash
1. Start VM
2. Sélectionner ISO Ubuntu
3. Suivre l'installation :
   - Language: English
   - Keyboard: [Votre disposition]
   - Install Ubuntu Server
   - Network: Accepter DHCP pour les deux
   - No proxy
   - Mirror: Default
   - Disk: Use entire disk
   - Storage: Default
   - Profile Setup:
     * Your name: Quantum Security
     * Server name: dev-station
     * Username: quantum
     * Password: [votre mot de passe fort]
   - SSH: Install OpenSSH server ✓
   - Snaps: Aucun (skip)
4. Reboot
```

#### Configuration Post-Installation

```bash
# Se connecter en console (dans VirtualBox)
# Username: quantum
# Password: [votre mot de passe]

# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Installer outils de base
sudo apt install -y \
    curl wget git vim nano \
    net-tools dnsutils htop \
    build-essential ca-certificates

# Configurer IP statique pour Host-Only
sudo vim /etc/netplan/00-installer-config.yaml
```

Fichier `/etc/netplan/00-installer-config.yaml` :
```yaml
network:
  version: 2
  ethernets:
    enp0s3:  # NAT (Internet)
      dhcp4: true
    enp0s8:  # Host-Only (réseau local)
      addresses:
        - 192.168.56.103/24
```

```bash
# Appliquer la configuration
sudo netplan apply

# Vérifier
ip addr show enp0s8
ping -c 3 192.168.56.1  # Hôte
```

#### Se connecter en SSH depuis l'hôte

```bash
# Depuis votre machine hôte
ssh quantum@192.168.56.103

# Si connexion réussie, vous pouvez maintenant travailler
# depuis votre terminal préféré !
```

### Étape 5 : Installation des Outils Dev (VM3)

```bash
# Se connecter en SSH
ssh quantum@192.168.56.103

# Télécharger le script d'installation
cat > ~/setup-dev-station.sh << 'EOF'
#!/bin/bash

echo "=== Installation Dev Tools pour Quantum Security ==="

# Docker
echo "Installation Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# OpenSSL (déjà installé normalement)
sudo apt install -y openssl libssl-dev

# Python et Qiskit
echo "Installation Python + Qiskit..."
sudo apt install -y python3 python3-pip python3-venv
pip3 install --user \
    qiskit qiskit-aer \
    matplotlib jupyter \
    numpy scipy

# liboqs (Post-Quantum Crypto)
echo "Installation liboqs..."
sudo apt install -y cmake ninja-build
cd ~
git clone --depth 1 --branch main https://github.com/open-quantum-safe/liboqs.git
cd liboqs
mkdir build && cd build
cmake -GNinja .. -DCMAKE_INSTALL_PREFIX=/usr/local
ninja
sudo ninja install
sudo ldconfig

# Nginx (pour mTLS)
echo "Installation Nginx..."
sudo apt install -y nginx

# Outils additionnels
sudo apt install -y \
    jq yq \
    tree \
    tcpdump wireshark-common

echo "=== Installation terminée ==="
echo "Redémarrer la session : exit puis ssh quantum@192.168.56.103"
EOF

chmod +x ~/setup-dev-station.sh
~/setup-dev-station.sh
```

### Étape 6 : Créer Snapshot

```bash
# Arrêter la VM
sudo poweroff

# Dans VirtualBox Manager :
# 1. Sélectionner dev-workstation
# 2. Menu > Machine > Take Snapshot
# 3. Name: "Base Configuration - Dev Tools Installed"
# 4. Description: "Ubuntu 22.04 + Docker + OpenSSL + liboqs + Python/Qiskit"
```

### Étape 7 : Cloner pour VM2 (Semaine 2)

```bash
# Dans VirtualBox Manager :
# 1. Right-click dev-workstation > Clone
# 2. Name: spire-server
# 3. MAC Address Policy: Generate new MAC addresses
# 4. Clone type: Full clone
# 5. Snapshots: Current machine state

# Démarrer spire-server
# Se connecter en console et modifier :
sudo hostnamectl set-hostname spire-server
sudo vim /etc/netplan/00-installer-config.yaml
# Changer IP : 192.168.56.102
sudo netplan apply
sudo reboot
```

### Étape 8 : Cloner pour VM1 (Semaine 2-3)

```bash
# Même processus que VM2
# Name: k8s-master
# IP: 192.168.56.101
```

---

## 🚀 GUIDE DE SETUP : AWS (OPTIONNEL)

### Option 1 : AWS Free Tier avec Terraform

Créer `terraform/main.tf` :

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"  # Geneva proche
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "quantum-security-vpc"
    Project = "PostQuantum-ZeroTrust"
  }
}

# Subnet Public
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "quantum-security-public"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "quantum-security-igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "quantum-security-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "dev_station" {
  name        = "quantum-security-dev"
  description = "Security group for dev workstation"
  vpc_id      = aws_vpc.main.id

  # SSH from your IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]  # Remplacer par votre IP
  }

  # HTTP/HTTPS for demos
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SPIRE Server
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Kubernetes API
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "quantum-security-sg"
  }
}

# EC2 Instance
resource "aws_instance" "dev_station" {
  ami           = "ami-0c38b837cd80f13bb"  # Ubuntu 22.04 eu-west-1
  instance_type = "t2.micro"  # Free Tier eligible

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.dev_station.id]

  key_name = "quantum-security-key"  # Créer cette clé dans AWS Console

  root_block_device {
    volume_size = 30  # GB - Free Tier: 30GB
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update && apt upgrade -y
              apt install -y curl wget git vim docker.io
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name    = "quantum-security-dev"
    Project = "PostQuantum-ZeroTrust"
  }
}

# Elastic IP
resource "aws_eip" "dev_station" {
  instance = aws_instance.dev_station.id
  domain   = "vpc"

  tags = {
    Name = "quantum-security-eip"
  }
}

# Outputs
output "instance_public_ip" {
  value = aws_eip.dev_station.public_ip
}

output "instance_id" {
  value = aws_instance.dev_station.id
}

output "ssh_command" {
  value = "ssh -i quantum-security-key.pem ubuntu@${aws_eip.dev_station.public_ip}"
}
```

### Déploiement Terraform

```bash
# Installer Terraform
brew install terraform  # macOS
# ou sudo apt install terraform  # Linux

# Initialiser
cd terraform
terraform init

# Créer clé SSH dans AWS Console (EC2 > Key Pairs)
# Télécharger quantum-security-key.pem
chmod 400 quantum-security-key.pem

# Remplacer YOUR_IP dans main.tf par votre IP publique
curl ifconfig.me

# Vérifier le plan
terraform plan

# Déployer
terraform apply

# Connexion SSH
ssh -i quantum-security-key.pem ubuntu@<IP_AFFICHÉE>
```

### Option 2 : AWS Console (Manuel)

```bash
1. Se connecter à AWS Console
2. EC2 > Launch Instance
3. Configuration :
   - Name: quantum-security-dev
   - AMI: Ubuntu Server 22.04 LTS
   - Instance type: t2.micro (Free Tier)
   - Key pair: Créer nouvelle ou utiliser existante
   - Network: Default VPC
   - Storage: 30 GB gp3
4. Security Group :
   - SSH (22) from My IP
   - HTTP (80) from Anywhere
   - HTTPS (443) from Anywhere
5. Launch instance
6. Attendre "Running"
7. Copier Public IP
8. SSH: ssh -i key.pem ubuntu@<PUBLIC_IP>
```

---

## 🎯 PLAN DE DÉPLOIEMENT PROGRESSIF

### 🔹 Semaine 1 : VM3 Seulement

**Jour 1** :
```bash
✅ Installer VirtualBox
✅ Créer VM3 (dev-workstation)
✅ Configurer réseau
✅ Installer Docker, OpenSSL
✅ Commencer Lab 1.1
```

**Jour 2-5** :
```bash
✅ Labs OpenSSL (1.1, 1.2)
✅ Installer liboqs
✅ Labs PQC (1.3, 1.4, 1.5)
✅ Prendre snapshots réguliers
```

### 🔹 Semaine 2 : + VM2 (SPIRE)

**Jour 1** :
```bash
✅ Cloner VM3 → VM2 (spire-server)
✅ Configurer IP 192.168.56.102
✅ Installer SPIRE Server
✅ Installer PostgreSQL
```

**Jour 2-5** :
```bash
✅ Configurer SPIRE Server
✅ Installer SPIRE Agent sur VM3
✅ Créer workloads
✅ Tests mTLS entre VM2 et VM3
✅ Labs SPIFFE (2.2, 2.3, 2.4)
```

### 🔹 Semaine 3 : + VM1 (Kubernetes) [Optionnel]

**Jour 1-2** :
```bash
✅ Cloner VM3 → VM1 (k8s-master)
✅ Configurer IP 192.168.56.101
✅ Installer Kubernetes
✅ Intégrer SPIFFE dans K8s
⏳ QKD simulation sur VM3
```

**Jour 3-5** :
```bash
✅ Finaliser démos
✅ Rédaction state-of-art
✅ Préparation présentation
⏳ Migration AWS (si souhaité)
```

---

## 💰 ESTIMATION RESSOURCES

### VirtualBox (Local)

**Semaine 1** : 1 VM
- RAM utilisée : 4 GB
- Disk : 40 GB
- CPU : 2 cores

**Semaine 2** : 2 VMs
- RAM utilisée : 6 GB (4+2)
- Disk : 60 GB (40+20)
- CPU : 4 cores (2+2)

**Semaine 3** : 3 VMs
- RAM utilisée : 10 GB (4+2+4)
- Disk : 100 GB (40+20+40)
- CPU : 6 cores (2+2+2)

**Machine hôte recommandée** :
- RAM : 16 GB (laisser 6 GB pour l'OS)
- Disk : 150 GB libres
- CPU : 8 cores (laisser 2 pour l'OS)

### AWS (Cloud)

**Free Tier** : $0-10/mois
- 750h t2.micro (suffisant)
- 30 GB EBS
- Pas de coûts si respect limites

**Standard** : $30-50/mois
- 1x t3.small
- 50 GB EBS
- Data transfer

---

## ✅ RECOMMANDATION FINALE

### 🏆 Pour Votre Cas : **VIRTUALBOX**

**Pourquoi ?**
1. ✅ **Gratuit** - Budget zéro
2. ✅ **Local** - Pas besoin Internet constant
3. ✅ **Contrôle total** - Snapshots, rollback
4. ✅ **Portable** - Démo sur laptop
5. ✅ **Focus** - Apprendre les technos, pas le cloud
6. ✅ **Progression** - Ajouter VMs au fur et à mesure

**Progression** :
```
Semaine 1 : 1 VM  → Labs crypto
Semaine 2 : 2 VMs → SPIFFE/SPIRE
Semaine 3 : 3 VMs → Kubernetes (optionnel)
```

### 🌐 Quand Utiliser AWS ?

**Utilisez AWS si** :
- ✅ Vous avez Free Tier actif (gratuit 12 mois)
- ✅ Machine locale insuffisante (< 16 GB RAM)
- ✅ Vous voulez expérience cloud en bonus
- ✅ Besoin URL publique pour démo Prof. Schiller
- ✅ Mobilité (travailler depuis plusieurs endroits)

**Migration facile Semaine 3** :
- Export configurations de VirtualBox
- Terraform pour recréer sur AWS
- ~2-3h de migration

---

## 📝 Checklist Démarrage

### Avant de Commencer
- [ ] Lire ce document complètement
- [ ] Vérifier ressources machine (RAM, CPU, Disk)
- [ ] Décider : VirtualBox ou AWS ?
- [ ] Installer VirtualBox (si local)
- [ ] Créer compte AWS (si cloud)

### Setup Initial (VirtualBox)
- [ ] Installer VirtualBox + Extension Pack
- [ ] Créer réseau Host-Only (vboxnet0)
- [ ] Télécharger Ubuntu 22.04 ISO
- [ ] Créer VM3 (dev-workstation)
- [ ] Configurer réseau (NAT + Host-Only)
- [ ] Installer Ubuntu Server
- [ ] Configurer IP statique (192.168.56.103)
- [ ] Tester SSH depuis hôte
- [ ] Installer outils dev (script)
- [ ] Prendre snapshot "Base"

### Setup Initial (AWS)
- [ ] Créer compte AWS
- [ ] Configurer AWS CLI
- [ ] Créer clé SSH
- [ ] Décider : Terraform ou Console ?
- [ ] Déployer instance t2.micro
- [ ] Configurer Security Group
- [ ] Attacher Elastic IP
- [ ] Tester SSH
- [ ] Installer outils dev

### Validation
- [ ] SSH fonctionne
- [ ] Internet accessible (apt update)
- [ ] Docker installé et fonctionnel
- [ ] OpenSSL version 3.x
- [ ] Git configuré
- [ ] Prêt pour Lab 1.1 ! 🚀

---

## 🆘 Troubleshooting

### VirtualBox : VM ne démarre pas
```bash
# Vérifier virtualisation activée dans BIOS
# Windows: Hyper-V doit être désactivé
# Mac: System Preferences > Security

# Vérifier logs
VBoxManage showvminfo dev-workstation
```

### VirtualBox : Pas de réseau
```bash
# Vérifier adapters
VBoxManage showvminfo dev-workstation | grep NIC

# Recréer host-only
VBoxManage hostonlyif remove vboxnet0
VBoxManage hostonlyif create
```

### AWS : Connexion SSH refusée
```bash
# Vérifier Security Group : port 22 ouvert ?
# Vérifier clé SSH : chmod 400 key.pem
# Vérifier IP publique : aws ec2 describe-instances
```

### Performances insuffisantes
```bash
# VirtualBox : Augmenter RAM/CPU
# Activer VT-x/AMD-V dans BIOS
# Désactiver Hyper-V (Windows)

# AWS : Upsize instance (t3.small)
```

---

## 📚 Ressources Additionnelles

### VirtualBox
- [Documentation officielle](https://www.virtualbox.org/manual/)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)
- [Networking Guide](https://www.virtualbox.org/manual/ch06.html)

### AWS
- [Free Tier](https://aws.amazon.com/free/)
- [EC2 Getting Started](https://docs.aws.amazon.com/ec2/index.html)
- [Terraform AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Kubernetes
- [K8s Documentation](https://kubernetes.io/docs/)
- [K3s (lightweight)](https://k3s.io/)
- [Kubeadm Setup](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/)

---

## 🎯 Prochaines Étapes

1. ✅ Lire ce document
2. ✅ Décider : VirtualBox (recommandé) ou AWS
3. ✅ Suivre guide setup correspondant
4. ✅ Valider checklist
5. ✅ Commencer Lab 1.1 ! 🚀

**Questions ?** Notez-les pour discussion !

---

**Créé le** : 26 janvier 2026  
**Auteur** : Claude Assistant  
**Status** : ✅ Architecture validée  
**Recommandation** : 🏆 VirtualBox
