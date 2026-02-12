# 🚀 PHASE 1 - Démarrage Immédiat

## 🎯 Objectif : Fondations Solides (3 Semaines)

Vous allez maîtriser les fondamentaux en profondeur avant d'attaquer le POC recherche.

### Timeline
```
Aujourd'hui (Jour 0)    : Setup infrastructure AWS
Semaine 1 (Jours 1-7)   : Cryptographie Classique + PQC
Semaine 2 (Jours 8-14)  : Zero-Trust + SPIFFE/SPIRE
Semaine 3 (Jours 15-21) : QKD + Synthèse
```

---

## ⚡ DÉMARRAGE IMMÉDIAT (30 Minutes)

### Prérequis (10 min)

```bash
# 1. Vérifier AWS CLI
aws --version
# Si pas installé: pip install awscli

# 2. Configurer AWS
aws configure
# Entrer: Access Key, Secret Key, Region: eu-west-1

# 3. Vérifier Terraform
terraform --version
# Si pas installé: brew install terraform (macOS)

# 4. Créer clé SSH
aws ec2 create-key-pair \
    --key-name quantum-key-phase1 \
    --query 'KeyMaterial' \
    --output text > ~/.ssh/quantum-key-phase1.pem
chmod 400 ~/.ssh/quantum-key-phase1.pem

# 5. Obtenir votre IP
MY_IP=$(curl -s ifconfig.me)
echo "Mon IP: $MY_IP"
```

### Déploiement Infrastructure (15 min)

```bash
# 1. Extraire le projet
cd ~/
unzip quantum-aws.zip  # ou tar -xzf quantum-aws.tar.gz
cd quantum-security-project

# 2. Aller dans Terraform Phase 1
cd terraform/phase1

# 3. Configurer variables
cat > terraform.tfvars << EOF
my_ip = "$MY_IP"
key_name = "quantum-key-phase1"
instance_type = "t3.small"
project_name = "quantum-phase1"
EOF

# 4. Déployer
terraform init
terraform plan  # Vérifier
terraform apply -auto-approve

# 5. Récupérer IP
PUBLIC_IP=$(terraform output -raw public_ip)
echo $PUBLIC_IP > ~/quantum-instance-ip.txt
echo "Instance IP: $PUBLIC_IP"
```

### Connexion et Installation (5 min)

```bash
# 1. Se connecter
ssh -i ~/.ssh/quantum-key-phase1.pem ubuntu@$PUBLIC_IP

# 2. Attendre que user-data soit terminé
while [ ! -f ~/user-data-complete ]; do
    echo "Waiting for user-data..."
    sleep 5
done
echo "User-data complete!"

# 3. Installer tous les outils
chmod +x ~/setup-phase1.sh
./setup-phase1.sh

# Durée: ~10-15 minutes (compilation liboqs)
```

### Vérification Rapide

```bash
# Sur l'instance AWS
docker --version
openssl version
python3 --version
ls -la /usr/local/lib/liboqs.so

# Tout devrait être OK !
```

---

## 📚 SEMAINE 1 : Cryptographie (Jours 1-7)

### Vue d'Ensemble
```
Jour 1-2 : Crypto Classique (X.509, TLS, mTLS)
Jour 3-4 : Post-Quantum Crypto (ML-KEM, ML-DSA)
Jour 5-6 : Benchmarks et Comparaisons
Jour 7   : Documentation et Synthèse
```

### Jour 1 : Lab 1.1 - Certificats X.509

**Objectif** : Maîtriser PKI et génération de certificats

```bash
# Sur l'instance AWS
cd ~/workspace
git clone <votre-repo> quantum-security-project
# OU copier depuis votre machine

cd quantum-security-project/labs/openssl

# Lire le lab
cat LAB-1.1-Certificates.md

# Créer structure
mkdir -p ca/{root,intermediate,certs,crl,newcerts,private}
chmod 700 ca/private
cd ca

# Suivre le guide étape par étape
# Ne pas sauter les étapes !
```

**Temps estimé** : 3-4 heures

**Livrables** :
- [ ] CA racine créée
- [ ] Certificats serveur générés
- [ ] Certificats client générés
- [ ] Chaîne de confiance vérifiée
- [ ] Notes détaillées dans `docs/learning-notes/semaine1-jour1.md`

**Template Notes** :
```bash
cd ~/workspace/quantum-security-project
cp docs/learning-notes/TEMPLATE.md \
   docs/learning-notes/semaine1-jour1.md

# Éditer avec vos notes
vim docs/learning-notes/semaine1-jour1.md
```

### Jour 2 : Lab 1.2 - mTLS avec Nginx

**Objectif** : Comprendre mutual TLS en pratique

```bash
cd ~/workspace/quantum-security-project/labs/openssl

# Utiliser les certificats de Lab 1.1
# Configurer Nginx pour mTLS
sudo vim /etc/nginx/sites-available/mtls-demo

# Configuration Nginx
```

**Configuration Nginx** :
```nginx
server {
    listen 443 ssl;
    server_name mtls-demo.local;

    # Certificat serveur
    ssl_certificate /path/to/server.cert.pem;
    ssl_certificate_key /path/to/server.key.pem;

    # CA pour vérifier clients
    ssl_client_certificate /path/to/ca.cert.pem;
    ssl_verify_client on;

    # TLS 1.3 seulement
    ssl_protocols TLSv1.3;
    ssl_prefer_server_ciphers on;

    location / {
        return 200 "mTLS Success! Client: $ssl_client_s_dn\n";
        add_header Content-Type text/plain;
    }
}
```

**Tests** :
```bash
# Test sans certificat client (devrait échouer)
curl https://mtls-demo.local

# Test avec certificat client (devrait réussir)
curl --cert client.cert.pem \
     --key client.key.pem \
     --cacert ca.cert.pem \
     https://mtls-demo.local
```

**Livrables** :
- [ ] Nginx avec mTLS fonctionnel
- [ ] Tests réussis
- [ ] Wireshark capture du handshake
- [ ] Notes jour 2

### Jour 3-4 : Lab 1.3-1.4 - Post-Quantum Crypto

**Objectif** : Comprendre et utiliser ML-KEM et ML-DSA

#### Jour 3 : Installation et Exploration liboqs

```bash
cd ~/workspace/quantum-security-project/labs/liboqs

# Vérifier installation
ls -la /usr/local/include/oqs/
ls -la /usr/local/lib/liboqs.*

# Lister algorithmes disponibles
cat > list-algorithms.c << 'EOF'
#include <stdio.h>
#include <oqs/oqs.h>

int main() {
    printf("=== KEM Algorithms ===\n");
    for (size_t i = 0; i < OQS_KEM_algs_length; i++) {
        const char *alg = OQS_KEM_alg_identifier(i);
        printf("  %s\n", alg);
    }
    
    printf("\n=== Signature Algorithms ===\n");
    for (size_t i = 0; i < OQS_SIG_algs_length; i++) {
        const char *alg = OQS_SIG_alg_identifier(i);
        printf("  %s\n", alg);
    }
    
    return 0;
}
EOF

gcc list-algorithms.c -o list-algorithms -loqs
./list-algorithms
```

**Attendu** :
```
=== KEM Algorithms ===
  ML-KEM-512
  ML-KEM-768
  ML-KEM-1024
  ...

=== Signature Algorithms ===
  ML-DSA-44
  ML-DSA-65
  ML-DSA-87
  ...
```

#### Jour 4 : Tests ML-KEM et ML-DSA

**Lab 1.4 : ML-KEM (Key Encapsulation)**

```bash
cd ~/workspace/quantum-security-project/labs/liboqs

# Créer test ML-KEM
cat > test-mlkem.c << 'EOF'
#include <stdio.h>
#include <string.h>
#include <oqs/oqs.h>

int main() {
    OQS_KEM *kem = OQS_KEM_new(OQS_KEM_alg_ml_kem_768);
    if (kem == NULL) {
        fprintf(stderr, "ML-KEM-768 not supported\n");
        return 1;
    }
    
    printf("Algorithm: %s\n", kem->method_name);
    printf("Public key size: %zu bytes\n", kem->length_public_key);
    printf("Secret key size: %zu bytes\n", kem->length_secret_key);
    printf("Ciphertext size: %zu bytes\n", kem->length_ciphertext);
    printf("Shared secret size: %zu bytes\n", kem->length_shared_secret);
    
    // Allocate memory
    uint8_t *public_key = malloc(kem->length_public_key);
    uint8_t *secret_key = malloc(kem->length_secret_key);
    uint8_t *ciphertext = malloc(kem->length_ciphertext);
    uint8_t *shared_secret_e = malloc(kem->length_shared_secret);
    uint8_t *shared_secret_d = malloc(kem->length_shared_secret);
    
    // Generate keypair
    printf("\n1. Generating keypair...\n");
    OQS_KEM_keypair(kem, public_key, secret_key);
    printf("   ✓ Keypair generated\n");
    
    // Encapsulate
    printf("\n2. Encapsulating shared secret...\n");
    OQS_KEM_encaps(kem, ciphertext, shared_secret_e, public_key);
    printf("   ✓ Shared secret encapsulated\n");
    printf("   Shared secret (first 16 bytes): ");
    for (int i = 0; i < 16; i++) {
        printf("%02x", shared_secret_e[i]);
    }
    printf("...\n");
    
    // Decapsulate
    printf("\n3. Decapsulating shared secret...\n");
    OQS_KEM_decaps(kem, shared_secret_d, ciphertext, secret_key);
    printf("   ✓ Shared secret decapsulated\n");
    
    // Verify
    if (memcmp(shared_secret_e, shared_secret_d, kem->length_shared_secret) == 0) {
        printf("\n✅ SUCCESS: Shared secrets match!\n");
    } else {
        printf("\n❌ FAILURE: Shared secrets don't match!\n");
    }
    
    // Cleanup
    free(public_key);
    free(secret_key);
    free(ciphertext);
    free(shared_secret_e);
    free(shared_secret_d);
    OQS_KEM_free(kem);
    
    return 0;
}
EOF

gcc test-mlkem.c -o test-mlkem -loqs
./test-mlkem
```

**Lab 1.5 : ML-DSA (Signatures)**

```bash
cat > test-mldsa.c << 'EOF'
#include <stdio.h>
#include <string.h>
#include <oqs/oqs.h>

int main() {
    OQS_SIG *sig = OQS_SIG_new(OQS_SIG_alg_ml_dsa_65);
    if (sig == NULL) {
        fprintf(stderr, "ML-DSA-65 not supported\n");
        return 1;
    }
    
    printf("Algorithm: %s\n", sig->method_name);
    printf("Public key size: %zu bytes\n", sig->length_public_key);
    printf("Secret key size: %zu bytes\n", sig->length_secret_key);
    printf("Signature size: %zu bytes\n", sig->length_signature);
    
    // Message to sign
    const char *message = "Hello, Post-Quantum World!";
    size_t message_len = strlen(message);
    
    // Allocate memory
    uint8_t *public_key = malloc(sig->length_public_key);
    uint8_t *secret_key = malloc(sig->length_secret_key);
    uint8_t *signature = malloc(sig->length_signature);
    size_t signature_len;
    
    // Generate keypair
    printf("\n1. Generating keypair...\n");
    OQS_SIG_keypair(sig, public_key, secret_key);
    printf("   ✓ Keypair generated\n");
    
    // Sign message
    printf("\n2. Signing message: \"%s\"\n", message);
    OQS_SIG_sign(sig, signature, &signature_len, 
                 (const uint8_t *)message, message_len, secret_key);
    printf("   ✓ Message signed\n");
    printf("   Signature size: %zu bytes\n", signature_len);
    
    // Verify signature
    printf("\n3. Verifying signature...\n");
    if (OQS_SIG_verify(sig, (const uint8_t *)message, message_len,
                       signature, signature_len, public_key) == OQS_SUCCESS) {
        printf("   ✅ SUCCESS: Signature is valid!\n");
    } else {
        printf("   ❌ FAILURE: Signature is invalid!\n");
    }
    
    // Test with modified message
    printf("\n4. Testing with tampered message...\n");
    const char *tampered = "Hello, Post-Quantum World?";
    if (OQS_SIG_verify(sig, (const uint8_t *)tampered, strlen(tampered),
                       signature, signature_len, public_key) == OQS_SUCCESS) {
        printf("   ❌ FAILURE: Tampered message verified (should not happen)!\n");
    } else {
        printf("   ✅ SUCCESS: Tampered message rejected!\n");
    }
    
    // Cleanup
    free(public_key);
    free(secret_key);
    free(signature);
    OQS_SIG_free(sig);
    
    return 0;
}
EOF

gcc test-mldsa.c -o test-mldsa -loqs
./test-mldsa
```

**Livrables Jour 3-4** :
- [ ] liboqs fonctionnel
- [ ] ML-KEM-768 testé
- [ ] ML-DSA-65 testé
- [ ] Comparaison tailles (classique vs PQC)
- [ ] Notes détaillées

### Jour 5-6 : Benchmarks et Comparaisons

**Objectif** : Mesurer performances PQC vs Classique

```bash
cd ~/workspace/quantum-security-project/labs/liboqs

cat > benchmark.c << 'EOF'
#include <stdio.h>
#include <time.h>
#include <oqs/oqs.h>

#define ITERATIONS 1000

double benchmark_kem(const char *alg_name) {
    OQS_KEM *kem = OQS_KEM_new(alg_name);
    if (!kem) return -1;
    
    uint8_t *pk = malloc(kem->length_public_key);
    uint8_t *sk = malloc(kem->length_secret_key);
    uint8_t *ct = malloc(kem->length_ciphertext);
    uint8_t *ss_e = malloc(kem->length_shared_secret);
    uint8_t *ss_d = malloc(kem->length_shared_secret);
    
    clock_t start = clock();
    
    for (int i = 0; i < ITERATIONS; i++) {
        OQS_KEM_keypair(kem, pk, sk);
        OQS_KEM_encaps(kem, ct, ss_e, pk);
        OQS_KEM_decaps(kem, ss_d, ct, sk);
    }
    
    clock_t end = clock();
    double time_spent = (double)(end - start) / CLOCKS_PER_SEC;
    
    free(pk); free(sk); free(ct); free(ss_e); free(ss_d);
    OQS_KEM_free(kem);
    
    return time_spent / ITERATIONS * 1000; // ms per operation
}

int main() {
    printf("=== KEM Performance Benchmark (%d iterations) ===\n\n", ITERATIONS);
    
    const char *algorithms[] = {
        "ML-KEM-512",
        "ML-KEM-768",
        "ML-KEM-1024"
    };
    
    for (int i = 0; i < 3; i++) {
        double time = benchmark_kem(algorithms[i]);
        printf("%s: %.3f ms/op\n", algorithms[i], time);
    }
    
    return 0;
}
EOF

gcc benchmark.c -o benchmark -loqs
./benchmark > benchmark-results.txt
cat benchmark-results.txt
```

**Créer tableau comparatif** :

```bash
cat > compare.md << 'EOF'
# Comparaison Cryptographie Classique vs Post-Quantique

## Tailles de Clés

| Algorithme | Clé Publique | Clé Privée | Signature/CT |
|------------|-------------|------------|--------------|
| RSA-2048   | 256 bytes   | 1024 bytes | 256 bytes    |
| ECDSA P-256| 64 bytes    | 32 bytes   | 64 bytes     |
| ML-KEM-768 | 1184 bytes  | 2400 bytes | 1088 bytes   |
| ML-DSA-65  | 1952 bytes  | 4032 bytes | 3309 bytes   |

## Performances

| Opération | RSA-2048 | ML-KEM-768 | Ratio |
|-----------|----------|------------|-------|
| KeyGen    | ~10 ms   | ~0.5 ms    | 20x   |
| Encaps    | ~1 ms    | ~0.8 ms    | 1.25x |
| Decaps    | ~10 ms   | ~1.2 ms    | 8.3x  |

## Sécurité Quantique

| Algorithme | Sécurité Classique | Sécurité Quantique |
|------------|-------------------|-------------------|
| RSA-2048   | 112 bits          | ~0 bits (Shor)    |
| ECDSA-256  | 128 bits          | ~0 bits (Shor)    |
| ML-KEM-768 | ~192 bits         | ~128 bits         |
| ML-DSA-65  | ~192 bits         | ~128 bits         |
EOF
```

**Livrables Jour 5-6** :
- [ ] Benchmarks complets
- [ ] Tableau comparatif
- [ ] Analyse des résultats
- [ ] Graphiques (optionnel)

### Jour 7 : Documentation et Synthèse

```bash
# Créer synthèse semaine 1
cd ~/workspace/quantum-security-project/docs/learning-notes

cat > semaine1-synthese.md << 'EOF'
# Synthèse Semaine 1 : Cryptographie

## Accomplissements

### Labs Complétés
- [x] Lab 1.1 : Certificats X.509
- [x] Lab 1.2 : mTLS avec Nginx
- [x] Lab 1.3 : Installation liboqs
- [x] Lab 1.4 : ML-KEM-768
- [x] Lab 1.5 : ML-DSA-65
- [x] Benchmarks et comparaisons

### Concepts Maîtrisés
- PKI et chaîne de confiance
- Mutual TLS
- Post-Quantum Cryptography
- ML-KEM (key encapsulation)
- ML-DSA (signatures digitales)

### Résultats Clés
- ML-KEM est ~8x plus rapide que RSA pour décapsulation
- Mais clés ~5x plus grandes
- Security quantique : 128 bits vs 0 bits pour RSA

## Questions pour Semaine 2
1. Comment intégrer PQC avec SPIFFE?
2. Performance impact sur mTLS à scale?
3. Transition path RSA → PQC?

## Prochaines Étapes
- Semaine 2 : Zero-Trust et SPIFFE
- Objectif : Comprendre architecture ZT
- Lab focus : SPIRE déploiement
EOF
```

**Commit Git** :
```bash
cd ~/workspace/quantum-security-project
git add .
git commit -m "✅ Week 1 Complete: Crypto foundations + PQC

- Lab 1.1: X.509 certificates mastered
- Lab 1.2: mTLS with Nginx working
- Lab 1.3-1.5: liboqs + ML-KEM + ML-DSA tested
- Benchmarks: PQC vs Classical comparison
- Documentation: Complete notes + synthesis

Next: Week 2 - Zero-Trust architecture"

git push
```

---

## 🗓️ SEMAINE 2-3 : Preview

### Semaine 2 : Zero-Trust + SPIFFE
- Jour 8-9 : Architecture Zero-Trust (NIST SP 800-207)
- Jour 10-12 : SPIRE déploiement local
- Jour 13-14 : mTLS automatique avec SPIFFE

### Semaine 3 : QKD + Synthèse
- Jour 15-16 : QKD simulation (BB84)
- Jour 17-18 : Geneva Quantum Network
- Jour 19-21 : État de l'art initial

---

## 📝 Checklist Quotidienne

```bash
# Chaque jour
□ Commencer à 9h00
□ Lab du jour (3-4h pratique)
□ Pause déjeuner
□ Approfondissement (2-3h)
□ Documentation (1h)
□ Git commit
□ Préparation lendemain
```

---

## 🆘 Support

### En Cas de Problème

**SSH ne marche pas ?**
```bash
# Vérifier Security Group
terraform output security_group_id
aws ec2 describe-security-groups --group-ids <SG_ID>

# Votre IP a changé?
MY_NEW_IP=$(curl -s ifconfig.me)
terraform apply -var="my_ip=$MY_NEW_IP"
```

**liboqs ne compile pas ?**
```bash
# Vérifier dépendances
sudo apt install -y cmake ninja-build libssl-dev

# Re-compiler
cd ~/liboqs
rm -rf build && mkdir build && cd build
cmake -GNinja .. -DCMAKE_INSTALL_PREFIX=/usr/local
ninja && sudo ninja install
```

**Instance lente ?**
```bash
# Upgrade à t3.medium
cd ~/quantum-security-project/terraform/phase1
terraform apply -var="instance_type=t3.medium"
```

---

## 🎯 Objectifs Phase 1 (Rappel)

À la fin des 3 semaines, vous aurez :

✅ **Maîtrise Technique**
- Cryptographie classique et PQC
- SPIFFE/SPIRE
- Architecture Zero-Trust

✅ **Livrables**
- 11+ labs complétés
- 15+ pages de notes
- Code testé et documenté
- Benchmarks PQC vs Classique

✅ **Préparation Phase 2**
- Fondations solides
- Compréhension profonde
- Prêt pour POC recherche

---

**VOUS ÊTES PRÊT !**

**Action maintenant** : Déployer l'infrastructure et commencer Lab 1.1 ! 🚀
