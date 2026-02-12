# 🚀 Terraform Phase 1 - Infrastructure Apprentissage

## 🎯 Objectif

Déployer une infrastructure AWS simple et économique pour les 3 premières semaines d'apprentissage.

### Ce Qui Sera Créé

- **1 EC2 Instance** Ubuntu 22.04 (t3.small par défaut)
- **1 Elastic IP** (IP publique fixe)
- **1 Security Group** (SSH depuis votre IP, HTTP/HTTPS ouvert)
- **1 Volume EBS** 50GB (encrypted)
- **CloudWatch Monitoring** (basic)

**Coût estimé** : ~€15/mois (t3.small) ou €0 avec Free Tier (t2.micro)

---

## ✅ Prérequis

### 1. AWS CLI Configuré

```bash
# Installer
pip install awscli

# Configurer
aws configure
# Access Key ID: <votre clé>
# Secret Access Key: <votre secret>
# Region: eu-west-1
# Output: json

# Vérifier
aws sts get-caller-identity
```

### 2. Terraform Installé

```bash
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Vérifier
terraform --version
```

### 3. Clé SSH Créée dans AWS

```bash
# Option A: Via AWS CLI (recommandé)
aws ec2 create-key-pair \
    --key-name quantum-key-phase1 \
    --query 'KeyMaterial' \
    --output text > ~/.ssh/quantum-key-phase1.pem

chmod 400 ~/.ssh/quantum-key-phase1.pem

# Option B: Via AWS Console
# EC2 > Key Pairs > Create key pair
# Name: quantum-key-phase1
# Format: .pem
# Download et sauvegarder dans ~/.ssh/
```

---

## 🚀 Déploiement (5 Minutes)

### Étape 1 : Configuration (1 min)

```bash
# Obtenir votre IP publique
MY_IP=$(curl -s -4 ifconfig.me)
echo "Mon IP: $MY_IP"

# Créer terraform.tfvars
cat > terraform.tfvars << EOF
my_ip         = "$MY_IP"
key_name      = "quantum-key-phase1"
instance_type = "t3.small"
aws_region    = "eu-west-3"
project_name  = "quantum-phase1"
EOF

# Vérifier
cat terraform.tfvars
```

### Étape 2 : Initialisation (1 min)

```bash
# Initialiser Terraform
terraform init

# Vous devriez voir:
# Terraform has been successfully initialized!
```

### Étape 3 : Planification (1 min)

```bash
# Voir ce qui va être créé
terraform plan

# Devrait afficher:
# Plan: 4 to add, 0 to change, 0 to destroy
```

### Étape 4 : Application (2 min)

```bash
# Déployer l'infrastructure
terraform apply

# Ou sans confirmation:
terraform apply -auto-approve

# Durée: ~2-3 minutes
```

### Étape 5 : Récupération Info

```bash
# IP publique
PUBLIC_IP=$(terraform output -raw public_ip)
echo "Instance IP: $PUBLIC_IP"

# Sauvegarder pour plus tard
echo $PUBLIC_IP > ~/quantum-instance-ip.txt

# Toutes les infos
terraform output

# Commande SSH
terraform output ssh_command
```

---

## 🔌 Connexion à l'Instance

### Première Connexion

```bash
# Se connecter
ssh -i ~/.ssh/quantum-key-phase1.pem ubuntu@$(terraform output -raw public_ip)

# Ou avec l'IP sauvegardée
ssh -i ~/.ssh/quantum-key-phase1.pem ubuntu@$(cat ~/quantum-instance-ip.txt)
```

**Note** : À la première connexion, tapez `yes` quand demandé.

### Vérifier User-Data

```bash
# Sur l'instance

# Attendre que user-data soit terminé
tail -f /var/log/cloud-init-output.log
# Ctrl+C quand terminé

# Ou vérifier le marker
ls -la ~/user-data-complete
# Devrait exister
```

---

## 🛠️ Installation Complète

### Exécuter Setup Script

```bash
# Sur l'instance AWS

# Le script est déjà présent (créé par user-data)
ls -la ~/setup-phase1.sh

# Exécuter
chmod +x ~/setup-phase1.sh
./setup-phase1.sh

# Durée: ~10-15 minutes (compilation liboqs)
```

Le script installe :
- Python + Qiskit
- liboqs (Post-Quantum Crypto)
- Wireshark
- Bash aliases
- Workspace structure

### Redémarrer Session

```bash
# Important pour activer Docker et groupes
exit

# Reconnexion
ssh -i ~/.ssh/quantum-key-phase1.pem ubuntu@$(cat ~/quantum-instance-ip.txt)
```

### Validation

```bash
# Vérifier que tout fonctionne
docker --version
openssl version
python3 --version
python3 -c "import qiskit; print(qiskit.__version__)"
ls -la /usr/local/lib/liboqs.so

# Test Docker (sans sudo!)
docker run hello-world

# Tout devrait être ✓
```

---

## 📦 Cloner le Projet

```bash
# Sur l'instance
cd ~/workspace

# Option A: Clone depuis GitHub (si vous avez poussé)
git clone https://github.com/VOTRE-USER/quantum-security-project.git

# Option B: Copier depuis votre machine
# Sur VOTRE MACHINE:
cd ~/quantum-security-project
tar -czf project.tar.gz .
scp -i ~/.ssh/quantum-key-phase1.pem \
    project.tar.gz \
    ubuntu@$(cat ~/quantum-instance-ip.txt):~/workspace/

# Sur l'INSTANCE:
cd ~/workspace
tar -xzf project.tar.gz
mv . quantum-security-project  # Si nécessaire

# Vérifier
cd quantum-security-project
ls -la
```

---

## 🎓 Commencer Lab 1.1

```bash
# Sur l'instance
cd ~/workspace/quantum-security-project/labs/openssl

# Lire le guide
cat LAB-1.1-Certificates.md

# Créer structure
mkdir -p ca/{root,intermediate,certs,crl,newcerts,private}
chmod 700 ca/private
cd ca

# Suivre le guide LAB-1.1 étape par étape !
```

---

## 💰 Gestion des Coûts

### Voir les Coûts Actuels

```bash
# Via AWS CLI
aws ce get-cost-and-usage \
    --time-period Start=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
    --granularity MONTHLY \
    --metrics BlendedCost

# Via Console
# AWS Console > Billing > Cost Explorer
```

### Arrêter l'Instance (Économiser)

```bash
# Arrêter (vous gardez les données, mais ne payez que le stockage)
aws ec2 stop-instances --instance-ids $(terraform output -raw instance_id)

# Redémarrer plus tard
aws ec2 start-instances --instance-ids $(terraform output -raw instance_id)

# Récupérer nouvelle IP (si pas d'Elastic IP)
aws ec2 describe-instances \
    --instance-ids $(terraform output -raw instance_id) \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text
```

**Note** : Avec Elastic IP (notre config), l'IP ne change pas.

### Détruire Tout (€0)

```bash
# ⚠️ ATTENTION: Supprime TOUT (instance + données)
terraform destroy

# Ou sans confirmation
terraform destroy -auto-approve
```

---

## 🔧 Modifications de Configuration

### Changer Type d'Instance

```bash
# Éditer terraform.tfvars
vim terraform.tfvars

# Modifier instance_type
instance_type = "t3.medium"  # ou t2.micro pour Free Tier

# Appliquer
terraform apply

# ⚠️ Cela va arrêter et redémarrer l'instance
```

### Mettre à Jour IP (si votre IP change)

```bash
# Obtenir nouvelle IP
MY_NEW_IP=$(curl -s ifconfig.me)

# Mettre à jour
echo "my_ip = \"$MY_NEW_IP\"" > terraform.tfvars
echo "key_name = \"quantum-key-phase1\"" >> terraform.tfvars
echo "instance_type = \"t3.small\"" >> terraform.tfvars

# Appliquer (met à jour Security Group)
terraform apply
```

---

## 📊 Outputs Disponibles

```bash
# Instance ID
terraform output instance_id

# Public IP
terraform output public_ip

# Private IP
terraform output private_ip

# Commande SSH
terraform output ssh_command

# Toutes les infos
terraform output instance_info

# Prochaines étapes
terraform output next_steps
```

---

## 🆘 Troubleshooting

### SSH Refuse Connexion

**Problème** : `Connection refused` ou `Connection timed out`

**Solutions** :

```bash
# 1. Vérifier que l'instance est running
aws ec2 describe-instances \
    --instance-ids $(terraform output -raw instance_id) \
    --query 'Reservations[0].Instances[0].State.Name'

# Devrait afficher: "running"

# 2. Vérifier Security Group
aws ec2 describe-security-groups \
    --group-ids $(terraform output -raw security_group_id) \
    --query 'SecurityGroups[0].IpPermissions'

# Votre IP devrait être dans les règles

# 3. Votre IP a changé?
MY_NEW_IP=$(curl -s ifconfig.me)
terraform apply -var="my_ip=$MY_NEW_IP"
```

### Instance Lente / Freeze

**Problème** : Instance très lente, commands timeout

**Solutions** :

```bash
# Option 1: Redémarrer
aws ec2 reboot-instances --instance-ids $(terraform output -raw instance_id)

# Option 2: Upgrade instance type
# Éditer terraform.tfvars
instance_type = "t3.medium"

# Appliquer
terraform apply
```

### liboqs Ne Compile Pas

**Problème** : Erreur durant `./setup-phase1.sh`

**Solutions** :

```bash
# Sur l'instance
cd ~/liboqs
rm -rf build

# Réinstaller dépendances
sudo apt-get update
sudo apt-get install -y cmake ninja-build libssl-dev

# Recompiler
mkdir build && cd build
cmake -GNinja .. -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=ON
ninja
sudo ninja install
sudo ldconfig

# Vérifier
ls -la /usr/local/lib/liboqs.so
```

### Terraform State Lock

**Problème** : `Error acquiring the state lock`

**Solution** :

```bash
# Forcer unlock (si sûr qu'aucun autre terraform ne tourne)
terraform force-unlock <LOCK_ID>

# LOCK_ID est affiché dans le message d'erreur
```

---

## 📚 Fichiers du Projet

```
terraform/phase1/
├── main.tf                      # Configuration principale
├── user-data.sh                 # Script auto-exécuté au boot
├── terraform.tfvars.example     # Template de variables
├── terraform.tfvars             # Vos variables (git-ignored)
├── README.md                    # Ce fichier
└── .terraform/                  # Dossier Terraform (auto-créé)
```

---

## 🔄 Workflow Quotidien

### Démarrer la Journée

```bash
# Se connecter
ssh -i ~/.ssh/quantum-key-phase1.pem ubuntu@$(cat ~/quantum-instance-ip.txt)

# Aller dans projet
cd ~/workspace/quantum-security-project

# Voir status Git
git status

# Continuer lab du jour
cd labs/openssl  # ou liboqs, spiffe, etc.
```

### Fin de Journée

```bash
# Documenter
cd ~/workspace/quantum-security-project
vim docs/learning-notes/semaine1-jourX.md

# Commiter
git add .
git commit -m "📝 Day X: Lab X.X completed"
git push

# Arrêter instance (économiser) - optionnel
exit
aws ec2 stop-instances --instance-ids $(terraform output -raw instance_id)
```

---

## 📝 Commandes Utiles

### Copier Fichiers

```bash
# Vers instance
scp -i ~/.ssh/quantum-key-phase1.pem \
    local-file.txt \
    ubuntu@$(cat ~/quantum-instance-ip.txt):~/

# Depuis instance
scp -i ~/.ssh/quantum-key-phase1.pem \
    ubuntu@$(cat ~/quantum-instance-ip.txt):~/remote-file.txt \
    ./
```

### Monitoring

```bash
# CPU usage
aws cloudwatch get-metric-statistics \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization \
    --dimensions Name=InstanceId,Value=$(terraform output -raw instance_id) \
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 300 \
    --statistics Average
```

### Backup

```bash
# Créer AMI snapshot
aws ec2 create-image \
    --instance-id $(terraform output -raw instance_id) \
    --name "quantum-phase1-$(date +%Y%m%d)" \
    --description "Phase 1 learning instance backup"

# Lister AMIs
aws ec2 describe-images --owners self
```

---

## 🎯 Prochaines Étapes

Une fois l'infrastructure déployée :

1. ✅ Connexion SSH réussie
2. ✅ Setup script exécuté
3. ✅ Validations OK
4. ✅ Projet cloné
5. 🎓 **Commencer Lab 1.1 !**

Référez-vous à `docs/PHASE1_START.md` pour le planning détaillé des 3 semaines.

---

## 📞 Support

- **Documentation Terraform** : https://registry.terraform.io/providers/hashicorp/aws/
- **AWS Free Tier** : https://aws.amazon.com/free/
- **Guide Phase 1** : `docs/PHASE1_START.md`

---

**Créé le** : 8 février 2026  
**Phase** : 1 - Learning (3 semaines)  
**Coût** : ~€15/mois (t3.small)  
**Status** : ✅ Prêt à déployer
