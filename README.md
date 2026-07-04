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
- **A license key** and **registry credentials** — both issued by Ontos Research.

## Install

**1. Authenticate to the image registry:**

```bash
docker login ghcr.io -u <your-username>
```

**2. (Recommended) Verify the images are genuinely from Ontos Research.** They are
signed with [cosign](https://docs.sigstore.dev/); `cosign.pub` is in this repo:

```bash
cosign verify --key cosign.pub ghcr.io/ontos-research/ontos/control-plane:0.1.0
cosign verify --key cosign.pub ghcr.io/ontos-research/ontos/secure-agent:0.1.0
```

**3. Configure and run:**

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

The bundled agent reaches sources on the same network as this host. Oracle works
out of the box (thin mode — no Instant Client); SQL Server (ODBC Driver 18) and
PostgreSQL are built in. Add connections in **Settings → Connections**. For a
source on a different network segment, run an additional agent there (ask us).

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
For a license key, registry credentials, a new version, or support, contact
Ontos Research.
