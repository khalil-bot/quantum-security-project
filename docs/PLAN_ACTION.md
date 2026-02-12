# Plan d'Action Détaillé - 3 Semaines

## 🎯 Objectif Global
Maîtriser les fondamentaux de la sécurité post-quantique et Zero-Trust pour débuter le projet de recherche avec Prof. Schiller.

---

## 📅 SEMAINE 1 : Fondations Cryptographiques

### Jour 1-2 : Cryptographie Classique
**Objectifs d'apprentissage :**
- ☐ Comprendre architecture PKI complète
- ☐ Maîtriser génération de certificats X.509
- ☐ Configurer TLS et mTLS

**Activités pratiques :**
```bash
# Lab 1.1 : Génération certificats
cd labs/openssl
- Créer CA racine
- Générer certificats serveur/client
- Vérifier chaîne de confiance

# Lab 1.2 : Configuration mTLS
cd labs/openssl
- Configurer Nginx avec mTLS
- Tester authentification mutuelle
- Analyser handshake TLS avec Wireshark
```

**Livrables :**
- [ ] Certificats CA, serveur, client générés
- [ ] Configuration Nginx fonctionnelle
- [ ] Notes d'apprentissage (`docs/learning-notes/week1-day1-2.md`)

---

### Jour 3-5 : Post-Quantum Cryptography
**Objectifs d'apprentissage :**
- ☐ Lire et comprendre FIPS 203 (ML-KEM)
- ☐ Lire et comprendre FIPS 204 (ML-DSA)
- ☐ Comprendre différence avec crypto classique

**Activités pratiques :**
```bash
# Lab 1.3 : Installation liboqs
cd labs/liboqs
- Compiler liboqs depuis sources
- Tester tous les algorithmes disponibles
- Benchmarker performances

# Lab 1.4 : Tests ML-KEM et ML-DSA
- Générer paires de clés ML-KEM-768
- Tester encapsulation/décapsulation
- Générer signatures ML-DSA-65
- Vérifier signatures
```

**Livrables :**
- [ ] liboqs installé et fonctionnel
- [ ] Script de génération clés PQC
- [ ] Benchmark comparatif RSA vs ML-KEM
- [ ] Notes techniques détaillées

**Ressources :**
- [FIPS 203](https://csrc.nist.gov/pubs/fips/203/final)
- [FIPS 204](https://csrc.nist.gov/pubs/fips/204/final)
- [liboqs Documentation](https://github.com/open-quantum-safe/liboqs)

---

## 📅 SEMAINE 2 : Zero-Trust et SPIFFE

### Jour 1-2 : Architectures Zero-Trust
**Objectifs d'apprentissage :**
- ☐ Comprendre les 7 piliers Zero-Trust
- ☐ Étudier NIST SP 800-207
- ☐ Analyser différence avec périmètre traditionnel

**Activités théoriques :**
- Lecture NIST SP 800-207 (complet)
- Schématiser architecture Zero-Trust
- Identifier use cases pratiques

**Activités pratiques :**
```bash
# Lab 2.1 : Analyse architecturale
cd docs/learning-notes
- Créer diagrammes architecturaux
- Comparer modèles périmètre vs Zero-Trust
- Identifier composants critiques
```

**Livrables :**
- [ ] Résumé NIST SP 800-207 (2-3 pages)
- [ ] Diagrammes architecturaux
- [ ] Matrice comparaison modèles sécurité

---

### Jour 3-5 : SPIFFE/SPIRE Hands-on
**Objectifs d'apprentissage :**
- ☐ Comprendre modèle identité SPIFFE
- ☐ Maîtriser configuration SPIRE
- ☐ Implémenter mTLS automatique

**Activités pratiques :**
```bash
# Lab 2.2 : Installation SPIRE
cd labs/spiffe-spire
- Installer SPIRE Server
- Installer SPIRE Agent
- Configurer attestation

# Lab 2.3 : Création workloads
- Créer entrée workload backend
- Créer entrée workload frontend
- Obtenir SVIDs via Workload API

# Lab 2.4 : mTLS automatique
- Déployer 2 microservices
- Configurer mTLS avec SPIFFE
- Tester communication sécurisée
- Rotation automatique certificats
```

**Livrables :**
- [ ] SPIRE Server/Agent opérationnels
- [ ] 2+ workloads enregistrés
- [ ] Démo mTLS fonctionnelle
- [ ] Documentation configuration complète

**Ressources :**
- [SPIFFE Documentation](https://spiffe.io/docs/)
- [SPIRE Quickstart](https://spiffe.io/docs/latest/spire/installing/)

---

## 📅 SEMAINE 3 : QKD et Préparation Projet

### Jour 1-2 : Quantum Key Distribution
**Objectifs d'apprentissage :**
- ☐ Comprendre protocole BB84
- ☐ Étudier sécurité information-théorique
- ☐ Analyser implémentations pratiques

**Activités théoriques :**
- Étude protocole BB84 en détail
- Comprendre bases quantiques
- Analyser attaques possibles (intercept-resend)

**Activités pratiques :**
```bash
# Lab 3.1 : Simulation BB84
cd labs/qkd
- Simuler BB84 avec Qiskit
- Implémenter détection erreurs
- Tester avec eavesdropper

# Lab 3.2 : Geneva Quantum Network
- Étudier architecture GQN
- Analyser publications récentes
- Identifier applications pratiques
```

**Livrables :**
- [ ] Simulation BB84 fonctionnelle
- [ ] Notes protocole QKD (détaillées)
- [ ] Analyse Geneva Quantum Network

**Ressources :**
- [BB84 Original Paper](https://doi.org/10.1016/j.tcs.2014.05.025)
- [Geneva Quantum Network](https://www.unige.ch/gap/qic/qkd/)

---

### Jour 3-5 : Synthèse et Préparation
**Objectifs :**
- ☐ Consolider connaissances Kubernetes
- ☐ Rédiger state-of-the-art
- ☐ Préparer questions pour Prof. Schiller

**Activités :**
```bash
# Révision Kubernetes
- Revoir module 8
- Tester déploiement avec SPIFFE
- Intégrer PQC dans pods

# Rédaction state-of-the-art
cd docs/state-of-art
- Structure du document (voir template)
- Rédaction (objectif : 10 pages)
- Revue et corrections
```

**Livrables :**
- [ ] State-of-the-art (10 pages minimum)
- [ ] Liste questions pour Prof. Schiller
- [ ] Démo Kubernetes + SPIFFE + PQC
- [ ] Présentation synthèse (15 slides)

---

## 📊 Métriques de Succès

### Compétences Techniques
- [ ] Capable de générer et gérer certificats X.509
- [ ] Maîtrise liboqs et algorithmes PQC
- [ ] Capable de déployer SPIRE en production
- [ ] Compréhension approfondie QKD

### Documentation
- [ ] 15+ pages de notes techniques
- [ ] State-of-the-art professionnel (10 pages)
- [ ] 3+ labs fonctionnels et documentés

### Pratique
- [ ] 5+ configurations opérationnelles
- [ ] 2+ démos prêtes à montrer
- [ ] Repository Git bien organisé

---

## 🎯 Points de Contrôle

### Fin Semaine 1
- ✅ Crypto classique maîtrisée ?
- ✅ liboqs installé et testé ?
- ✅ Notes complètes ?

### Fin Semaine 2
- ✅ SPIRE opérationnel ?
- ✅ mTLS démo fonctionnelle ?
- ✅ Architecture Zero-Trust comprise ?

### Fin Semaine 3
- ✅ State-of-the-art finalisé ?
- ✅ Questions préparées ?
- ✅ Prêt pour démarrage projet ?

---

## 📝 Template Notes Quotidiennes

Utiliser le format suivant dans `docs/learning-notes/` :

```markdown
# [Date] - [Sujet]

## 🎯 Objectifs du Jour
- Objectif 1
- Objectif 2

## 📚 Apprentissages
### Concepts Théoriques
- ...

### Pratique
- ...

## 💡 Insights
- ...

## ❓ Questions en Suspens
- ...

## ✅ Prochaines Étapes
- ...
```

---

**Commencé le** : 26 janvier 2026  
**Statut** : 🚀 Démarrage Phase 1
