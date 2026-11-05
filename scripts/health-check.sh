#!/usr/bin/env bash
#
# health-check.sh — Verify CLIProxyAPI is responding.
#
set -euo pipefail

TUNNEL_URL="${TUNNEL_URL:-http://localhost:8317}"
ACCESS_KEY="${CLIPROXY_ACCESS_KEY:-change-me}"

echo "=== CLIProxyAPI Health Check ==="
echo "Endpoint: $TUNNEL_URL"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $ACCESS_KEY" \
  --max-time 15 \
  "$TUNNEL_URL/v1/models" || echo "000")

if [[ "$HTTP_CODE" == "200" ]]; then
  echo "✅ Healthy — HTTP $HTTP_CODE"
  curl -s -H "Authorization: Bearer $ACCESS_KEY" \
    --max-time 15 "$TUNNEL_URL/v1/models" | head -c 300
  echo ""
else
  echo "❌ Unhealthy — HTTP $HTTP_CODE"
  exit 1
fi
