Modified files:

- [scripts/check-binaries.sh](/home/udai/work/personal/multi-agent-workflow/scripts/check-binaries.sh) — replaced the `pi` requirement with `codex`, updated the header and install hint, and kept `rg` and `fd`.
- [scripts/copy-agentic-files.sh](/home/udai/work/personal/multi-agent-workflow/scripts/copy-agentic-files.sh) — removed the `.claude/personas` copy and pi-worker comment; replaced the stale-agent warning with one warning naming the removed bin files, agent, and trimmed specialist agents.

Commands and literal output:

```text
$ bash -n scripts/check-binaries.sh
exit=0
```

```text
$ bash -n scripts/copy-agentic-files.sh
exit=0
```

```text
$ scripts/check-binaries.sh; echo exit=$?
Checking binaries for the multi-agent workflow…

  [32m✓[0m codex              codex-cli 0.156.1  — codex-worker and codex-reviewer
  [31m✗[0m fd                 NOT FOUND  — Claude Code Glob tool backend (fd-find)
[31m1 required binary/binaries missing.[0m

Install hints:
  codex — npm install -g @openai/codex
  rg    — https://github.com/BurntSushi/ripgrep#installation
  fd    — https://github.com/sharkdp/fd#installation
  [32m✓[0m rg                 ripgrep 15.2.0 (rev e89fff89ac)  — Claude Code Grep tool backend (ripgrep)

exit=1
```

Issue: `scripts/check-binaries.sh` exits `1` because `fd` is not installed; `codex` and `rg` are present. No other files were created, modified, or deleted by me, and I made no git writes.