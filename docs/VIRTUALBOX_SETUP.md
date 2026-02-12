# 🖥️ Guide de Setup VirtualBox - Pas à Pas

## 🎯 Vue d'Ensemble

Ce guide vous permet de créer votre environnement de lab en 3 phases :
- **Phase 1 (Semaine 1)** : 1 VM Control Plane
- **Phase 2 (Semaine 2)** : +2 VMs Workers
- **Phase 3 (Semaine 3)** : Kubernetes sur les 3 VMs

## ✅ Prérequis

### Vérifier Votre Machine

```bash
# Linux/Mac
cat /proc/cpuinfo | grep processor | wc -l  # Nombre de cores
free -h                                      # RAM disponible
df -h                                        # Espace disque

# Windows (PowerShell)
Get-WmiObject Win32_Processor | Select NumberOfCores, NumberOfLogicalProcessors
Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum
Get-PSDrive
```

**Configuration Minimum** :
- ✅ 8 CPU cores
- ✅ 16 GB RAM
- ✅ 100 GB SSD libre
- ✅ Virtualisation activée dans BIOS

**Configuration Recommandée** :
- ⭐ 12+ CPU cores
- ⭐ 24-32 GB RAM
- ⭐ 200 GB SSD/NVMe
- ⭐ Virtualisation VT-x/AMD-V

### Activer la Virtualisation (si nécessaire)

#### Windows (Hyper-V doit être désactivé)
```powershell
# Vérifier si Hyper-V est actif
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V

# Si actif, désactiver (redémarrage requis)
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

#### BIOS/UEFI
1. Redémarrer et entrer dans BIOS (F2, Del, F10 selon fabricant)
2. Chercher "Intel VT-x" ou "AMD-V" ou "Virtualization Technology"
3. Activer
4. Sauvegarder et redémarrer

---

## 📥 Phase 0 : Installation VirtualBox

### Téléchargement

**VirtualBox** : https://www.virtualbox.org/wiki/Downloads
- Version recommandée : **7.0+**
- Extension Pack : **Télécharger aussi**

**Ubuntu ISO** : https://ubuntu.com/download/server
- Version : **Ubuntu 24.04 LTS Server**
- Fichier : `ubuntu-24.04-live-server-amd64.iso` (~2.5 GB)

### Installation VirtualBox

#### Windows
```
1. Exécuter VirtualBox-7.0.x-Win.exe
2. Next → Next → Install
3. Installer Oracle VM VirtualBox Extension Pack
```

#### macOS
```bash
# Via Homebrew (recommandé)
brew install --cask virtualbox
brew install --cask virtualbox-extension-pack
```

#### Linux (Ubuntu/Debian)
```bash
# Ajouter le dépôt Oracle
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

# Installer
sudo apt update
sudo apt install virtualbox-7.0

# Extension Pack
wget https://download.virtualbox.org/virtualbox/7.0.14/Oracle_VM_VirtualBox_Extension_Pack-7.0.14.vbox-extpack
sudo VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-7.0.14.vbox-extpack
```

### Vérification Installation

```bash
VBoxManage --version
# Sortie attendue : 7.0.x...
```

---

## 🖥️ Phase 1 : VM Control Plane (Semaine 1)

### Étape 1.1 : Créer la VM

```bash
# Via ligne de commande (optionnel, sinon GUI)
VBoxManage createvm --name "quantum-control-plane" --ostype Ubuntu_64 --register

# Configurer ressources
VBoxManage modifyvm "quantum-control-plane" \
    --cpus 4 \
    --memory 8192 \
    --vram 16 \
    --nic1 nat \
    --nic2 hostonly \
    --hostonlyadapter2 "vboxnet0" \
    --boot1 dvd \
    --boot2 disk \
    --boot3 none \
    --boot4 none \
    --audio none \
    --clipboard bidirectional

# Créer disque virtuel (40 GB)
VBoxManage createhd --filename ~/VirtualBox\ VMs/quantum-control-plane/quantum-control-plane.vdi --size 40960 --format VDI

# Attacher disque
VBoxManage storagectl "quantum-control-plane" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "quantum-control-plane" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium ~/VirtualBox\ VMs/quantum-control-plane/quantum-control-plane.vdi

# Attacher ISO Ubuntu
VBoxManage storagectl "quantum-control-plane" --name "IDE Controller" --add ide
VBoxManage storageattach "quantum-control-plane" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium ~/Downloads/ubuntu-24.04-live-server-amd64.iso
```

### Étape 1.2 : Installation Ubuntu (Via GUI)

1. **Démarrer la VM**
   ```bash
   VBoxManage startvm "quantum-control-plane"
   ```

2. **Installation Ubuntu**
   - Langue : English
   - Keyboard : Français (ou votre layout)
   - Installation type : Ubuntu Server (minimized)
   - Network : 
     - enp0s3 (NAT) : DHCP auto
     - enp0s8 (Host-only) : 192.168.56.10/24
   - Storage : Use entire disk (40 GB)
   - Profile :
     - Name : `quantum`
     - Server name : `control-plane`
     - Username : `quantum`
     - Password : `[mot de passe fort]`
   - SSH : ☑ Install OpenSSH server
   - Snaps : Aucun (pour l'instant)

3. **Premier boot**
   ```bash
   # Se connecter
   Username: quantum
   Password: [votre mot de passe]
   
   # Update système
   sudo apt update && sudo apt upgrade -y
   
   # Installer essentiels
   sudo apt install -y \
       build-essential \
       git \
       curl \
       wget \
       vim \
       net-tools \
       openssh-server \
       ca-certificates
   ```

### Étape 1.3 : Configuration Réseau

#### Créer Network Host-Only (si pas existant)

```bash
# Lister réseaux existants
VBoxManage list hostonlyifs

# Si vboxnet0 n'existe pas, créer
VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0

# Activer DHCP (optionnel)
VBoxManage dhcpserver add --ifname vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0 --lowerip 192.168.56.100 --upperip 192.168.56.200
VBoxManage dhcpserver modify --ifname vboxnet0 --enable
```

#### Configuration IP Statique sur VM

```bash
# Sur la VM Control Plane
sudo vim /etc/netplan/00-installer-config.yaml
```

Contenu :
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:  # NAT - Internet
      dhcp4: true
    enp0s8:  # Host-Only - Inter-VM
      dhcp4: no
      addresses:
        - 192.168.56.10/24
```

Appliquer :
```bash
sudo netplan apply
ip a  # Vérifier IPs
```

### Étape 1.4 : SSH depuis Machine Hôte

```bash
# Depuis votre machine hôte
ssh quantum@192.168.56.10

# Copier votre clé SSH (recommandé)
ssh-copy-id quantum@192.168.56.10

# Se connecter sans mot de passe
ssh quantum@192.168.56.10
```

### Étape 1.5 : Installation Outils Crypto (Semaine 1)

```bash
# Sur la VM
# OpenSSL (déjà présent, vérifier version)
openssl version
# OpenSSL 3.0.x attendu

# Git configuration
git config --global user.name "Quantum Security"
git config --global user.email "quantum@lab.local"

# Docker (pour plus tard)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker quantum
newgrp docker
docker --version

# Python et pip
sudo apt install -y python3 python3-pip python3-venv
python3 --version  # 3.12.x attendu

# Cloner votre projet
git clone [URL_DE_VOTRE_REPO]
cd quantum-security-project
```

### Étape 1.6 : Snapshot Sécurité

```bash
# Depuis machine hôte
VBoxManage snapshot "quantum-control-plane" take "base-install-clean" --description "Ubuntu 24.04 + SSH + Docker"

# Lister snapshots
VBoxManage snapshot "quantum-control-plane" list
```

**✅ Semaine 1 complète** : Vous pouvez maintenant faire les Labs 1.1 à 1.5 sur cette VM !

---

## 🖥️ Phase 2 : VMs Workers (Semaine 2)

### Étape 2.1 : Cloner Control Plane

Au lieu de réinstaller Ubuntu, on clone :

```bash
# Arrêter Control Plane
VBoxManage controlvm "quantum-control-plane" poweroff

# Cloner pour Worker 1
VBoxManage clonevm "quantum-control-plane" \
    --name "quantum-worker-1" \
    --register \
    --snapshot "base-install-clean" \
    --options link

# Cloner pour Worker 2
VBoxManage clonevm "quantum-control-plane" \
    --name "quantum-worker-2" \
    --register \
    --snapshot "base-install-clean" \
    --options link

# Redémarrer Control Plane
VBoxManage startvm "quantum-control-plane" --type headless
```

### Étape 2.2 : Configurer Workers

#### Worker 1
```bash
# Démarrer
VBoxManage startvm "quantum-worker-1"

# Se connecter
ssh quantum@192.168.56.10  # Temporairement même IP

# Changer hostname
sudo hostnamectl set-hostname worker-1

# Changer IP
sudo vim /etc/netplan/00-installer-config.yaml
# Mettre : 192.168.56.11/24

sudo netplan apply

# Regénérer machine-id (important!)
sudo rm -f /etc/machine-id
sudo systemd-machine-id-setup

# Redémarrer
sudo reboot
```

#### Worker 2
```bash
# Même processus
VBoxManage startvm "quantum-worker-2"
ssh quantum@[IP-temporaire]

sudo hostnamectl set-hostname worker-2
# IP : 192.168.56.12/24
sudo netplan apply
sudo rm -f /etc/machine-id
sudo systemd-machine-id-setup
sudo reboot
```

### Étape 2.3 : Fichier Hosts

Sur **chaque VM** :
```bash
sudo vim /etc/hosts
```

Ajouter :
```
192.168.56.10   control-plane   control-plane.quantum.lab
192.168.56.11   worker-1        worker-1.quantum.lab
192.168.56.12   worker-2        worker-2.quantum.lab
```

Tester :
```bash
ping -c 2 control-plane
ping -c 2 worker-1
ping -c 2 worker-2
```

### Étape 2.4 : SSH Keys entre VMs

```bash
# Sur Control Plane
ssh-keygen -t ed25519 -C "control-plane@quantum.lab"

# Copier vers Workers
ssh-copy-id quantum@worker-1
ssh-copy-id quantum@worker-2

# Tester
ssh quantum@worker-1 'hostname'
ssh quantum@worker-2 'hostname'
```

**✅ Semaine 2 complète** : 3 VMs prêtes pour SPIFFE/SPIRE !

---

## 🚢 Phase 3 : Kubernetes k3s (Semaine 3)

### Étape 3.1 : Installation k3s Control Plane

```bash
# Sur control-plane
curl -sfL https://get.k3s.io | sh -s - server \
    --disable traefik \
    --disable servicelb \
    --node-name control-plane \
    --bind-address 192.168.56.10

# Vérifier
sudo k3s kubectl get nodes
# control-plane   Ready   control-plane,master   1m   v1.28.x
```

### Étape 3.2 : Récupérer Token

```bash
# Sur control-plane
sudo cat /var/lib/rancher/k3s/server/node-token
# Noter le token : K10xxx...
```

### Étape 3.3 : Joindre Workers

```bash
# Sur worker-1
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.10:6443 \
    K3S_TOKEN="[TOKEN_ICI]" \
    sh -s - agent --node-name worker-1

# Sur worker-2
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.10:6443 \
    K3S_TOKEN="[TOKEN_ICI]" \
    sh -s - agent --node-name worker-2
```

### Étape 3.4 : Vérifier Cluster

```bash
# Sur control-plane
sudo k3s kubectl get nodes
# NAME            STATUS   ROLES                  AGE   VERSION
# control-plane   Ready    control-plane,master   5m    v1.28.x
# worker-1        Ready    <none>                 2m    v1.28.x
# worker-2        Ready    <none>                 1m    v1.28.x

# Configurer kubectl local (sans sudo)
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown quantum:quantum ~/.kube/config
export KUBECONFIG=~/.kube/config

kubectl get nodes
```

**✅ Semaine 3 complète** : Cluster Kubernetes prêt pour SPIFFE/SPIRE !

---

## 🔧 Commandes Utiles

### Gestion VMs

```bash
# Lister toutes les VMs
VBoxManage list vms

# Démarrer
VBoxManage startvm "quantum-control-plane" --type headless
# Headless = sans GUI, en arrière-plan

# Arrêt propre
VBoxManage controlvm "quantum-control-plane" acpipowerbutton

# Arrêt forcé (éviter si possible)
VBoxManage controlvm "quantum-control-plane" poweroff

# Pause
VBoxManage controlvm "quantum-control-plane" pause

# Resume
VBoxManage controlvm "quantum-control-plane" resume

# État
VBoxManage showvminfo "quantum-control-plane" | grep State
```

### Snapshots

```bash
# Créer snapshot
VBoxManage snapshot "quantum-control-plane" take "semaine1-complete"

# Lister
VBoxManage snapshot "quantum-control-plane" list

# Restaurer
VBoxManage snapshot "quantum-control-plane" restore "semaine1-complete"

# Supprimer
VBoxManage snapshot "quantum-control-plane" delete "old-snapshot"
```

### Réseau

```bash
# Port forwarding (accès SSH via localhost)
VBoxManage modifyvm "quantum-control-plane" --natpf1 "ssh,tcp,,2222,,22"
# Puis : ssh -p 2222 quantum@localhost

# Supprimer port forwarding
VBoxManage modifyvm "quantum-control-plane" --natpf1 delete ssh
```

---

## 🆘 Troubleshooting

### VM ne démarre pas

```bash
# Vérifier logs
VBoxManage showvminfo "quantum-control-plane" | grep -i error

# Vérifier état
VBoxManage list runningvms
VBoxManage list vms
```

### Pas d'accès réseau

```bash
# Sur VM, vérifier interfaces
ip a
ip route

# Vérifier Host-Only network
VBoxManage list hostonlyifs

# Recréer si nécessaire
VBoxManage hostonlyif remove vboxnet0
VBoxManage hostonlyif create
```

### Performance lente

```bash
# Augmenter RAM (VM éteinte)
VBoxManage modifyvm "quantum-control-plane" --memory 12288

# Augmenter CPUs
VBoxManage modifyvm "quantum-control-plane" --cpus 6

# Activer nested virtualization (pour KVM)
VBoxManage modifyvm "quantum-control-plane" --nested-hw-virt on
```

### Disque plein

```bash
# Sur VM
sudo apt clean
docker system prune -a
sudo journalctl --vacuum-time=3d

# Étendre disque (VM éteinte)
VBoxManage modifyhd ~/VirtualBox\ VMs/quantum-control-plane/quantum-control-plane.vdi --resize 60000
# Puis dans VM : utiliser gparted ou parted pour étendre partition
```

---

## 📋 Checklist Validation

### Semaine 1
- [ ] VirtualBox 7.0+ installé
- [ ] Ubuntu 24.04 sur control-plane
- [ ] SSH fonctionnel depuis hôte
- [ ] Docker installé
- [ ] OpenSSL 3.x disponible
- [ ] Snapshot "base-install-clean" créé

### Semaine 2
- [ ] Worker-1 cloné et configuré (192.168.56.11)
- [ ] Worker-2 cloné et configuré (192.168.56.12)
- [ ] /etc/hosts configuré sur les 3 VMs
- [ ] SSH entre VMs sans mot de passe
- [ ] Ping entre toutes les VMs OK

### Semaine 3
- [ ] k3s installé sur control-plane
- [ ] Workers joints au cluster
- [ ] `kubectl get nodes` montre 3 nodes Ready
- [ ] Kubectl configuré sans sudo

---

## 📊 Résumé Configuration

| VM | Hostname | IP | vCPU | RAM | Disk | Rôle |
|----|----------|-------|------|-----|------|------|
| 1 | control-plane | 192.168.56.10 | 4 | 8 GB | 40 GB | SPIRE Server, K8s Master |
| 2 | worker-1 | 192.168.56.11 | 2 | 4 GB | 30 GB | SPIRE Agent, Workloads |
| 3 | worker-2 | 192.168.56.12 | 2 | 4 GB | 30 GB | SPIRE Agent, Workloads |

**Total** : 8 vCPU, 16 GB RAM, 100 GB Disk

---

Félicitations ! Votre infrastructure VirtualBox est maintenant prête pour les 3 semaines de labs ! 🎉
