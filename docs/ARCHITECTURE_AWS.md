# ☁️ Architecture Infrastructure AWS

## 📐 Architecture Globale

```
┌────────────────────────────────────────────────────────────────────────┐
│                           AWS Region (eu-central-1)                    │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │                    VPC: 10.0.0.0/16                              │ │
│  │                                                                  │ │
│  │  ┌─────────────────────────────────────────────────────────┐   │ │
│  │  │         Availability Zone: eu-central-1a                │   │ │
│  │  │                                                         │   │ │
│  │  │  ┌────────────────────────────────────────────────┐    │   │ │
│  │  │  │      Public Subnet: 10.0.1.0/24                │    │   │ │
│  │  │  │                                                │    │   │ │
│  │  │  │  ┌──────────────┐   ┌──────────────┐         │    │   │ │
│  │  │  │  │   Bastion    │   │  NAT Gateway │         │    │   │ │
│  │  │  │  │   Host       │   │              │         │    │   │ │
│  │  │  │  │  (t3.micro)  │   │              │         │    │   │ │
│  │  │  │  └──────────────┘   └──────────────┘         │    │   │ │
│  │  │  │                                                │    │   │ │
│  │  │  └────────────────────────────────────────────────┘    │   │ │
│  │  │                                                         │   │ │
│  │  │  ┌────────────────────────────────────────────────┐    │   │ │
│  │  │  │      Private Subnet: 10.0.2.0/24               │    │   │ │
│  │  │  │                                                │    │   │ │
│  │  │  │  ┌──────────────┐  ┌──────────────┐          │    │   │ │
│  │  │  │  │   EC2        │  │   EC2        │          │    │   │ │
│  │  │  │  │   SPIRE      │  │   Backend    │          │    │   │ │
│  │  │  │  │   Server     │  │   Service    │          │    │   │ │
│  │  │  │  │              │  │              │          │    │   │ │
│  │  │  │  │ 10.0.2.10    │  │ 10.0.2.20    │          │    │   │ │
│  │  │  │  │ (t3.medium)  │  │ (t3.medium)  │          │    │   │ │
│  │  │  │  └──────────────┘  └──────────────┘          │    │   │ │
│  │  │  │                                                │    │   │ │
│  │  │  │  ┌──────────────┐                             │    │   │ │
│  │  │  │  │   EC2        │                             │    │   │ │
│  │  │  │  │   Frontend   │                             │    │   │ │
│  │  │  │  │   Service    │                             │    │   │ │
│  │  │  │  │              │                             │    │   │ │
│  │  │  │  │ 10.0.2.30    │                             │    │   │ │
│  │  │  │  │ (t3.medium)  │                             │    │   │ │
│  │  │  │  └──────────────┘                             │    │   │ │
│  │  │  │                                                │    │   │ │
│  │  │  │  ┌────────────────────────────────────┐       │    │   │ │
│  │  │  │  │         RDS PostgreSQL             │       │    │   │ │
│  │  │  │  │    (For SPIRE datastore)          │       │    │   │ │
│  │  │  │  │        db.t3.micro                 │       │    │   │ │
│  │  │  │  └────────────────────────────────────┘       │    │   │ │
│  │  │  │                                                │    │   │ │
│  │  │  └────────────────────────────────────────────────┘    │   │ │
│  │  │                                                         │   │ │
│  │  └─────────────────────────────────────────────────────────┘   │ │
│  │                                                                  │ │
│  │  ┌──────────────────────────────────────────────────────────┐  │ │
│  │  │               Optional: EKS Cluster                      │  │ │
│  │  │        (For Kubernetes tests - Semaine 3)               │  │ │
│  │  │                                                          │  │ │
│  │  │  ┌────────────────┐  ┌────────────────┐                │  │ │
│  │  │  │  EKS Worker 1  │  │  EKS Worker 2  │                │  │ │
│  │  │  │  (t3.medium)   │  │  (t3.medium)   │                │  │ │
│  │  │  └────────────────┘  └────────────────┘                │  │ │
│  │  │                                                          │  │ │
│  │  └──────────────────────────────────────────────────────────┘  │ │
│  │                                                                  │ │
│  │  ┌──────────────────────────────────────────────────────────┐  │ │
│  │  │                 Internet Gateway                         │  │ │
│  │  └──────────────────────────────────────────────────────────┘  │ │
│  │                                                                  │ │
│  └──────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │                      Security Groups                             │ │
│  │                                                                  │ │
│  │  • Bastion: SSH (22) from Your IP                              │ │
│  │  • SPIRE Server: 8081 from Private Subnet                      │ │
│  │  • Backend: 8443 from Frontend                                 │ │
│  │  • Frontend: 8444 from Bastion/Internet                        │ │
│  │  • RDS: 5432 from SPIRE Server                                 │ │
│  └──────────────────────────────────────────────────────────────────┘ │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

## 🖥️ Spécifications des Instances

### EC2 1 : SPIRE Server
```yaml
Instance Type: t3.medium (2 vCPU, 4 GB RAM)
AMI: Ubuntu 22.04 LTS (ami-0a628e1e89aaedf80)
Subnet: Private (10.0.2.10)
Storage: 20 GB GP3
Security Group: sg-spire-server

Services:
  - SPIRE Server
  - Connection to RDS PostgreSQL
  - CloudWatch Agent (logs/metrics)
```

### EC2 2 : Backend Service
```yaml
Instance Type: t3.medium (2 vCPU, 4 GB RAM)
AMI: Ubuntu 22.04 LTS
Subnet: Private (10.0.2.20)
Storage: 20 GB GP3
Security Group: sg-backend

Services:
  - SPIRE Agent
  - Application backend
  - liboqs (Post-Quantum Crypto)
  - SPIFFE Workload
```

### EC2 3 : Frontend Service
```yaml
Instance Type: t3.medium (2 vCPU, 4 GB RAM)
AMI: Ubuntu 22.04 LTS
Subnet: Private (10.0.2.30)
Storage: 20 GB GP3
Security Group: sg-frontend

Services:
  - SPIRE Agent
  - Application frontend
  - liboqs
  - SPIFFE Workload
```

### EC2 4 : Bastion Host
```yaml
Instance Type: t3.micro (2 vCPU, 1 GB RAM)
AMI: Ubuntu 22.04 LTS
Subnet: Public (10.0.1.10)
Storage: 8 GB GP3
Security Group: sg-bastion
Elastic IP: Yes

Purpose:
  - SSH Gateway to private instances
  - Management access
```

### RDS : PostgreSQL
```yaml
Instance Class: db.t3.micro (2 vCPU, 1 GB RAM)
Engine: PostgreSQL 14.x
Storage: 20 GB GP3
Multi-AZ: No (pour économiser)
Backup: 7 days
Subnet: Private
Security Group: sg-rds

Purpose:
  - SPIRE Server datastore
```

### Optional: EKS Cluster (Semaine 3)
```yaml
Control Plane: Managed by AWS
Worker Nodes: 2x t3.medium
CNI: AWS VPC CNI
Storage: EBS CSI Driver
Addons: SPIFFE CSI Driver

Purpose:
  - Kubernetes + SPIFFE integration tests
  - Production-like orchestration
```

## 💰 Estimation Coûts Détaillée

### Option 1 : Configuration Minimale (Sans EKS)

#### Compute (EC2)
```
t3.medium x3 (SPIRE + 2 workloads)
- On-Demand: 0.0416 $/h x 3 x 720h = ~90 CHF/mois
- Avec Free Tier: 750h gratuits → ~60 CHF/mois

t3.micro x1 (Bastion)
- On-Demand: 0.0104 $/h x 720h = ~7 CHF/mois
- Avec Free Tier: Gratuit
```

#### Storage (EBS)
```
GP3 20GB x4 instances = 80GB
- 0.08 $/GB-month → ~6 CHF/mois
```

#### Database (RDS)
```
db.t3.micro PostgreSQL
- On-Demand: 0.017 $/h x 720h = ~12 CHF/mois
- Storage 20GB: ~2 CHF/mois
- Total RDS: ~14 CHF/mois
```

#### Networking
```
NAT Gateway: 0.045 $/h x 720h = ~32 CHF/mois
Data Transfer Out: ~5-10 CHF/mois (modéré)
Elastic IP (active): Gratuit
```

#### Monitoring
```
CloudWatch Logs: ~2-5 CHF/mois
CloudWatch Metrics: ~1-3 CHF/mois
```

**Total Option 1 (sans Free Tier)** : ~130 CHF/mois  
**Total Option 1 (avec Free Tier)** : ~80 CHF/mois  
**Pour 3 semaines** : ~55-90 CHF

---

### Option 2 : Avec EKS (Semaine 3 uniquement)

#### EKS Control Plane
```
0.10 $/h x 720h = ~72 CHF/mois
```

#### EKS Worker Nodes
```
t3.medium x2
- On-Demand: 0.0416 $/h x 2 x 720h = ~60 CHF/mois
- Avec Free Tier EC2: ~30 CHF/mois
```

#### Application Load Balancer
```
ALB: ~0.0225 $/h x 720h = ~16 CHF/mois
Data processed: ~2-5 CHF/mois
```

**Total Option 2 (avec EKS)** : ~200-250 CHF/mois  
**Si EKS uniquement 1 semaine** : ~50-60 CHF

---

### 🎁 Réduction avec AWS Free Tier

#### Eligible (12 mois après inscription)
```
✅ 750h EC2 t2.micro/t3.micro par mois
✅ 30 GB EBS Storage
✅ 750h RDS db.t2.micro/db.t3.micro
✅ 15 GB Data Transfer Out
✅ CloudWatch: 10 metrics, 5GB logs
```

#### Non-Eligible
```
❌ EKS Control Plane (toujours payant)
❌ NAT Gateway (toujours payant)
❌ t3.medium (sauf si dans les 750h)
❌ ALB (toujours payant)
```

**Économie avec Free Tier** : ~40-60 CHF/mois

---

### 💳 Crédits Étudiants Disponibles

#### AWS Educate
```
100 $ de crédits gratuits
Pas besoin de carte de crédit
Accès via email .edu ou .ch
```

#### GitHub Student Developer Pack
```
Inclut crédits AWS
+ Autres avantages cloud
Application: education.github.com
```

**Avec crédits étudiants** : **Coût = 0 CHF !** 🎉

## 🚀 Déploiement avec Terraform

### Structure Terraform
```
terraform/
├── main.tf                 # Configuration principale
├── variables.tf            # Variables
├── outputs.tf              # Outputs
├── terraform.tfvars        # Valeurs des variables
├── modules/
│   ├── vpc/               # VPC, Subnets, IGW, NAT
│   ├── security/          # Security Groups
│   ├── compute/           # EC2 instances
│   ├── database/          # RDS PostgreSQL
│   └── eks/               # EKS Cluster (optional)
└── scripts/
    ├── user-data-spire.sh     # Bootstrap SPIRE Server
    ├── user-data-agent.sh     # Bootstrap SPIRE Agent
    └── user-data-bastion.sh   # Bootstrap Bastion
```

### main.tf (Simplifié)
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
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "QuantumSecurity"
      Environment = "Development"
      ManagedBy   = "Terraform"
    }
  }
}

# VPC
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  availability_zone   = "eu-central-1a"
}

# Security Groups
module "security" {
  source = "./modules/security"
  
  vpc_id      = module.vpc.vpc_id
  your_ip     = var.your_ip_address
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami           = var.ubuntu_ami
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnet_id
  
  vpc_security_group_ids = [module.security.bastion_sg_id]
  
  key_name = var.key_pair_name
  
  tags = {
    Name = "quantum-bastion"
  }
}

# SPIRE Server
resource "aws_instance" "spire_server" {
  ami           = var.ubuntu_ami
  instance_type = "t3.medium"
  subnet_id     = module.vpc.private_subnet_id
  
  vpc_security_group_ids = [module.security.spire_server_sg_id]
  
  user_data = file("${path.module}/scripts/user-data-spire.sh")
  
  tags = {
    Name = "quantum-spire-server"
  }
}

# Backend Service
resource "aws_instance" "backend" {
  ami           = var.ubuntu_ami
  instance_type = "t3.medium"
  subnet_id     = module.vpc.private_subnet_id
  
  vpc_security_group_ids = [module.security.backend_sg_id]
  
  user_data = file("${path.module}/scripts/user-data-agent.sh")
  
  tags = {
    Name = "quantum-backend"
  }
}

# Frontend Service
resource "aws_instance" "frontend" {
  ami           = var.ubuntu_ami
  instance_type = "t3.medium"
  subnet_id     = module.vpc.private_subnet_id
  
  vpc_security_group_ids = [module.security.frontend_sg_id]
  
  user_data = file("${path.module}/scripts/user-data-agent.sh")
  
  tags = {
    Name = "quantum-frontend"
  }
}

# RDS PostgreSQL
resource "aws_db_instance" "spire_db" {
  identifier = "quantum-spire-db"
  
  engine         = "postgres"
  engine_version = "14.7"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_type      = "gp3"
  
  db_name  = "spire"
  username = var.db_username
  password = var.db_password
  
  db_subnet_group_name   = module.vpc.db_subnet_group_name
  vpc_security_group_ids = [module.security.rds_sg_id]
  
  backup_retention_period = 7
  skip_final_snapshot     = true
  
  tags = {
    Name = "quantum-spire-db"
  }
}
```

### variables.tf
```hcl
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-central-1"
}

variable "ubuntu_ami" {
  description = "Ubuntu 22.04 LTS AMI"
  type        = string
  default     = "ami-0a628e1e89aaedf80"  # eu-central-1
}

variable "key_pair_name" {
  description = "SSH Key Pair Name"
  type        = string
}

variable "your_ip_address" {
  description = "Your IP for SSH access (CIDR format)"
  type        = string
}

variable "db_username" {
  description = "RDS PostgreSQL Username"
  type        = string
  default     = "spire_admin"
  sensitive   = true
}

variable "db_password" {
  description = "RDS PostgreSQL Password"
  type        = string
  sensitive   = true
}
```

### Déploiement Terraform
```bash
# 1. Initialiser Terraform
cd terraform
terraform init

# 2. Créer terraform.tfvars
cat > terraform.tfvars <<EOF
aws_region       = "eu-central-1"
key_pair_name    = "your-key-pair"
your_ip_address  = "$(curl -s ifconfig.me)/32"
db_password      = "YourSecurePassword123!"
EOF

# 3. Valider la configuration
terraform validate

# 4. Voir le plan
terraform plan

# 5. Déployer
terraform apply

# 6. Obtenir les outputs
terraform output

# 7. Détruire l'infrastructure (après le projet)
terraform destroy
```

## 📋 Checklist Déploiement AWS

### Préparation
- [ ] Compte AWS créé
- [ ] AWS CLI installé et configuré
- [ ] Terraform installé
- [ ] SSH Key Pair créé
- [ ] Vérifier Free Tier eligible

### Infrastructure de Base
- [ ] VPC créé (10.0.0.0/16)
- [ ] Public Subnet créé
- [ ] Private Subnet créé
- [ ] Internet Gateway attaché
- [ ] NAT Gateway déployé
- [ ] Route Tables configurées

### Security
- [ ] Security Groups configurés
- [ ] SSH Key Pair associé
- [ ] IAM Roles créés (si nécessaire)

### Compute
- [ ] Bastion Host lancé
- [ ] SPIRE Server lancé
- [ ] Backend instance lancée
- [ ] Frontend instance lancée
- [ ] Elastic IP associée au Bastion

### Database
- [ ] RDS PostgreSQL créée
- [ ] DB Subnet Group configuré
- [ ] Connection string obtenue
- [ ] Test de connexion OK

### Configuration
- [ ] SPIRE Server configuré
- [ ] SPIRE Agents configurés
- [ ] Workloads enregistrés
- [ ] mTLS testé
- [ ] liboqs installé

### Monitoring
- [ ] CloudWatch Logs configurés
- [ ] CloudWatch Metrics activés
- [ ] Alarmes créées (optional)

## 🎯 Avantages Architecture AWS

✅ **Production-Ready** : Infrastructure réelle  
✅ **Highly Available** : Multi-AZ possible  
✅ **Managed Services** : RDS, CloudWatch  
✅ **Scalable** : Auto-scaling facile  
✅ **Secure** : VPC, Security Groups, IAM  
✅ **Remote Access** : De n'importe où  
✅ **Professional** : Expérience valorisable  

## 🔍 Monitoring et Debugging

### CloudWatch Logs
```bash
# Installer CloudWatch Agent sur chaque instance
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/config.json \
  -s

# Voir les logs dans AWS Console
# CloudWatch > Log Groups > /aws/ec2/quantum-*
```

### SSH via Bastion
```bash
# SSH vers Bastion
ssh -i your-key.pem ubuntu@<BASTION_ELASTIC_IP>

# SSH vers instance privée depuis Bastion
ssh -i your-key.pem ubuntu@10.0.2.10  # SPIRE Server
ssh -i your-key.pem ubuntu@10.0.2.20  # Backend
ssh -i your-key.pem ubuntu@10.0.2.30  # Frontend

# Ou en une commande avec ProxyJump
ssh -J ubuntu@<BASTION_IP> ubuntu@10.0.2.10 -i your-key.pem
```

### AWS Systems Manager (Alternative)
```bash
# Se connecter via SSM (pas besoin de SSH)
aws ssm start-session --target <instance-id>
```

## 📊 Comparaison Configuration Minimale vs Complète

| Feature | Minimale | Complète (avec EKS) |
|---------|----------|---------------------|
| **EC2 Instances** | 4 (3+1 bastion) | 6 (3+1+2 workers) |
| **Kubernetes** | ❌ | ✅ EKS |
| **Load Balancer** | ❌ | ✅ ALB |
| **Coût/mois** | ~80 CHF | ~200 CHF |
| **Temps setup** | 2h | 3-4h |
| **Complexité** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

## 🎓 Recommandation pour Projet Académique

Pour un projet de recherche de 3 semaines :

**Option Recommandée** : Configuration Minimale  
**Quand** : Semaine 3 uniquement (démo)  
**Durée** : 1 semaine (~20-30 CHF)  
**Avec** : Crédits étudiants = **Gratuit** ! 🎉

---

**Temps setup** : 2-3 heures avec Terraform  
**Difficulté** : ⭐⭐⭐⭐/5  
**Prérequis** : Compte AWS, Terraform, connaissances cloud de base
