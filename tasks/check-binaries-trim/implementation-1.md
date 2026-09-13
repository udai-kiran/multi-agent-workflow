All changes complete and verified. Implementation report follows.

---

## Implementation Report

### Files created, modified, or deleted
- **Modified:** `scripts/check-binaries.sh` (only file touched)

### Summary of changes
Per the spec — among worker CLIs, only `pi` remains required; `npx` and `codex` moved to optional:

1. **Header comments:** Removed the `#   dsh-worker    → npx (invokes ...)` line and the `#   codex-worker  → codex` / `#   codex-reviewer→ codex` lines from the "Workers and the binaries they need" block. Kept `pi-worker`, `worker-stats`, `worker-log`, and `all workers` lines.
2. **Required section:** Removed the `check_bin "npx" required ...` block (with its `|| (( missing_required++ )) || true` continuation) and the `check_bin "codex" required ...` block. Required checks are now exactly: git, pi, rg, fd.
3. **Optional section:** Added, immediately BEFORE the existing `check_bin "claude"` line:
   ```bash
   check_bin "npx"   optional "dsh-worker: runs npx @deepseek-ai/dsh (not currently needed)"
   check_bin "codex" optional "codex-worker and codex-reviewer (not currently needed)"
   ```
4. **Install hints block:** Removed the `echo "  npx   — ships with Node.js: https://nodejs.org" >&2` line and the `echo "  codex — npm install -g @openai/codex  (or follow https://github.com/openai/codex)" >&2` line. The `pi` hint line was preserved.

No other lines were changed. Existing style was matched exactly: same column alignment/spacing of `check_bin` arguments (`"name"`, 3-space padding, `required`/`optional` column, description quoting), backslash continuations, and 4-space indentation inside the `else` block for the install hints.

**Implementation note:** The first edit attempt failed because the install-hint lines inside the `else` block are indented with 4 leading spaces, which my initial `oldText` omitted (the `read` tool output didn't make the leading whitespace obvious). The edit tool being atomic meant nothing was applied; I confirmed via `git diff --stat` (empty) and reapplied all five hunks with the corrected indentation in one edit call.

### Commands run and output
- `bash -n scripts/check-binaries.sh` → `syntax OK`
- `git diff scripts/check-binaries.sh` → shows exactly 5 hunks: header comment removals, npx required-block removal, codex required-block removal, two optional entries added before `claude`, and two install-hint lines removed. No unintended changes.
- `./scripts/check-binaries.sh` → exit 0; output confirms required checks are now only git/pi/rg/fd (all found), and npx/codex are reported as optional entries.

### Issues, risks, or deviations
- **None in the changes themselves.** Two observation-level notes (not acted on, since the task said "Do NOT change anything else"):
  1. The pre-existing optional `node` entry still says `"Node.js runtime (required by npx / dsh)"`; I left it as-is since it wasn't in scope.
  2. With npx/codex now optional, `missing_required` can only be incremented by git/pi/rg/fd; the script logic required no changes to accommodate this.
