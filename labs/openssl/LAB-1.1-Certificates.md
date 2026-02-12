# Lab 1.1 : Génération de Certificats X.509 avec OpenSSL

## 🎯 Objectifs
- Comprendre l'architecture PKI (Public Key Infrastructure)
- Créer une autorité de certification (CA) racine
- Générer des certificats serveur et client
- Vérifier la chaîne de confiance

## 📚 Prérequis
- OpenSSL installé (version 3.x recommandée)
- Connaissances de base en cryptographie asymétrique

## 🔧 Étape 1 : Préparation de l'Environnement

### Vérifier l'installation d'OpenSSL
```bash
openssl version -a
```

### Créer la structure de dossiers
```bash
cd labs/openssl
mkdir -p ca/{root,intermediate,certs,crl,newcerts,private}
chmod 700 ca/private
cd ca
```

### Initialiser les fichiers nécessaires
```bash
# Index de la CA
touch root/index.txt
echo 1000 > root/serial

# Pour les CRL (Certificate Revocation Lists)
echo 1000 > root/crlnumber
```

## 📄 Étape 2 : Configuration de la CA Racine

### Créer le fichier de configuration
Créez `root/openssl-root.cnf` :

```ini
[ ca ]
default_ca = CA_default

[ CA_default ]
dir               = ./root
certs             = $dir/certs
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
RANDFILE          = $dir/private/.rand

private_key       = $dir/private/ca.key.pem
certificate       = $dir/certs/ca.cert.pem

crlnumber         = $dir/crlnumber
crl               = $dir/crl/ca.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

default_md        = sha256
name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_strict

[ policy_strict ]
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits        = 4096
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256
x509_extensions     = v3_ca

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

countryName_default             = CH
stateOrProvinceName_default     = Geneva
localityName_default            = Geneva
0.organizationName_default      = Quantum Security Lab
organizationalUnitName_default  = Security Research
emailAddress_default            = admin@quantumsec.lab

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_intermediate_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ server_cert ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ crl_ext ]
authorityKeyIdentifier=keyid:always

[ ocsp ]
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning
```

## 🔐 Étape 3 : Créer la CA Racine

### Générer la clé privée de la CA
```bash
openssl genrsa -aes256 -out root/private/ca.key.pem 4096
chmod 400 root/private/ca.key.pem
```
**⚠️ Attention** : Utilisez un mot de passe fort ! Notez-le de manière sécurisée.

### Créer le certificat auto-signé de la CA
```bash
openssl req -config root/openssl-root.cnf \
    -key root/private/ca.key.pem \
    -new -x509 -days 7300 -sha256 -extensions v3_ca \
    -out root/certs/ca.cert.pem
```

Remplissez les informations :
```
Country Name: CH
State or Province: Geneva
Locality: Geneva
Organization: Quantum Security Lab
Organizational Unit: Root CA
Common Name: Quantum Security Root CA
Email: root-ca@quantumsec.lab
```

### Vérifier le certificat de la CA
```bash
openssl x509 -noout -text -in root/certs/ca.cert.pem
```

**Points à vérifier** :
- ✅ Signature Algorithm: sha256WithRSAEncryption
- ✅ Validity: 20 ans (7300 jours)
- ✅ Subject Key Identifier présent
- ✅ Basic Constraints: CA:TRUE

## 🖥️ Étape 4 : Générer un Certificat Serveur

### Créer la clé privée du serveur
```bash
openssl genrsa -out private/server.key.pem 2048
chmod 400 private/server.key.pem
```

### Créer la demande de certificat (CSR)
```bash
openssl req -config root/openssl-root.cnf \
    -key private/server.key.pem \
    -new -sha256 -out certs/server.csr.pem
```

Informations pour le serveur :
```
Country Name: CH
State or Province: Geneva
Locality: Geneva
Organization: Quantum Security Lab
Organizational Unit: Web Services
Common Name: server.quantumsec.lab
Email: webmaster@quantumsec.lab
```

### Signer le certificat serveur avec la CA
```bash
openssl ca -config root/openssl-root.cnf \
    -extensions server_cert -days 375 -notext -md sha256 \
    -in certs/server.csr.pem \
    -out certs/server.cert.pem
```

### Vérifier le certificat serveur
```bash
openssl x509 -noout -text -in certs/server.cert.pem
```

**Points à vérifier** :
- ✅ Issuer: Quantum Security Root CA
- ✅ Subject: server.quantumsec.lab
- ✅ Extended Key Usage: TLS Web Server Authentication
- ✅ Validity: 375 jours

## 👤 Étape 5 : Générer un Certificat Client

### Créer la clé privée du client
```bash
openssl genrsa -out private/client.key.pem 2048
chmod 400 private/client.key.pem
```

### Créer la CSR du client
```bash
openssl req -config root/openssl-root.cnf \
    -key private/client.key.pem \
    -new -sha256 -out certs/client.csr.pem
```

Informations pour le client :
```
Country Name: CH
State or Province: Geneva
Locality: Geneva
Organization: Quantum Security Lab
Organizational Unit: Research Team
Common Name: Alice Researcher
Email: alice@quantumsec.lab
```

### Signer le certificat client
```bash
openssl ca -config root/openssl-root.cnf \
    -extensions usr_cert -days 375 -notext -md sha256 \
    -in certs/client.csr.pem \
    -out certs/client.cert.pem
```

### Vérifier le certificat client
```bash
openssl x509 -noout -text -in certs/client.cert.pem
```

## ✅ Étape 6 : Vérifier la Chaîne de Confiance

### Vérifier que le certificat serveur est bien signé par la CA
```bash
openssl verify -CAfile root/certs/ca.cert.pem certs/server.cert.pem
```

Résultat attendu : `certs/server.cert.pem: OK`

### Vérifier le certificat client
```bash
openssl verify -CAfile root/certs/ca.cert.pem certs/client.cert.pem
```

### Afficher la chaîne complète
```bash
cat certs/server.cert.pem root/certs/ca.cert.pem > certs/server-chain.pem
openssl verify -CAfile root/certs/ca.cert.pem certs/server-chain.pem
```

## 🔍 Étape 7 : Analyse Avancée

### Comparer les certificats
```bash
# Afficher uniquement le sujet et l'émetteur
openssl x509 -noout -subject -issuer -in root/certs/ca.cert.pem
openssl x509 -noout -subject -issuer -in certs/server.cert.pem
```

### Extraire la clé publique
```bash
# Du certificat serveur
openssl x509 -in certs/server.cert.pem -pubkey -noout > certs/server-public.key

# De la clé privée serveur
openssl rsa -in private/server.key.pem -pubout -out private/server-public-from-private.key

# Comparer les deux
diff certs/server-public.key private/server-public-from-private.key
```

### Vérifier les dates d'expiration
```bash
openssl x509 -noout -dates -in certs/server.cert.pem
```

## 📊 Résultats Attendus

Après ce lab, vous devriez avoir :

```
ca/
├── root/
│   ├── certs/
│   │   └── ca.cert.pem          # Certificat CA racine
│   ├── private/
│   │   └── ca.key.pem           # Clé privée CA (protégée)
│   ├── index.txt                # Base de données CA
│   └── serial                   # Numéro de série
├── certs/
│   ├── server.cert.pem          # Certificat serveur
│   ├── server.csr.pem           # CSR serveur
│   ├── server-chain.pem         # Chaîne complète
│   ├── client.cert.pem          # Certificat client
│   └── client.csr.pem           # CSR client
└── private/
    ├── server.key.pem           # Clé privée serveur
    └── client.key.pem           # Clé privée client
```

## 🎓 Concepts Clés Appris

1. **CA Racine** : Autorité auto-signée de confiance
2. **CSR** : Certificate Signing Request
3. **Chaîne de confiance** : CA → Certificat intermédiaire/feuille
4. **Extensions X.509** : keyUsage, extendedKeyUsage, basicConstraints
5. **Durée de validité** : CA (20 ans) vs Certificats (375 jours)

## 🔄 Exercices Supplémentaires

1. **Créer une CA intermédiaire** : Ajoutez un niveau dans la hiérarchie
2. **Révoquer un certificat** : Utilisez `openssl ca -revoke`
3. **Générer une CRL** : Liste de révocation
4. **Créer un certificat wildcard** : `*.quantumsec.lab`
5. **Test avec curl** : Utiliser les certificats pour HTTPS

## ❓ Questions de Compréhension

1. Pourquoi la clé privée de la CA doit-elle être protégée par mot de passe ?
2. Quelle est la différence entre `server_cert` et `usr_cert` extensions ?
3. Pourquoi les certificats ont-ils une durée de validité limitée ?
4. Que se passe-t-il si on perd la clé privée de la CA ?
5. Comment vérifier qu'un certificat n'a pas été révoqué ?

## 📝 Notes pour le Lab 1.2

Le prochain lab utilisera ces certificats pour configurer mTLS avec Nginx.  
Assurez-vous de bien comprendre la structure avant de continuer.

---

**Temps estimé** : 2-3 heures  
**Difficulté** : ⭐⭐/5  
**Prérequis suivant** : Lab 1.2 - Configuration mTLS avec Nginx
