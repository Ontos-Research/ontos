# Which features should we use?

Ontos is adopted along paths, not feature-by-feature. Find the situation below that sounds
like yours; each path says what to do first and what you will have at the end. The paths
compound — most customers walk them in roughly this order, and every path makes the next
one cheaper.

> Evaluating with an AI assistant? Have it read this file plus
> [`capabilities.md`](capabilities.md) and it can recommend a path against your goals.

## "We don't actually know what's in our estate"

*Symptoms: nobody can list the systems of record; documentation is tribal; every project
starts with archaeology.*

1. Connect your databases (**Settings → Connections**) — the secure agent reaches them
   inside your network; only metadata leaves.
2. Run an **estate census**: one sweep that inventories systems and assets and reports
   coverage honestly — what was read, what was skipped, what is unreachable.
3. Turn on **schema discovery** and **profiling** for the systems that matter; explore the
   catalog and the mined **join graph**.

**You end up with:** a live, evidence-backed inventory — the raw material every other path
builds on. Start here; every other path assumes it.

## "Every report defines things differently — nobody trusts the numbers"

*Symptoms: three revenue figures in the same meeting; "active customer" means four things;
migrations keep rediscovering the same logic.*

1. Let Ontos **propose concepts and definitions** from the discovered evidence (schemas,
   query logs, existing models — it can transcribe a semantic model you already have).
2. Review the proposals *with the contradictions shown*: where two definitions disagree on
   the same meaning, Ontos surfaces it rather than picking silently.
3. Have your owners **certify** the definitions that are right — certification is always a
   human act. Capture business terms as **vocabulary** so synonyms resolve to one meaning.

**You end up with:** a certified semantic contract — versioned like code (diff, history,
revert), with every definition carrying its evidence and its approver.

## "We want people (and AI) to get trustworthy answers, not confident guesses"

*Symptoms: self-serve BI produced self-serve chaos; leadership asks a number and gets three;
you are evaluating LLM tools but don't trust them near data.*

1. Walk the two paths above until a minimum useful contract is certified.
2. Open **Answers**: business questions answered from certified knowledge only — figures
   arrive with citations and confidence; questions the contract can't support get a named
   abstention instead of a guess, plus a demand signal telling the data team exactly what
   to certify next.
3. Optionally connect your AI assistants over **MCP** ([`ai-access.md`](ai-access.md)) so
   they consume the same governed context under the same rules, read-only and audited.

**You end up with:** an answer surface that is honest about its limits — and a ranked list
of which knowledge to govern next, driven by real demand.

## "Things drift and break silently"

*Symptoms: a schema change broke a dashboard three weeks before anyone noticed; certified
docs rot quietly.*

1. Turn on **data health** checks where they matter: critical findings block, warnings
   advise; failures can open **incidents** directly from the failing run.
2. Rely on **decay**: certifications age and demand re-certification — trust is re-earned,
   never permanent. Revoked definitions stop serving immediately, and say so.
3. Use **lineage** to trace any run or answer back through what it read.

**You end up with:** drift that announces itself, instead of surfacing in a board meeting.

## What to do in your first week

1. Install (see [`README.md`](../README.md)), connect one real database.
2. Run the estate census; skim the catalog and join graph.
3. Pick the *one* business term your organization argues about most.
4. Walk it through propose → review contradictions → certify → ask it in Answers.

That single walked path — one term, evidence to certified answer — is the whole product in
miniature, and the fastest honest evaluation of whether Ontos earns a place in your estate.
