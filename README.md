# Ontos

Self-hosted, AI-agentic data integration platform. A **control plane** (API +
operator console) and a **secure agent** run on your own Linux host; the agent
connects out to your Oracle / SQL Server / PostgreSQL. Your data never leaves
your network — only metadata reaches the control plane, and verification of your
license is fully offline (works air-gapped).

## Before you install

- **A Linux host with Docker** (compose plugin), ~2 GB free disk, a free port.
- **Run it on an internal / trusted network** — behind your firewall or VPN. The
  console has **no built-in user authentication** (trusted-network model). Do not
  expose it directly to the public internet.
- **Network reachability** from the host to your data sources and to an LLM
  endpoint (OpenAI/Groq public API, or an in-network OpenAI-compatible endpoint).
- **A license key** — issued by Ontos Research. The images are free to download;
  a valid license is required to run.

## Install

**1. (Recommended) Verify the images are genuinely from Ontos Research.** They are
public and signed with [cosign](https://docs.sigstore.dev/); `cosign.pub` is in
this repo (no registry login needed):

```bash
cosign verify --key cosign.pub ghcr.io/ontos-research/ontos/control-plane:0.1.0
cosign verify --key cosign.pub ghcr.io/ontos-research/ontos/secure-agent:0.1.0
```

**2. Configure and run:**

```bash
git clone https://github.com/ontos-research/ontos.git
cd ontos
cp .env.example .env
#   edit .env → paste ONTOS_LICENSE and DATADEX_SEED_LLM_API_KEY
./install.sh
```

`install.sh` verifies the license, pulls the images, generates secrets, seeds a
workspace, and boots. Open:

```
http://<this-host>:8080/operator
```

The control plane **will not start without a valid license** (`ONTOS_LICENSE`, or a
file mounted at `/app/license.key`). An admin user + default workspace are seeded
automatically and a secure agent auto-enrolls — set your workspace LLM key in
**Settings → Access** if you left it blank.

## Connecting your data

The bundled agent reaches sources on the same network as this host. Oracle (incl.
legacy password verifiers — Instant Client is bundled), SQL Server (ODBC Driver 18),
and PostgreSQL are built in. Add connections in **Settings → Connections**. For a
source on a different network segment, run an additional agent there (ask us).

## Behind a corporate proxy

If this host reaches the internet only through a proxy — especially one that does
**TLS interception** (re-signs HTTPS with a private root CA, e.g. Cisco WSA) — set
these in `.env` before installing. The containers inherit neither the host's proxy
nor its CA trust, so both must be given explicitly:

```
HTTP_PROXY=http://proxy.corp.example:3128
HTTPS_PROXY=http://proxy.corp.example:3128
NO_PROXY=.corp.example,10.0.0.0/8         # extra internal domains/CIDRs
# Only if the proxy intercepts TLS — a host CA bundle that INCLUDES the proxy root CA:
ONTOS_CA_BUNDLE=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem   # RHEL
```

Then `./install.sh` (or `--update`). LLM calls route through the proxy and trust the
intercepted certificates; loopback + internal traffic (Postgres, the agent, the
healthcheck) always stay off the proxy. No rebuild needed.

## License states

Offline Ed25519, verified at startup and live during operation:

| State | Behavior |
|---|---|
| valid | full operation |
| expired ≤ 14 days | operates, warns to renew |
| expired > 14 days | boots **read-only** (existing data readable; new runs blocked) |
| missing / invalid | control plane will not start |

Check the current state any time: `curl http://<host>:8080/api/v1/license`.

## Update

```bash
# bump ONTOS_VERSION in .env when a new release is announced, then:
./install.sh --update      # pulls new images, recreates, keeps your data
```

## Manage

```bash
docker compose ps
docker compose logs -f control-plane
docker compose logs -f secure-agent
docker compose down          # stop (keeps data)
docker compose down -v       # stop and wipe all data
```

## License & support

The Ontos images are **licensed software, not open source** — see [LICENSE](LICENSE).
They're free to download; a valid license key is required to run. For a license
key, a new version, or support, contact Ontos Research.
