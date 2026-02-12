# 🏗️ Architecture Infrastructure VirtualBox

## 📐 Architecture Globale

```
┌─────────────────────────────────────────────────────────────────────┐
│                        HOST MACHINE (Votre Laptop)                   │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                    VirtualBox Network                          │ │
│  │                  NAT Network: 10.0.0.0/24                     │ │
│  │                                                                │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │ │
│  │  │   VM1        │  │   VM2        │  │   VM3        │       │ │
│  │  │   SPIRE      │  │   Backend    │  │   Frontend   │       │ │
│  │  │   Server     │  │   Service    │  │   Service    │       │ │
│  │  │              │  │              │  │              │       │ │
│  │  │ 10.0.0.10   │  │ 10.0.0.20   │  │ 10.0.0.30   │       │ │
│  │  │              │  │              │  │              │       │ │
│  │  │ - SPIRE      │  │ - SPIRE      │  │ - SPIRE      │       │ │
│  │  │   Server     │  │   Agent      │  │   Agent      │       │ │
│  │  │              │  │ - App + TLS  │  │ - App + TLS  │       │ │
│  │  │              │  │ - liboqs     │  │ - liboqs     │       │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘       │ │
│  │                                                                │ │
│  │  ┌──────────────────────────────────────────────────────┐    │ │
│  │  │          Optional: VM4 - Kubernetes (k3s)            │    │ │
│  │  │                  10.0.0.40                           │    │ │
│  │  │          (Pour tests Kubernetes + SPIFFE)            │    │ │
│  │  └──────────────────────────────────────────────────────┘    │ │
│  │                                                                │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## 🖥️ Spécifications des VMs

### VM1 : SPIRE Server (Control Plane)
```yaml
Nom: spire-server
OS: Ubuntu 22.04 LTS
CPU: 2 cores
RAM: 2 GB
Disk: 20 GB
IP: 10.0.0.10
Ports: 8081 (SPIRE API)

Services:
  - SPIRE Server
  - PostgreSQL (pour SPIRE datastore)
  - Nginx (pour reverse proxy/TLS)
```

### VM2 : Backend Service (Workload 1)
```yaml
Nom: backend-service
OS: Ubuntu 22.04 LTS
CPU: 2 cores
RAM: 2 GB
Disk: 20 GB
IP: 10.0.0.20
Ports: 8443 (HTTPS avec mTLS)

Services:
  - SPIRE Agent
  - Application backend (Python/Go)
  - liboqs (Post-Quantum Crypto)
  - Workload avec SVID
```

### VM3 : Frontend Service (Workload 2)
```yaml
Nom: frontend-service
OS: Ubuntu 22.04 LTS
CPU: 2 cores
RAM: 2 GB
Disk: 20 GB
IP: 10.0.0.30
Ports: 8444 (HTTPS avec mTLS)

Services:
  - SPIRE Agent
  - Application frontend (Python/Go)
  - liboqs (Post-Quantum Crypto)
  - Workload avec SVID
```

### VM4 : Kubernetes (Optional - Semaine 3)
```yaml
Nom: k3s-cluster
OS: Ubuntu 22.04 LTS
CPU: 4 cores
RAM: 4 GB
Disk: 30 GB
IP: 10.0.0.40

Services:
  - k3s (Lightweight Kubernetes)
  - SPIFFE CSI Driver
  - Sample microservices
```

## 📊 Ressources Requises sur Host

### Configuration Minimale (VM1 + VM2 + VM3)
```
CPU: 6 cores (peut partager)
RAM: 6 GB alloués (8GB+ recommandé sur host)
Disk: 60 GB d'espace libre
Network: Connexion internet pour installations
```

### Configuration Recommandée (avec VM4)
```
CPU: 10 cores (ou 6 cores partagés)
RAM: 10 GB alloués (16GB+ recommandé sur host)
Disk: 90 GB d'espace libre
```

### Configuration Optimale
```
CPU: 12+ cores
RAM: 16 GB alloués (32GB sur host)
Disk: 120 GB SSD
```

## 🔧 Configuration Réseau VirtualBox

### NAT Network Setup
```bash
# Créer le réseau NAT
VBoxManage natnetwork add --netname quantum-net --network "10.0.0.0/24" --enable --dhcp off

# Port forwarding pour accès depuis host
VBoxManage natnetwork modify --netname quantum-net \
  --port-forward-4 "spire:tcp:[127.0.0.1]:8081:[10.0.0.10]:8081" \
  --port-forward-4 "backend:tcp:[127.0.0.1]:8443:[10.0.0.20]:8443" \
  --port-forward-4 "frontend:tcp:[127.0.0.1]:8444:[10.0.0.30]:8444"
```

### Accès depuis Host
```bash
# SPIRE Server API
curl https://localhost:8081

# Backend Service
curl https://localhost:8443

# Frontend Service
curl https://localhost:8444
```

## 📦 Stack Logicielle par VM

### VM1 - SPIRE Server
```bash
# Base
- Ubuntu 22.04
- OpenSSL 3.x
- PostgreSQL 14

# SPIFFE/SPIRE
- SPIRE Server 1.8+
- spire-server.conf

# Monitoring (Optional)
- Prometheus exporter
- Grafana
```

### VM2 & VM3 - Workloads
```bash
# Base
- Ubuntu 22.04
- OpenSSL 3.x
- Docker (optional)

# SPIFFE
- SPIRE Agent 1.8+
- SPIFFE Workload API

# Crypto
- liboqs (Post-Quantum)
- ML-KEM-768, ML-DSA-65

# Application
- Python 3.10+ ou Go 1.21+
- Simple web service avec mTLS
```

## 🚀 Déploiement Pas-à-Pas

### Phase 1 : Création des VMs (30 min)

```bash
# 1. Télécharger Ubuntu 22.04 ISO
wget https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso

# 2. Créer VM1 - SPIRE Server
VBoxManage createvm --name "spire-server" --ostype Ubuntu_64 --register
VBoxManage modifyvm "spire-server" --memory 2048 --cpus 2
VBoxManage modifyvm "spire-server" --nic1 natnetwork --nat-network1 "quantum-net"
VBoxManage createhd --filename "spire-server.vdi" --size 20480
VBoxManage storagectl "spire-server" --name "SATA" --add sata --controller IntelAhci
VBoxManage storageattach "spire-server" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "spire-server.vdi"

# 3. Répéter pour VM2 et VM3
# (voir script automation plus bas)
```

### Phase 2 : Installation OS (1h)

```bash
# Pour chaque VM:
1. Booter sur ISO Ubuntu
2. Installation standard
3. Configurer IP statique
4. Installer openssh-server
5. Créer snapshot "base-install"
```

### Phase 3 : Configuration SPIRE (2h)

**VM1 - SPIRE Server:**
```bash
# Installation
wget https://github.com/spiffe/spire/releases/download/v1.8.0/spire-1.8.0-linux-amd64-musl.tar.gz
tar xvf spire-1.8.0-linux-amd64-musl.tar.gz
sudo cp -r spire-1.8.0/bin/* /opt/spire/bin/
sudo cp -r spire-1.8.0/conf/server/* /opt/spire/conf/

# Configuration
sudo vim /opt/spire/conf/server.conf
# (voir fichier de config détaillé)

# Démarrage
sudo systemctl enable spire-server
sudo systemctl start spire-server
```

**VM2 & VM3 - SPIRE Agents:**
```bash
# Installation similaire
# Configuration agent.conf
# Enregistrement avec SPIRE Server
# Démarrage agent
```

### Phase 4 : Tests Crypto (1-2h)

```bash
# Installer liboqs sur VM2 et VM3
# Générer clés post-quantiques
# Tester mTLS avec SPIFFE + PQC
```

## 🤖 Automatisation avec Vagrant

### Vagrantfile Complet
```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  
  # SPIRE Server
  config.vm.define "spire-server" do |server|
    server.vm.hostname = "spire-server"
    server.vm.network "private_network", ip: "10.0.0.10"
    server.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
      vb.name = "spire-server"
    end
    server.vm.provision "shell", path: "scripts/setup-spire-server.sh"
  end
  
  # Backend Service
  config.vm.define "backend" do |backend|
    backend.vm.hostname = "backend-service"
    backend.vm.network "private_network", ip: "10.0.0.20"
    backend.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
      vb.name = "backend-service"
    end
    backend.vm.provision "shell", path: "scripts/setup-workload.sh"
  end
  
  # Frontend Service
  config.vm.define "frontend" do |frontend|
    frontend.vm.hostname = "frontend-service"
    frontend.vm.network "private_network", ip: "10.0.0.30"
    frontend.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
      vb.name = "frontend-service"
    end
    frontend.vm.provision "shell", path: "scripts/setup-workload.sh"
  end
  
  # Optional: Kubernetes
  config.vm.define "k3s", autostart: false do |k3s|
    k3s.vm.hostname = "k3s-cluster"
    k3s.vm.network "private_network", ip: "10.0.0.40"
    k3s.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 4
      vb.name = "k3s-cluster"
    end
    k3s.vm.provision "shell", path: "scripts/setup-k3s.sh"
  end
end
```

### Commandes Vagrant
```bash
# Démarrer toutes les VMs
vagrant up

# Démarrer uniquement SPIRE server et backend
vagrant up spire-server backend

# SSH dans une VM
vagrant ssh spire-server

# Arrêter toutes les VMs
vagrant halt

# Détruire et recréer
vagrant destroy -f
vagrant up

# Créer snapshot
vagrant snapshot save baseline

# Restaurer snapshot
vagrant snapshot restore baseline
```

## 📋 Checklist Déploiement

### Préparation
- [ ] VirtualBox 7.x installé
- [ ] Vagrant installé (optionnel)
- [ ] 16GB+ RAM disponible
- [ ] 100GB+ espace disque
- [ ] ISO Ubuntu 22.04 téléchargé

### VM1 - SPIRE Server
- [ ] VM créée avec specs correctes
- [ ] Ubuntu installé
- [ ] IP statique configurée (10.0.0.10)
- [ ] SSH fonctionnel
- [ ] SPIRE Server installé
- [ ] Base de données PostgreSQL
- [ ] SPIRE Server running

### VM2 - Backend
- [ ] VM créée
- [ ] Ubuntu installé
- [ ] IP statique (10.0.0.20)
- [ ] SPIRE Agent installé
- [ ] liboqs installé
- [ ] Workload enregistré dans SPIRE
- [ ] mTLS fonctionnel

### VM3 - Frontend
- [ ] VM créée
- [ ] Ubuntu installé
- [ ] IP statique (10.0.0.30)
- [ ] SPIRE Agent installé
- [ ] liboqs installé
- [ ] Workload enregistré dans SPIRE
- [ ] Communication avec Backend OK

### Tests
- [ ] Ping entre toutes les VMs
- [ ] SPIRE Server API accessible
- [ ] SVIDs générés pour workloads
- [ ] mTLS entre frontend et backend
- [ ] Rotation automatique des certificats
- [ ] Tests PQC (ML-KEM, ML-DSA)

## 💾 Gestion des Snapshots

### Stratégie de Snapshots
```bash
# 1. Après installation OS propre
Snapshot: "01-base-ubuntu"

# 2. Après installation SPIRE
Snapshot: "02-spire-installed"

# 3. Après configuration complète
Snapshot: "03-fully-configured"

# 4. Avant chaque lab destructif
Snapshot: "04-before-lab-X"
```

### Commandes VirtualBox
```bash
# Créer snapshot
VBoxManage snapshot spire-server take "base-install"

# Lister snapshots
VBoxManage snapshot spire-server list

# Restaurer snapshot
VBoxManage snapshot spire-server restore "base-install"

# Supprimer snapshot
VBoxManage snapshot spire-server delete "base-install"
```

## 🔍 Monitoring et Debugging

### Accès Console
```bash
# Via VirtualBox GUI
# Ou via SSH depuis host:
ssh -p 2222 user@localhost  # (avec port forwarding)
```

### Logs Importants
```bash
# SPIRE Server
tail -f /var/log/spire/server.log

# SPIRE Agent
tail -f /var/log/spire/agent.log

# Application logs
journalctl -u app-service -f
```

### Tests Réseau
```bash
# Depuis VM1
ping 10.0.0.20
ping 10.0.0.30

# Test SPIRE API
curl http://localhost:8081/healthcheck

# Test mTLS
openssl s_client -connect 10.0.0.20:8443 -cert client.pem -key client.key
```

## 🎯 Avantages de cette Architecture

✅ **Isolation complète** : Chaque service dans sa VM  
✅ **Contrôle total** : Accès root sur tout  
✅ **Snapshots** : Retour arrière facile  
✅ **Gratuit** : Aucun coût  
✅ **Portable** : Vagrant = reproduisible  
✅ **Évolutif** : Ajouter VM4 pour Kubernetes facilement  
✅ **Réaliste** : Architecture multi-node production-like  

## 📚 Prochaines Étapes

1. Décider : Vagrant (automatisé) ou Manuel
2. Créer les VMs
3. Suivre le guide de déploiement
4. Tester la connectivité
5. Installer SPIRE
6. Commencer les labs !

---

**Temps total setup** : 4-6 heures  
**Difficulté** : ⭐⭐⭐/5  
**Prérequis** : VirtualBox, 16GB RAM
