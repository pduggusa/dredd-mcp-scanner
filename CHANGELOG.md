# Changelog

All notable changes to dredd-mcp-scanner are documented here.

## [1.1.0] - 2026-06-27

### Added
- **Transitive dependency-graph checking (Shai-Hulud class).** The scan now resolves the target repo's full npm/pypi transitive dependency graph and checks *every* package — direct and deep transitive — against the IOC corpus, not just the repo name. This catches supply-chain compromise hiding in transitive deps, which a name-only scan can't see.
- **`dep_graph` field** documented on the signed verdict (reports whether the transitive tree was evaluated). Use `DREDD_VERBOSE=1` to print the full JSON.
- **OSV malicious-package feeds (npm + PyPI)** noted in the corpus the scanner cross-references.
- **Feed-validation links**: novelty (`/api/v1/feed-uniqueness`), timeliness (`/api/v1/kev-lead`), accuracy (`/api/v1/spamhaus-validation`).
- **CHANGELOG.md** — you're reading it.
- Version stamp (`1.1.0`) in the `scan.sh` header.

### Changed
- README now leads with dependency-graph checking; corrected the IOC corpus figure to **1.10M+** (was `1.13M+`).
