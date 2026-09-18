#!/usr/bin/env bash
# copy-agentic-files.sh — copy the committed agentic workflow files to a target directory.
#
# Usage: copy-agentic-files.sh <target-dir>
#
# Copies:
#   .claude/agents/      — agent definitions (*.md)
#   .claude/bin/         — worker bin scripts
#   .claude/config/      — worker-map.json and other config
#   .claude/hooks/       — hook scripts and hook-utils
#   .claude/settings.json
#   .codex/AGENTS.md     — Codex reviewer instructions
#   CLAUDE.md            — behavioral guidelines
#   README.md            — project readme (if present)
#
# Deliberately excluded (private / runtime-only):
#   .claude/.credentials.json   — API credentials
#   .claude/.claude.json        — runtime state
#   .claude/backups/
#   .claude/sessions/
#   .claude/projects/
#   .claude/history.jsonl
#   .claude/file-history/
#   .claude/shell-snapshots/
#   .claude/session-env/
#   .claude/cache/
#   .claude/plugins/
#
# Bin scripts are made executable in the target directory.
set -euo pipefail

usage() {
    cat >&2 <<'EOF'
Usage: copy-agentic-files.sh <target-dir>

  <target-dir>  directory to copy agentic files into; created if absent.
                The .claude/ and .codex/ sub-trees are reproduced under it.

Example:
  copy-agentic-files.sh ~/projects/my-new-project
EOF
}

if [[ $# -ne 1 || -z "$1" ]]; then
    usage
    exit 2
fi

target="$1"
repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "error: not inside a git repository" >&2
    exit 1
}

# ── helpers ──────────────────────────────────────────────────────────────────

info()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn()  { printf '  \033[33m!\033[0m %s\n' "$*"; }
error() { printf '  \033[31m✗\033[0m %s\n' "$*" >&2; }

copy_dir() {
    # copy_dir <src-relative-to-repo-root> <dst-relative-to-target>
    local src="$repo_root/$1"
    local dst="$target/$2"
    if [[ ! -d "$src" ]]; then
        warn "skipping (not found): $1/"
        return
    fi
    mkdir -p "$dst"
    cp -r "$src/." "$dst/"
    info "copied $1/ → $2/"
}

copy_file() {
    # copy_file <src-relative-to-repo-root> [dst-relative-to-target]
    local src="$repo_root/$1"
    local dst_rel="${2:-$1}"
    local dst="$target/$dst_rel"
    if [[ ! -f "$src" ]]; then
        warn "skipping (not found): $1"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    info "copied $1 → $dst_rel"
}

# ── create target ─────────────────────────────────────────────────────────────

mkdir -p "$target"
echo "Target: $target"
echo ""

# ── copy agent definitions ────────────────────────────────────────────────────

copy_dir ".claude/agents"    ".claude/agents"
warn "existing installations may have stale moved files in .claude/agents/ (cpp-pro, django-developer, electron-pro, golang-pro, mobile-developer, python-pro, rust-engineer, sql-pro, typescript-pro, vue-expert); remove them manually to avoid confusion"

# Language specialist knowledge for pi-worker injection (not spawnable agents).
copy_dir ".claude/personas"  ".claude/personas"

# ── copy bin scripts ──────────────────────────────────────────────────────────

copy_dir ".claude/bin"       ".claude/bin"

# Make every bin script executable in the target.
if [[ -d "$target/.claude/bin" ]]; then
    find "$target/.claude/bin" -type f -exec chmod +x {} \;
    info "set +x on all files in .claude/bin/"
fi

# ── copy config ───────────────────────────────────────────────────────────────

copy_dir ".claude/config"    ".claude/config"

# ── copy hooks ────────────────────────────────────────────────────────────────

copy_dir ".claude/hooks"     ".claude/hooks"

# Make hook scripts executable.
if [[ -d "$target/.claude/hooks" ]]; then
    find "$target/.claude/hooks" -name "*.sh" -exec chmod +x {} \;
    info "set +x on hook scripts in .claude/hooks/"
fi

# ── copy settings (no credentials) ───────────────────────────────────────────

copy_file ".claude/settings.json"

# ── copy codex reviewer config ────────────────────────────────────────────────

copy_file ".codex/AGENTS.md"

# ── merge .gitignore (append lines not already present in target) ─────────────

merge_gitignore() {
    local src="$repo_root/.gitignore"
    local dst="$target/.gitignore"
    if [[ ! -f "$src" ]]; then
        warn "skipping (not found): .gitignore"
        return
    fi
    if [[ ! -f "$dst" ]]; then
        cp "$src" "$dst"
        info "copied .gitignore → .gitignore"
        return
    fi
    local added=0
    while IFS= read -r line; do
        # Skip blank lines and comments for the duplicate check,
        # but still append them if the exact line is absent.
        if ! grep -qxF "$line" "$dst"; then
            printf '%s\n' "$line" >> "$dst"
            (( added++ )) || true
        fi
    done < "$src"
    if (( added > 0 )); then
        info "merged .gitignore → .gitignore ($added new line(s) added)"
    else
        info ".gitignore already up-to-date (no new lines)"
    fi
}

merge_gitignore

# ── copy top-level docs ───────────────────────────────────────────────────────

copy_file "CLAUDE.md"
copy_file "README.md"

# ── summary ───────────────────────────────────────────────────────────────────

echo ""
echo "Done. Agentic files copied to: $target"
echo ""
echo "Next steps:"
echo "  1. Run scripts/check-binaries.sh on the target host to verify tooling."
echo "  2. Add your API credentials (.claude/.credentials.json or env vars) — do NOT copy from this repo."
echo "  3. If Claude Code is configured for a different project root, update .claude/settings.json as needed."
