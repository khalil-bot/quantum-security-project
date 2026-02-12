# 🖥️ Setup VirtualBox - Guide Complet

## 📋 Prérequis

- VirtualBox 7.0+
- 16 GB RAM minimum sur machine hôte
- 100 GB espace disque disponible
- Ubuntu ISO 22.04 LTS

## 🚀 Installation VirtualBox

### Linux (Ubuntu/Debian)
```bash
# Ajouter le repository VirtualBox
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

# Installer
sudo apt update
sudo apt install virtualbox-7.0

# Extension Pack (pour USB, RDP, etc.)
wget https://download.virtualbox.org/virtualbox/7.0.14/Oracle_VM_VirtualBox_Extension_Pack-7.0.14.vbox-extpack
sudo vboxmanage extpack install Oracle_VM_VirtualBox_Extension_Pack-7.0.14.vbox-extpack
```

### macOS
```bash
# Avec Homebrew
brew install --cask virtualbox
brew install --cask virtualbox-extension-pack
```

### Windows
1. Télécharger depuis https://www.virtualbox.org/wiki/Downloads
2. Installer l'exécutable
3. Installer Extension Pack

## 🌐 Configuration Réseau

### Créer Réseau Host-Only
```bash
# Créer réseau host-only
vboxmanage hostonlyif create

# Configurer l'interface (généralement vboxnet0)
vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0

# Activer DHCP sur ce réseau
vboxmanage dhcpserver add --ifname vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0 --lowerip 192.168.56.100 --upperip 192.168.56.200
vboxmanage dhcpserver modify --ifname vboxnet0 --enable
```

## 📦 Création des VMs - Semaine 2 (SPIFFE/SPIRE)

### VM 1 : SPIRE Server

```bash
#!/bin/bash
# Script: create-spire-server-vm.sh

VM_NAME="spire-server"
ISO_PATH="/path/to/ubuntu-22.04-server-amd64.iso"

# Créer VM
vboxmanage createvm --name "$VM_NAME" --ostype Ubuntu_64 --register

# Configurer ressources
vboxmanage modifyvm "$VM_NAME" \
  --memory 2048 \
  --cpus 2 \
  --vram 16 \
  --nic1 hostonly --hostonlyadapter1 vboxnet0 \
  --nic2 nat \
  --boot1 dvd --boot2 disk --boot3 none --boot4 none

# Créer disque virtuel
vboxmanage createmedium disk \
  --filename "$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi" \
  --size 20480 \
  --format VDI

# Attacher disque
vboxmanage storagectl "$VM_NAME" --name "SATA Controller" --add sata --bootable on
vboxmanage storageattach "$VM_NAME" \
  --storagectl "SATA Controller" \
  --port 0 --device 0 --type hdd \
  --medium "$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"

# Attacher ISO
vboxmanage storagectl "$VM_NAME" --name "IDE Controller" --add ide
vboxmanage storageattach "$VM_NAME" \
  --storagectl "IDE Controller" \
  --port 0 --device 0 --type dvddrive \
  --medium "$ISO_PATH"

echo "VM $VM_NAME créée. Démarrez avec: vboxmanage startvm $VM_NAME"
```

### VM 2-3 : Workload Nodes

```bash
#!/bin/bash
# Script: create-workload-vm.sh

create_workload_vm() {
    VM_NAME=$1
    IP_LAST_OCTET=$2
    
    vboxmanage createvm --name "$VM_NAME" --ostype Ubuntu_64 --register
    
    vboxmanage modifyvm "$VM_NAME" \
      --memory 2048 \
      --cpus 2 \
      --nic1 hostonly --hostonlyadapter1 vboxnet0 \
      --nic2 nat
    
    vboxmanage createmedium disk \
      --filename "$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi" \
      --size 20480
    
    vboxmanage storagectl "$VM_NAME" --name "SATA Controller" --add sata
    vboxmanage storageattach "$VM_NAME" \
      --storagectl "SATA Controller" \
      --port 0 --device 0 --type hdd \
      --medium "$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"
    
    echo "VM $VM_NAME créée (IP: 192.168.56.$IP_LAST_OCTET)"
}

# Créer les VMs
create_workload_vm "workload-1" 11
create_workload_vm "workload-2" 12
```

## 🔧 Post-Installation Ubuntu (Toutes VMs)

### Configuration Initiale

```bash
# Dans chaque VM après installation Ubuntu

# 1. Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# 2. Installer outils essentiels
sudo apt install -y \
  curl wget git vim \
  net-tools openssh-server \
  build-essential

# 3. Configurer IP statique
sudo vim /etc/netplan/00-installer-config.yaml
```

#### Configuration Netplan pour SPIRE Server (192.168.56.10)
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:  # Host-only adapter
      addresses:
        - 192.168.56.10/24
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
    enp0s8:  # NAT adapter
      dhcp4: true
```

#### Configuration Netplan pour Workload 1 (192.168.56.11)
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      addresses:
        - 192.168.56.11/24
      gateway4: 192.168.56.1
      nameservers:
        addresses: [8.8.8.8]
    enp0s8:
      dhcp4: true
```

Appliquer :
```bash
sudo netplan apply
```

### Installation Docker (Toutes VMs)

```bash
#!/bin/bash
# install-docker.sh

# Désinstaller anciennes versions
sudo apt remove -y docker docker-engine docker.io containerd runc

# Installer dépendances
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Ajouter clé GPG Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Ajouter repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installer Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Ajouter user au groupe docker
sudo usermod -aG docker $USER

# Activer Docker au démarrage
sudo systemctl enable docker
sudo systemctl start docker

echo "Docker installé. Déconnectez-vous et reconnectez-vous pour utiliser docker sans sudo."
```

## 📸 Snapshots

### Créer Snapshot après Installation

```bash
#!/bin/bash
# create-snapshot.sh

create_snapshot() {
    VM_NAME=$1
    SNAPSHOT_NAME="baseline-configured"
    
    vboxmanage snapshot "$VM_NAME" take "$SNAPSHOT_NAME" \
      --description "Ubuntu 22.04 + Docker + Network configured"
    
    echo "Snapshot créé pour $VM_NAME"
}

# Snapshots pour toutes les VMs
create_snapshot "spire-server"
create_snapshot "workload-1"
create_snapshot "workload-2"
```

### Restaurer Snapshot

```bash
# Lister snapshots
vboxmanage snapshot spire-server list

# Restaurer
vboxmanage snapshot spire-server restore "baseline-configured"

# Redémarrer VM
vboxmanage startvm spire-server --type headless
```

## 🔗 Test de Connectivité

### Script de Test
```bash
#!/bin/bash
# test-connectivity.sh

echo "=== Test Connectivité VMs ==="

# Depuis machine hôte
ping -c 2 192.168.56.10  # SPIRE Server
ping -c 2 192.168.56.11  # Workload 1
ping -c 2 192.168.56.12  # Workload 2

# SSH test
ssh -o ConnectTimeout=5 user@192.168.56.10 "echo 'SPIRE Server OK'"
ssh -o ConnectTimeout=5 user@192.168.56.11 "echo 'Workload 1 OK'"
ssh -o ConnectTimeout=5 user@192.168.56.12 "echo 'Workload 2 OK'"
```

## 📊 Configuration Finale

### Récapitulatif des VMs

| VM | Hostname | IP | RAM | CPU | Disque | Rôle |
|----|----------|-----|-----|-----|--------|------|
| spire-server | spire-server | 192.168.56.10 | 2GB | 2 | 20GB | SPIRE Server |
| workload-1 | workload-1 | 192.168.56.11 | 2GB | 2 | 20GB | Backend Service |
| workload-2 | workload-2 | 192.168.56.12 | 2GB | 2 | 20GB | Frontend Service |

### Table de Routage

```
Machine Hôte (192.168.56.1)
    │
    ├── vboxnet0 (Host-Only Network: 192.168.56.0/24)
    │   ├── SPIRE Server (192.168.56.10)
    │   ├── Workload 1 (192.168.56.11)
    │   └── Workload 2 (192.168.56.12)
    │
    └── Toutes VMs ont aussi accès NAT pour Internet
```

## 🚀 Démarrage Rapide

### Script de Gestion Global

```bash
#!/bin/bash
# vbox-manager.sh

ACTION=$1

start_all() {
    echo "Démarrage de toutes les VMs..."
    vboxmanage startvm spire-server --type headless
    sleep 30
    vboxmanage startvm workload-1 --type headless
    vboxmanage startvm workload-2 --type headless
    echo "Toutes les VMs démarrées"
}

stop_all() {
    echo "Arrêt de toutes les VMs..."
    vboxmanage controlvm workload-2 acpipowerbutton
    vboxmanage controlvm workload-1 acpipowerbutton
    sleep 10
    vboxmanage controlvm spire-server acpipowerbutton
    echo "Toutes les VMs arrêtées"
}

status_all() {
    echo "=== Status des VMs ==="
    vboxmanage list runningvms
}

case $ACTION in
    start)
        start_all
        ;;
    stop)
        stop_all
        ;;
    status)
        status_all
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac
```

Utilisation :
```bash
chmod +x vbox-manager.sh
./vbox-manager.sh start   # Démarrer toutes VMs
./vbox-manager.sh status  # Voir status
./vbox-manager.sh stop    # Arrêter toutes VMs
```

## 💾 Export/Import VMs

### Exporter VM
```bash
# Exporter une VM en OVA
vboxmanage export spire-server \
  --output spire-server.ova \
  --manifest \
  --description "SPIRE Server configured"
```

### Importer VM
```bash
# Importer une VM
vboxmanage import spire-server.ova
```

## 🔧 Troubleshooting

### VM ne démarre pas
```bash
# Vérifier les logs
vboxmanage showvminfo spire-server --log 0

# Réinitialiser VM
vboxmanage controlvm spire-server poweroff
vboxmanage startvm spire-server
```

### Problème réseau
```bash
# Vérifier configuration réseau
vboxmanage showvminfo spire-server | grep NIC

# Re-créer réseau host-only
vboxmanage hostonlyif remove vboxnet0
vboxmanage hostonlyif create
# Puis reconfigurer (voir section Configuration Réseau)
```

### Accès SSH refusé
```bash
# Dans la VM
sudo systemctl status ssh
sudo systemctl restart ssh

# Vérifier firewall
sudo ufw status
sudo ufw allow 22
```

## 📝 Checklist Setup Complet

- [ ] VirtualBox installé
- [ ] Extension Pack installé
- [ ] Réseau host-only créé (vboxnet0)
- [ ] VM spire-server créée
- [ ] VM workload-1 créée
- [ ] VM workload-2 créée
- [ ] Ubuntu installé sur toutes VMs
- [ ] IPs statiques configurées
- [ ] Docker installé sur toutes VMs
- [ ] SSH activé sur toutes VMs
- [ ] Snapshots baseline créés
- [ ] Test connectivité réussi

## 🎯 Prochaine Étape

Une fois ce setup terminé, passez à :
- `labs/spiffe-spire/LAB-2.2-Installation.md` pour installer SPIRE

---

**Temps estimé** : 2-3 heures  
**Difficulté** : ⭐⭐⭐/5
