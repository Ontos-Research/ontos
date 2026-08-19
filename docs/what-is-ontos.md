# What is Ontos?

> **Ontos builds the trusted semantic contract between enterprise data and AI.**

Every enterprise already has the raw material: schemas, query logs, reports, tribal
knowledge. What it lacks is a governed answer to the questions that matter before AI can be
trusted anywhere near the data: *what does "active member" actually mean here? Which of the
four revenue definitions is authoritative? What evidence supports that mapping — and who
signed off on it?*

Ontos turns that raw material into a **certified semantic contract**: a continuously
maintained, evidence-backed, human-approved understanding of the business's concepts, their
physical bindings, authoritative measures and relationships, and the rules for how AI may
use them — when it must cite, when it must ask, and when it must refuse to answer.

## How it works — the lifecycle

1. **Discover** evidence from your estate: schemas, query logs, profiles, existing models.
2. **Infer** candidate business concepts, definitions, and relationships from that evidence.
3. **Bind** concepts to the actual physical implementations (tables, columns, joins, grains).
4. **Expose** the evidence, the uncertainty, and the contradictions — never hide a conflict.
5. **Route** ambiguous knowledge to the humans who own it.
6. **Certify** a minimum useful contract; certification is a human act, always.
7. **Serve** the certified context to people and AI systems, with citations.
8. **Detect drift** and propose updates as the estate changes — trust decays; it is re-earned.

The result compounds: every question answered, every contradiction resolved, every
certification granted makes the next one cheaper.

## What it is not

- **Not an ETL platform or pipeline builder.** A data-movement runtime exists as supporting
  infrastructure, but it is not the product and is never the headline.
- **Not a BI tool.** The Answers surface exists to prove the context is useful and expose
  coverage gaps — consumption is a surface, the contract is the product.
- **Not an autonomous modeler.** Ontos proposes; humans certify. An uncertified claim is
  served as a proposal with its evidence, or not at all.

## Architecture in one paragraph

Two components, both on your infrastructure. The **control plane** (API + operator console)
holds metadata only: the catalog, the ontology, evidence, certifications, audit. The
**secure agent** runs next to your databases (Oracle, SQL Server, PostgreSQL), connects
*outward* to the control plane, and executes reads locally — **your data never leaves your
network**. License verification is fully offline; the stack works air-gapped.

## Honesty as a design principle

Ontos prefers a governed "I can't answer that, and here is why" over a confident guess.
Answers carry citations and confidence; questions outside the certified contract produce a
named abstention and a demand signal that tells the data team exactly what knowledge is
missing. A revoked definition stops serving the moment it is revoked — and says so.
