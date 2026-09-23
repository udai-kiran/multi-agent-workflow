Modified only [setup.html](/home/udai/work/personal/multi-agent-workflow/setup.html).

- Replaced the worker roster with the fixed coordinator, sol, luna, haiku-worker, sonnet-worker, and codex-reviewer roles; removed the old performance-selection note.
- Updated pipeline labels and the implementation rule to name `sol`.
- Replaced the specialist list with the requested persona and workflow agent grids.

Commands run and output:

```text
grep -nEi "pi-|openrouter|deepseek|kimi|glm|grok|gemini|cold" setup.html; echo exit=$?
exit=1
```

```text
git diff --stat -- setup.html
 setup.html | 136 ++++++++++++++++++++++---------------------------------------
 1 file changed, 48 insertions(+), 88 deletions(-)
```

Issues, risks, or deviations: None. I did not change the `<style>` block or run any git write commands.