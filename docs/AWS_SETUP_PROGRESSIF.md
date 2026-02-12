# 🚀 AWS Setup Progressif - Guide Pas-à-Pas

## 🎯 Stratégie : Infrastructure Progressive

Nous allons créer l'infrastructure **au fur et à mesure** des besoins :

```
Semaine 1 (Labs 1.1-1.5) : 1 EC2 instance (Dev Station)
Semaine 2 (Labs 2.1-2.4) : +1 EC2 instance (SPIRE Server)  
Semaine 3 (Labs 3.1-3.2) : K3s sur instance existante (optionnel)
```

**Coût estimé** : €30-50 pour 3 semaines (ou €0-10 avec Free Tier si compte < 12 mois)

---

## 📋 PRÉREQUIS (À FAIRE MAINTENANT)

### 1. Créer Compte AWS

```bash
# Si pas encore de compte :
# 1. Aller sur https://aws.amazon.com/free/
# 2. Cliquer "Create a Free Account"
# 3. Fournir email, password, nom de compte
# 4. Ajouter carte bancaire (pas de charge si Free Tier)
# 5. Vérifier identité (appel téléphonique)
# 6. Choisir "Basic Support" (gratuit)
```

**⚠️ Important** : 
- Free Tier = 750h/mois de t2.micro (gratuit pendant 12 mois)
- Après 12 mois ou si dépassement = facturation
- On utilisera t3.small (~€15/mois) pour meilleures perfs

### 2. Configurer AWS CLI

```bash
# Installation
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Windows
# Télécharger : https://awscli.amazonaws.com/AWSCLIV2.msi

# Vérification
aws --version
# Devrait afficher : aws-cli/2.x.x
```

### 3. Créer Clés d'Accès AWS

```bash
# Dans AWS Console :
# 1. Aller dans IAM > Users > [Votre user] > Security credentials
# 2. Créer "Access key" pour CLI
# 3. Télécharger les clés (Access Key ID + Secret Access Key)
# ⚠️ GARDEZ-LES SECRÈTES !

# Configurer AWS CLI
aws configure

# Entrer :
AWS Access Key ID: [Votre Access Key ID]
AWS Secret Access Key: [Votre Secret Access Key]
Default region name: eu-west-1  # Geneva proche
Default output format: json

# Test
aws sts get-caller-identity
# Devrait afficher votre Account ID
```

### 4. Créer Paire de Clés SSH

```bash
# Dans AWS Console
# 1. EC2 > Network & Security > Key Pairs
# 2. Create key pair
#    Name: quantum-security-key
#    Type: RSA
#    Format: .pem (Linux/Mac) ou .ppk (Windows/PuTTY)
# 3. Download et sauvegarder dans ~/.ssh/

# OU via CLI
aws ec2 create-key-pair \
    --key-name quantum-security-key \
    --query 'KeyMaterial' \
    --output text > ~/.ssh/quantum-security-key.pem

# Permissions
chmod 400 ~/.ssh/quantum-security-key.pem

# Test (après création instance)
# ssh -i ~/.ssh/quantum-security-key.pem ubuntu@<IP>
```

### 5. Installer Terraform (Recommandé)

```bash
# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Linux
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Windows
# Télécharger : https://www.terraform.io/downloads

# Vérification
terraform --version
```

---

## 🏗️ SEMAINE 1 : Infrastructure Minimale

### Objectif
Créer **1 instance EC2** pour les labs crypto (1.1 à 1.5).

### Architecture Semaine 1

```
┌─────────────────── AWS ───────────────────┐
│                                            │
│  VPC: 10.0.0.0/16 (eu-west-1)             │
│                                            │
│  Public Subnet: 10.0.1.0/24               │
│  ┌─────────────────────────────────┐      │
│  │  EC2: quantum-dev-week1         │      │
│  │  Type: t3.small                 │      │
│  │  Ubuntu 22.04                   │      │
│  │  2GB RAM, 2 vCPU                │      │
│  │  30GB EBS                        │      │
│  │  Elastic IP: XX.XX.XX.XX        │      │
│  │                                  │      │
│  │  Services:                       │      │
│  │  - OpenSSL                       │      │
│  │  - liboqs                        │      │
│  │  - Python/Qiskit                 │      │
│  │  - Docker, Nginx                 │      │
│  └─────────────────────────────────┘      │
│                                            │
│  Security Group: Allow SSH from Your IP   │
└────────────────────────────────────────────┘
```

### Option A : Terraform (Recommandé - Infrastructure as Code)

Créez `terraform/week1/main.tf` :

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
  region = "eu-west-1"
}

# Variables
variable "my_ip" {
  description = "Your public IP for SSH access"
  type        = string
  # Obtenir avec: curl ifconfig.me
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "quantum-security-key"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "quantum-security-vpc"
    Project = "PostQuantum-Week1"
    Week    = "1"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "quantum-security-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "quantum-security-public"
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
resource "aws_security_group" "dev_week1" {
  name        = "quantum-security-dev-week1"
  description = "Security group for dev workstation - Week 1"
  vpc_id      = aws_vpc.main.id

  # SSH from your IP only
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  # HTTP/HTTPS for Nginx demos
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound : tout autorisé
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "quantum-security-sg-week1"
    Week = "1"
  }
}

# EC2 Instance
resource "aws_instance" "dev_week1" {
  # Ubuntu 22.04 LTS (eu-west-1)
  # Vérifier dernière AMI: https://cloud-images.ubuntu.com/locator/ec2/
  ami           = "ami-0c38b837cd80f13bb"  # Ubuntu 22.04 eu-west-1
  instance_type = "t3.small"  # 2GB RAM, 2 vCPU, ~€15/mois

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.dev_week1.id]
  key_name               = var.key_name

  root_block_device {
    volume_size           = 30  # GB
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              # Mise à jour système
              apt-get update
              apt-get upgrade -y
              
              # Outils de base
              apt-get install -y curl wget git vim htop
              
              # Docker
              curl -fsSL https://get.docker.com | sh
              usermod -aG docker ubuntu
              
              # Marker pour indiquer que user_data est terminé
              touch /home/ubuntu/user-data-complete
              EOF

  tags = {
    Name    = "quantum-dev-week1"
    Project = "PostQuantum-Crypto"
    Week    = "1"
  }
}

# Elastic IP
resource "aws_eip" "dev_week1" {
  instance = aws_instance.dev_week1.id
  domain   = "vpc"

  tags = {
    Name = "quantum-dev-week1-eip"
  }
}

# Outputs
output "instance_id" {
  value = aws_instance.dev_week1.id
}

output "public_ip" {
  value = aws_eip.dev_week1.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.dev_week1.public_ip}"
}

output "instance_info" {
  value = {
    id         = aws_instance.dev_week1.id
    public_ip  = aws_eip.dev_week1.public_ip
    private_ip = aws_instance.dev_week1.private_ip
    type       = aws_instance.dev_week1.instance_type
  }
}
```

Créez `terraform/week1/terraform.tfvars` :

```hcl
# Obtenez votre IP avec: curl ifconfig.me
my_ip = "VOTRE_IP_ICI"  # Format: "1.2.3.4"

key_name = "quantum-security-key"
```

### Déploiement Semaine 1

```bash
# 1. Créer le dossier
mkdir -p ~/quantum-security-project/terraform/week1
cd ~/quantum-security-project/terraform/week1

# 2. Copier les fichiers main.tf et terraform.tfvars ci-dessus

# 3. Obtenir votre IP publique
curl ifconfig.me
# Remplacer VOTRE_IP_ICI dans terraform.tfvars

# 4. Initialiser Terraform
terraform init

# 5. Vérifier le plan
terraform plan

# 6. Déployer !
terraform apply

# Confirmer avec: yes

# 7. Récupérer l'IP publique
terraform output public_ip

# 8. Se connecter
ssh -i ~/.ssh/quantum-security-key.pem ubuntu@<IP_PUBLIQUE>
```

### Option B : AWS Console (Manuel - Plus Rapide pour Démarrer)

```bash
1. AWS Console > EC2 > Launch Instance

2. Configuration :
   Name: quantum-dev-week1
   
   Application and OS Images:
   - Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
   - Architecture: 64-bit (x86)
   
   Instance type:
   - t3.small (2 vCPU, 2 GiB RAM) ~€15/mois
   OU
   - t2.micro (1 vCPU, 1 GiB RAM) FREE TIER (si éligible)
   
   Key pair:
   - Sélectionner: quantum-security-key
   
   Network settings:
   - VPC: default (ou créer nouveau)
   - Subnet: No preference
   - Auto-assign public IP: Enable
   
   Firewall (security groups):
   - Create new security group
   - Security group name: quantum-security-sg-week1
   - Rules:
     * SSH (22) - Source: My IP
     * HTTP (80) - Source: Anywhere (0.0.0.0/0)
     * HTTPS (443) - Source: Anywhere (0.0.0.0/0)
   
   Configure storage:
   - 30 GiB gp3
   
   Advanced details:
   - User data: (copier le script ci-dessous)

3. Launch instance

4. Attendre "Running" status (2-3 min)

5. Elastic IP (optionnel mais recommandé):
   - EC2 > Network & Security > Elastic IPs
   - Allocate Elastic IP address
   - Actions > Associate Elastic IP address
   - Instance: quantum-dev-week1
   - Associate
```

**User Data Script** :
```bash
#!/bin/bash
set -e

# Mise à jour
apt-get update
apt-get upgrade -y

# Outils de base
apt-get install -y \
    curl wget git vim nano htop tree \
    net-tools dnsutils \
    build-essential

# Docker
curl -fsSL https://get.docker.com | sh
usermod -aG docker ubuntu

# Marker
touch /home/ubuntu/user-data-complete
```

### Post-Installation Semaine 1

```bash
# 1. Se connecter
ssh -i ~/.ssh/quantum-security-key.pem ubuntu@<IP_PUBLIQUE>

# 2. Vérifier user-data terminé
ls -la ~/user-data-complete  # Devrait exister

# 3. Télécharger le script d'installation
wget https://raw.githubusercontent.com/.../setup-dev-station.sh
# OU créer manuellement (voir ci-dessous)

# 4. Exécuter installation complète
chmod +x setup-dev-station.sh
./setup-dev-station.sh

# 5. Redémarrer session
exit
ssh -i ~/.ssh/quantum-security-key.pem ubuntu@<IP_PUBLIQUE>

# 6. Vérifier installations
docker --version
openssl version
python3 --version
ls -la /usr/local/include/oqs  # liboqs
```

### Script Installation Complet (Pour AWS)

Créez `setup-aws-week1.sh` :

```bash
#!/bin/bash
set -e

echo "=== Quantum Security - AWS Week 1 Setup ==="

# Update system
sudo apt update && sudo apt upgrade -y

# Basic tools
sudo apt install -y \
    curl wget git vim nano \
    htop tree net-tools dnsutils \
    build-essential ca-certificates \
    jq unzip

# Docker (si pas déjà fait par user-data)
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
fi

# Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# OpenSSL
sudo apt install -y openssl libssl-dev

# Python + Qiskit
sudo apt install -y python3 python3-pip python3-venv
pip3 install --user --upgrade pip
pip3 install --user qiskit qiskit-aer matplotlib jupyter numpy scipy

# liboqs (Post-Quantum Crypto)
echo "Installing liboqs (5-10 min)..."
sudo apt install -y cmake ninja-build
cd ~
git clone --depth 1 https://github.com/open-quantum-safe/liboqs.git
cd liboqs
mkdir build && cd build
cmake -GNinja .. -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=ON
ninja
sudo ninja install
sudo ldconfig
cd ~

# Nginx
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl stop nginx

# Git config
git config --global user.name "Quantum Security"
git config --global user.email "quantum@aws.lab"
git config --global init.defaultBranch main

# Clone project
mkdir -p ~/workspace
cd ~/workspace
# git clone <your-repo-url> quantum-security-project

# Bash aliases
cat >> ~/.bashrc << 'EOF'

# Quantum Project
alias proj='cd ~/workspace/quantum-security-project'
alias lab='cd ~/workspace/quantum-security-project/labs'
alias ll='ls -lah'

# Docker
alias dps='docker ps'
alias di='docker images'

# Git
alias gs='git status'
alias gl='git log --oneline -10'
EOF

echo "=== Setup Week 1 Complete ==="
echo ""
echo "Installations:"
echo "  ✓ Docker $(docker --version | awk '{print $3}')"
echo "  ✓ OpenSSL $(openssl version | awk '{print $2}')"
echo "  ✓ Python $(python3 --version | awk '{print $2}')"
echo "  ✓ liboqs (Post-Quantum)"
echo "  ✓ Nginx"
echo ""
echo "Next steps:"
echo "  1. exit"
echo "  2. ssh -i ~/.ssh/quantum-security-key.pem ubuntu@<IP>"
echo "  3. cd ~/workspace"
echo "  4. Clone your project"
echo "  5. Start Lab 1.1!"
```

### Validation Semaine 1

```bash
# Checklist
✓ Instance AWS running
✓ SSH connection works
✓ Docker installed
✓ OpenSSL 3.x
✓ liboqs compiled
✓ Python + Qiskit
✓ Nginx installed
✓ Ready for Lab 1.1!

# Tests
docker run hello-world
openssl version
python3 -c "import qiskit; print(qiskit.__version__)"
ls -la /usr/local/lib/liboqs.so
```

---

## 🏗️ SEMAINE 2 : Ajout SPIRE Server

### Objectif
Ajouter **1 instance EC2** pour SPIRE Server (labs 2.1-2.4).

### Architecture Semaine 2

```
┌─────────────────── AWS ───────────────────┐
│  VPC: 10.0.0.0/16                         │
│                                            │
│  Public Subnet: 10.0.1.0/24               │
│  ┌──────────────┐    ┌──────────────┐    │
│  │ EC2: SPIRE   │    │ EC2: Dev     │    │
│  │ t3.micro     │────│ (Week 1)     │    │
│  │ 1GB RAM      │    │              │    │
│  │ Private IP   │    │ Public IP    │    │
│  │              │    │              │    │
│  │ - SPIRE      │    │ - Dev Tools  │    │
│  │   Server     │    │ - SPIRE      │    │
│  │ - PostgreSQL │    │   Agent      │    │
│  └──────────────┘    └──────────────┘    │
│                                            │
│  Security Group: VPC internal only        │
└────────────────────────────────────────────┘
```

**Note** : SPIRE Server n'a PAS besoin d'IP publique (communication VPC interne uniquement).

### Terraform Semaine 2

Créez `terraform/week2/main.tf` :

```hcl
# Importer VPC de Week 1
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["quantum-security-vpc"]
  }
}

data "aws_subnet" "public" {
  filter {
    name   = "tag:Name"
    values = ["quantum-security-public"]
  }
}

# Security Group pour SPIRE Server
resource "aws_security_group" "spire_week2" {
  name        = "quantum-security-spire-week2"
  description = "Security group for SPIRE Server - Week 2"
  vpc_id      = data.aws_vpc.main.id

  # SPIRE Server API (8081) depuis VPC
  ingress {
    description = "SPIRE Server API from VPC"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # SSH depuis instance Dev seulement (optionnel)
  ingress {
    description     = "SSH from Dev instance"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [data.aws_security_group.dev_week1.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "quantum-security-sg-spire-week2"
    Week = "2"
  }
}

# Instance SPIRE Server
resource "aws_instance" "spire_week2" {
  ami           = "ami-0c38b837cd80f13bb"  # Ubuntu 22.04
  instance_type = "t3.micro"  # 1GB RAM suffit, ~€7/mois

  subnet_id              = data.aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.spire_week2.id]
  key_name               = var.key_name

  # Pas d'IP publique (accès via bastion ou VPC)
  associate_public_ip_address = false

  root_block_device {
    volume_size = 20  # GB
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y postgresql postgresql-contrib
              EOF

  tags = {
    Name    = "quantum-spire-week2"
    Project = "PostQuantum-ZeroTrust"
    Week    = "2"
  }
}

output "spire_private_ip" {
  value = aws_instance.spire_week2.private_ip
}
```

**Problème** : SPIRE Server sans IP publique → Accès compliqué.

**Solution** : Utiliser instance Dev comme bastion SSH.

```bash
# Depuis votre machine → Dev instance → SPIRE Server
ssh -i ~/.ssh/quantum-security-key.pem \
    -J ubuntu@<DEV_PUBLIC_IP> \
    ubuntu@<SPIRE_PRIVATE_IP>
```

**Alternative Simple** : Donner IP publique temporaire à SPIRE pour setup, puis retirer.

---

## 💡 APPROCHE SIMPLIFIÉE (RECOMMANDÉE POUR 3 SEMAINES)

### Option All-in-One : 1 Seule Instance pour Tout

Pour simplifier et réduire coûts pendant apprentissage :

```
┌─────────────── AWS ────────────────┐
│                                     │
│  EC2: quantum-dev-allinone         │
│  t3.small (2GB RAM, 2 vCPU)       │
│  Public IP: XX.XX.XX.XX           │
│                                     │
│  Semaine 1:                        │
│  - OpenSSL, liboqs                │
│  - Python/Qiskit                  │
│  - Docker, Nginx                  │
│                                     │
│  Semaine 2: +                      │
│  - SPIRE Server                    │
│  - SPIRE Agent                     │
│  - PostgreSQL                      │
│  - Services démo                   │
│                                     │
│  Semaine 3: +                      │
│  - K3s (Kubernetes léger)         │
│  - QKD simulations                │
└─────────────────────────────────────┘
```

**Avantages** :
- 1 seule instance à gérer
- Pas de réseau complexe
- Coût réduit (~€15/mois vs €22/mois)
- Parfait pour labs
- Migration facile vers multi-instances plus tard

**C'est ce que je recommande pour commencer !**

---

## 🎯 NEXT STEPS : Démarrer Maintenant

### Actions Immédiates (30 min)

```bash
# 1. Vérifier compte AWS
aws sts get-caller-identity

# 2. Vérifier clé SSH existe
ls ~/.ssh/quantum-security-key.pem

# 3. Obtenir votre IP
curl ifconfig.me

# 4. Choisir approche :
#    A) Terraform (Infrastructure as Code) - Recommandé
#    B) AWS Console (Manuel) - Plus rapide pour démarrer

# Je vous prépare les deux !
```

Voulez-vous que je vous prépare :
1. **Les fichiers Terraform complets** pour déployer en 5 min ?
2. **Un guide AWS Console pas-à-pas** avec screenshots ?
3. **Les scripts d'installation** optimisés pour AWS ?

Dites-moi et je crée tout de suite ! 🚀

---

**Prochaine étape** : Créer votre première instance AWS maintenant !
