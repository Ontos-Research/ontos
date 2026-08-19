# Connecting AI clients (MCP)

A running Ontos instance can serve its governed context directly to AI assistants — Claude
Code, Claude Desktop, or any MCP-compatible client — over an authenticated, audited,
**read-only** endpoint. Your assistant gets the certified contract; it never gets an
execution surface.

## The trust model, first

- **Read-only by mandate.** The MCP surface structurally excludes execution triggers
  (task runs, pipeline runs, action invocations). This is enforced server-side, not by
  client configuration.
- **Service-account auth.** Access requires a workspace-scoped service account with
  least-privilege permissions and a bearer API key, minted in the console.
- **Everything is audited.** Every authentication, tool listing, and tool call lands in the
  audit trail with the service account and key that made it.
- **Network reach, not network exposure.** The endpoint lives on the control plane
  (`http://<host>:8080/api/v1/mcp`) inside your network. Reach it over VPN; never expose the
  port publicly.

## Setup

1. In the operator console, open **Settings → Access** and find the remote MCP section.
2. Create a scoped **service account** and mint an API key. Keep the key like a password —
   it can be revoked and re-minted at any time.
3. Use the built-in **Test connection** to confirm the endpoint answers from your machine.

## Connecting Claude Code

Copy `mcp/remote_mcp_stdio_bridge.py` from this repo to the workstation where Claude Code
runs (it is dependency-free — Python 3 standard library only), then register it:

```bash
claude mcp add ontos \
  --env DATADEX_REMOTE_MCP_URL="http://<host>:8080/api/v1/mcp" \
  --env DATADEX_REMOTE_MCP_API_KEY="<your-service-account-key>" \
  -- python3 /path/to/remote_mcp_stdio_bridge.py
```

Claude Desktop and other config-file clients use the equivalent `mcpServers` entry:

```json
{
  "mcpServers": {
    "ontos": {
      "command": "python3",
      "args": ["/path/to/remote_mcp_stdio_bridge.py"],
      "env": {
        "DATADEX_REMOTE_MCP_URL": "http://<host>:8080/api/v1/mcp",
        "DATADEX_REMOTE_MCP_API_KEY": "<your-service-account-key>"
      }
    }
  }
}
```

## Verifying by hand

The endpoint speaks plain JSON-RPC over HTTP POST, so `curl` works for a smoke test:

```bash
curl -s http://<host>:8080/api/v1/mcp \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <your-service-account-key>' \
  -d '{"jsonrpc":"2.0","id":"1","method":"tools/list","params":{}}'
```

## What tools you get today

The remote tool surface is **intentionally minimal in this release**: it exposes estate
inventory (`connection.list_connections`) and exists to prove the authenticated,
audited loop end-to-end with real MCP clients. It widens release by release under the same
read-only mandate — catalog search, ontology reads, and governed answers are the natural
next tiers.

If you have a concrete workflow in mind ("let our assistant browse the certified ontology",
"let it ask governed questions"), tell us which capabilities you need first — client demand
directly drives the widening order.
