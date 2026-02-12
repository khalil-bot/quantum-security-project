#!/bin/bash
set -e

echo "============================================"
echo "  Setting up k3s (Lightweight Kubernetes)"
echo "============================================"

# Update system
echo "[1/4] Updating system..."
apt-get update -qq
apt-get install -y curl wget

# Install k3s
echo "[2/4] Installing k3s..."
curl -sfL https://get.k3s.io | sh -s - \
    --write-kubeconfig-mode 644 \
    --disable traefik \
    --node-name k3s-quantum

# Wait for k3s to be ready
echo "[3/4] Waiting for k3s to be ready..."
for i in {1..30}; do
    if kubectl get nodes > /dev/null 2>&1; then
        echo "✅ k3s is ready!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 2
done

# Install SPIFFE CSI Driver (optional for advanced usage)
echo "[4/4] Preparing for SPIFFE integration..."
cat > /tmp/spiffe-csi-driver.yaml <<'EOF'
# Placeholder for SPIFFE CSI Driver
# Will be configured in Week 3
apiVersion: v1
kind: Namespace
metadata:
  name: spiffe-system
EOF

kubectl apply -f /tmp/spiffe-csi-driver.yaml

# Setup kubectl for vagrant user
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
chmod 600 /home/vagrant/.kube/config

# Create welcome message
cat > /etc/motd <<'EOF'
╔════════════════════════════════════════════════╗
║    k3s Kubernetes Cluster - Quantum Project   ║
╚════════════════════════════════════════════════╝

Kubernetes cluster is ready!

📦 Cluster Info:
   kubectl get nodes
   kubectl cluster-info

🔧 Useful Commands:
   kubectl get pods -A
   kubectl get namespaces
   kubectl logs <pod-name>

📚 Next Steps:
   1. Deploy SPIFFE CSI Driver
   2. Create test workloads
   3. Test SPIFFE integration

EOF

echo ""
echo "============================================"
echo "  k3s Setup Complete!"
echo "============================================"
echo ""
kubectl get nodes
echo ""
echo "Kubeconfig: /etc/rancher/k3s/k3s.yaml"
echo "For vagrant user: ~/.kube/config"
echo ""
echo "Access from host:"
echo "  scp -P 2222 vagrant@localhost:/etc/rancher/k3s/k3s.yaml ~/.kube/quantum-k3s.yaml"
echo "  export KUBECONFIG=~/.kube/quantum-k3s.yaml"
echo "  kubectl get nodes"
echo ""
