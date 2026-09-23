# 002 — Claude + Codex only

## Objective

Branch `claude-codex` runs on two harnesses only: Claude Code and Codex CLI.
Remove pi (and every OpenRouter model), the perf-selection machinery, and
trim the specialist agents.

## Roles

| Role | Agent | Model |
|------|-------|-------|
| Coordinator / planner | `coordinator` (Claude) | Opus 5.5 |
| Intelligent worker (implement) | `codex-worker` bin, worker `sol` | `gpt-6-sol`, reasoning `max` |
| Grunt / log analysis | `codex-worker` bin, worker `luna` | `gpt-6-luna`, reasoning `medium` |
| Grunt / log analysis (read-only) | `haiku-worker` subagent | Claude Haiku |
| Verify + implement fallback | `sonnet-worker` subagent | Claude Sonnet |
| Code reviewer | `codex-reviewer` bin | `gpt-6-astra`, reasoning `high` |

Models: user chose `gpt-6-sol` for the intelligent worker (replacing the
originally requested terra) and `gpt-6-luna` for grunt. Both verified
first-hand on codex-cli 0.156.1 (`-m gpt-6-sol` / `-m gpt-6-luna`, effort max → "OK").

## Pre-existing defect found

Both codex bins pass `--reasoning <level>`; codex-cli 0.156.1 rejects it
(`error: unexpected argument '--reasoning' found`). So every codex-worker and
codex-reviewer call currently fails. Fix: `-c model_reasoning_effort=<level>`.

## Changes

1. `.claude/bin/codex-worker` — fix reasoning flag; default model gpt-6-sol;
   optional 3rd arg `[persona-name]` (ported from pi-worker); drop perf-log
   write. (A ported post-run format-file pass was dropped after review: it
   formatted every dirty file, including user and concurrent-worker edits.)
2. `.claude/bin/codex-reviewer` — fix reasoning flag; drop pi-worker comment;
   run under `--sandbox read-only` instead of bypassing the sandbox (review
   finding: docs claimed read-only, bin was not).
3. Delete: `.claude/bin/pi-worker`, `.claude/bin/worker-log`,
   `.claude/bin/worker-stats`, `.claude/agents/pi-worker.md`, 38 specialist
   agents, `tasks/smoke-test/*{pi,dsh}*`.
   Keep specialists: python-pro, typescript-pro, golang-pro, rust-engineer,
   sql-pro, security-engineer, debugger, performance-engineer.
   Their "Integration with other agents" blocks (naming deleted agents) removed.
   Follow-up (user request): also delete `tasks/.worker-*.jsonl` (fed the removed
   worker-stats) and agents `test-runner` / `ci-validator` — they wrapped
   compass-only bins (`run-gates`: npm typecheck/lint/test; `check-ci`:
   node:test log parsing) at a nonexistent `/work/personal/compass` path.
   `haiku-worker` covers running named commands and CI/log analysis.
4. `.claude/config/worker-map.json` — fixed role map (coordinator writes).
5. `.claude/agents/coordinator.md` — rewrite for the roles (coordinator writes).
6. `.claude/agents/codex-worker.md` — repo-relative bin path, sol/luna, persona arg.
7. New `.claude/agents/haiku-worker.md` — read-only grunt (investigate,
   verify runs, log analysis).
8. `.claude/agents/sonnet-worker.md` — persona section count/wording.
9. `scripts/check-binaries.sh` — require `codex` instead of `pi`.
10. `scripts/copy-agentic-files.sh` — drop personas dir + pi comment; stale-file warning.
11. `setup.html` — roster, rules, agent grid.

## Acceptance

- `rg -i 'pi-worker|PI_WORKER|openrouter|deepseek|kimi|glm|grok|gemini|\bdsh\b|worker-stats|worker-log|cold.start'`
  over tracked files outside `tasks/` → no hits.
- `bash -n` on every changed bin/script passes; `jq . worker-map.json` passes.
- `codex-worker` usage errors: 0 args → exit 2; unknown persona → exit 2.
- Real smoke run: codex-worker with luna writes a report; codex-reviewer writes a review.
- `scripts/check-binaries.sh` exits 0 on this host.
