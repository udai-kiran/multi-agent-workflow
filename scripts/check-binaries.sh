#!/usr/bin/env bash
# check-binaries.sh — verify that all binaries required by the multi-agent workflow are present.
#
# Usage: check-binaries.sh [--quiet]
#
# Exit codes:
#   0  all required binaries found
#   1  one or more required binaries missing
#
# Workers and the binaries they need:
#   dsh-worker    → npx (invokes `npx @deepseek-ai/dsh`)
#   pi-worker     → pi  (npm global: @earendil-works/pi-coding-agent)
#   codex-worker  → codex
#   codex-reviewer→ codex
#   worker-stats  → awk, git
#   worker-log    → git
#   all workers   → git (repo root detection)
#
# Claude Code itself → claude
set -euo pipefail

QUIET=0
[[ "${1:-}" == "--quiet" ]] && QUIET=1

pass() { [[ $QUIET -eq 1 ]] || printf '  \033[32m✓\033[0m %-18s %s\n' "$1" "$2"; }
fail() { printf '  \033[31m✗\033[0m %-18s %s\n' "$1" "$2" >&2; }
note() { [[ $QUIET -eq 1 ]] || printf '  \033[33m~\033[0m %-18s %s\n' "$1" "$2"; }

check_bin() {
    # check_bin <name> <required|optional> <description>
    local name="$1" kind="$2" desc="$3"
    if command -v "$name" >/dev/null 2>&1; then
        local ver
        # Best-effort version string — silence errors for tools that don't support --version
        ver="$(("$name" --version 2>/dev/null || "$name" version 2>/dev/null || true) | head -1)"
        pass "$name" "${ver:-(found)}  — $desc"
        return 0
    else
        if [[ "$kind" == "required" ]]; then
            fail "$name" "NOT FOUND  — $desc"
        else
            note "$name" "not found (optional)  — $desc"
        fi
        return 1
    fi
}

missing_required=0

echo "Checking binaries for the multi-agent workflow…"
echo ""

# ── required ─────────────────────────────────────────────────────────────────

check_bin "git"   required  "repo root detection used by every worker bin" \
    || (( missing_required++ )) || true

check_bin "npx"   required  "dsh-worker: runs 'npx @deepseek-ai/dsh'" \
    || (( missing_required++ )) || true

check_bin "pi"    required  "pi-worker: runs 'pi --no-session --model …'" \
    || (( missing_required++ )) || true

check_bin "codex" required  "codex-worker and codex-reviewer: runs 'codex exec …'" \
    || (( missing_required++ )) || true

# ── optional / strongly recommended ──────────────────────────────────────────

echo ""

check_bin "claude" optional "Claude Code CLI (the coordinator agent host)"
check_bin "node"   optional "Node.js runtime (required by npx / dsh)"
check_bin "awk"    optional "worker-stats report generation"
check_bin "jq"     optional "JSON wrangling in hook scripts"

# ── summary ───────────────────────────────────────────────────────────────────

echo ""
if [[ $missing_required -eq 0 ]]; then
    printf '\033[32mAll required binaries found.\033[0m\n'
    exit 0
else
    printf '\033[31m%d required binary/binaries missing.\033[0m\n' "$missing_required" >&2
    echo "" >&2
    echo "Install hints:" >&2
    echo "  npx   — ships with Node.js: https://nodejs.org" >&2
    echo "  pi    — npm install -g @earendil-works/pi-coding-agent" >&2
    echo "  codex — npm install -g @openai/codex  (or follow https://github.com/openai/codex)" >&2
    exit 1
fi
