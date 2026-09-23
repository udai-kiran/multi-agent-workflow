- `ls .claude/bin` output:
  ```text
  codex-reviewer
  codex-worker
  format-file
  ```
- First line of `.claude/agents/python-pro.md` after the frontmatter: **(no body line found)**.
- Yes, I received a DOMAIN GUIDANCE block above the task.

Files created, modified, or deleted: none.

Command run: `ls .claude/bin && awk 'BEGIN{fm=0; body=0} NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {fm=0; body=1; next} body {print; exit}' .claude/agents/python-pro.md`

Output: shown above. No issues or deviations.