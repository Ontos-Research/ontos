# Capability map

What you can do with a running Ontos instance, grouped by activity. Everything below is
driven from the operator console; most of it is also reachable by AI assistants over MCP
(see [`ai-access.md`](ai-access.md)).

## See your estate

- **Estate census** — one sweep that inventories systems, assets, and their relationships,
  and reports coverage honestly: what was read, what was skipped, what is unreachable.
- **Schema discovery** — tables, columns, types, keys pulled through the secure agent.
- **Query-log discovery** — mine the database's own query history for real usage: which
  tables are actually joined, which columns actually filter, what the business actually asks.
- **Profiling and preview** — row counts, distributions, null rates, sampled rows; the
  evidence base for grain and key claims.
- **Join graph** — the estate's real join topology, mined from evidence rather than declared.

## Build the semantic contract

- **Ontology** — business objects and concepts with properties, bound to physical tables and
  columns; grains and valid joins are recorded claims, not assumptions.
- **Links** — typed relationships between objects, each carrying its evidence.
- **Measures** — governed metric definitions (what we count when we say "active"), certified
  and versioned like everything else.
- **Vocabulary** — synonyms and business terms, so "member", "subscriber", and "policyholder"
  resolve to one governed meaning.
- **Definition versioning** — git-style history for every definition: diff any two versions,
  revert, and see exactly what a certification was granted against.

## Govern it

- **Certification lifecycle** — proposals carry evidence; humans certify; trust decays and
  must be re-earned; revocation stops serving immediately and is disclosed, never silent.
- **Provenance everywhere** — every claim links to the evidence that supports (or
  contradicts) it, and to the human decision that blessed it.
- **Access control** — role-based permissions, workspace scoping, secrets management, and
  least-privilege service accounts for machine access.
- **Data health** — quality checks with a ledger: critical findings block, warnings advise;
  incidents can be raised straight from failing runs.
- **Audit** — every consequential action, human or AI, lands in a searchable audit trail.

## Ask it

- **Governed chat** — conversational access to the contract in the console, with the same
  citation and abstention rules as everything else.
- **Answers** — business questions answered *from certified knowledge only*: figures come
  with citations and confidence; questions the contract cannot support get a named
  abstention plus a demand signal for the data team.
- **Lineage** — trace any run, task, or answer back through what it read and why.
- **MCP access** — connect Claude Code or another MCP client directly to a running instance,
  authenticated and read-only ([`ai-access.md`](ai-access.md)).

## Supporting runtime

- **Connectors** — Oracle (Instant Client bundled, legacy verifiers included), SQL Server
  (ODBC 18), PostgreSQL — all through the secure agent; data stays in your network.
- **Tasks and pipelines** — a working data-movement runtime with runs, retries, failure
  explanation, and lineage. Deliberately kept as supporting infrastructure, not the product.
