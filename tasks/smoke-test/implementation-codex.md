Files created:

- `tasks/smoke-test/hello-codex.txt` — contains the required single line: `smoke test passed by codex-worker`.

Commands run:

- `pwd && rg --files tasks/smoke-test 2>/dev/null || true && git status --short`
  - Confirmed repository location and existing task directory.
- `wc -l tasks/smoke-test/hello-codex.txt && od -An -t x1 tasks/smoke-test/hello-codex.txt && git status --short -- tasks/smoke-test/hello-codex.txt`
  - Verified one line, exact text bytes with trailing newline, and that only the requested file is newly created.

Issues, risks, or deviations:

- None. No other files were modified by this task.