# dredd-mcp-scanner

> Vet an MCP-shaped GitHub repo before you install it.
> *Jeevesus saves. Dredd judges.*

A tiny bash script that hits the public Dredd scan endpoint and tells you whether the target repo is safe to clone. Backed by the DugganUSA threat-intel corpus (1.13M+ IOCs).

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
2. The Dredd backend fetches the repo's `package.json` / `requirements.txt`
3. Cross-references every dependency against our IOC corpus (Socket, Aikido, GitGuardian, ReversingLabs, Phylum, StepSecurity, Wiz, URLhaus, OTX, etc.)
4. Also checks the repo name itself against `mcp_findings` (URLhaus typosquat catches, GlassWorm flags, SmartLoader, etc.)
5. Returns a JSON verdict: `BLOCK`, `ADVISORY`, or `ALLOW`, HMAC-signed.

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

## License

MIT.

## Source

- Scanner backend: closed (analytics.dugganusa.com — DugganUSA platform)
- This wrapper: open MIT, fork freely
- Companion repo: [github.com/pduggusa/dredd-mcp](https://github.com/pduggusa/dredd-mcp)

---

*Built in Minneapolis on $75/month. Read-only. 95% epistemic ceiling. Receipts do the work.*
