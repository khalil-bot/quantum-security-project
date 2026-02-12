# 🧪 Laboratoires Pratiques

Ce dossier contient tous les laboratoires pratiques organisés par semaine et technologie.

## 📂 Organisation

```
labs/
├── openssl/          # Semaine 1 - Cryptographie classique
├── liboqs/           # Semaine 1 - Post-Quantum Crypto
├── spiffe-spire/     # Semaine 2 - Zero-Trust
└── qkd/              # Semaine 3 - Quantum Key Distribution
```

## 🗓️ Planning des Labs

### Semaine 1 : Cryptographie

#### Labs OpenSSL (Jour 1-2)
- **Lab 1.1** : Génération de certificats X.509 [✓ Disponible]
- **Lab 1.2** : Configuration mTLS avec Nginx [⏳ À venir]

#### Labs liboqs (Jour 3-5)
- **Lab 1.3** : Installation et test liboqs [⏳ À venir]
- **Lab 1.4** : Tests ML-KEM-768 [⏳ À venir]
- **Lab 1.5** : Tests ML-DSA-65 [⏳ À venir]

### Semaine 2 : Zero-Trust

#### Labs Architecturaux (Jour 1-2)
- **Lab 2.1** : Analyse architecture Zero-Trust [⏳ À venir]

#### Labs SPIFFE/SPIRE (Jour 3-5)
- **Lab 2.2** : Installation SPIRE Server/Agent [⏳ À venir]
- **Lab 2.3** : Création et gestion workloads [⏳ À venir]
- **Lab 2.4** : Démo mTLS automatique [⏳ À venir]

### Semaine 3 : QKD

#### Labs Quantum (Jour 1-2)
- **Lab 3.1** : Simulation BB84 avec Qiskit [⏳ À venir]
- **Lab 3.2** : Étude Geneva Quantum Network [⏳ À venir]

## 🎯 Utilisation

Chaque lab contient :
- 📖 Un guide détaillé (`.md`)
- 🔧 Scripts d'automatisation (`.sh`)
- 📁 Fichiers de configuration
- ✅ Checklist de validation

### Format des Labs

Tous les labs suivent cette structure :
```markdown
# Lab X.Y : Titre

## 🎯 Objectifs
## 📚 Prérequis
## 🔧 Étapes
## ✅ Validation
## 🎓 Concepts Appris
## ❓ Questions
```

## 🚀 Quick Start

Pour commencer le premier lab :
```bash
cd labs/openssl
cat LAB-1.1-Certificates.md
```

## 📊 Progression

| Lab | Status | Temps | Complété |
|-----|--------|-------|----------|
| Lab 1.1 | 🔄 | 2-3h | - |
| Lab 1.2 | ⏳ | 2-3h | - |
| Lab 1.3 | ⏳ | 2h | - |
| Lab 1.4 | ⏳ | 3h | - |
| Lab 1.5 | ⏳ | 3h | - |
| Lab 2.1 | ⏳ | 2h | - |
| Lab 2.2 | ⏳ | 3h | - |
| Lab 2.3 | ⏳ | 3h | - |
| Lab 2.4 | ⏳ | 4h | - |
| Lab 3.1 | ⏳ | 3h | - |
| Lab 3.2 | ⏳ | 2h | - |

**Total estimé** : ~30-32 heures de pratique

## 💡 Conseils

1. **Suivez l'ordre** : Les labs sont conçus de manière progressive
2. **Documentez** : Prenez des notes dans `docs/learning-notes/`
3. **Expérimentez** : N'hésitez pas à modifier les configurations
4. **Validez** : Complétez toutes les vérifications avant de passer au suivant

## 🆘 Troubleshooting

En cas de problème :
1. Vérifiez les logs détaillés
2. Consultez la section troubleshooting du lab
3. Vérifiez les versions des outils
4. Documentez le problème dans les notes

## 📚 Ressources

- Documentation officielle des outils
- Standards NIST
- Papers académiques (voir `docs/references/`)

---

**Mise à jour** : 26 janvier 2026
