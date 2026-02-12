# 🏛️ Architecture Production Zero-Trust avec Post-Quantum Cryptography

## 🎯 Vision et Objectifs

### Objectif Principal
Construire une infrastructure **production-ready** intégrant :
- **Zero-Trust Architecture** complète (NIST SP 800-207)
- **Post-Quantum Cryptography** (ML-KEM, ML-DSA) 
- **SPIFFE/SPIRE** pour l'identité workload
- **Haute disponibilité** (Multi-AZ)
- **Sécurité en profondeur**
- **Observabilité complète**

### Principes Directeurs
1. **Never Trust, Always Verify** - Aucune confiance implicite
2. **Least Privilege** - Permissions minimales
3. **Defense in Depth** - Sécurité à chaque niveau
4. **Crypto-Agility** - Capacité à migrer les algorithmes
5. **Zero Standing Privileges** - Pas d'accès permanent
6. **Assume Breach** - Préparer la compromission

---

## 📐 Architecture Globale

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           AWS CLOUD (eu-west-1)                          │
│                                                                           │
│  ┌─────────────────────────── VPC (10.0.0.0/16) ──────────────────────┐ │
│  │                                                                      │ │
│  │  ┌───────── PUBLIC SUBNETS ─────────┐                              │ │
│  │  │  AZ-A: 10.0.1.0/24              │                              │ │
│  │  │  AZ-B: 10.0.2.0/24              │                              │ │
│  │  │  AZ-C: 10.0.3.0/24              │                              │ │
│  │  │                                   │                              │ │
│  │  │  ┌──────────────────────┐        │                              │ │
│  │  │  │  Application LB      │        │                              │ │
│  │  │  │  (TLS 1.3 + PQC)    │◄───────┼──── Internet                │ │
│  │  │  └──────────────────────┘        │                              │ │
│  │  │           │                       │                              │ │
│  │  │  ┌────────▼──────────┐           │                              │ │
│  │  │  │  NAT Gateways     │           │                              │ │
│  │  │  │  (HA - 3 AZs)     │           │                              │ │
│  │  │  └───────────────────┘           │                              │ │
│  │  └───────────────────────────────────┘                              │ │
│  │                                                                      │ │
│  │  ┌───────── PRIVATE SUBNETS (APP) ──────────┐                      │ │
│  │  │  AZ-A: 10.0.11.0/24                      │                      │ │
│  │  │  AZ-B: 10.0.12.0/24                      │                      │ │
│  │  │  AZ-C: 10.0.13.0/24                      │                      │ │
│  │  │                                            │                      │ │
│  │  │  ┌────────────────────────────────────┐  │                      │ │
│  │  │  │  EKS Cluster                       │  │                      │ │
│  │  │  │  ┌──────────────────────────────┐ │  │                      │ │
│  │  │  │  │  Workload Pods               │ │  │                      │ │
│  │  │  │  │  - SPIRE Agent (DaemonSet)   │ │  │                      │ │
│  │  │  │  │  - Service Mesh (mTLS)       │ │  │                      │ │
│  │  │  │  │  - PQC TLS termination       │ │  │                      │ │
│  │  │  │  └──────────────────────────────┘ │  │                      │ │
│  │  │  └────────────────────────────────────┘  │                      │ │
│  │  └────────────────────────────────────────────┘                      │ │
│  │                                                                      │ │
│  │  ┌───────── PRIVATE SUBNETS (DATA) ─────────┐                      │ │
│  │  │  AZ-A: 10.0.21.0/24                      │                      │ │
│  │  │  AZ-B: 10.0.22.0/24                      │                      │ │
│  │  │  AZ-C: 10.0.23.0/24                      │                      │ │
│  │  │                                            │                      │ │
│  │  │  ┌────────────────────────────────────┐  │                      │ │
│  │  │  │  SPIRE Server Cluster (HA)         │  │                      │ │
│  │  │  │  - 3 instances (1 per AZ)          │  │                      │ │
│  │  │  │  - PostgreSQL backend              │  │                      │ │
│  │  │  │  - PQC-protected communication     │  │                      │ │
│  │  │  └────────────────────────────────────┘  │                      │ │
│  │  │                                            │                      │ │
│  │  │  ┌────────────────────────────────────┐  │                      │ │
│  │  │  │  RDS PostgreSQL (Multi-AZ)         │  │                      │ │
│  │  │  │  - TDE enabled                     │  │                      │ │
│  │  │  │  - PQC key exchange                │  │                      │ │
│  │  │  └────────────────────────────────────┘  │                      │ │
│  │  └────────────────────────────────────────────┘                      │ │
│  │                                                                      │ │
│  │  ┌───────── PRIVATE SUBNETS (MGMT) ─────────┐                      │ │
│  │  │  AZ-A: 10.0.31.0/24                      │                      │ │
│  │  │  AZ-B: 10.0.32.0/24                      │                      │ │
│  │  │                                            │                      │ │
│  │  │  ┌────────────────────────────────────┐  │                      │ │
│  │  │  │  Bastion Host (SSM Session Mgr)    │  │                      │ │
│  │  │  │  - No public IP                    │  │                      │ │
│  │  │  │  - MFA required                    │  │                      │ │
│  │  │  └────────────────────────────────────┘  │                      │ │
│  │  │                                            │                      │ │
│  │  │  ┌────────────────────────────────────┐  │                      │ │
│  │  │  │  Monitoring Stack                  │  │                      │ │
│  │  │  │  - Prometheus                      │  │                      │ │
│  │  │  │  - Grafana                         │  │                      │ │
│  │  │  │  - ELK Stack                       │  │                      │ │
│  │  │  └────────────────────────────────────┘  │                      │ │
│  │  └────────────────────────────────────────────┘                      │ │
│  │                                                                      │ │
│  │  ┌──────── Security Services ────────┐                             │ │
│  │  │  • VPC Flow Logs                  │                             │ │
│  │  │  • GuardDuty                      │                             │ │
│  │  │  • Security Hub                   │                             │ │
│  │  │  • CloudTrail (all APIs)          │                             │ │
│  │  │  • Config Rules                   │                             │ │
│  │  │  • WAF (on ALB)                   │                             │ │
│  │  └───────────────────────────────────┘                             │ │
│  │                                                                      │ │
│  │  ┌──────── Crypto Services ──────────┐                             │ │
│  │  │  • AWS KMS (envelope encryption)  │                             │ │
│  │  │  • Secrets Manager                │                             │ │
│  │  │  • Certificate Manager (ACM)      │                             │ │
│  │  │  • Custom PQC CA                  │                             │ │
│  │  └───────────────────────────────────┘                             │ │
│  └──────────────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────────────┘
```

---

## 🔒 Niveaux de Sécurité (Defense in Depth)

### Niveau 1 : Périmètre Réseau
```
Internet
    │
    ▼
┌─────────────────────────────┐
│  AWS Shield Standard/Advanced│  ← DDoS Protection
└─────────────────────────────┘
    │
    ▼
┌─────────────────────────────┐
│  Route 53 (DNSSEC)          │  ← DNS Protection
└─────────────────────────────┘
    │
    ▼
┌─────────────────────────────┐
│  AWS WAF                    │  ← Web Application Firewall
│  - OWASP Top 10             │
│  - Rate limiting            │
│  - Geo-blocking             │
└─────────────────────────────┘
    │
    ▼
┌─────────────────────────────┐
│  Application Load Balancer  │  ← TLS 1.3 + PQC
│  - TLS termination          │
│  - X.509 client certs       │
│  - Header injection         │
└─────────────────────────────┘
```

### Niveau 2 : Réseau VPC
```
┌─────────────────────────────┐
│  Network ACLs               │  ← Stateless firewall
│  - Deny by default          │
│  - Allow only required      │
└─────────────────────────────┘
    │
    ▼
┌─────────────────────────────┐
│  Security Groups            │  ← Stateful firewall
│  - Least privilege          │
│  - Tag-based rules          │
│  - No 0.0.0.0/0 inbound     │
└─────────────────────────────┘
    │
    ▼
┌─────────────────────────────┐
│  VPC Flow Logs              │  ← Network monitoring
│  - All traffic logged       │
│  - Anomaly detection        │
└─────────────────────────────┘
```

### Niveau 3 : Kubernetes Network Policies
```
┌─────────────────────────────┐
│  Calico/Cilium              │  ← CNI with Network Policies
│  - Namespace isolation      │
│  - Pod-to-Pod rules         │
│  - Egress filtering         │
└─────────────────────────────┘
    │
    ▼
┌─────────────────────────────┐
│  Service Mesh (Istio/Linkerd│  ← mTLS enforcement
│  - Automatic mTLS           │
│  - Authorization policies   │
│  - Traffic encryption       │
└─────────────────────────────┘
```

### Niveau 4 : Identité Workload (SPIFFE/SPIRE)
```
┌─────────────────────────────┐
│  SPIRE Server               │  ← Trust Root
│  - HA cluster (3 nodes)     │
│  - Hardware attestation     │
│  - Short-lived SVIDs        │
└─────────────────────────────┘
    │
    ▼
┌─────────────────────────────┐
│  SPIRE Agent (DaemonSet)    │  ← Identity Provider
│  - Node attestation         │
│  - Workload attestation     │
│  - SVID rotation (1h TTL)   │
└─────────────────────────────┘
    │
    ▼
┌─────────────────────────────┐
│  Application Workload       │  ← SPIFFE-aware
│  - Fetch SVID via API       │
│  - Use for mTLS             │
│  - Verify peer SVID         │
└─────────────────────────────┘
```

### Niveau 5 : Application Security
```
┌─────────────────────────────┐
│  Runtime Security           │  ← Falco/Aqua/Sysdig
│  - System call monitoring   │
│  - Process whitelisting     │
│  - File integrity           │
└─────────────────────────────┘
    │
    ▼
┌─────────────────────────────┐
│  Secret Management          │  ← AWS Secrets Manager
│  - No secrets in code       │
│  - Rotation automated       │
│  - Audit all access         │
└─────────────────────────────┘
```

### Niveau 6 : Cryptographie Post-Quantique
```
┌─────────────────────────────┐
│  PQC Layer                  │
│                             │
│  TLS 1.3 with PQC:          │
│  - ML-KEM-768 (key exchange)│
│  - ML-DSA-65 (signatures)   │
│  - Hybrid mode (PQC+RSA)    │
│                             │
│  Certificate Chain:         │
│  - Root CA: ML-DSA-87       │
│  - Intermediate: ML-DSA-65  │
│  - Leaf: ML-DSA-44 + ECDSA  │
│                             │
│  SPIRE Extensions:          │
│  - Custom PQC plugin        │
│  - Hybrid SVID format       │
└─────────────────────────────┘
```

---

## 🎯 Composants Principaux

### 1. Application Load Balancer (ALB)
**Fonction** : Point d'entrée HTTPS, terminaison TLS

**Configuration** :
- **Listener HTTPS:443**
  - TLS 1.3 uniquement
  - Cipher suites PQC + classiques (hybrid)
  - Certificate: ACM + custom PQC cert
  - Client auth: X.509 mutual TLS (optional)

- **Listener HTTP:80**
  - Redirect vers HTTPS

- **Target Groups**
  - Health checks : `/health` endpoint
  - Deregistration delay : 30s
  - Stickiness : Cookie-based (1h)

- **WAF Integration**
  - Rate limiting : 1000 req/5min per IP
  - OWASP rules activated
  - Custom rules for PQC handshake

**Haute Disponibilité** :
- Multi-AZ (3 zones)
- Auto-scaling (min 2, max 10)

### 2. EKS Cluster
**Fonction** : Orchestration Kubernetes

**Configuration** :
- **Version** : Latest stable (1.28+)
- **Endpoint** : Private only
- **Networking** : Calico CNI
- **RBAC** : Strict, no cluster-admin
- **Secrets** : AWS Secrets Manager CSI driver
- **Logging** : All logs to CloudWatch

**Node Groups** :
```yaml
Compute Nodes:
  - Instance type: t3.medium (min), m5.large (prod)
  - Min: 3 (1 per AZ)
  - Max: 30
  - AMI: Bottlerocket (security-hardened)
  - IAM role: Least privilege
  - User data: SPIRE Agent bootstrap

System Nodes:
  - Instance type: t3.small
  - Min: 2
  - Taints: system-only
  - For: kube-system, monitoring, SPIRE
```

**Add-ons** :
- SPIRE integration
- Secrets Store CSI Driver
- AWS Load Balancer Controller
- Cluster Autoscaler
- Metrics Server
- CoreDNS (patched for DNSSEC)

### 3. SPIRE Server Cluster (HA)
**Fonction** : Autorité de certification pour identités workload

**Architecture HA** :
```
┌─────────────────────────────────────────┐
│  SPIRE Server Cluster                   │
│                                         │
│  AZ-A           AZ-B           AZ-C     │
│  ┌─────┐       ┌─────┐       ┌─────┐  │
│  │ S1  │       │ S2  │       │ S3  │  │
│  │(act)│◄─────►│(act)│◄─────►│(stby│  │
│  └─────┘       └─────┘       └─────┘  │
│     │             │             │       │
│     └─────────────┼─────────────┘       │
│                   ▼                     │
│         ┌──────────────────┐            │
│         │  RDS PostgreSQL  │            │
│         │  (Multi-AZ)      │            │
│         └──────────────────┘            │
└─────────────────────────────────────────┘
```

**Configuration** :
```hcl
# spire-server.conf
server {
  bind_address = "0.0.0.0"
  bind_port = "8081"
  trust_domain = "production.quantumsec.io"
  data_dir = "/var/lib/spire/data"
  log_level = "INFO"
  
  ca_ttl = "87600h"  # 10 ans
  default_svid_ttl = "1h"  # SVIDs courte durée
  
  # CA avec PQC
  ca_key_type = "ml-dsa-65"  # Post-quantum signature
  
  # Haute disponibilité
  federation {
    bundle_endpoint {
      address = "0.0.0.0"
      port = 8443
    }
  }
}

plugins {
  DataStore "sql" {
    plugin_data {
      database_type = "postgres"
      connection_string = "postgresql://spire:${DB_PASS}@${DB_HOST}/spire"
      
      # Connection pooling
      max_open_conns = 25
      max_idle_conns = 10
    }
  }
  
  KeyManager "disk" {
    plugin_data {
      keys_path = "/var/lib/spire/keys"
    }
  }
  
  NodeAttestor "aws_iid" {
    plugin_data {
      # Attestation basée sur instance identity document
    }
  }
  
  # Plugin custom pour PQC
  KeyManager "pqc" {
    plugin_data {
      algorithm = "ml-kem-768"
      key_path = "/var/lib/spire/pqc-keys"
    }
  }
}
```

**Déploiement** :
- StatefulSet Kubernetes
- 3 replicas (1 per AZ)
- Persistent volumes pour keys
- Init container : DB migration
- Liveness probe : gRPC health check
- Readiness probe : federation bundle availability

### 4. SPIRE Agent (DaemonSet)
**Fonction** : Fournir identités aux workloads sur chaque nœud

**Configuration** :
```hcl
# spire-agent.conf
agent {
  data_dir = "/run/spire"
  log_level = "INFO"
  server_address = "spire-server.spire.svc.cluster.local"
  server_port = "8081"
  trust_domain = "production.quantumsec.io"
  
  # Socket pour Workload API
  socket_path = "/run/spire/sockets/agent.sock"
}

plugins {
  NodeAttestor "k8s_psat" {
    plugin_data {
      cluster = "production-cluster"
    }
  }
  
  WorkloadAttestor "k8s" {
    plugin_data {
      # Attestation basée sur ServiceAccount
    }
  }
  
  WorkloadAttestor "unix" {
    plugin_data {
      # Attestation basée sur UID/GID
    }
  }
}
```

**DaemonSet Kubernetes** :
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: spire-agent
  namespace: spire
spec:
  selector:
    matchLabels:
      app: spire-agent
  template:
    metadata:
      labels:
        app: spire-agent
    spec:
      hostPID: true
      hostNetwork: true
      dnsPolicy: ClusterFirstWithHostNet
      
      serviceAccountName: spire-agent
      
      initContainers:
      - name: init
        image: spire-agent:latest
        command: ["spire-agent", "api", "fetch", "jwt"]
        
      containers:
      - name: spire-agent
        image: spire-agent:latest
        args:
          - -config
          - /run/spire/config/agent.conf
        
        volumeMounts:
        - name: spire-config
          mountPath: /run/spire/config
          readOnly: true
        - name: spire-sockets
          mountPath: /run/spire/sockets
        - name: spire-data
          mountPath: /run/spire/data
        
        livenessProbe:
          exec:
            command:
              - /opt/spire/bin/spire-agent
              - healthcheck
          initialDelaySeconds: 15
          periodSeconds: 60
      
      volumes:
      - name: spire-config
        configMap:
          name: spire-agent
      - name: spire-sockets
        hostPath:
          path: /run/spire/sockets
          type: DirectoryOrCreate
      - name: spire-data
        hostPath:
          path: /run/spire/data
          type: DirectoryOrCreate
```

### 5. Service Mesh (Istio/Linkerd)
**Fonction** : mTLS automatique entre services

**Choix : Linkerd** (plus simple, mTLS par défaut)

**Installation** :
```bash
linkerd install --set proxyInit.runAsRoot=false | kubectl apply -f -
linkerd check

# Injection automatique
kubectl annotate namespace default linkerd.io/inject=enabled
```

**Configuration mTLS** :
```yaml
---
apiVersion: policy.linkerd.io/v1beta1
kind: Server
metadata:
  name: backend-server
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend
  port: 8080
  proxyProtocol: TLS
---
apiVersion: policy.linkerd.io/v1alpha1
kind: MeshTLSAuthentication
metadata:
  name: backend-mtls
  namespace: default
spec:
  identities:
    - "spiffe://production.quantumsec.io/ns/default/sa/frontend"
```

**Intégration SPIFFE** :
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: linkerd-config
  namespace: linkerd
data:
  values: |
    identity:
      issuer:
        scheme: spiffe
        trustDomain: production.quantumsec.io
```

### 6. RDS PostgreSQL
**Fonction** : Base de données pour SPIRE Server

**Configuration** :
```
Instance Class: db.t3.medium (min), db.r5.large (prod)
Engine: PostgreSQL 15
Multi-AZ: Enabled
Storage: 100GB gp3, autoscaling to 1TB
Encryption: 
  - At rest: KMS (AWS managed key)
  - In transit: TLS 1.3 + PQC (custom)
Backups:
  - Automated: 7 days retention
  - Manual snapshots: Before changes
  - Point-in-time recovery: Enabled
Monitoring:
  - Enhanced monitoring: 60s granularity
  - Performance Insights: Enabled
  - CloudWatch alarms: CPU, connections, storage
```

**Network** :
- Private subnets only
- Security group : Allow 5432 from SPIRE servers only
- No public access

**Credentials** :
- Stored in AWS Secrets Manager
- Rotation: 30 days
- IAM authentication: Enabled

---

## 📋 Plan de Déploiement Séquentiel

### Phase 0 : Préparation (Semaine 0)
**Durée : 3-5 jours**

#### Jour 1 : Setup AWS Account & Terraform
- [ ] Créer AWS Organization
- [ ] Setup multi-account (prod, staging, dev)
- [ ] Enable AWS Organizations features
- [ ] Configure CloudTrail organization-wide
- [ ] Setup Terraform backend (S3 + DynamoDB)
- [ ] Configure Terraform Cloud/Enterprise
- [ ] Setup CI/CD (GitHub Actions/GitLab CI)

#### Jour 2 : Certificats PQC Root CA
- [ ] Compiler liboqs sur machine locale
- [ ] Générer clés Root CA (ML-DSA-87)
- [ ] Créer certificat Root CA
- [ ] Stocker clés dans AWS KMS
- [ ] Documenter procédure recovery
- [ ] Setup HSM (optionnel, recommandé)

#### Jour 3-4 : Networking Foundation
- [ ] Déployer VPC avec Terraform
- [ ] Créer subnets (public, private app, private data, mgmt)
- [ ] Setup Internet Gateway
- [ ] Deploy NAT Gateways (3 AZs)
- [ ] Configure Route Tables
- [ ] Enable VPC Flow Logs
- [ ] Setup Transit Gateway (si multi-VPC)

#### Jour 5 : Security Baseline
- [ ] Configure GuardDuty
- [ ] Enable Security Hub
- [ ] Setup Config Rules
- [ ] Configure CloudTrail
- [ ] Enable AWS Shield Standard
- [ ] Setup SNS for alerts
- [ ] Create IAM roles (least privilege)

---

### Phase 1 : Core Infrastructure (Semaine 1)
**Durée : 5-7 jours**

#### Étape 1.1 : EKS Cluster Base
```bash
# Jour 1-2
```
- [ ] Create EKS cluster
- [ ] Configure OIDC provider
- [ ] Setup IRSA (IAM Roles for Service Accounts)
- [ ] Deploy Calico CNI
- [ ] Configure CoreDNS
- [ ] Enable control plane logging
- [ ] Setup kubectl access (via IAM)
- [ ] Install essential add-ons (metrics-server, etc.)

**Terraform** :
```hcl
# À créer : terraform/production/eks.tf
```

#### Étape 1.2 : Node Groups
```bash
# Jour 3
```
- [ ] Create compute node group (3 AZs)
- [ ] Create system node group
- [ ] Configure auto-scaling
- [ ] Setup instance profiles
- [ ] Configure user-data (SPIRE Agent prep)
- [ ] Test pod scheduling

#### Étape 1.3 : RDS PostgreSQL
```bash
# Jour 4
```
- [ ] Create DB subnet group
- [ ] Deploy RDS instance (Multi-AZ)
- [ ] Configure security groups
- [ ] Setup parameter group (PQC TLS)
- [ ] Enable encryption
- [ ] Configure backups
- [ ] Create secrets in Secrets Manager
- [ ] Test connectivity from EKS

#### Étape 1.4 : Load Balancer
```bash
# Jour 5
```
- [ ] Install AWS Load Balancer Controller
- [ ] Create target groups
- [ ] Deploy ALB
- [ ] Configure listeners (HTTP → HTTPS redirect)
- [ ] Upload TLS certificates to ACM
- [ ] Configure health checks
- [ ] Test external access

#### Étape 1.5 : Monitoring Foundation
```bash
# Jour 6-7
```
- [ ] Deploy Prometheus Operator
- [ ] Configure Prometheus
- [ ] Deploy Grafana
- [ ] Setup dashboards
- [ ] Configure CloudWatch integration
- [ ] Setup alerts (PagerDuty/Slack)
- [ ] Deploy metrics exporters

---

### Phase 2 : SPIFFE/SPIRE Deployment (Semaine 2)
**Durée : 5-7 jours**

#### Étape 2.1 : SPIRE Server Preparation
```bash
# Jour 1-2
```
- [ ] Create `spire` namespace
- [ ] Create ServiceAccounts
- [ ] Configure RBAC
- [ ] Create ConfigMaps (spire-server.conf)
- [ ] Create Secrets (DB credentials)
- [ ] Build custom SPIRE image (avec PQC plugin)
- [ ] Push to ECR

**Custom SPIRE Image** :
```dockerfile
# Dockerfile.spire-server-pqc
FROM ghcr.io/spiffe/spire-server:1.8.7

# Install liboqs
RUN apt-get update && apt-get install -y \
    cmake ninja-build git

WORKDIR /tmp
RUN git clone --depth 1 https://github.com/open-quantum-safe/liboqs.git && \
    cd liboqs && \
    mkdir build && cd build && \
    cmake -GNinja .. -DCMAKE_INSTALL_PREFIX=/usr/local && \
    ninja && ninja install && \
    ldconfig

# Copy custom PQC plugin
COPY plugins/pqc-keymanager.so /opt/spire/plugins/

# Copy configuration
COPY config/server.conf /etc/spire/server.conf

ENTRYPOINT ["/opt/spire/bin/spire-server", "run", "-config", "/etc/spire/server.conf"]
```

#### Étape 2.2 : SPIRE Server Deployment
```bash
# Jour 3
```
- [ ] Create PersistentVolumeClaims
- [ ] Deploy StatefulSet (3 replicas)
- [ ] Create Service (headless + LoadBalancer)
- [ ] Verify pods startup
- [ ] Check database connectivity
- [ ] Initialize SPIRE Server
- [ ] Generate bootstrap bundle

**StatefulSet** :
```yaml
# À créer : k8s/spire/server-statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: spire-server
  namespace: spire
spec:
  serviceName: spire-server
  replicas: 3
  selector:
    matchLabels:
      app: spire-server
  template:
    metadata:
      labels:
        app: spire-server
    spec:
      serviceAccountName: spire-server
      
      initContainers:
      - name: init-db
        image: postgres:15
        command:
          - sh
          - -c
          - |
            until pg_isready -h $DB_HOST -U $DB_USER; do
              echo "Waiting for database..."
              sleep 2
            done
        env:
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: spire-db
              key: host
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: spire-db
              key: username
      
      containers:
      - name: spire-server
        image: <ECR_REPO>/spire-server-pqc:latest
        args:
          - -config
          - /run/spire/config/server.conf
        
        ports:
        - containerPort: 8081
          name: grpc
          protocol: TCP
        - containerPort: 8443
          name: federation
          protocol: TCP
        
        volumeMounts:
        - name: spire-config
          mountPath: /run/spire/config
          readOnly: true
        - name: spire-data
          mountPath: /run/spire/data
        - name: spire-sockets
          mountPath: /run/spire/sockets
        
        livenessProbe:
          exec:
            command:
              - /opt/spire/bin/spire-server
              - healthcheck
          initialDelaySeconds: 30
          periodSeconds: 60
        
        readinessProbe:
          exec:
            command:
              - /opt/spire/bin/spire-server
              - healthcheck
          initialDelaySeconds: 10
          periodSeconds: 10
      
      volumes:
      - name: spire-config
        configMap:
          name: spire-server
      - name: spire-sockets
        emptyDir: {}
  
  volumeClaimTemplates:
  - metadata:
      name: spire-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: gp3
      resources:
        requests:
          storage: 10Gi
```

#### Étape 2.3 : SPIRE Agent Deployment
```bash
# Jour 4
```
- [ ] Build custom Agent image (avec PQC)
- [ ] Create DaemonSet
- [ ] Configure node attestation
- [ ] Configure workload attestation
- [ ] Verify agent registration
- [ ] Test SVID issuance

**DaemonSet** :
```yaml
# À créer : k8s/spire/agent-daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: spire-agent
  namespace: spire
spec:
  selector:
    matchLabels:
      app: spire-agent
  template:
    metadata:
      labels:
        app: spire-agent
    spec:
      hostPID: true
      hostNetwork: true
      dnsPolicy: ClusterFirstWithHostNet
      
      serviceAccountName: spire-agent
      
      initContainers:
      - name: init
        image: <ECR_REPO>/spire-agent-pqc:latest
        command:
          - sh
          - -c
          - cp /opt/spire/bin/spire-agent /spire-agent-init/
        volumeMounts:
        - name: spire-agent-init
          mountPath: /spire-agent-init
      
      containers:
      - name: spire-agent
        image: <ECR_REPO>/spire-agent-pqc:latest
        args:
          - -config
          - /run/spire/config/agent.conf
        
        volumeMounts:
        - name: spire-config
          mountPath: /run/spire/config
          readOnly: true
        - name: spire-bundle
          mountPath: /run/spire/bundle
          readOnly: true
        - name: spire-sockets
          mountPath: /run/spire/sockets
        - name: spire-data
          mountPath: /run/spire/data
        
        livenessProbe:
          exec:
            command:
              - /opt/spire/bin/spire-agent
              - healthcheck
              - -socketPath
              - /run/spire/sockets/agent.sock
          initialDelaySeconds: 15
          periodSeconds: 60
        
        readinessProbe:
          exec:
            command:
              - /opt/spire/bin/spire-agent
              - healthcheck
              - -socketPath
              - /run/spire/sockets/agent.sock
          initialDelaySeconds: 5
          periodSeconds: 10
      
      volumes:
      - name: spire-config
        configMap:
          name: spire-agent
      - name: spire-bundle
        configMap:
          name: spire-bundle
      - name: spire-sockets
        hostPath:
          path: /run/spire/sockets
          type: DirectoryOrCreate
      - name: spire-data
        hostPath:
          path: /run/spire/data
          type: DirectoryOrCreate
      - name: spire-agent-init
        emptyDir: {}
```

#### Étape 2.4 : Registration Entries
```bash
# Jour 5
```
- [ ] Create node entries
- [ ] Create workload entries
- [ ] Configure federation (if multi-cluster)
- [ ] Test SVID rotation
- [ ] Verify mTLS between workloads

**Script d'enregistrement** :
```bash
#!/bin/bash
# scripts/spire-register-workloads.sh

SPIRE_SERVER_POD=$(kubectl get pods -n spire -l app=spire-server -o jsonpath='{.items[0].metadata.name}')

# Enregistrer frontend
kubectl exec -n spire $SPIRE_SERVER_POD -- \
  /opt/spire/bin/spire-server entry create \
  -spiffeID spiffe://production.quantumsec.io/ns/default/sa/frontend \
  -parentID spiffe://production.quantumsec.io/spire/agent/k8s_psat/production-cluster \
  -selector k8s:ns:default \
  -selector k8s:sa:frontend \
  -ttl 3600

# Enregistrer backend
kubectl exec -n spire $SPIRE_SERVER_POD -- \
  /opt/spire/bin/spire-server entry create \
  -spiffeID spiffe://production.quantumsec.io/ns/default/sa/backend \
  -parentID spiffe://production.quantumsec.io/spire/agent/k8s_psat/production-cluster \
  -selector k8s:ns:default \
  -selector k8s:sa:backend \
  -ttl 3600
```

#### Étape 2.5 : Workload Integration
```bash
# Jour 6-7
```
- [ ] Create test workloads
- [ ] Integrate SPIFFE helper
- [ ] Implement mTLS in applications
- [ ] Test end-to-end communication
- [ ] Verify certificate rotation
- [ ] Load testing

---

**Je continue avec les phases suivantes ?**

J'ai créé :
1. ✅ Architecture globale production-grade
2. ✅ Defense in depth (6 niveaux)
3. ✅ Détail de tous les composants
4. ✅ Plan séquentiel Phase 0-2 (3 semaines)

**Voulez-vous que je continue avec :**
- Phase 3 : PQC Integration (Semaine 3)
- Phase 4 : Service Mesh & mTLS (Semaine 4)
- Phase 5 : Application Deployment (Semaine 5)
- Phase 6 : Observability & Monitoring (Semaine 6)
- Phase 7 : Security Hardening (Semaine 7)
- Phase 8 : Disaster Recovery & Testing (Semaine 8)

Ou voulez-vous des détails supplémentaires sur une phase spécifique ?
