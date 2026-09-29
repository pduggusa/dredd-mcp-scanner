# Changelog

All notable changes to dredd-mcp-scanner are documented here.

## [1.1.2] - 2026-09-29

### Changed
- Refreshed corpus figures from the live `/api/v1/search/stats` (1.9M+ IOCs, ~68M documents across 70 indexes).
- Removed the retired "275+ consumers in 46 countries" line. It counted blocked, User-Agent-less scrapers as consumers, so we stopped quoting it on 2026-05-30.

## [1.1.1] - 2026-06-30

### Added
- Documented the fourth live validation axis — Liveness (`/api/v1/feed-efficacy`).

### Changed
- Refreshed IOC corpus copy to 1.5M+ IOCs (~1.57M live).
- Reworded the Timeliness validation reference to point at the live kev-lead ledger instead of a fixed "~31 days ahead" average.
- Version stamp bumped to `1.1.1` in the `scan.sh` header.

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
