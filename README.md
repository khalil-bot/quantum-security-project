# Projet : Sécurité Post-Quantique et Zero-Trust

## 🎯 Objectif du Projet

Exploration pratique des technologies de sécurité post-quantique et des architectures Zero-Trust, avec focus sur :
- **Cryptographie Post-Quantique** (NIST FIPS 203/204)
- **SPIFFE/SPIRE** pour l'identité Zero-Trust
- **Quantum Key Distribution** (QKD)
- **Intégration Kubernetes**

## 📅 Timeline : 3 Semaines

### Semaine 1 : Fondations Cryptographiques
- Cryptographie classique (X.509, TLS, mTLS)
- Post-Quantum Cryptography (ML-KEM, ML-DSA)
- Hands-on avec OpenSSL et liboqs

### Semaine 2 : Zero-Trust et SPIFFE
- Architectures Zero-Trust (NIST SP 800-207)
- SPIFFE/SPIRE déploiement local
- mTLS entre microservices

### Semaine 3 : QKD et Synthèse
- Quantum Key Distribution (BB84)
- Geneva Quantum Network
- State-of-the-art et préparation présentation

## 📁 Structure du Projet

```
quantum-security-project/
├── docs/                      # Documentation
│   ├── state-of-art/         # État de l'art (objectif: 10 pages)
│   ├── learning-notes/       # Notes d'apprentissage hebdomadaires
│   └── references/           # Références académiques et techniques
├── src/                      # Code source
│   ├── week1-crypto/         # Implémentations cryptographiques
│   ├── week2-zerotrust/      # Démos Zero-Trust/SPIFFE
│   └── week3-qkd/           # Expériences QKD
├── labs/                     # Laboratoires pratiques
│   ├── openssl/             # Exercices OpenSSL
│   ├── liboqs/              # Tests liboqs
│   ├── spiffe-spire/        # Configurations SPIRE
│   └── qkd/                 # Simulations QKD
├── presentations/            # Slides et présentations
└── scripts/                  # Scripts d'automatisation
```

## 🔧 Technologies Utilisées

### Cryptographie
- **OpenSSL** 3.x - Cryptographie classique
- **liboqs** - Open Quantum Safe Library
- **ML-KEM-768** (FIPS 203) - Encapsulation de clés
- **ML-DSA-65** (FIPS 204) - Signatures numériques

### Zero-Trust
- **SPIFFE** - Secure Production Identity Framework
- **SPIRE** - SPIFFE Runtime Environment
- **Envoy** - Service mesh avec mTLS

### Quantum
- **Qiskit** - Simulations quantiques
- **Geneva Quantum Network** - Infrastructure QKD

### Infrastructure
- **Kubernetes** - Orchestration
- **Docker** - Containerisation
- **Terraform** - Infrastructure as Code

## 📚 Références Clés

### Standards NIST
- [FIPS 203](https://csrc.nist.gov/pubs/fips/203/final) - ML-KEM
- [FIPS 204](https://csrc.nist.gov/pubs/fips/204/final) - ML-DSA
- [SP 800-207](https://csrc.nist.gov/publications/detail/sp/800-207/final) - Zero Trust Architecture

### Projets Open Source
- [Open Quantum Safe](https://openquantumsafe.org/)
- [SPIFFE](https://spiffe.io/)
- [Geneva Quantum Network](https://www.unige.ch/gap/qic/qkd/)

## ✅ Checklist Semaine par Semaine

### Semaine 1 : Cryptographie
- [ ] Générer certificats X.509
- [ ] Configurer mTLS avec Nginx
- [ ] Installer liboqs
- [ ] Tester ML-KEM-768 et ML-DSA-65
- [ ] Documentation : Notes cryptographie

### Semaine 2 : Zero-Trust
- [ ] Installer SPIRE Server/Agent
- [ ] Créer entrées workload
- [ ] Obtenir SVIDs X.509
- [ ] Démo mTLS microservices
- [ ] Documentation : Architecture Zero-Trust

### Semaine 3 : QKD & Synthèse
- [ ] Comprendre protocole BB84
- [ ] Simuler QKD avec Qiskit
- [ ] Étudier Geneva Quantum Network
- [ ] Rédiger state-of-the-art (10 pages)
- [ ] Préparer questions pour Prof. Schiller

## 🚀 Quick Start

```bash
# Cloner le repository
git clone <repository-url>
cd quantum-security-project

# Installer dépendances (voir docs/setup/)
./scripts/setup.sh

# Lancer premier lab
cd labs/openssl
./01-generate-certificates.sh
```

## 📝 Notes de Progression

Les notes quotidiennes sont dans `docs/learning-notes/` organisées par semaine.

## 🤝 Encadrement

- **Superviseur** : Prof. Jean-Philippe Schiller
- **Institution** : [Votre institution]
- **Période** : [Dates du projet]

## 📧 Contact

[Votre nom] - [Votre email]

---

**Dernière mise à jour** : 26 janvier 2026
# quantum-security-project
