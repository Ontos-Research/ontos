#!/usr/bin/env bash
# Ontos self-hosted installer — one command to a running control plane + agent.
#
# Three ways to run:
#   * From the repo (online): builds the images from source.
#   * From an offline bundle (air-gapped): loads pre-built images (see build-bundle.sh).
#   * From a registry (GHCR): pulls prebuilt images (needs ONTOS_REGISTRY in .env).
# The mode is auto-detected; override with --offline / --build / --registry.
#
# Usage:  ./install.sh [--update] [--offline|--build|--registry] [--skip-preflight] [--no-build]
#   --update          reuse existing .env + data, refresh images, recreate containers
#   --offline         force offline mode (load images.tar.gz, no build)
#   --build           force build mode (compile images from the repo)
#   --registry        force registry mode (docker compose pull from ONTOS_REGISTRY)
#   --skip-preflight  don't probe the LLM endpoint
#   --no-build        (build mode) start without rebuilding images
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

log()  { printf '\033[1;36m[ontos]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[ontos]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[ontos]\033[0m %s\n' "$*" >&2; exit 1; }

MODE=""; UPDATE=0; SKIP_PREFLIGHT=0; BUILD_FLAG="--build"; FORCE_RECREATE=""
for arg in "$@"; do
  case "$arg" in
    --offline)  MODE=offline ;;
    --build)    MODE=build ;;
    --registry) MODE=registry ;;
    --update)  UPDATE=1; FORCE_RECREATE="--force-recreate" ;;
    --skip-preflight) SKIP_PREFLIGHT=1 ;;
    --no-build) BUILD_FLAG="" ;;
    -h|--help) sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "Unknown argument: $arg" ;;
  esac
done

# --- 1. Detect container engine + compose ----------------------------------
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  ENGINE=docker; COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  ENGINE=docker; COMPOSE="docker-compose"
elif command -v podman >/dev/null 2>&1 && podman compose version >/dev/null 2>&1; then
  ENGINE=podman; COMPOSE="podman compose"
elif command -v podman-compose >/dev/null 2>&1; then
  ENGINE=podman; COMPOSE="podman-compose"
else
  die "No container engine found. Install Docker (with the compose plugin) or Podman."
fi

# --- 2. Resolve mode (offline vs build) ------------------------------------
if [ -z "$MODE" ]; then
  if [ -f .env ] && grep -q '^ONTOS_REGISTRY=.' .env; then MODE=registry
  elif [ -f images.tar.gz ]; then MODE=offline
  elif [ -f docker-compose.build.yml ]; then MODE=build
  else die "Cannot determine mode: set ONTOS_REGISTRY in .env (registry), or provide images.tar.gz (offline) / docker-compose.build.yml (build)."
  fi
fi
case "$MODE" in
  offline|registry) FILES="-f docker-compose.yml"; BUILD_FLAG="" ;;
  build) FILES="-f docker-compose.yml -f docker-compose.build.yml" ;;
esac
log "Engine: ${COMPOSE} · mode: ${MODE}$([ "$UPDATE" -eq 1 ] && echo ' · update')"

rand() { openssl rand -hex "${1:-16}" 2>/dev/null || python3 -c "import secrets,sys;print(secrets.token_hex(int(sys.argv[1])))" "${1:-16}"; }
ask() { # ask <var> <prompt> <default>
  local __var=$1 __prompt=$2 __default=${3:-} __reply=""
  if [ -t 0 ]; then
    read -r -p "$(printf '\033[1;36m? \033[0m%s%s: ' "$__prompt" "${__default:+ [$__default]}")" __reply || true
  fi
  printf -v "$__var" '%s' "${__reply:-$__default}"
}

# --- 3. Configure .env -----------------------------------------------------
DATADEX_PORT="${DATADEX_PORT:-8080}"
if [ "$UPDATE" -eq 1 ]; then
  [ -f .env ] || die "--update needs an existing .env — run ./install.sh first."
  set -a; . ./.env; set +a
  log "Reusing existing .env (data volume preserved)."
elif [ -f .env ]; then
  log ".env exists — reusing it (delete it to reconfigure)."
  set -a; . ./.env; set +a
else
  log "First run — configuring .env"
  POSTGRES_PASSWORD="$(rand 16)"
  DATADEX_SECRETS_KEY="$(rand 32)"
  ask DATADEX_SEED_LLM_PROVIDER "LLM provider (openai/groq)" "openai"
  ask DATADEX_SEED_LLM_API_KEY  "LLM API key (blank to configure later in the console)" ""
  case "$DATADEX_SEED_LLM_PROVIDER" in
    groq) default_model="openai/gpt-oss-120b" ;;
    *)    default_model="gpt-5.4-mini" ;;
  esac
  ask DATADEX_SEED_LLM_MODEL "LLM model" "$default_model"
  ask BASE_URL "OpenAI-compatible base URL (blank = public API)" ""
  DATADEX_OPENAI_RESPONSES_URL=""; DATADEX_GROQ_URL=""
  if [ -n "$BASE_URL" ]; then
    case "$DATADEX_SEED_LLM_PROVIDER" in
      groq) DATADEX_GROQ_URL="$BASE_URL" ;;
      *)    DATADEX_OPENAI_RESPONSES_URL="$BASE_URL" ;;
    esac
  fi
  ONTOS_REGISTRY="${ONTOS_REGISTRY:-}"; ONTOS_VERSION="${ONTOS_VERSION:-local}"
  if [ "$MODE" = registry ]; then
    ask _OWNER "GHCR owner (your GitHub username or org)" ""
    [ -n "$_OWNER" ] && ONTOS_REGISTRY="ghcr.io/${_OWNER}/"
    ask ONTOS_VERSION "Image version to pull" "latest"
  fi
  cat > .env <<EOF
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
DATADEX_SECRETS_KEY=$DATADEX_SECRETS_KEY
DATADEX_PORT=$DATADEX_PORT
DATADEX_AGENT_MAX_RUNS=${DATADEX_AGENT_MAX_RUNS:-4}
DATADEX_SEED_LLM_PROVIDER=$DATADEX_SEED_LLM_PROVIDER
DATADEX_SEED_LLM_API_KEY=$DATADEX_SEED_LLM_API_KEY
DATADEX_SEED_LLM_MODEL=$DATADEX_SEED_LLM_MODEL
DATADEX_OPENAI_RESPONSES_URL=$DATADEX_OPENAI_RESPONSES_URL
DATADEX_GROQ_URL=$DATADEX_GROQ_URL
ONTOS_REGISTRY=$ONTOS_REGISTRY
ONTOS_VERSION=$ONTOS_VERSION
EOF
  chmod 600 .env
  log "Wrote .env (secrets generated, mode 600)."
fi

# --- 3b. Backfill secrets (e.g. a copied .env.example with blank secrets) ----
for _v in POSTGRES_PASSWORD DATADEX_SECRETS_KEY; do
  eval "_cur=\${$_v:-}"
  if [ -z "$_cur" ]; then
    _n=16; [ "$_v" = DATADEX_SECRETS_KEY ] && _n=32
    _val="$(rand $_n)"; printf -v "$_v" '%s' "$_val"
    if [ -f .env ] && grep -q "^$_v=" .env; then
      python3 - "$_v" "$_val" <<'PY'
import re, sys
v, val = sys.argv[1], sys.argv[2]
s = open('.env').read()
open('.env', 'w').write(re.sub(rf'^{v}=.*$', f'{v}={val}', s, flags=re.M))
PY
    else
      printf '%s=%s\n' "$_v" "$_val" >> .env
    fi
    log "generated $_v"
  fi
done

# --- 4. LLM reachability preflight ------------------------------------------
if [ "$SKIP_PREFLIGHT" -eq 0 ] && [ -n "${DATADEX_SEED_LLM_API_KEY:-}" ]; then
  if [ -n "${DATADEX_OPENAI_RESPONSES_URL:-}${DATADEX_GROQ_URL:-}" ]; then
    probe="${DATADEX_OPENAI_RESPONSES_URL:-$DATADEX_GROQ_URL}"
  elif [ "${DATADEX_SEED_LLM_PROVIDER:-openai}" = "groq" ]; then
    probe="https://api.groq.com/openai/v1/models"
  else
    probe="https://api.openai.com/v1/models"
  fi
  log "Preflight: probing LLM endpoint…"
  code="$(curl -sS -o /dev/null -m 8 -w '%{http_code}' -H "Authorization: Bearer ${DATADEX_SEED_LLM_API_KEY}" "$probe" 2>/dev/null || echo 000)"
  if [ "$code" = "000" ]; then
    warn "LLM endpoint NOT reachable from this host ($probe)."
    warn "If egress is blocked, set DATADEX_OPENAI_RESPONSES_URL / DATADEX_GROQ_URL to an in-network endpoint in .env."
    warn "Continuing anyway (re-run with --skip-preflight to silence)."
  else
    log "LLM endpoint reachable (HTTP $code)."
  fi
fi

# --- 5. Offline: load images ------------------------------------------------
if [ "$MODE" = offline ]; then
  [ -f images.tar.gz ] || die "offline mode but images.tar.gz not found next to this script."
  log "Loading pre-built images ($ENGINE load)…"
  $ENGINE load -i images.tar.gz >/dev/null
fi

# --- 5b. Registry: pull images ----------------------------------------------
if [ "$MODE" = registry ]; then
  [ -n "${ONTOS_REGISTRY:-}" ] || die "registry mode needs ONTOS_REGISTRY in .env (e.g. ghcr.io/<owner>/)."
  log "Pulling images from ${ONTOS_REGISTRY}…"
  # shellcheck disable=SC2086
  $COMPOSE $FILES pull || die "Pull failed. If the packages are private: $ENGINE login ghcr.io -u <user>"
fi

# --- 6. Build + start -------------------------------------------------------
if [ "$MODE" = build ] && [ -n "$BUILD_FLAG" ]; then
  log "Building images and starting the stack (first build compiles the console + pulls base images — a few minutes)…"
else
  log "Starting the stack…"
fi
# shellcheck disable=SC2086
$COMPOSE $FILES up -d $BUILD_FLAG $FORCE_RECREATE

# --- 7. Wait for health -----------------------------------------------------
url="http://127.0.0.1:${DATADEX_PORT:-8080}/health"
log "Waiting for the control plane at ${url} …"
healthy=0
for _ in $(seq 1 60); do
  if curl -sf -m 3 "$url" >/dev/null 2>&1; then healthy=1; break; fi
  sleep 3
done
[ "$healthy" -eq 1 ] && log "Control plane healthy." || warn "Control plane not healthy yet. Inspect: $COMPOSE $FILES logs control-plane"

# --- 8. Summary -------------------------------------------------------------
verb=$([ "$UPDATE" -eq 1 ] && echo "updated" || echo "up")
cat <<EOF

  ✅ Ontos is ${verb}.
     Console : http://<this-host>:${DATADEX_PORT:-8080}/operator
     Health  : ${url}
     Agent   : bundled secure-agent (Oracle + SQL Server drivers baked in)

  Manage:
     $COMPOSE $FILES ps
     $COMPOSE $FILES logs -f control-plane
     ./install.sh --update      # after dropping in a newer bundle / pulling new source
     $COMPOSE $FILES down       # stop (keeps data)
     $COMPOSE $FILES down -v    # stop and wipe all data

EOF
