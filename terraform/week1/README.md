# 🚀 Déploiement AWS avec Terraform - Semaine 1

## 🎯 Qu'est-ce qui sera créé ?

Cette configuration Terraform va créer sur AWS :

- **1 VPC** (10.0.0.0/16) avec Internet Gateway
- **1 Subnet Public** (10.0.1.0/24)
- **1 Security Group** (SSH depuis votre IP, HTTP/HTTPS ouvert)
- **1 Instance EC2** Ubuntu 22.04 (t3.small recommandé)
- **1 Elastic IP** (IP publique fixe)

**Coût estimé** : ~€15/mois pour t3.small (ou €0 avec Free Tier si t2.micro)

---

## ✅ Prérequis

Avant de commencer, assurez-vous d'avoir :

1. ✅ **Compte AWS** avec accès créé
2. ✅ **AWS CLI** installé et configuré (`aws configure`)
3. ✅ **Terraform** installé (version 1.0+)
4. ✅ **Clé SSH** créée dans AWS EC2 (Key Pairs)

### Vérification rapide

```bash
# AWS CLI configuré ?
aws sts get-caller-identity
# Devrait afficher votre Account ID

# Terraform installé ?
terraform --version
# Devrait afficher: Terraform v1.x.x

# Clé SSH existe ?
ls ~/.ssh/quantum-security-key.pem
# Devrait exister (ou le nom que vous avez choisi)
```

---

## 🚀 Déploiement en 5 Étapes

### Étape 1 : Obtenir votre IP publique

```bash
curl ifconfig.me
# Note: Sauvegardez cette IP, vous en aurez besoin
```

### Étape 2 : Configurer les variables

```bash
# Copier le template
cp terraform.tfvars.example terraform.tfvars

# Éditer avec votre IP
vim terraform.tfvars
# OU
nano terraform.tfvars
```

Remplacez `VOTRE_IP_ICI` par l'IP obtenue à l'étape 1 :

```hcl
my_ip = "1.2.3.4"  # Votre IP réelle
key_name = "quantum-security-key"  # Nom de votre clé SSH dans AWS
instance_type = "t3.small"  # ou "t2.micro" pour Free Tier
```

### Étape 3 : Initialiser Terraform

```bash
# Dans le dossier terraform/week1
terraform init
```

Vous devriez voir :
```
Terraform has been successfully initialized!
```

### Étape 4 : Vérifier le plan

```bash
terraform plan
```

Terraform va afficher ce qu'il va créer :
- 1 VPC
- 1 Internet Gateway
- 1 Subnet
- 1 Route Table
- 1 Security Group
- 1 EC2 Instance
- 1 Elastic IP

**Total : 8 ressources**

### Étape 5 : Déployer !

```bash
terraform apply
```

Terraform va demander confirmation :
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

Tapez `yes` et appuyez sur Entrée.

**Durée** : ~2-3 minutes

---

## 📊 Récupérer les Informations

Une fois le déploiement terminé, Terraform affiche :

```bash
Outputs:

instance_id = "i-0123456789abcdef0"
public_ip = "54.123.45.67"
private_ip = "10.0.1.123"
ssh_command = "ssh -i ~/.ssh/quantum-security-key.pem ubuntu@54.123.45.67"
```

Vous pouvez aussi les récupérer avec :

```bash
# IP publique
terraform output public_ip

# Commande SSH complète
terraform output ssh_command

# Toutes les infos
terraform output instance_info
```

---

## 🔌 Se Connecter à l'Instance

```bash
# Utiliser la commande affichée par Terraform
ssh -i ~/.ssh/quantum-security-key.pem ubuntu@<PUBLIC_IP>

# OU utiliser l'output Terraform
$(terraform output -raw ssh_command)
```

**Première connexion** :
```
The authenticity of host '54.123.45.67 (54.123.45.67)' can't be established.
...
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```

Tapez `yes`.

Vous devriez voir :
```
Welcome to Ubuntu 22.04.3 LTS
...
ubuntu@ip-10-0-1-123:~$
```

---

## ✅ Vérifications Post-Déploiement

```bash
# 1. Vérifier que user-data est terminé
ls -la ~/user-data-complete
# Devrait exister

# 2. Vérifier Docker
docker --version

# 3. Vérifier OpenSSL
openssl version

# 4. Voir les logs user-data (si problème)
sudo cat /var/log/user-data.log
```

---

## 🛠️ Installation Complète des Outils

Le user-data a installé Docker et les bases. Pour installer TOUT (liboqs, Python/Qiskit, etc.) :

```bash
# Sur l'instance EC2
cd ~
wget https://raw.githubusercontent.com/.../scripts/setup-aws-week1.sh
# OU copier depuis votre projet local

chmod +x setup-aws-week1.sh
./setup-aws-week1.sh
```

**Durée** : ~10-15 minutes (compilation liboqs)

Puis redémarrer session :
```bash
exit
ssh -i ~/.ssh/quantum-security-key.pem ubuntu@<PUBLIC_IP>
```

---

## 📝 Commandes Terraform Utiles

### Voir l'état actuel
```bash
terraform show
```

### Mettre à jour l'infrastructure
```bash
# Après modification de main.tf ou variables
terraform plan
terraform apply
```

### Détruire l'infrastructure
```bash
# ⚠️ ATTENTION : Supprime TOUT
terraform destroy

# Terraform demandera confirmation
# Tapez 'yes' pour confirmer
```

### Voir les outputs
```bash
terraform output
terraform output public_ip
terraform output -json instance_info
```

---

## 💰 Gestion des Coûts

### Voir les coûts estimés
Utilisez [Infracost](https://www.infracost.io/) (optionnel) :

```bash
brew install infracost  # macOS
infracost breakdown --path .
```

### Arrêter l'instance (économiser)
```bash
# Via AWS CLI
aws ec2 stop-instances --instance-ids $(terraform output -raw instance_id)

# Redémarrer
aws ec2 start-instances --instance-ids $(terraform output -raw instance_id)
```

**Note** : Vous payez toujours l'Elastic IP et le stockage, mais pas le compute.

### Détruire complètement (€0)
```bash
terraform destroy
```

---

## 🆘 Troubleshooting

### Erreur : "Error: creating EC2 Instance: InvalidKeyPair.NotFound"
**Cause** : La clé SSH n'existe pas dans AWS  
**Solution** :
```bash
# Créer la clé dans AWS
aws ec2 create-key-pair \
    --key-name quantum-security-key \
    --query 'KeyMaterial' \
    --output text > ~/.ssh/quantum-security-key.pem
chmod 400 ~/.ssh/quantum-security-key.pem
```

### Erreur : "Error: creating Security Group: InvalidParameterValue"
**Cause** : IP invalide dans terraform.tfvars  
**Solution** :
```bash
# Vérifier format IP
curl ifconfig.me
# Doit être "1.2.3.4" sans /32
```

### SSH refuse la connexion
**Cause** : Security Group ou IP changée  
**Solution** :
```bash
# Mettre à jour votre IP dans terraform.tfvars
my_ip = "NOUVELLE_IP"

# Appliquer
terraform apply
```

### Instance lente / pas de RAM
**Cause** : t2.micro insuffisant  
**Solution** :
```bash
# Dans terraform.tfvars, changer:
instance_type = "t3.small"

# Appliquer (détruira et recréera instance)
terraform apply
```

---

## 📚 Prochaines Étapes

Une fois l'instance déployée et configurée :

1. ✅ Cloner le projet Git
2. ✅ Commencer Lab 1.1 (Certificats X.509)
3. ✅ Documenter dans `docs/learning-notes/`
4. ✅ Faire snapshots AMI réguliers

### Créer un snapshot AMI

```bash
# Via CLI
aws ec2 create-image \
    --instance-id $(terraform output -raw instance_id) \
    --name "quantum-dev-week1-snapshot-$(date +%Y%m%d)" \
    --description "Snapshot après installation complète"
```

---

## 🔄 Semaine 2 et 3

Pour les semaines suivantes, nous ajouterons :
- **Semaine 2** : Instance SPIRE Server
- **Semaine 3** : K3s pour Kubernetes

Les configurations Terraform seront dans :
- `terraform/week2/`
- `terraform/week3/`

---

## 📞 Support

- Documentation Terraform AWS : https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- AWS Free Tier : https://aws.amazon.com/free/
- Terraform Getting Started : https://learn.hashicorp.com/terraform

**Questions ?** Consultez `docs/AWS_SETUP_PROGRESSIF.md` !

---

**Créé le** : 26 janvier 2026  
**Pour** : Quantum Security Project - Week 1  
**Coût** : ~€15/mois (t3.small)
