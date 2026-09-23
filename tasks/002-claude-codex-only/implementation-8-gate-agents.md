Files changed:

- Deleted `.claude/agents/test-runner.md` and `.claude/agents/ci-validator.md`; these agent wrappers depend on bins found only in another project.
- Deleted `tasks/.worker-perf.jsonl` and `tasks/.worker-verify.jsonl`; these logs fed the removed `worker-stats` tool.
- Modified `setup.html` to remove the two requested Workflow Agents chips.
- Modified `scripts/copy-agentic-files.sh` to add both agent names to the existing manual cleanup warning.

Commands run and output:

```text
$ ls .claude/agents tasks | head -40
.claude/agents:
codex-reviewer.md
codex-worker.md
coordinator.md
debugger.md
golang-pro.md
haiku-worker.md
performance-engineer.md
python-pro.md
rust-engineer.md
security-engineer.md
sonnet-worker.md
sql-pro.md
typescript-pro.md

tasks:
001-agents-to-skills
002-claude-codex-only
check-binaries-trim
codex-review.2iQI8z.md
codex-review.83kGxk.md
codex-review.WdI7W8.md
codex-review.jdlDt8.md
codex-review.p9SyuP.md
codex-review.rv1Clz.md
codex-review.yfhXEb.md
format-file
smoke-test

$ grep -n "test-runner\|ci-validator" setup.html scripts/copy-agentic-files.sh
scripts/copy-agentic-files.sh:97:warn "files removed from this repo are not deleted from an existing target install; remove bin pi-worker, worker-log, worker-stats, agent pi-worker, test-runner, ci-validator, and the trimmed specialist agents manually"

$ bash -n scripts/copy-agentic-files.sh; echo exit=$?
exit=0

$ git status --porcelain=v1
 D .claude/agents/ci-validator.md
 D .claude/agents/test-runner.md
 M scripts/copy-agentic-files.sh
 M setup.html
 D tasks/.worker-perf.jsonl
 D tasks/.worker-verify.jsonl
?? .claude/plugins/
?? .claude/skills/
?? .claude/state/
```

Issues or deviations: `git status` shows pre-existing untracked `.claude/plugins/`, `.claude/skills/`, and `.claude/state/`; I did not modify them. No git write commands were run.