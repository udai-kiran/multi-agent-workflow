# Design: Move Language Specialists Out of `.claude/agents/`

**Author:** udaikiran  
**Date:** 2026-09-17  
**Status:** Codex-reviewed — corrections folded in

---

## Problem

`.claude/agents/` currently holds **53 files**, three of which are distinct kinds of content bundled together:

| Kind | Count | Examples |
|------|-------|---------|
| Core workflow agents | 7 | coordinator, sonnet-worker, pi-worker, codex-worker, codex-reviewer, test-runner, ci-validator |
| Domain/role specialists | ~36 | devops-engineer, security-engineer, kubernetes-specialist, terraform-engineer … |
| Language/framework specialists | 10 | python-pro, typescript-pro, golang-pro, rust-engineer, cpp-pro, sql-pro, django-developer, vue-expert, mobile-developer, electron-pro |

The **language/framework specialists** are never spawned as Claude Code subagents (`subagent_type: <name>`). Their only actual use is **persona injection** — `pi-worker` reads the file body and prepends it as domain guidance to the task prompt. Keeping them in `.claude/agents/` gives them full Claude Code agent status (listed in the system-reminder roster, discoverable as subagents) for no benefit.

**Symptoms:**
- System-reminder agent list is ~19% larger than necessary, adding context overhead.
- The roster misleads: a user or coordinator treating `python-pro` as a spawnable subagent gets an unguarded implementation agent with no `sonnet-worker` discipline.
- Cognitive overhead: distinguishing "workflow agents I actually spawn" from "persona bodies I inject" requires knowing 53 filenames.

---

## Key Research Findings

### `.claude/skills/` is reserved and incompatible

Claude Code defines a real **Skills** feature at `.claude/skills/`. It requires:
```
.claude/skills/
└── <skill-name>/
    └── SKILL.md        ← required; flat .md files directly in skills/ are ignored
```
Dropping flat agent files there is silently ignored by Claude Code, but pollutes a reserved namespace. **`.claude/skills/` is off the table for this design.**

### `.claude/` subtrees not covered by `.gitignore`

The project `.gitignore` only excludes specific runtime files and directories (`.claude/.credentials.json`, `.claude/sessions/`, `.claude/backups/`, etc.). A new subdirectory like `.claude/personas/` is **not git-ignored** and would be committed normally.

### All references to `.claude/agents/` for persona path

The persona lookup path is hard-coded in the following places:

| File | Line | Text |
|------|------|------|
| `.claude/bin/pi-worker` | 15 | Usage help: "`.claude/agents/`, e.g. 'frontend-developer'" |
| `.claude/bin/pi-worker` | 46 | `persona_file="$repo_root/.claude/agents/${persona}.md"` |
| `.claude/agents/pi-worker.md` | 21 | "basename of a file under `.claude/agents/`" |
| `.claude/agents/sonnet-worker.md` | 29 | "under `.claude/agents/` (e.g. `frontend-developer`, `sql-pro`…)" |
| `.claude/agents/coordinator.md` | 168 | "`.claude/agents/` also holds ~45 generic domain-specialist agents" |
| `.claude/agents/coordinator.md` | 189 | "Spawning the specialist directly as `subagent_type: <name>` is possible" (names `sql-pro` as an example at line 196) |
| `setup.html` | 310 | "45+ Specialist Subagents" roster lists 8 of the 10 moved names as spawnable agents |
| `scripts/copy-agentic-files.sh` | 96 | `copy_dir ".claude/agents" ".claude/agents"` — copies agents/ tree to target installations |

---

## Two Goals, Two Designs

The user's request — "move language-specific agents to a skill" — hides two distinct motivations. This section makes them explicit so the right one can be selected.

### Goal A — Shrink the roster (recommended)

**What it means:** Language specialist bodies become a plain **persona library** that pi-worker and sonnet-worker read for domain guidance. They are never spawnable as Claude Code subagents.

**Proposed path:** `.claude/personas/`

- Not reserved by any Claude Code feature.
- Not git-ignored.
- Keeps all Claude tooling under `.claude/`.
- Consistent prefix: persona files use no YAML frontmatter (or minimal descriptive comments only — frontmatter is unnecessary without the agent harness).

**Files to move (10):**

```
.claude/agents/cpp-pro.md         → .claude/personas/cpp-pro.md
.claude/agents/django-developer.md → .claude/personas/django-developer.md
.claude/agents/electron-pro.md    → .claude/personas/electron-pro.md
.claude/agents/golang-pro.md      → .claude/personas/golang-pro.md
.claude/agents/mobile-developer.md → .claude/personas/mobile-developer.md
.claude/agents/python-pro.md      → .claude/personas/python-pro.md
.claude/agents/rust-engineer.md   → .claude/personas/rust-engineer.md
.claude/agents/sql-pro.md         → .claude/personas/sql-pro.md
.claude/agents/typescript-pro.md  → .claude/personas/typescript-pro.md
.claude/agents/vue-expert.md      → .claude/personas/vue-expert.md
```

**Files to update (7):**

1. **`.claude/bin/pi-worker`** — update persona lookup (lines 15 and 46) to check `.claude/personas/` first, then `.claude/agents/` as backward-compat fallback:
   ```bash
   # try personas/ first, fall back to agents/
   persona_file="$repo_root/.claude/personas/${persona}.md"
   [[ -f "$persona_file" ]] || persona_file="$repo_root/.claude/agents/${persona}.md"
   ```
   Also update the usage() help text at line 15 to name both directories.
2. **`.claude/agents/pi-worker.md`** — update the doc line referencing `.claude/agents/`.
3. **`.claude/agents/sonnet-worker.md`** — update the doc line referencing `.claude/agents/`.
4. **`.claude/agents/coordinator.md`** — update two sections:
   - Line 168: "~45 generic domain-specialist agents" paragraph — note that language specialists now live in `.claude/personas/`.
   - Lines 189–196: The `subagent_type: <name>` direct-spawning route. This is a **behavioral change**: language specialists moved to `.claude/personas/` are no longer registered Claude Code agents and cannot be spawned as `subagent_type: python-pro` etc. The coordinator doc must be updated to restrict the direct-spawning example list to specialists that remain in `.claude/agents/` (e.g. `security-engineer`), and note that language personas are injection-only.
5. **`setup.html`** — update the "45+ Specialist Subagents" roster at line 310 to remove the 8 moved names (django-developer, golang-pro, mobile-developer, python-pro, rust-engineer, sql-pro, typescript-pro, vue-expert) or re-label them as "Language Personas (inject via pi-worker)" rather than spawnable subagents.
6. **`scripts/copy-agentic-files.sh`** — add a `copy_dir ".claude/personas" ".claude/personas"` step alongside the existing `agents/` copy at line 96. Also document a migration policy: existing installations retain stale agent files in `.claude/agents/` for the moved names; callers of the copy script should manually remove them or the script should emit a warning listing obsolete files.
7. **`.claude/agents/coordinator.md` system-prompt text** (the coordinator's own operating instructions passed to Claude Code) — if this file is also served as the system prompt for the coordinator agent, the inline roster list and the briefing for specialist workers needs the same update as above.

**Scope note:** This design moves only the 10 language/framework specialists. The ~36 domain specialists (devops-engineer, security-engineer, etc.) remain in `.claude/agents/`. If the motivation is broader roster pruning, the same mechanism generalises to all non-workflow specialists — that's a separate decision.

**Effort:** Small-to-medium. File bodies are unchanged (frontmatter stripped at injection anyway). The bin change is 3 lines. Doc and HTML updates are phrase-to-paragraph level. The migration policy for `copy-agentic-files.sh` is the most open-ended part.

---

### Goal B — Claude auto-loads domain guidance

**What it means:** When working on a Python file, Claude automatically receives Python expertise without the coordinator explicitly naming a persona. This is the real Claude Code **Skills** feature.

**Path:** `.claude/skills/<language-name>/SKILL.md`

**What it actually requires:**
- Each language becomes a subdirectory: `.claude/skills/python-pro/SKILL.md`
- SKILL.md uses the Skills frontmatter schema (`description`, `paths`, `when_to_use`, `allowed-tools`, etc.) — different from agent frontmatter
- Claude Code auto-discovers and injects them based on `paths:` glob patterns (e.g. `**/*.py`)
- Persona injection via `pi-worker` still works if pi-worker is updated to also scan `.claude/skills/<name>/SKILL.md`

**Effort:** Larger. Every file needs its frontmatter rewritten to the Skills schema. The `paths:` field needs per-language glob patterns. The pi-worker bin needs dual-path lookups. The system behavior changes (guidance loads automatically, not on coordinator demand).

**Tradeoff:** Powerful for interactive Claude use; more complex to maintain; automatic loading may be unwanted for generic briefs that happen to touch Python files.

---

## Recommendation

**Implement Goal A now.** It solves the stated problem (roster bloat, persona/agent confusion) with minimal risk and a 6-file change. Goal B is additive and can be layered on top later if automatic guidance loading is wanted.

**Do not use `.claude/skills/` for Goal A** — even though flat files there are silently ignored today, it names a reserved path that Claude Code actively scans, and future Claude Code versions may parse or reject unexpected content there.

---

## Acceptance Criteria

1. The 10 specialist files exist in `.claude/personas/` with no frontmatter (or comment-only header).
2. The 10 files no longer exist in `.claude/agents/`.
3. `pi-worker <report> '<brief>' python-pro` resolves correctly and produces a report (persona body injected from `.claude/personas/python-pro.md`).
4. `pi-worker <report> '<brief>' frontend-developer` still resolves correctly (fallback to `.claude/agents/frontend-developer.md`).
5. The Claude Code agent roster (system-reminder) no longer lists the 10 moved files.
6. All 7 files listed above are updated to reflect the new path.
7. `scripts/copy-agentic-files.sh` copies `.claude/personas/` in fresh installs.
8. Direct-spawning removal is explicitly documented: `subagent_type: python-pro` (and the other 9) is a broken route post-move; coordinator.md and setup.html reflect this.

---

## Out of Scope

- Moving domain specialists (devops-engineer, security-engineer, etc.) — separate decision.
- Implementing Goal B (real Skills) — separate task.
- Any changes to persona file bodies (content is unchanged; only location and frontmatter change).
- Upstream re-sync assumptions: file lengths vary (electron-pro: 239 lines, python-pro/typescript-pro/golang-pro: 276, mobile-developer: 283) — these are not uniformly generated, so no maintenance-comment contract is needed or warranted.
