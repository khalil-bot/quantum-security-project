# 🚀 Guide de Démarrage Rapide

Bienvenue dans votre projet de sécurité post-quantique ! Ce guide vous aide à démarrer efficacement.

## ✅ Checklist Premier Jour

### 1. Vérifier l'environnement
```bash
# Vérifier Git
git --version

# Vérifier OpenSSL
openssl version

# Vérifier Python (pour Qiskit plus tard)
python3 --version

# Vérifier Docker (pour SPIRE)
docker --version
```

### 2. Explorer le repository
```bash
# Lire le README principal
cat README.md

# Consulter le plan d'action
cat docs/PLAN_ACTION.md

# Voir la progression
cat docs/PROGRESSION.md
```

### 3. Préparer pour le Lab 1.1
```bash
# Aller dans le dossier openssl
cd labs/openssl

# Lire le guide du lab
cat LAB-1.1-Certificates.md

# Créer les dossiers nécessaires
mkdir -p ca/{root,intermediate,certs,crl,newcerts,private}
chmod 700 ca/private
```

## 📋 Workflow Quotidien Recommandé

### Matin (2-3h)
1. **Révision** : Relire notes du jour précédent
2. **Théorie** : Lire documentation/standards (1-2h)
3. **Planification** : Définir objectifs du jour

### Après-midi (3-4h)
1. **Pratique** : Faire les labs hands-on
2. **Expérimentation** : Tester variations
3. **Debugging** : Résoudre problèmes

### Soir (1h)
1. **Documentation** : Rédiger notes du jour
2. **Commit Git** : Sauvegarder progrès
3. **Préparation** : Lire intro du lendemain

## 🎯 Premier Sprint (Jours 1-2)

### Jour 1 : Théorie et Setup
**Objectifs** :
- [ ] Réviser concepts PKI
- [ ] Comprendre architecture CA
- [ ] Compléter Lab 1.1 partie 1-3

**Timeline suggérée** :
- 09h00-10h30 : Révision théorique PKI
- 10h30-11h00 : Pause ☕
- 11h00-12h30 : Lab 1.1 - CA Root
- 12h30-14h00 : Déjeuner 🍽️
- 14h00-16h00 : Lab 1.1 - Certificats serveur/client
- 16h00-16h30 : Pause ☕
- 16h30-17h30 : Vérification et tests
- 17h30-18h30 : Documentation et notes

### Jour 2 : Approfondissement mTLS
**Objectifs** :
- [ ] Comprendre handshake TLS
- [ ] Installer et configurer Nginx
- [ ] Compléter Lab 1.2

## 📝 Template Notes Jour 1

Créez `docs/learning-notes/semaine1-jour1.md` :

```bash
cp docs/learning-notes/TEMPLATE.md docs/learning-notes/semaine1-jour1.md
```

Puis éditez avec vos notes du jour.

## 🔧 Outils Essentiels

### Installation rapide (Ubuntu/Debian)
```bash
# OpenSSL
sudo apt update
sudo apt install openssl

# Python et pip
sudo apt install python3 python3-pip

# Docker (pour SPIRE plus tard)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Outils de développement
sudo apt install git curl wget vim tree
```

### Installation rapide (macOS)
```bash
# Homebrew (si pas installé)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# OpenSSL
brew install openssl@3

# Python
brew install python3

# Docker Desktop
# Télécharger depuis https://www.docker.com/products/docker-desktop
```

## 📚 Ressources de Démarrage

### À lire en priorité
1. **Module 1** : Cryptographie classique (révision)
2. **Module 3** : PKI et X.509
3. **Lab 1.1** : Guide complet

### Standards NIST
- [FIPS 203](https://csrc.nist.gov/pubs/fips/203/final) - À lire Jour 3
- [FIPS 204](https://csrc.nist.gov/pubs/fips/204/final) - À lire Jour 4
- [SP 800-207](https://csrc.nist.gov/publications/detail/sp/800-207/final) - Semaine 2

### Documentation Technique
- [OpenSSL Documentation](https://www.openssl.org/docs/)
- [X.509 RFC 5280](https://datatracker.ietf.org/doc/html/rfc5280)
- [TLS 1.3 RFC 8446](https://datatracker.ietf.org/doc/html/rfc8446)

## 💡 Conseils pour Réussir

### Organisation
- ✅ **Planifiez** : 30 min chaque matin
- ✅ **Documentez** : Après chaque lab
- ✅ **Committez** : Au moins 1x par jour
- ✅ **Révisez** : 15 min chaque soir

### Apprentissage
- 📖 **Lisez d'abord** : Théorie avant pratique
- 🔧 **Pratiquez** : Ne pas juste lire
- ❓ **Questionnez** : Notez les incertitudes
- 🔄 **Itérez** : Expérimentez les variations

### Gestion du Temps
- ⏱️ **Pomodoro** : 25 min travail, 5 min pause
- 🎯 **Focus** : Un objectif à la fois
- 🚫 **Distractions** : Mode avion pendant labs
- 💪 **Endurance** : Pauses régulières

## 🆘 En Cas de Blocage

### Problèmes Techniques
1. Vérifier les logs détaillés
2. Google l'erreur exacte
3. Consulter la documentation officielle
4. Essayer dans Docker (environnement propre)

### Problèmes de Compréhension
1. Relire la section du cours
2. Chercher des explications alternatives
3. Dessiner des diagrammes
4. Noter question pour Prof. Schiller

### Problèmes de Temps
1. Prioriser les objectifs critiques
2. Reporter les exercices bonus
3. Demander extension si nécessaire
4. Ajuster le planning

## 🎓 Objectifs de Fin de Semaine 1

À la fin de la première semaine, vous devriez :

### Compétences
- [x] Maîtriser génération certificats X.509
- [x] Comprendre architecture PKI complète
- [x] Configurer mTLS basique
- [x] Installer et tester liboqs
- [x] Générer clés post-quantiques

### Livrables
- [x] CA root fonctionnelle
- [x] Certificats serveur/client valides
- [x] Configuration Nginx mTLS
- [x] Script génération PQC
- [x] 10+ pages de notes

### Documentation
- [x] Notes quotidiennes complètes
- [x] Labs documentés avec screenshots
- [x] Questions identifiées
- [x] Repository Git à jour

## 📊 Métriques de Succès

Utilisez ce système pour suivre votre progression :

```
🔴 Non démarré
🟡 En cours
🟢 Complété
✅ Validé et testé
```

### Exemple
- 🔴 Lab 1.3 - Installation liboqs
- 🟡 Lab 1.1 - Génération certificats (en cours)
- 🟢 Configuration Git (complété)
- ✅ Repository initialisé (validé)

## 🚀 C'est Parti !

Vous êtes maintenant prêt à commencer. Bonne chance !

```bash
# Commencez par le Lab 1.1
cd labs/openssl
cat LAB-1.1-Certificates.md

# Créez vos notes du jour
cp docs/learning-notes/TEMPLATE.md docs/learning-notes/semaine1-jour1.md

# Let's go! 💪
```

---

**Questions ?** Notez-les dans vos notes quotidiennes.  
**Problèmes ?** Consultez la section troubleshooting.  
**Suggestions ?** Améliorez cette documentation !

**Bon apprentissage ! 🎓**
