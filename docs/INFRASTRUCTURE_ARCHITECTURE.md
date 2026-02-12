# 🏗️ Architecture d'Infrastructure - Recommandations

## 🎯 Analyse de Vos Besoins

Pour votre projet de 3 semaines, vous avez besoin de :
- **Labs cryptographiques** (OpenSSL, liboqs)
- **Environnement SPIFFE/SPIRE** (Server + Agents)
- **Microservices** pour démonstrations mTLS
- **Kubernetes** pour intégration finale
- **Simulation QKD** (Qiskit)

## 📊 Comparaison VirtualBox vs AWS

| Critère | VirtualBox (Local) | AWS Cloud |
|---------|-------------------|-----------|
| **Coût** | 🟢 Gratuit | 🟡 ~$50-100/mois |
| **Performance** | 🟡 Limité par votre machine | 🟢 Excellent |
| **Flexibilité** | 🟢 Contrôle total | 🟢 Scalable |
| **Apprentissage** | 🟢 Infra as Code local | 🟢 Cloud-native skills |
| **Portabilité** | 🟡 VM lourdes | 🟢 Accessible partout |
| **Complexité Setup** | 🟢 Simple | 🟡 Courbe apprentissage |
| **Réalisme Pro** | 🟡 Local only | 🟢 Production-like |
| **Destruction/Recréation** | 🟡 Lent | 🟢 Rapide (IaC) |

## 🏆 Ma Recommandation : **Approche Hybride**

### Phase 1-2 (Semaines 1-2) : VirtualBox
- Apprentissage crypto et SPIFFE
- Environnement stable et reproductible
- Pas de coûts
- Facile à debugger

### Phase 3 (Semaine 3) : AWS (optionnel)
- Déploiement "production-like"
- Kubernetes managé (EKS)
- Démo professionnelle pour Prof. Schiller
- Expérience cloud

---

## 🖥️ OPTION 1 : Architecture VirtualBox (Recommandée pour démarrer)

### Architecture Globale

```
┌─────────────────────────────────────────────────────────────┐
│ Machine Hôte (votre laptop/desktop)                          │
│                                                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │ VirtualBox                                          │     │
│  │                                                     │     │
│  │  ┌──────────────────────────────────────────┐     │     │
│  │  │ VM 1: Control Plane (4 vCPU, 8GB RAM)   │     │     │
│  │  │                                          │     │     │
│  │  │  • Ubuntu 24.04 LTS                     │     │     │
│  │  │  • SPIRE Server                         │     │     │
│  │  │  • PostgreSQL (SPIRE datastore)         │     │     │
│  │  │  • Kubernetes Control Plane (k3s)       │     │     │
│  │  │  • Nginx (reverse proxy)                │     │     │
│  │  │  • Tools: OpenSSL, liboqs, Git          │     │     │
│  │  └──────────────────────────────────────────┘     │     │
│  │                                                     │     │
│  │  ┌──────────────────────────────────────────┐     │     │
│  │  │ VM 2: Worker Node 1 (2 vCPU, 4GB RAM)   │     │     │
│  │  │                                          │     │     │
│  │  │  • Ubuntu 24.04 LTS                     │     │     │
│  │  │  • SPIRE Agent                          │     │     │
│  │  │  • Workload: Backend Service            │     │     │
│  │  │  • Kubernetes Worker                    │     │     │
│  │  └──────────────────────────────────────────┘     │     │
│  │                                                     │     │
│  │  ┌──────────────────────────────────────────┐     │     │
│  │  │ VM 3: Worker Node 2 (2 vCPU, 4GB RAM)   │     │     │
│  │  │                                          │     │     │
│  │  │  • Ubuntu 24.04 LTS                     │     │     │
│  │  │  • SPIRE Agent                          │     │     │
│  │  │  • Workload: Frontend Service           │     │     │
│  │  │  • Kubernetes Worker                    │     │     │
│  │  └──────────────────────────────────────────┘     │     │
│  │                                                     │     │
│  └────────────────────────────────────────────────────┘     │
│                                                               │
│  Network: NAT + Host-Only Adapter                            │
│  - NAT: Internet access                                      │
│  - Host-Only: 192.168.56.0/24 (communication inter-VMs)      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Spécifications Minimales

**Configuration Minimale (Machine Hôte)** :
- CPU : 8 cores (Intel i5/i7 ou AMD Ryzen 5/7)
- RAM : 16 GB minimum, **24 GB recommandé**
- Disk : 100 GB SSD libre
- OS : Windows 10/11, macOS, ou Linux

**Configuration Optimale** :
- CPU : 12+ cores
- RAM : 32 GB
- Disk : 200 GB NVMe SSD

### Allocation Ressources VMs

| VM | vCPU | RAM | Disk | Rôle |
|----|------|-----|------|------|
| Control Plane | 4 | 8 GB | 40 GB | SPIRE Server, K8s Master |
| Worker 1 | 2 | 4 GB | 30 GB | Backend workload |
| Worker 2 | 2 | 4 GB | 30 GB | Frontend workload |
| **TOTAL** | **8** | **16 GB** | **100 GB** | |

### Plan de Déploiement VirtualBox

#### Semaine 1 : Setup Initial
```bash
# Jour 1-2 : VM Control Plane uniquement
- Installation Ubuntu 24.04
- OpenSSL, certificats
- Labs crypto classique
- Pas besoin des autres VMs encore

# Jour 3-5 : Ajout liboqs
- Installation liboqs sur Control Plane
- Tests PQC
```

#### Semaine 2 : SPIFFE/SPIRE
```bash
# Jour 1-2 : SPIRE Server
- Configuration SPIRE Server sur Control Plane
- Architecture Zero-Trust

# Jour 3-5 : SPIRE Agents + Workloads
- Créer VM Worker 1 et 2
- Installer SPIRE Agents
- Déployer microservices
- Demo mTLS
```

#### Semaine 3 : Kubernetes
```bash
# Jour 1-2 : QKD sur Control Plane
- Simulation BB84

# Jour 3-5 : K8s + Intégration
- k3s sur les 3 VMs
- SPIFFE + Kubernetes
- Démo finale
```

### Avantages VirtualBox

✅ **Coût zéro**  
✅ **Offline** : travail sans internet  
✅ **Snapshots** : retour arrière facile  
✅ **Contrôle total** : root access partout  
✅ **Reproductible** : export OVA  
✅ **Debugging facile** : accès console directe  

### Inconvénients VirtualBox

❌ **Performance** : limité par votre machine  
❌ **Portabilité** : VMs lourdes (100+ GB)  
❌ **Pas scalable** : difficile d'ajouter ressources  
❌ **Pas "cloud-native"** : moins réaliste pour production  

---

## ☁️ OPTION 2 : Architecture AWS (Pour démo professionnelle)

### Architecture AWS

```
┌─────────────────────────────────────────────────────────────────┐
│ AWS Account                                                      │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ VPC: quantum-security-vpc (10.0.0.0/16)                  │   │
│  │                                                           │   │
│  │  ┌─────────────────┐  ┌─────────────────┐               │   │
│  │  │ Public Subnet   │  │ Private Subnet  │               │   │
│  │  │ 10.0.1.0/24     │  │ 10.0.10.0/24    │               │   │
│  │  │                 │  │                 │               │   │
│  │  │ ┌─────────────┐ │  │ ┌─────────────┐ │               │   │
│  │  │ │ Bastion     │ │  │ │ EKS Cluster │ │               │   │
│  │  │ │ EC2 (t3.micro│ │  │ │             │ │               │   │
│  │  │ │ Jump host)  │ │  │ │ Control     │ │               │   │
│  │  │ └─────────────┘ │  │ │ Plane       │ │               │   │
│  │  │                 │  │ │ (Managed)   │ │               │   │
│  │  │ ┌─────────────┐ │  │ └─────────────┘ │               │   │
│  │  │ │ NAT Gateway │ │  │                 │               │   │
│  │  │ └─────────────┘ │  │ ┌─────────────┐ │               │   │
│  │  └─────────────────┘  │ │ Node Group  │ │               │   │
│  │                        │ │             │ │               │   │
│  │  ┌─────────────────┐  │ │ 3x t3.medium│ │               │   │
│  │  │ Internet        │  │ │ nodes       │ │               │   │
│  │  │ Gateway         │  │ │             │ │               │   │
│  │  └─────────────────┘  │ │ - SPIRE     │ │               │   │
│  │                        │ │ - Workloads │ │               │   │
│  │                        │ └─────────────┘ │               │   │
│  │                        │                 │               │   │
│  │                        │ ┌─────────────┐ │               │   │
│  │                        │ │ RDS         │ │               │   │
│  │                        │ │ PostgreSQL  │ │               │   │
│  │                        │ │ (t3.micro)  │ │               │   │
│  │                        │ └─────────────┘ │               │   │
│  │                        └─────────────────┘               │   │
│  │                                                           │   │
│  │  Services:                                               │   │
│  │  • ECR (Docker Registry)                                 │   │
│  │  • Secrets Manager (certificates, keys)                  │   │
│  │  • CloudWatch (logs, monitoring)                         │   │
│  │  • S3 (backups, artifacts)                               │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  Region: eu-central-1 (Frankfurt) ou eu-west-1 (Ireland)        │
│  Availability Zones: 2 AZs pour haute disponibilité              │
└─────────────────────────────────────────────────────────────────┘
```

### Ressources AWS Détaillées

#### Compute
- **EKS Cluster** : Control plane managé (~$73/mois)
- **EC2 Node Group** : 3x t3.medium (2 vCPU, 4GB) (~$95/mois)
- **Bastion Host** : 1x t3.micro (~$8/mois)

#### Storage & Database
- **RDS PostgreSQL** : t3.micro (~$15/mois)
- **EBS Volumes** : 100 GB gp3 (~$10/mois)
- **S3** : Stockage artifacts (~$5/mois)

#### Network
- **NAT Gateway** : (~$35/mois)
- **Data Transfer** : (~$10/mois)

#### Services
- **ECR** : Docker registry (~$5/mois)
- **Secrets Manager** : (~$2/mois)
- **CloudWatch** : Logs (~$5/mois)

**Coût Total Estimé** : **$260-280/mois**

⚠️ **Mais pour 3 semaines** : ~**$180-200** si bien optimisé

### Optimisations de Coût AWS

#### Option 1 : Infrastructure Minimale (Semaine 3 uniquement)
```
• Pas d'EKS, utiliser ECS Fargate ou EC2 simple
• 1x t3.medium EC2 pour tout (~$30/mois)
• Pas de RDS, utiliser PostgreSQL sur EC2
• Pas de NAT Gateway, tout en public (lab only!)

Coût réduit: ~$40-50 pour 1 semaine
```

#### Option 2 : AWS Free Tier (Nouveaux comptes)
```
• 750h/mois EC2 t2.micro (12 mois gratuit)
• 20 GB RDS (12 mois)
• 5 GB S3
• Peut couvrir une partie des labs

Coût: ~$0-20 pour 3 semaines
```

### Plan de Déploiement AWS (Semaine 3)

```bash
# Jour 1 : Infrastructure as Code
├── Terraform/CloudFormation
│   ├── VPC et networking
│   ├── EC2 instances ou EKS
│   └── Security groups

# Jour 2-3 : Déploiement Services
├── SPIRE sur Kubernetes
├── Microservices avec mTLS
└── PQC integration

# Jour 4-5 : Demo et Documentation
├── Tests end-to-end
├── Monitoring et logs
└── Présentation
```

### Avantages AWS

✅ **Production-like** : architecture réaliste  
✅ **Scalable** : ajout ressources facile  
✅ **Managed services** : EKS, RDS  
✅ **IaC** : Terraform reproductible  
✅ **Monitoring** : CloudWatch intégré  
✅ **Compétences cloud** : bonus pour CV  

### Inconvénients AWS

❌ **Coût** : ~$180-200 pour 3 semaines  
❌ **Complexité** : courbe apprentissage  
❌ **Internet requis** : pas de travail offline  
❌ **Setup time** : plus long qu'une VM  
❌ **Debugging** : moins direct que local  

---

## 🎯 Ma Recommandation Finale

### Pour Votre Situation (3 semaines, apprentissage, budget étudiant)

```
┌─────────────────────────────────────────────────────┐
│ APPROCHE RECOMMANDÉE : HYBRIDE                       │
│                                                      │
│ Semaine 1-2 : VirtualBox (local)                    │
│ ├── Labs crypto (OpenSSL, liboqs)                   │
│ ├── SPIFFE/SPIRE complet                            │
│ ├── Microservices demos                             │
│ └── Coût: 0€                                        │
│                                                      │
│ Semaine 3 : AWS (optionnel, si budget)              │
│ ├── Déploiement Kubernetes                          │
│ ├── Demo "production-ready"                         │
│ ├── Architecture professionnelle                    │
│ └── Coût: ~50-80€ (1 semaine)                       │
│                                                      │
│ TOTAL : 0€ à 80€                                     │
└─────────────────────────────────────────────────────┘
```

### Arguments pour VirtualBox d'Abord

1. **Apprentissage focus** : crypto et SPIFFE sont indépendants du cloud
2. **Budget** : 0€ vs 200€
3. **Reproductibilité** : snapshots pour recommencer
4. **Offline** : travail partout
5. **Prof. Schiller** : sûrement plus intéressé par la compréhension que l'infra

### Quand Passer à AWS ?

Si vous voulez :
- Expérience cloud sur CV
- Demo plus "impressive"
- Apprendre Terraform/EKS
- Architecture réaliste

Mais **ce n'est pas nécessaire** pour valider vos 3 semaines !

---

## 🚀 Plan d'Action Recommandé

### Semaine 1 : Setup VirtualBox

**Jour 1** :
```bash
1. Installer VirtualBox
2. Télécharger Ubuntu 24.04 ISO
3. Créer VM Control Plane
4. Installer base (OpenSSL, Git, Docker)
```

**Jour 2-5** :
```bash
Continue avec VM Control Plane
- Labs OpenSSL
- Installation liboqs
- Tests PQC
```

### Semaine 2 : Expansion Multi-VM

**Jour 1-2** :
```bash
1. Configurer SPIRE Server sur Control Plane
2. Créer VM Worker 1
3. Créer VM Worker 2
```

**Jour 3-5** :
```bash
1. SPIRE Agents sur Workers
2. Microservices avec mTLS
3. Démos
```

### Semaine 3 : Décision

**Option A - VirtualBox** :
```bash
1. Installer k3s sur les 3 VMs
2. SPIFFE + Kubernetes
3. QKD simulation
4. Demo finale locale
```

**Option B - Migration AWS** (si budget) :
```bash
1. Créer compte AWS / utiliser free tier
2. Terraform pour infrastructure
3. Déployer sur EKS
4. Demo cloud
```

---

## 📋 Guides de Setup à Créer

Je vous propose de créer ensuite :

1. **VIRTUALBOX_SETUP.md** - Guide complet VirtualBox
2. **AWS_SETUP.md** - Guide Terraform AWS (optionnel)
3. **NETWORK_CONFIG.md** - Configuration réseau détaillée
4. **KUBERNETES_SETUP.md** - k3s ou EKS selon choix

Voulez-vous que je crée ces guides maintenant ?

---

## 🤔 Questions pour Vous Aider à Décider

1. **Budget** : Avez-vous ~100-200€ à dépenser ?
2. **Machine** : Votre laptop a combien de RAM ? (16GB+ OK pour VirtualBox)
3. **Objectif principal** : Apprendre ou impressionner ?
4. **Expérience cloud** : Avez-vous déjà utilisé AWS/Azure/GCP ?
5. **Prof. Schiller** : A-t-il mentionné des préférences ?

**Mon conseil** : Commencez avec VirtualBox, et décidez en Semaine 2 si vous voulez ajouter AWS pour la démo finale. Vous ne perdez rien !
