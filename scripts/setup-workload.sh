#!/bin/bash
set -e

echo "============================================"
echo "  Setting up SPIRE Agent & Workload"
echo "============================================"

# Variables
SPIRE_VERSION="1.8.7"
SPIRE_URL="https://github.com/spiffe/spire/releases/download/v${SPIRE_VERSION}/spire-${SPIRE_VERSION}-linux-amd64-musl.tar.gz"
INSTALL_DIR="/opt/spire"
SPIRE_SERVER=${SPIRE_SERVER:-"10.0.0.10"}

# Update system
echo "[1/8] Updating system..."
apt-get update -qq
apt-get install -y curl wget tar build-essential cmake ninja-build git python3 python3-pip

# Download SPIRE
echo "[2/8] Downloading SPIRE v${SPIRE_VERSION}..."
cd /tmp
wget -q ${SPIRE_URL}
tar xzf spire-${SPIRE_VERSION}-linux-amd64-musl.tar.gz

# Install SPIRE Agent
echo "[3/8] Installing SPIRE Agent..."
mkdir -p ${INSTALL_DIR}/{bin,conf,data,agent}
cp -r spire-${SPIRE_VERSION}/bin/* ${INSTALL_DIR}/bin/
cp -r spire-${SPIRE_VERSION}/conf/agent/* ${INSTALL_DIR}/conf/

# Create SPIRE Agent config
echo "[4/8] Creating SPIRE Agent configuration..."
cat > ${INSTALL_DIR}/conf/agent.conf <<EOF
agent {
    data_dir = "/opt/spire/agent/data"
    log_level = "DEBUG"
    server_address = "${SPIRE_SERVER}"
    server_port = "8081"
    socket_path = "/tmp/spire-agent/public/api.sock"
    trust_domain = "quantum.lab"
}

plugins {
    NodeAttestor "join_token" {
        plugin_data {}
    }

    KeyManager "memory" {
        plugin_data {}
    }

    WorkloadAttestor "unix" {
        plugin_data {}
    }
}

health_checks {
    listener_enabled = true
    bind_address = "127.0.0.1"
    bind_port = "8082"
    live_path = "/live"
    ready_path = "/ready"
}
EOF

# Create socket directory
mkdir -p /tmp/spire-agent/public
chmod 755 /tmp/spire-agent/public

# Create systemd service for agent
echo "[5/8] Creating SPIRE Agent systemd service..."
cat > /etc/systemd/system/spire-agent.service <<'EOF'
[Unit]
Description=SPIRE Agent
After=network.target

[Service]
Type=simple
User=root
ExecStart=/opt/spire/bin/spire-agent run -config /opt/spire/conf/agent.conf
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Install liboqs (Post-Quantum Crypto)
echo "[6/8] Installing liboqs..."
cd /tmp
git clone --depth 1 --branch main https://github.com/open-quantum-safe/liboqs.git
cd liboqs
mkdir -p build && cd build
cmake -GNinja -DCMAKE_INSTALL_PREFIX=/usr/local ..
ninja
ninja install
ldconfig

# Verify liboqs
echo "liboqs installed successfully!"
ls -la /usr/local/lib/liboqs.* || echo "Note: liboqs libraries may have different names"

# Install Python tools for testing
echo "[7/8] Installing Python dependencies..."
pip3 install --quiet flask cryptography

# Add SPIRE to PATH
cat > /etc/profile.d/spire.sh <<'EOF'
export PATH=$PATH:/opt/spire/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
EOF

# Create helper script for workload registration
echo "[8/8] Creating helper scripts..."
cat > /usr/local/bin/register-workload.sh <<'EOF'
#!/bin/bash
# Helper script to register workload with SPIRE Server
# Usage: register-workload.sh <workload-name> <process-path>

WORKLOAD_NAME=${1:-"app"}
PROCESS_PATH=${2:-"/usr/bin/python3"}
SPIRE_SERVER=${SPIRE_SERVER:-"10.0.0.10"}

echo "Registering workload: ${WORKLOAD_NAME}"
echo "Process path: ${PROCESS_PATH}"
echo "SPIRE Server: ${SPIRE_SERVER}"

ssh vagrant@${SPIRE_SERVER} "sudo /opt/spire/bin/spire-server entry create \
    -spiffeID spiffe://quantum.lab/workload/${WORKLOAD_NAME} \
    -parentID spiffe://quantum.lab/agent \
    -selector unix:path:${PROCESS_PATH}"

echo "Workload registered successfully!"
EOF
chmod +x /usr/local/bin/register-workload.sh

# Note: Agent will be started after getting join token from server
echo ""
echo "============================================"
echo "  SPIRE Agent Setup Complete!"
echo "============================================"
echo ""
echo "⚠️  IMPORTANT: Agent is NOT started yet!"
echo ""
echo "To start the agent, you need a join token from SPIRE Server:"
echo ""
echo "1. SSH to SPIRE Server:"
echo "   vagrant ssh spire-server"
echo ""
echo "2. Generate join token:"
echo "   sudo /opt/spire/bin/spire-server token generate -spiffeID spiffe://quantum.lab/agent"
echo ""
echo "3. SSH to this workload and start agent with token:"
echo "   sudo /opt/spire/bin/spire-agent run -config /opt/spire/conf/agent.conf -joinToken <TOKEN> &"
echo ""
echo "Or enable the systemd service (after join):"
echo "   sudo systemctl enable spire-agent"
echo "   sudo systemctl start spire-agent"
echo ""
echo "liboqs installed at: /usr/local/lib"
echo "Socket path: /tmp/spire-agent/public/api.sock"
echo ""
