#!/bin/bash
set -e

echo "============================================"
echo "  Setting up SPIRE Server"
echo "============================================"

# Variables
SPIRE_VERSION="1.8.7"
SPIRE_URL="https://github.com/spiffe/spire/releases/download/v${SPIRE_VERSION}/spire-${SPIRE_VERSION}-linux-amd64-musl.tar.gz"
INSTALL_DIR="/opt/spire"

# Update system
echo "[1/8] Updating system..."
apt-get update -qq
apt-get install -y curl wget tar postgresql postgresql-contrib

# Download SPIRE
echo "[2/8] Downloading SPIRE v${SPIRE_VERSION}..."
cd /tmp
wget -q ${SPIRE_URL}
tar xzf spire-${SPIRE_VERSION}-linux-amd64-musl.tar.gz

# Install SPIRE
echo "[3/8] Installing SPIRE..."
mkdir -p ${INSTALL_DIR}/{bin,conf,data}
cp -r spire-${SPIRE_VERSION}/bin/* ${INSTALL_DIR}/bin/
cp -r spire-${SPIRE_VERSION}/conf/server/* ${INSTALL_DIR}/conf/

# Configure PostgreSQL
echo "[4/8] Configuring PostgreSQL..."
sudo -u postgres psql -c "CREATE DATABASE spire;"
sudo -u postgres psql -c "CREATE USER spire WITH ENCRYPTED PASSWORD 'spire';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE spire TO spire;"

# Create SPIRE Server config
echo "[5/8] Creating SPIRE Server configuration..."
cat > ${INSTALL_DIR}/conf/server.conf <<'EOF'
server {
    bind_address = "0.0.0.0"
    bind_port = "8081"
    trust_domain = "quantum.lab"
    data_dir = "/opt/spire/data"
    log_level = "DEBUG"
    
    ca_subject {
        country = ["CH"]
        organization = ["Quantum Security Lab"]
        common_name = "SPIRE Server CA"
    }
}

plugins {
    DataStore "sql" {
        plugin_data {
            database_type = "postgres"
            connection_string = "postgresql://spire:spire@localhost/spire?sslmode=disable"
        }
    }

    NodeAttestor "join_token" {
        plugin_data {}
    }

    KeyManager "memory" {
        plugin_data {}
    }
}

health_checks {
    listener_enabled = true
    bind_address = "0.0.0.0"
    bind_port = "8080"
    live_path = "/live"
    ready_path = "/ready"
}
EOF

# Create systemd service
echo "[6/8] Creating systemd service..."
cat > /etc/systemd/system/spire-server.service <<'EOF'
[Unit]
Description=SPIRE Server
After=network.target postgresql.service
Requires=postgresql.service

[Service]
Type=simple
User=root
ExecStart=/opt/spire/bin/spire-server run -config /opt/spire/conf/server.conf
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Add SPIRE to PATH
echo "[7/8] Adding SPIRE to PATH..."
cat > /etc/profile.d/spire.sh <<'EOF'
export PATH=$PATH:/opt/spire/bin
EOF

# Start SPIRE Server
echo "[8/8] Starting SPIRE Server..."
systemctl daemon-reload
systemctl enable spire-server
systemctl start spire-server

# Wait for SPIRE to be ready
echo "Waiting for SPIRE Server to be ready..."
for i in {1..30}; do
    if curl -s http://localhost:8080/ready > /dev/null 2>&1; then
        echo "✅ SPIRE Server is ready!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 2
done

# Show status
echo ""
echo "============================================"
echo "  SPIRE Server Setup Complete!"
echo "============================================"
echo ""
echo "Status:"
systemctl status spire-server --no-pager | head -10
echo ""
echo "Health check: http://10.0.0.10:8080/ready"
echo "SPIRE API: http://10.0.0.10:8081"
echo ""
echo "Useful commands:"
echo "  spire-server healthcheck"
echo "  spire-server token generate -spiffeID spiffe://quantum.lab/agent"
echo "  journalctl -u spire-server -f"
echo ""
