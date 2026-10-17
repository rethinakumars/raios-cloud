#!/bin/bash
set -e

echo "[RAIOS] Starting Floci + Docker bootstrap..."

###############################################
# 1. Install Docker
###############################################
if ! command -v docker &> /dev/null; then
    echo "[RAIOS] Installing Docker..."
    sudo dnf install -y docker || sudo apt install -y docker.io
    sudo systemctl enable --now docker
else
    echo "[RAIOS] Docker already installed."
fi

###############################################
# 2. Install Floci CLI
###############################################
if ! command -v floci &> /dev/null; then
    echo "[RAIOS] Installing Floci CLI..."
    curl -fsSL https://floci.io/install.sh | sh
else
    echo "[RAIOS] Floci CLI already installed."
fi

###############################################
# 3. Start Floci AWS Emulator
###############################################
echo "[RAIOS] Starting Floci AWS Emulator..."
floci start || true

echo "[RAIOS] Checking Floci status..."
floci status

echo "[RAIOS] Floci + Docker bootstrap complete."

