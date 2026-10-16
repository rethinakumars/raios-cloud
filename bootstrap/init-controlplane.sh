#!/bin/bash
set -e

echo "[RAIOS] Initializing Control Plane..."

###############################################
# 1. System Update
###############################################
sudo dnf update -y

###############################################
# 2. Install Base Tools
###############################################
sudo dnf install -y git unzip tar curl jq python3 python3-pip

###############################################
# 3. Create RAIOS Directory
###############################################
sudo mkdir -p /opt/raios
sudo chown $USER:$USER /opt/raios

###############################################
# 4. Clone or Update GitHub Repo
###############################################
if [ ! -d "/opt/raios/raios-cloud" ]; then
    echo "[RAIOS] Cloning repo..."
    git clone https://github.com/rethinakumars/raios-cloud.git /opt/raios/raios-cloud
else
    echo "[RAIOS] Updating repo..."
    cd /opt/raios/raios-cloud
    git pull
fi

###############################################
# 5. Install AWS CLI (v2)
###############################################
if ! command -v aws &> /dev/null; then
    echo "[RAIOS] Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip /tmp/awscliv2.zip -d /tmp
    sudo /tmp/aws/install
fi

###############################################
# 6. Install Floci (AWS emulator)
###############################################
FLOCI_DIR="/opt/raios/floci"

if [ ! -d "$FLOCI_DIR" ]; then
    echo "[RAIOS] Installing Floci..."
    mkdir -p $FLOCI_DIR
    cd $FLOCI_DIR

    # Replace with your floci download source
    curl -L https://example.com/floci-latest.tar.gz -o floci.tar.gz
    tar -xvf floci.tar.gz
fi

###############################################
# 7. Configure Floci
###############################################
echo "[RAIOS] Configuring Floci..."
cp /opt/raios/raios-cloud/controlplane/floci/config/* $FLOCI_DIR/

###############################################
# 8. Install Floci systemd service
###############################################
echo "[RAIOS] Installing floci.service..."

sudo tee /etc/systemd/system/floci.service > /dev/null <<EOF
[Unit]
Description=Floci AWS Emulator
After=network.target

[Service]
Type=simple
ExecStart=$FLOCI_DIR/floci --config $FLOCI_DIR/floci.yaml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable floci
sudo systemctl restart floci

###############################################
# 9. Install Orchestrator
###############################################
echo "[RAIOS] Setting up Python Orchestrator..."

ORCH_DIR="/opt/raios/orchestrator"
mkdir -p $ORCH_DIR
cp -r /opt/raios/raios-cloud/controlplane/orchestrator/* $ORCH_DIR/

###############################################
# 10. Orchestrator systemd service
###############################################
echo "[RAIOS] Installing raios-orchestrator.service..."

sudo tee /etc/systemd/system/raios-orchestrator.service > /dev/null <<EOF
[Unit]
Description=RAIOS Region Orchestrator
After=network.target floci.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 $ORCH_DIR/main.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable raios-orchestrator
sudo systemctl restart raios-orchestrator

###############################################
# 11. Controlplane Identity File
###############################################
echo "role: controlplane" | sudo tee /etc/raios-node.yaml

###############################################
# 12. Final Status
###############################################
echo "[RAIOS] Control Plane Initialization Complete."
systemctl status floci --no-pager
systemctl status raios-orchestrator --no-pager
