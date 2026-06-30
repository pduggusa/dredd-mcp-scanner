#!/usr/bin/env bash
# dredd-mcp-scanner — vet a GitHub-hosted MCP repo before you install it
# version: 1.1.1
#
# Now resolves the full transitive npm/pypi dependency graph (Shai-Hulud class),
# not just the repo name. Verdict is signed and carries a dep_graph field.
#
# Usage:  bash scan.sh https://github.com/owner/repo
# Or:     bash scan.sh owner/repo
#
# Calls https://analytics.dugganusa.com/api/v1/dredd/scan and prints the verdict.
# No auth required. Free. Public read-only.
#
# Try a known bad:
#   bash scan.sh https://github.com/betinhocapoeira/mcp-bsl-lsp-bridge
# Try a known clean:
#   bash scan.sh https://github.com/pduggusa/dredd-mcp

set -u

API="${DREDD_API:-https://analytics.dugganusa.com/api/v1/dredd/scan}"
TARGET="${1:-}"

if [ -z "$TARGET" ]; then
  cat <<EOF
Usage: bash scan.sh <github-url-or-owner/repo>

Examples:
  bash scan.sh https://github.com/pduggusa/dredd-mcp
  bash scan.sh betinhocapoeira/mcp-bsl-lsp-bridge

Environment:
  DREDD_API   override the scan endpoint (default: https://analytics.dugganusa.com/api/v1/dredd/scan)
EOF
  exit 1
fi

# Normalize: accept owner/repo OR full URL
case "$TARGET" in
  https://*) URL="$TARGET" ;;
  http://*)  URL="$TARGET" ;;
  *)         URL="https://github.com/$TARGET" ;;
esac

# Strict: github.com only
case "$URL" in
  https://github.com/*) : ;;
  *) echo "Only github.com URLs are supported (got: $URL)"; exit 2 ;;
esac

echo "Scanning $URL ..."

# URL-encode the parameter
ENCODED=$(printf '%s' "$URL" | python3 -c 'import sys,urllib.parse;print(urllib.parse.quote_plus(sys.stdin.read()))' 2>/dev/null || node -e 'process.stdout.write(encodeURIComponent(require("fs").readFileSync(0,"utf8")))' <<< "$URL")
RESPONSE=$(curl -fsS --max-time 20 "$API?url=$ENCODED")

if [ -z "$RESPONSE" ]; then
  echo "Error: empty response from $API"
  exit 3
fi

# Extract verdict + severity + counts (jq if available, fall back to grep)
if command -v jq >/dev/null 2>&1; then
  VERDICT=$(printf '%s' "$RESPONSE" | jq -r '.verdict // "unknown"')
  SEVERITY=$(printf '%s' "$RESPONSE" | jq -r '.severity // "unknown"')
  DEPS=$(printf '%s' "$RESPONSE" | jq -r '.deps_total // 0')
  MATCHES=$(printf '%s' "$RESPONSE" | jq -r '.matches | length // 0')
  REPO_FINDINGS=$(printf '%s' "$RESPONSE" | jq -r '.repo_level_findings | length // 0')
else
  VERDICT=$(printf '%s' "$RESPONSE" | grep -oE '"verdict":"[A-Z]+"' | head -1 | sed 's/.*"\([A-Z]*\)".*/\1/')
  SEVERITY=$(printf '%s' "$RESPONSE" | grep -oE '"severity":"[a-z]+"' | head -1 | sed 's/.*"\([a-z]*\)".*/\1/')
  DEPS="?"
  MATCHES="?"
  REPO_FINDINGS="?"
fi

# Color output
case "$VERDICT" in
  BLOCK)    COLOR='\033[0;31m' ;;  # red
  ADVISORY) COLOR='\033[0;33m' ;;  # yellow
  ALLOW)    COLOR='\033[0;32m' ;;  # green
  *)        COLOR='\033[0;37m' ;;  # gray
esac
RESET='\033[0m'

echo ""
echo -e "Verdict:        ${COLOR}${VERDICT}${RESET} (severity: ${SEVERITY})"
echo "Dependencies:   ${DEPS} parsed"
echo "IOC matches:    ${MATCHES}"
echo "Repo findings:  ${REPO_FINDINGS}"
echo ""

# Show full JSON if jq present + flag set
if [ "${DREDD_VERBOSE:-}" = "1" ] && command -v jq >/dev/null 2>&1; then
  printf '%s' "$RESPONSE" | jq .
fi

# Exit code mirrors verdict
case "$VERDICT" in
  BLOCK)    exit 1 ;;
  ADVISORY) exit 2 ;;
  ALLOW)    exit 0 ;;
  *)        exit 4 ;;
esac
