#!/usr/bin/env sh
# Bundled secure-agent entrypoint: wait for the control plane and for the seed to
# publish an enrollment token into the shared volume, then poll for runs.
set -e

API_URL="${DATADEX_API_URL:-http://control-plane:8080}"
TOKEN_FILE="${DATADEX_SEED_TOKEN_FILE:-/shared/agent.env}"

echo "[agent] waiting for control plane at ${API_URL}…"
until python3 -c "import sys,urllib.request; urllib.request.urlopen(sys.argv[1] + '/health', timeout=3)" "$API_URL" >/dev/null 2>&1; do
  sleep 2
done

echo "[agent] waiting for enrollment token…"
until [ -f "$TOKEN_FILE" ]; do
  sleep 2
done
# shellcheck disable=SC1090
. "$TOKEN_FILE"

echo "[agent] enrolled — polling for runs"
exec python3 agent.py poll-runs --api-url "$API_URL" --token "$DATADEX_AGENT_TOKEN"
