# Ontos

Self-hosted, AI-agentic data integration platform. A **control plane** (API +
operator console) and a **secure agent** run on your own Linux host; the agent
connects out to your Oracle / SQL Server / PostgreSQL. Your data never leaves
your network — only metadata reaches the control plane.

## Install

**Requirements:** a Linux host with **Docker** (compose plugin), ~2 GB free disk,
a free port, and network access from the host to your data sources and to a model
endpoint.

**1. Authenticate to the image registry** (credentials issued by Ontos Research):

```bash
docker login ghcr.io -u <your-github-username>
```

**2. Configure and run:**

```bash
git clone https://github.com/ontos-research/ontos.git
cd ontos
cp .env.example .env
#   edit .env → set DATADEX_SEED_LLM_API_KEY (and DATADEX_PORT if 8080 is taken)
./install.sh
```

`install.sh` pulls the images, generates secrets, seeds a workspace, and boots.
When it finishes, open:

```
http://<this-host>:8080/operator
```

There's no login screen — an admin user and a default workspace are created
automatically, and a secure agent auto-enrolls. Set your workspace LLM key in
**Settings → Access** if you left it blank in `.env`.

## The model endpoint

The agent features need an LLM. Set `DATADEX_SEED_LLM_API_KEY` in `.env` (OpenAI
or Groq). If your host can't reach the public API, point
`DATADEX_OPENAI_RESPONSES_URL` (or `DATADEX_GROQ_URL`) at an in-network /
in-region OpenAI-compatible endpoint instead.

## Connecting your data

The bundled agent reaches sources on the same network as this host. Oracle works
out of the box (thin mode — no Instant Client); SQL Server (ODBC Driver 18) and
PostgreSQL are built in. Add connections in the operator console under
**Settings → Connections**. If a source lives on a different network segment, run
an additional agent there (ask us for the one-liner).

## Update

When a new version is released, bump `ONTOS_VERSION` in `.env` and run:

```bash
./install.sh --update      # pulls the new images, recreates, keeps your data
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
For access credentials, a new version, or help, contact Ontos Research.
