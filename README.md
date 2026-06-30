# dredd-mcp-scanner

> Vet an MCP-shaped GitHub repo — and its whole dependency graph — before you install it.
> *Jeevesus saves. Dredd judges.*

A tiny bash script that hits the public Dredd scan endpoint and tells you whether the target repo is safe to clone. Backed by the DugganUSA threat-intel corpus (1.5M+ IOCs).

## What's New — it checks the dependency graph, not just the repo

Dredd no longer stops at the repo name. It resolves the target's **full transitive npm/pypi dependency graph** and joins *every* package — direct and deep transitive — against the IOC corpus, including the **OSV malicious-package feeds for npm and PyPI**. This is the **Shai-Hulud class** of attack: the malicious code is rarely in the repo you scanned — it's buried in a transitive dependency whose publish token got stolen. A name-only scan is blind to exactly that.

The scan returns a **signed verdict** (`BLOCK` / `ADVISORY` / `ALLOW`) plus a **`dep_graph`** field telling you whether the transitive tree was actually evaluated:

```
DREDD_VERBOSE=1 bash scan.sh owner/repo   # prints the full JSON incl. dep_graph
```

If the repo exposes no resolvable manifest, `dep_graph.evaluated` is `false` and you get an advisory — Dredd tells you it couldn't see the tree rather than pretending it's clean.

## Quick start

```
git clone https://github.com/pduggusa/dredd-mcp-scanner
cd dredd-mcp-scanner

# Try a KNOWN BAD (URLhaus-tagged SmartLoader typosquat)
bash scan.sh https://github.com/betinhocapoeira/mcp-bsl-lsp-bridge

# Try a KNOWN CLEAN
bash scan.sh https://github.com/pduggusa/dredd-mcp

# Either form works
bash scan.sh owner/repo
bash scan.sh https://github.com/owner/repo
```

Exit codes mirror the verdict:

| Exit | Meaning |
|---|---|
| `0` | ALLOW (no findings) |
| `1` | BLOCK (critical / high — do not install) |
| `2` | ADVISORY (medium / advisory — review before installing) |
| `4` | unknown / API error |

Use it in CI to fail a build that pulls a bad MCP:

```
- run: bash scan.sh ${{ github.repository }} || exit 1
```

## What it actually does

1. Sends the GitHub URL to `https://analytics.dugganusa.com/api/v1/dredd/scan`
2. The Dredd backend fetches the repo's `package.json` / `requirements.txt` and **resolves the full transitive dependency graph** (npm/pypi)
3. Cross-references **every** package — direct and transitive — against our IOC corpus (Socket, Aikido, GitGuardian, ReversingLabs, Phylum, StepSecurity, Wiz, URLhaus, OTX, plus OSV malicious-package feeds for npm and PyPI). This is what catches Shai-Hulud-class compromise hiding deep in the tree.
4. Also checks the repo name itself against `mcp_findings` (URLhaus typosquat catches, GlassWorm flags, SmartLoader, etc.)
5. Returns a signed JSON verdict: `BLOCK`, `ADVISORY`, or `ALLOW`, HMAC-signed, with a `dep_graph` field reporting whether the transitive tree was evaluated.

## Real examples that come back BAD

These are pre-loaded in `mcp_findings` and will return `BLOCK`:

- `betinhocapoeira/mcp-bsl-lsp-bridge` — SmartLoader (URLhaus)
- `tkboys123/whatsapp-bridge-mcp` — SmartLoader
- `swit2025/context-bridge-mcp` — SmartLoader
- `alyamani18/mcp-agent-bridge` — SmartLoader
- (10 more)

There's also a documented **test fixture** that always returns BLOCK:

```
curl 'https://analytics.dugganusa.com/api/v1/dredd/preflight?server=dredd-test-known-bad-mcp'
```

Use it to verify your scanner installation works end-to-end without scanning a real malicious repo.

## Get a Dredd badge for your own repo

```
[![Dredd](https://analytics.dugganusa.com/api/v1/dredd/badge?url=https://github.com/OWNER/REPO)](https://analytics.dugganusa.com/scan?url=https://github.com/OWNER/REPO)
```

The badge updates live with the current verdict. Green = ALLOW, yellow = ADVISORY, red = BLOCK.

## Web UI

Don't want a CLI? Use the browser version:

> **https://analytics.dugganusa.com/scan**

Same endpoint, paste a URL, see results.

## The Two MCPs (registry)

Both registered on the official Model Context Protocol Registry:

- **Jeevesus** — `io.github.pduggusa/dugganusa-threat-intel` — natural-language threat-intel search
- **Dredd MCP** — `io.github.pduggusa/dredd-mcp` — pre-flight invocation security check

## Why trust the corpus

The IOC corpus behind every verdict is independently checkable on four live, no-auth endpoints:

- **Novelty** — https://analytics.dugganusa.com/api/v1/feed-uniqueness (~75%+ of our IOCs aren't in ThreatFox)
- **Timeliness** — https://analytics.dugganusa.com/api/v1/kev-lead (a live ledger of how far ahead of CISA KEV we flagged each exploited CVE — leads, same-day, and no-receipt shown honestly)
- **Accuracy** — https://analytics.dugganusa.com/api/v1/spamhaus-validation (Spamhaus corroborates our calls)
- **Liveness** — https://analytics.dugganusa.com/api/v1/feed-efficacy (opt-in consumer reports of when our indicators actually fire on real traffic — proof the feed is operationally live, not just large)

## License

MIT.

## Source

- Scanner backend: closed (analytics.dugganusa.com — DugganUSA platform)
- This wrapper: open MIT, fork freely
- Companion repo: [github.com/pduggusa/dredd-mcp](https://github.com/pduggusa/dredd-mcp)

---

*Built in Minneapolis on $75/month. Read-only. 95% epistemic ceiling. Receipts do the work.*
