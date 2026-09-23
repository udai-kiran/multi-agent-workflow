Modified these eight files:

- `.claude/agents/python-pro.md`
- `.claude/agents/typescript-pro.md`
- `.claude/agents/golang-pro.md`
- `.claude/agents/rust-engineer.md`
- `.claude/agents/sql-pro.md`
- `.claude/agents/security-engineer.md`
- `.claude/agents/debugger.md`
- `.claude/agents/performance-engineer.md`

Removed each “Integration with other agents:” header and its bullets, keeping a single blank line before the final “Always prioritize …” line. I created or deleted no files and made no git writes.

Commands run and output:

- Inspected each target section with `rg -n -A8 -B2 'Integration with other agents:'` and checked each file’s ending with `tail -14`. The output showed the requested block followed by the final “Always prioritize …” line in each file.
- Ran a Python script to remove the header, contiguous bullets, and following separator blank line in the eight target files. It produced no output.
- Ran the requested verification commands:

```text
.claude/agents/python-pro.md:0
.claude/agents/typescript-pro.md:0
.claude/agents/golang-pro.md:0
.claude/agents/rust-engineer.md:0
.claude/agents/sql-pro.md:0
.claude/agents/security-engineer.md:0
.claude/agents/debugger.md:0
.claude/agents/performance-engineer.md:0
 .claude/agents/api-designer.md              | 237 -----------------------
 .claude/agents/api-documenter.md            | 277 ---------------------------
 .claude/agents/architect-reviewer.md        | 287 ----------------------------
 .claude/agents/azure-infra-engineer.md      |  55 ------
 .claude/agents/backend-developer.md         | 222 ---------------------
 .claude/agents/build-engineer.md            | 286 ---------------------------
 .claude/agents/cli-developer.md              | 286 ---------------------------
 .claude/agents/cloud-architect.md            | 277 ---------------------------
 .claude/agents/code-reviewer.md              | 287 ----------------------------
 .claude/agents/codex-worker.md               |  24 ++-
 .claude/agents/coordinator.md                | 212 ++++++++++----------
 .claude/agents/cpp-pro.md                    | 277 ---------------------------
 .claude/agents/database-administrator.md     | 287 ----------------------------
 .claude/agents/debugger.md                   |  10 -
 .claude/agents/dependency-manager.md         | 286 ---------------------------
 .claude/agents/deployment-engineer.md        | 287 ----------------------------
 .claude/agents/devops-engineer.md             | 287 ----------------------------
 .claude/agents/devops-incident-responder.md  | 287 ----------------------------
 .claude/agents/django-developer.md            | 287 ----------------------------
 .claude/agents/documentation-engineer.md     | 276 --------------------------
 .claude/agents/electron-pro.md                | 240 -----------------------
 .claude/agents/embedded-systems.md            | 287 ----------------------------
 .claude/agents/frontend-developer.md          | 133 -------------
 .claude/agents/fullstack-developer.md         | 235 -----------------------
 .claude/agents/git-workflow-manager.md        | 286 ---------------------------
 .claude/agents/golang-pro.md                  |  10 -
 .claude/agents/graphql-architect.md           | 238 -----------------------
 .claude/agents/incident-responder.md           | 287 ----------------------------
 .claude/agents/kubernetes-specialist.md       | 287 ----------------------------
 .claude/agents/mcp-developer.md               | 275 --------------------------
 .claude/agents/microservices-architect.md     | 239 -----------------------
 .claude/agents/mobile-developer.md             | 283 ---------------------------
 .claude/agents/network-engineer.md              | 287 ----------------------------
 .claude/agents/performance-engineer.md          |  10 -
 .claude/agents/pi-worker.md                     |  77 --------
 .claude/agents/platform-engineer.md              | 287 ----------------------------
 .claude/agents/python-pro.md                    |  10 -
 .claude/agents/refactoring-specialist.md        | 286 ---------------------------
 .claude/agents/rust-engineer.md                 |  10 -
 .claude/agents/security-engineer.md              |  10 -
 .claude/agents/sonnet-worker.md                 |   7 +-
 .claude/agents/sql-pro.md                        |  10 -
 .claude/agents/sre-engineer.md                  | 287 ----------------------------
 .claude/agents/terraform-engineer.md             | 287 ----------------------------
 .claude/agents/tooling-engineer.md               | 286 ---------------------------
 .claude/agents/typescript-pro.md                 |  10 -
 .claude/agents/ui-designer.md                    | 174 -----------------
 .claude/agents/vue-expert.md                     | 287 ----------------------------
 .claude/agents/websocket-engineer.md             | 150 ---------------
 .claude/agents/windows-infra-admin.md             |  54 ------
 50 files changed, 118 insertions(+), 9945 deletions(-)
- `tail -4 .claude/agents/python-pro.md`:

```text
- Database testing strategies
- Transaction management

Always prioritize code readability, type safety, and Pythonic idioms while delivering performant and secure solutions.
```

The scoped diff stat includes changes across 50 files in `.claude/agents/`; only the eight listed files were edited for this task. No other issues or deviations.