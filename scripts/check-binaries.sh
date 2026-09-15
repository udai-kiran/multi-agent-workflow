#!/usr/bin/env bash
# check-binaries.sh — verify that all binaries required by the multi-agent workflow are present.
#
# Usage: check-binaries.sh [--quiet]
#
# Exit codes:
#   0  all required binaries found
#   1  one or more required binaries missing
#
# Required binaries:
#   pi  → pi-worker (npm global: @earendil-works/pi-coding-agent)
#   rg  → Claude Code Grep tool backend (ripgrep)
#   fd  → Claude Code Glob tool backend (fd-find)
set -euo pipefail

QUIET=0
[[ "${1:-}" == "--quiet" ]] && QUIET=1

pass() { [[ $QUIET -eq 1 ]] || printf '  \033[32m✓\033[0m %-18s %s\n' "$1" "$2"; }
fail() { printf '  \033[31m✗\033[0m %-18s %s\n' "$1" "$2" >&2; }

check_bin() {
  # check_bin <name> <description>
  local name="$1" desc="$2"
  if command -v "$name" >/dev/null 2>&1; then
    local ver
    # Best-effort version string — silence errors for tools that don't support --version
    ver="$( ("$name" --version 2>/dev/null || "$name" version 2>/dev/null || true) | head -1)"
    pass "$name" "${ver:-(found)}  — $desc"
    return 0
  else
    fail "$name" "NOT FOUND  — $desc"
    return 1
  fi
}

missing_required=0

echo "Checking binaries for the multi-agent workflow…"
echo ""

# ── required ─────────────────────────────────────────────────────────────────

check_bin "pi" "pi-worker: runs 'pi --no-session --model …'" ||
  ((missing_required++)) || true

check_bin "rg" "Claude Code Grep tool backend (ripgrep)" ||
  ((missing_required++)) || true

check_bin "fd" "Claude Code Glob tool backend (fd-find)" ||
  ((missing_required++)) || true

# ── summary ───────────────────────────────────────────────────────────────────

echo ""
if [[ $missing_required -eq 0 ]]; then
  printf '\033[32mAll required binaries found.\033[0m\n'
  exit 0
else
  printf '\033[31m%d required binary/binaries missing.\033[0m\n' "$missing_required" >&2
  echo "" >&2
  echo "Install hints:" >&2
  echo "  pi    — npm install -g @earendil-works/pi-coding-agent" >&2
  echo "  rg    — https://github.com/BurntSushi/ripgrep#installation" >&2
  echo "  fd    — https://github.com/sharkdp/fd#installation" >&2
  exit 1
fi
