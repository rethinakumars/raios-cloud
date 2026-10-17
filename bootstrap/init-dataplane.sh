#!/bin/bash
set -e

echo "[RAIOS] Initializing Dataplane Node..."

###############################################
# 1. System Update
###############################################
sudo dnf update -y

###############################################
# 2. Install Base Tools + Nginx
###############################################
sudo dnf install -y git unzip tar jq python3 python3-pip nginx

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
# 5. Install Proxy Scripts + Config
###############################################
echo "[RAIOS] Installing Proxy..."

PROXY_DIR="/opt/raios/proxy"
mkdir -p $PROXY_DIR

# Copy proxy scripts/configs from repo (adjust paths to your layout)
cp /opt/raios/raios-cloud/dataplane/proxy/start-proxy.sh $PROXY_DIR/
cp /opt/raios/raios-cloud/dataplane/proxy/nginx.conf $PROXY_DIR/
cp /opt/raios/raios-cloud/dataplane/proxy/routes-aws.yaml $PROXY_DIR/

sudo chmod +x $PROXY_DIR/start-proxy.sh

###############################################
# 6. Configure Nginx to use RAIOS proxy config
###############################################
echo "[RAIOS] Configuring Nginx..."

sudo cp $PROXY_DIR/nginx.conf /etc/nginx/nginx.conf

sudo systemctl enable nginx
sudo systemctl restart nginx

###############################################
# 7. Install Health Daemon
###############################################
echo "[RAIOS] Installing Health Daemon..."

HEALTH_DIR="/opt/raios/healthd"
mkdir -p $HEALTH_DIR

cp /opt/raios/raios-cloud/dataplane/healthd/healthd.sh $HEALTH_DIR/
sudo chmod +x $HEALTH_DIR/healthd.sh

###############################################
# 8. proxy.service (systemd)
###############################################
echo "[RAIOS] Installing proxy.service..."

sudo tee /etc/systemd/system/raios-proxy.service > /dev/null <<EOF
[Unit]
Description=RAIOS Dataplane Proxy
After=network.target nginx.service

[Service]
Type=simple
ExecStart=$PROXY_DIR/start-proxy.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

###############################################
# 9. healthd.service (systemd)
###############################################
echo "[RAIOS] Installing healthd.service..."

sudo tee /etc/systemd/system/raios-healthd.service > /dev/null <<EOF
[Unit]
Description=RAIOS Dataplane Health Daemon
After=network.target

[Service]
Type=simple
ExecStart=$HEALTH_DIR/healthd.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable raios-proxy raios-healthd
sudo systemctl restart raios-proxy raios-healthd

###############################################
# 10. Dataplane Identity File
###############################################
echo "role: dataplane" | sudo tee /etc/raios-node.yaml

###############################################
# 11. Final Status
###############################################
echo "[RAIOS] Dataplane Initialization Complete."
systemctl status nginx --no-pager
systemctl status raios-proxy --no-pager
systemctl status raios-healthd --no-pager

