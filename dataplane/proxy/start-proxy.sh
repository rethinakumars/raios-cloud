#!/bin/bash
set -e

echo "[RAIOS] Starting Dataplane Proxy..."

# Load routes (future: dynamic reload)
ROUTES="/opt/raios/proxy/routes-aws.yaml"

# Start nginx
sudo nginx -g "daemon off;"

