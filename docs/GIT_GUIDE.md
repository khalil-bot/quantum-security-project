# 📚 Guide Git pour le Projet

## 🎯 Workflow Quotidien

### Début de Journée
```bash
# Vérifier le statut
git status

# Voir les derniers changements
git log --oneline -5

# Créer une branche pour la journée (optionnel)
git checkout -b jour-1-crypto-classique
```

### Pendant le Travail
```bash
# Ajouter des fichiers spécifiques
git add docs/learning-notes/semaine1-jour1.md
git add labs/openssl/ca/

# Ou tout ajouter
git add -A

# Vérifier ce qui sera commité
git status
git diff --staged
```

### Fin de Journée
```bash
# Commit avec message descriptif
git commit -m "📝 Jour 1: Complétion Lab 1.1 - Certificats X.509

- Création CA racine fonctionnelle
- Génération certificats serveur et client
- Vérification chaîne de confiance
- Documentation complète dans notes
"

# Voir l'historique
git log --oneline --graph
```

## 📝 Format des Messages de Commit

### Structure Recommandée
```
<emoji> <type>: <description courte>

<description détaillée optionnelle>
<liste des changements>
```

### Emojis Utiles
- 🚀 `:rocket:` - Initial commit, nouvelle fonctionnalité majeure
- 📝 `:memo:` - Documentation, notes
- 🔧 `:wrench:` - Configuration, setup
- ✨ `:sparkles:` - Nouveau lab, nouvel exemple
- 🐛 `:bug:` - Correction de bug
- 📊 `:bar_chart:` - Ajout de données, résultats
- 🔒 `:lock:` - Sécurité, cryptographie
- 🧪 `:test_tube:` - Tests, expérimentations
- 🎯 `:dart:` - Objectif atteint, milestone
- 🔄 `:arrows_counterclockwise:` - Refactoring, réorganisation

### Exemples de Messages
```bash
# Bon message
git commit -m "✨ Lab 1.2: Configuration mTLS avec Nginx complétée

- Installation et configuration Nginx
- Activation mTLS avec certificats générés
- Tests authentification mutuelle réussis
- Capture Wireshark du handshake TLS
- Documentation complète ajoutée
"

# Message trop vague (à éviter)
git commit -m "updates"
git commit -m "fix"
git commit -m "changes"
```

## 🌿 Stratégie de Branches

### Branche Principale
```bash
main  # Production-ready, documentation finalisée
```

### Branches de Travail (optionnel)
```bash
# Par semaine
semaine-1-crypto
semaine-2-zerotrust
semaine-3-qkd

# Par jour
jour-1-setup
jour-2-mtls
jour-3-pqc-install

# Par feature
feature/liboqs-integration
lab/spire-demo
docs/state-of-art
```

### Workflow avec Branches
```bash
# Créer et basculer sur nouvelle branche
git checkout -b lab-1.2-mtls

# Travailler...
git add .
git commit -m "🔧 Configuration Nginx pour mTLS"

# Retourner sur main et merger
git checkout main
git merge lab-1.2-mtls

# Supprimer la branche
git branch -d lab-1.2-mtls
```

## 📊 Commandes Utiles

### Visualisation
```bash
# Historique graphique
git log --graph --oneline --all --decorate

# Changements par fichier
git log --stat

# Rechercher dans l'historique
git log --grep="Lab 1"
git log --author="<votre nom>"

# Voir un commit spécifique
git show <commit-hash>
```

### Gestion des Fichiers
```bash
# Voir les fichiers modifiés
git status -s

# Voir les différences
git diff                    # Non staged
git diff --staged          # Staged
git diff main..branche     # Entre branches

# Annuler des changements
git restore <fichier>           # Annuler modifs (non staged)
git restore --staged <fichier>  # Unstage
git reset --hard HEAD          # Réinitialiser tout (⚠️ dangereux)
```

### Historique et Tags
```bash
# Créer un tag pour milestone
git tag -a v0.1-semaine1 -m "Fin Semaine 1: Crypto Classique et PQC"
git tag -a v0.2-semaine2 -m "Fin Semaine 2: Zero-Trust et SPIFFE"
git tag -a v1.0-final -m "Projet finalisé"

# Lister les tags
git tag -l

# Voir un tag
git show v0.1-semaine1
```

### Nettoyage
```bash
# Voir les fichiers non trackés
git clean -n

# Supprimer les fichiers non trackés
git clean -f

# Supprimer aussi les dossiers
git clean -fd
```

## 🔄 Gestion du .gitignore

### Fichiers à TOUJOURS Ignorer
```
# Clés privées (déjà dans .gitignore)
*.key
*.pem  # Sauf exemples
*.p12

# Secrets
*.secret
.env
secrets/

# Données SPIRE
spire-server/data/
spire-agent/data/
```

### Ajouter au .gitignore
```bash
# Ajouter un pattern
echo "*.tmp" >> .gitignore

# Forcer l'ajout d'un fichier ignoré (pour exemples)
git add -f labs/openssl/examples/sample.key
```

## 🆘 Situations d'Urgence

### Annuler le Dernier Commit (non pushé)
```bash
# Garder les changements
git reset --soft HEAD^

# Supprimer les changements (⚠️ dangereux)
git reset --hard HEAD^
```

### Retrouver un Fichier Supprimé
```bash
# Lister les commits qui ont touché le fichier
git log -- <fichier supprimé>

# Restaurer depuis un commit
git checkout <commit-hash> -- <fichier>
```

### Comparer avec Version Précédente
```bash
# Voir les changements depuis hier
git diff HEAD@{1.day.ago}

# Voir version d'un fichier à un moment donné
git show HEAD~3:labs/openssl/LAB-1.1-Certificates.md
```

## 📈 Suivi de Progression avec Git

### Stats du Projet
```bash
# Nombre de commits
git rev-list --count HEAD

# Contributions par auteur
git shortlog -sn

# Activité récente
git log --since="1 week ago" --oneline

# Fichiers les plus modifiés
git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -10
```

### Générer Rapport
```bash
# Rapport hebdomadaire
git log --since="1 week ago" --pretty=format:"%h - %an, %ar : %s" > weekly-report.txt

# Stats d'un fichier
git log --follow --stat -- docs/PROGRESSION.md
```

## 🎯 Checklist Fin de Semaine

Avant chaque weekend/milestone :

```bash
# 1. Vérifier l'état
git status

# 2. Commiter tout
git add -A
git commit -m "🎯 Fin Semaine X: Résumé"

# 3. Créer un tag
git tag -a v0.X-semaineX -m "Description"

# 4. Générer rapport
git log v0.X-1..HEAD --oneline > reports/semaine-X.txt

# 5. Sauvegarder (backup local)
git bundle create backup-semaine-X.bundle HEAD

# 6. Push (si remote configuré)
git push origin main
git push --tags
```

## 🔐 Bonnes Pratiques

### ✅ À Faire
- Commits fréquents (au moins 1x par jour)
- Messages descriptifs et clairs
- Vérifier `git status` avant commit
- Relire `git diff --staged`
- Utiliser .gitignore correctement
- Créer des tags aux milestones

### ❌ À Éviter
- Ne JAMAIS commiter de clés privées
- Éviter `git add .` sans vérification
- Ne pas faire de commits vagues ("fix", "update")
- Ne pas modifier l'historique public
- Ne pas ignorer les warnings Git

## 🚀 Commandes pour Démarrer

```bash
# Configuration initiale (déjà fait)
git config user.name "Quantum Security Researcher"
git config user.email "researcher@project.local"

# Alias utiles
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.lg "log --graph --oneline --all --decorate"

# Vérifier la config
git config --list
```

## 📝 Exemple de Session Complète

```bash
# Début de journée
cd quantum-security-project
git status
git log --oneline -3

# Créer notes du jour
cp docs/learning-notes/TEMPLATE.md docs/learning-notes/semaine1-jour2.md
vim docs/learning-notes/semaine1-jour2.md

# Travailler sur Lab 1.2
cd labs/openssl
# ... travail ...

# Ajouter et vérifier
cd ../..
git add -A
git status
git diff --staged

# Commit
git commit -m "📝 Jour 2: Lab 1.2 mTLS Nginx - En cours

- Installation Nginx 1.24
- Configuration SSL basique
- Test authentification serveur
- Préparation mTLS complet (demain)
"

# Fin de journée
git log --oneline -5
git tag jour-2-complete
```

---

**Documentation complète** : https://git-scm.com/doc  
**Mémo rapide** : https://training.github.com/downloads/github-git-cheat-sheet/
