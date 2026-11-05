#!/usr/bin/env bash
#
# signin-codex.sh — Run Codex device login on the hub via Docker.
# Run this from ~/cliproxyapi on the hub server.
#
set -euo pipefail

DATA_DIR="${DATA_DIR:-./data}"

echo "=== Codex Device Login ==="
echo "Mounting data dir: $DATA_DIR"

docker run --rm -it \
  -v "$(pwd)/$DATA_DIR:/app/data" \
  eceasy/cli-proxy-api:latest \
  -codex-device-login

echo ""
echo "=== Next ==="
echo "Complete the device code flow in your browser."
echo "Then verify in the management panel: https://<TUNNEL_URL>/management.html"
