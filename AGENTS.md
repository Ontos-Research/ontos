# AGENTS.md — orientation for AI assistants

You are probably reading this because someone pointed an AI coding assistant (Claude Code,
Codex, or similar) at this repository to understand what Ontos is, what it can do, or how to
operate an installed instance. Start here.

## What this repository is

The self-host install kit for **Ontos**. The product itself ships as two cosign-signed
container images on GHCR (`control-plane`, `secure-agent`); this repo holds everything needed
to verify, configure, and run them on a customer's own Linux host.

| File | Purpose |
|---|---|
| `README.md` | Install guide: prerequisites, verify, configure, run |
| `.env.example` | Configuration template (license, version pin, LLM key) |
| `install.sh` | Verifies license, pulls images, generates secrets, seeds a workspace, boots |
| `docker-compose.yml` / `docker-compose.proxy.yml` | Runtime topology (plain / corporate-proxy) |
| `cosign.pub` | Public key to verify image signatures |
| `docs/` | Product documentation — what Ontos does and how to use it |
| `mcp/remote_mcp_stdio_bridge.py` | Connect an MCP client (e.g. Claude Code) to a running instance |

## What Ontos is

Ontos builds a **trusted semantic contract** between enterprise data and AI: a continuously
maintained, evidence-backed, human-certified understanding of what the business's core
concepts mean, how they map to physical data, which measures and relationships are
authoritative, and what context an AI may use — including when it must cite, ask for
clarification, or abstain.

It is a **read-only context layer** over the data estate, not an ETL platform or a BI tool.
A secure agent runs inside the customer's network and connects out; **only metadata reaches
the control plane** — the data itself never leaves.

Read next:

- [`docs/what-is-ontos.md`](docs/what-is-ontos.md) — the product in one page
- [`docs/using-ontos.md`](docs/using-ontos.md) — **which features to use for which goal** (start here to advise a user)
- [`docs/capabilities.md`](docs/capabilities.md) — capability map, grouped by what you can do
- [`docs/ai-access.md`](docs/ai-access.md) — connecting AI clients over MCP

## Rules of engagement for agents working against a live instance

- **Trusted-network model.** The console has no built-in user authentication. Never expose
  its port to the public internet; reach it over the customer's VPN or internal network.
- **AI access is read-only by design.** The MCP surface excludes execution triggers
  server-side (no task runs, no pipeline runs, no action invocations). Do not attempt to
  work around this; it is a product mandate, not a gap.
- **Every MCP call is authenticated and audited.** Access rides workspace-scoped service
  accounts with least-privilege permissions, minted in the console (Settings → Access).
- **License verification is offline.** The instance works air-gapped; there is no phone-home.
