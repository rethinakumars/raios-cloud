#!/bin/bash
set -e

###############################################
# 0. Install systemd unit if not installed
###############################################
SERVICE_FILE="/etc/systemd/system/raios-register.service"

if [ ! -f "$SERVICE_FILE" ]; then
    echo "[RAIOS] Installing auto-registration systemd unit..."

    sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=RAIOS Dataplane Auto Registration
After=network-online.target

[Service]
Type=oneshot
ExecStart=/opt/raios/node-register.sh

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable raios-register
fi

###############################################
# 1. Discover controlplane IP via metadata
###############################################
CONTROLPLANE_IP=$(curl -s http://localhost:8080/metadata/controlplane-ip | jq -r '.controlplane_ip')
ORCHESTRATOR_PORT="8080"

###############################################
# 2. Detect private IP
###############################################
PRIVATE_IP=$(hostname -I | awk '{print $1}')

###############################################
# 3. Detect node ID
###############################################
NODE_ID=$(hostname)

###############################################
# 4. Register with orchestrator
###############################################
echo "[RAIOS] Registering node ${NODE_ID} (${PRIVATE_IP}) with controlplane ${CONTROLPLANE_IP}..."

RESPONSE=$(curl -s -X POST http://${CONTROLPLANE_IP}:${ORCHESTRATOR_PORT}/register-node \
  -H "Content-Type: application/json" \
  -d "{\"id\": \"${NODE_ID}\", \"role\": \"dataplane\", \"ip\": \"${PRIVATE_IP}\"}")

echo "[RAIOS] Registration response: ${RESPONSE}"

