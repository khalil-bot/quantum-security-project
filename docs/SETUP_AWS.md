# ☁️ Setup AWS - Guide Complet

## 💰 Estimation des Coûts

### Configuration Budget-Friendly (Recommandée)

```
┌─────────────────────────────────────────────────────┐
│            COÛTS AWS - 3 SEMAINES                   │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Semaine 1-2 : LOCAL (VirtualBox)      →  0€      │
│  Semaine 3 (5 jours AWS uniquement)    → 25-30€   │
│                                                     │
│  TOTAL PROJET                          → ~30€      │
└─────────────────────────────────────────────────────┘
```

### Détail des Coûts Semaine 3 (5 jours)

| Service | Type | Quantité | Coût/heure | Coût 5 jours | Note |
|---------|------|----------|------------|--------------|------|
| **EKS Control Plane** | - | 1 | $0.10 | $12 | Obligatoire |
| **EC2 Workers** | t3.medium | 2 | $0.0416 | $10 | Spot = -70% |
| **EBS Storage** | gp3 | 50GB | - | $2 | Disques |
| **ALB** | - | 1 | $0.0225 | $2.70 | Load Balancer |
| **Data Transfer** | - | <10GB | - | Gratuit | Tier gratuit |
| | | | **TOTAL** | **~27€** | |

### Optimisation des Coûts

#### Option 1 : Utiliser Spot Instances (Recommandé)
```
Économie : -70% sur les workers
EC2 Workers avec Spot : 10€ → 3€
Total optimisé : ~18-20€
```

#### Option 2 : Utiliser Free Tier (Première année AWS)
```
Si nouveau compte AWS :
- 750h EC2 t2.micro gratuit/mois
- 5GB S3 gratuit
- 10GB data transfer gratuit

Possible de faire tout le projet GRATUITEMENT !
```

#### Option 3 : Alternative à EKS (Ultra-Budget)
```
Remplacer EKS par k3s sur EC2 simple :
- 1x EC2 t3.medium (5 jours) : ~5€
- Total : ~5-8€ (économie de 80%)
```

## 🎯 Stratégie Recommandée

```
SEMAINE 1-2 : LOCAL
├── 100% gratuit
└── Tous les labs fonctionnent

SEMAINE 3 - JOURS 1-2 : LOCAL  
├── QKD simulations
└── Toujours gratuit

SEMAINE 3 - JOURS 3-5 : AWS
├── Déployer sur EKS
├── Démo finale
├── Screenshots/vidéos
└── DÉTRUIRE après présentation

COÛT TOTAL : 20-30€ (ou 0€ avec Free Tier)
```

## 📋 Prérequis

### 1. Compte AWS
```bash
# Créer compte sur : https://aws.amazon.com/
# Vous aurez besoin :
# - Email
# - Carte bancaire (validation, pas de charge immédiate)
# - Numéro de téléphone
```

### 2. Installer AWS CLI
```bash
# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# macOS
brew install awscli

# Vérifier
aws --version
```

### 3. Installer kubectl
```bash
# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# macOS
brew install kubectl

# Vérifier
kubectl version --client
```

### 4. Installer eksctl
```bash
# Linux
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# macOS
brew install eksctl

# Vérifier
eksctl version
```

### 5. Installer Terraform (optionnel, mais recommandé)
```bash
# Linux
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# macOS
brew install terraform

# Vérifier
terraform --version
```

## 🔑 Configuration AWS

### Créer Credentials
```bash
# 1. Aller sur AWS Console : https://console.aws.amazon.com/
# 2. IAM → Users → Créer utilisateur
# 3. Nom : quantum-security-admin
# 4. Permissions : AdministratorAccess (pour simplicité)
# 5. Créer Access Key

# 6. Configurer localement
aws configure

# Entrer :
AWS Access Key ID: AKIA...
AWS Secret Access Key: ...
Default region: eu-central-1  # Frankfurt (proche Zurich)
Default output format: json
```

### Vérifier Configuration
```bash
# Test connexion
aws sts get-caller-identity

# Output attendu :
# {
#     "UserId": "AIDA...",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/quantum-security-admin"
# }
```

## 🚀 Déploiement Option 1 : eksctl (Simple et Rapide)

### Configuration Cluster

Créer `cluster-config.yaml` :
```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: quantum-security
  region: eu-central-1
  version: "1.28"

# Configuration réseau
vpc:
  cidr: 10.0.0.0/16
  nat:
    gateway: Single  # Économiser : 1 seul NAT Gateway

# Managed Node Group avec Spot Instances
managedNodeGroups:
  - name: worker-nodes
    instanceType: t3.medium
    desiredCapacity: 2
    minSize: 2
    maxSize: 3
    volumeSize: 20
    volumeType: gp3
    
    # IMPORTANT : Spot Instances pour économiser 70%
    spot: true
    
    labels:
      role: worker
      environment: lab
    
    tags:
      Project: quantum-security
      Owner: student
      ManagedBy: eksctl
    
    iam:
      withAddonPolicies:
        autoScaler: true
        ebs: true
        efs: true

# CloudWatch Logging (optionnel, coûte extra)
cloudWatch:
  clusterLogging:
    enableTypes: ["api", "audit", "authenticator"]
```

### Créer le Cluster

```bash
# Créer cluster (15-20 minutes)
eksctl create cluster -f cluster-config.yaml

# Vérifier
kubectl get nodes

# Output attendu :
# NAME                            STATUS   ROLES    AGE   VERSION
# ip-10-0-1-123.ec2.internal     Ready    <none>   2m    v1.28.0
# ip-10-0-2-234.ec2.internal     Ready    <none>   2m    v1.28.0
```

## 🚀 Déploiement Option 2 : Terraform (Infrastructure as Code)

### Structure Terraform

```
terraform/
├── main.tf           # Configuration principale
├── variables.tf      # Variables
├── outputs.tf        # Outputs
└── versions.tf       # Versions providers
```

### `main.tf`
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
      Project     = "quantum-security"
      Environment = "lab"
      ManagedBy   = "terraform"
    }
  }
}

# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "quantum-security-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true  # Économie
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.28"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Managed Node Group avec Spot
  eks_managed_node_groups = {
    workers = {
      min_size       = 2
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"  # Économie 70%
      
      labels = {
        role = "worker"
      }
    }
  }

  # Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
}
```

### `variables.tf`
```hcl
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-central-1"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "quantum-security"
}
```

### `outputs.tf`
```hcl
output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
}
```

### Déployer avec Terraform

```bash
# Initialiser
cd terraform/
terraform init

# Planifier
terraform plan

# Appliquer
terraform apply -auto-approve

# Configurer kubectl
aws eks update-kubeconfig --region eu-central-1 --name quantum-security

# Vérifier
kubectl get nodes
```

## 📦 Déploiement SPIFFE/SPIRE sur EKS

### Namespace et Prérequis

```bash
# Créer namespace
kubectl create namespace spire

# Installer cert-manager (requis pour SPIRE)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Attendre que cert-manager soit prêt
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n cert-manager --timeout=300s
```

### Installer SPIRE via Helm

```bash
# Ajouter Helm repo
helm repo add spiffe https://spiffe.github.io/helm-charts-hardened/
helm repo update

# Installer SPIRE
helm install spire-crds spiffe/spire-crds -n spire

helm install spire spiffe/spire -n spire \
  --set global.spire.clusterName=quantum-security \
  --set global.spire.trustDomain=quantum-security.lab

# Vérifier installation
kubectl get pods -n spire
```

### Déployer Workloads de Test

`workload-deployment.yaml` :
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: quantum-workloads

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: quantum-workloads
  labels:
    app: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      serviceAccountName: backend-sa
      containers:
      - name: backend
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: spire-agent-socket
          mountPath: /run/spire/sockets
          readOnly: true
      volumes:
      - name: spire-agent-socket
        csi:
          driver: "csi.spiffe.io"
          readOnly: true

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backend-sa
  namespace: quantum-workloads

---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: quantum-workloads
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 80
```

Appliquer :
```bash
kubectl apply -f workload-deployment.yaml
kubectl get pods -n quantum-workloads
```

## 📊 Monitoring et Logs

### CloudWatch Logs
```bash
# Voir logs cluster
aws logs tail /aws/eks/quantum-security/cluster --follow

# Logs d'un pod
kubectl logs -f deployment/backend -n quantum-workloads
```

### Metrics avec kubectl
```bash
# Utilisation ressources nodes
kubectl top nodes

# Utilisation ressources pods
kubectl top pods -A
```

## 💰 Surveillance des Coûts

### Activer Cost Explorer
```bash
# Via AWS Console : 
# Billing → Cost Explorer → Enable

# Voir coûts actuels
aws ce get-cost-and-usage \
  --time-period Start=2024-01-20,End=2024-01-27 \
  --granularity DAILY \
  --metrics "UnblendedCost" \
  --group-by Type=SERVICE
```

### Alertes Budget
```bash
# Créer alerte à 25€
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget file://budget.json
```

`budget.json` :
```json
{
  "BudgetName": "quantum-security-budget",
  "BudgetLimit": {
    "Amount": "25",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST"
}
```

## 🧹 DESTRUCTION (IMPORTANT!)

### ⚠️ NE PAS OUBLIER DE DÉTRUIRE !

```bash
# Option 1 : eksctl
eksctl delete cluster --name quantum-security --region eu-central-1

# Option 2 : Terraform
cd terraform/
terraform destroy -auto-approve

# Vérifier suppression
aws eks list-clusters --region eu-central-1
# Output: { "clusters": [] }

# Vérifier EC2
aws ec2 describe-instances --region eu-central-1 --filters "Name=tag:Project,Values=quantum-security"
# Doit être vide

# Vérifier coûts finaux
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics "UnblendedCost"
```

### Checklist de Destruction

- [ ] `eksctl delete cluster` OU `terraform destroy`
- [ ] Vérifier EC2 instances terminées
- [ ] Vérifier EBS volumes supprimés
- [ ] Vérifier Load Balancers supprimés
- [ ] Vérifier VPC supprimé
- [ ] Vérifier NAT Gateway supprimé
- [ ] Attendre 24h et vérifier facture

## 🎯 Timeline Recommandée

```
Jour -1 (avant Semaine 3)
├── Créer compte AWS (si pas déjà fait)
├── Installer outils (aws-cli, kubectl, eksctl)
└── Configurer credentials

Jour 1 (Lundi Semaine 3)
├── QKD simulations en LOCAL
└── Préparer configs AWS

Jour 2 (Mardi)
├── Continuer QKD en LOCAL
└── 18h : Lancer création cluster AWS (15-20min)

Jour 3 (Mercredi)
├── Déployer SPIFFE/SPIRE sur EKS
├── Déployer workloads
└── Tests et validation

Jour 4 (Jeudi)
├── Intégration PQC dans pods
├── Screenshots et vidéos
└── Préparer démo

Jour 5 (Vendredi)
├── 9h : Présentation à Prof. Schiller avec démo live
└── 12h : DÉTRUIRE CLUSTER AWS ⚠️
```

## 🆘 Troubleshooting

### Cluster ne se crée pas
```bash
# Vérifier logs
eksctl utils describe-stacks --region eu-central-1 --cluster quantum-security

# Vérifier quotas
aws service-quotas list-service-quotas --service-code eks
```

### Coûts inattendus
```bash
# Identifier ressources coûteuses
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity DAILY \
  --metrics "UnblendedCost" \
  --group-by Type=SERVICE \
  --filter file://filter.json
```

### Impossible de détruire cluster
```bash
# Forcer suppression
eksctl delete cluster --name quantum-security --region eu-central-1 --force

# Nettoyer manuellement
aws cloudformation delete-stack --stack-name eksctl-quantum-security-cluster
```

## 💡 Conseils Pro

1. **Toujours utiliser Spot Instances** (-70% coût)
2. **Single NAT Gateway** (-50% sur NAT)
3. **Détruire le soir** si pas utilisé
4. **Alertes budget** à 20€
5. **Screenshots/vidéos** pour garder traces sans garder infra

## 📝 Checklist Setup AWS Complet

- [ ] Compte AWS créé
- [ ] AWS CLI installé et configuré
- [ ] kubectl installé
- [ ] eksctl installé
- [ ] Credentials configurés
- [ ] Budget alert créée (25€)
- [ ] Cluster EKS créé
- [ ] SPIFFE/SPIRE déployé
- [ ] Workloads de test déployés
- [ ] Monitoring configuré
- [ ] Screenshots/vidéos capturés
- [ ] ⚠️ CLUSTER DÉTRUIT après démo

---

**Coût Total Estimé** : 20-30€ (5 jours)  
**Ou GRATUIT avec Free Tier nouveau compte**  
**Temps Setup** : 2-3 heures  
**Difficulté** : ⭐⭐⭐⭐/5
