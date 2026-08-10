# testing-suite 🍬

A portable, multi-agent suite for **read-only code review** and **approval-gated implementation**,
grounded in *Clean Code* and *The Clean Coder*.

**Read-only review — 9 reviewers → 1 verdict:**
`TestRunner + LinterStaticAnalysis + CodeReviewer + SecurityReviewer + QualityStyleReviewer + TestQualityReviewer + PerformanceReviewer + DependencyDeploymentReviewer + SimplificationMaintainabilityReviewer -> Orchestrator`

**Approved-fix — write-gated:**
`DatabaseAuditor -> Tester -> Critic -> Orchestrator [APPROVAL GATE] -> TechLead -> Validator`

`Orchestrator` presents the brief and stops for an explicit YES. `TechLead` is the only agent with
write access. **No agent spawns another** — the playbooks own sequencing, which is what makes the
gate structural rather than a promise inside a prompt.

---

# 🚀 Quick start

```bash
git clone https://github.com/djdiptayan1/dj-skills.git
cd dj-skills
chmod +x ./testing-suite/install.sh && ./testing-suite/install.sh
```

**Restart your assistant session**, then from inside any git repository:

```
/code-review
```

That's it. It reviews your uncommitted changes and prints a verdict. It never edits files.

---

## 📦 Installation

### One copy, every runtime

The installer puts the skill in **one** shared place and points everything else at it, so a
`git pull` updates every assistant at once:

```
~/.agents/skills/testing-suite ──────────► <your clone>/testing-suite   ← the single source
        ▲             ▲            ▲
        │             │            │
~/.claude/skills   ~/.codex/skills  ~/.pi/skills
~/.claude/commands/code-review.md ──────► claude-commands/code-review.md
~/.omp/agent/config.yml ────────────────► customDirectories: <your clone's parent>
```

Nothing is copied. There is exactly one set of files to update, review, or delete.

### Option A — the installer (recommended)

```bash
chmod +x ./testing-suite/install.sh && ./testing-suite/install.sh
```

| Step | What it does | Runs when |
|---|---|---|
| 1 | Links the skill into the shared hub `~/.agents/skills/testing-suite` | always |
| 2 | Links `~/.claude/skills/` → hub, and the two slash commands into `~/.claude/commands/` | `~/.claude` exists |
| 3 | Links `~/.codex/skills/` and `~/.pi/skills/` → hub | `~/.codex` / `~/.pi` exist |
| 4 | Adds your clone's parent dir to `~/.omp/agent/config.yml` | that file exists |
| 5 | Links project-local `.agents/skills/` or `.claude/skills/` → hub | either exists in `$PWD` |

Then it verifies the chain resolves and **exits non-zero if it doesn't**.

**Both halves matter for Claude Code.** The slash command alone gives you a `/code-review` that
references `skill://testing-suite/...` with nothing behind it, so the agent has to hunt for the
playbooks. Step 2 links both. If you installed before this was fixed, just re-run it.

Safe to re-run: existing links are kept, stale ones are repaired, and a real directory sitting in
the way is reported rather than clobbered.

### Option B — manual

Create the hub link once, then point each runtime at it:

```bash
# 1. the single source
mkdir -p ~/.agents/skills
ln -s "$PWD/testing-suite" ~/.agents/skills/testing-suite

# 2. Claude Code — skill body + slash commands
mkdir -p ~/.claude/skills ~/.claude/commands
ln -s ../../.agents/skills/testing-suite ~/.claude/skills/testing-suite
ln -s "$PWD/testing-suite/claude-commands/code-review.md"          ~/.claude/commands/code-review.md
ln -s "$PWD/testing-suite/claude-commands/apply-approved-suite.md" ~/.claude/commands/apply-approved-suite.md

# 3. Codex (reads commands/*.toml from the skill dir) and Pi
mkdir -p ~/.codex/skills ~/.pi/skills
ln -s ~/.agents/skills/testing-suite ~/.codex/skills/testing-suite
ln -s ~/.agents/skills/testing-suite ~/.pi/skills/testing-suite
```

**OhMyPi** — point it at the **parent** of the skill, not the skill itself:

```yaml
# ~/.omp/agent/config.yml
skills:
  customDirectories:
    - /absolute/path/to/dj-skills
```

**One repo only**, instead of machine-wide:

```bash
mkdir -p .agents/skills
ln -s ~/.agents/skills/testing-suite .agents/skills/testing-suite
```

> Symlinks, never `cp -R`. A copy goes stale the moment you pull.

### Verify

```bash
readlink -f ~/.claude/skills/testing-suite     # → <your clone>/testing-suite
ls ~/.claude/skills/testing-suite/SKILL.md     # resolves through the hub
```

Then start a session and type `/` — `code-review` and `apply-approved-suite` should be listed.
Commands load at startup, so restart after installing.

### Sharing it with your team

```bash
npx skills add djdiptayan1/dj-skills
```

Matches this repository's `origin` remote. Verify it from a clean machine before circulating it —
the earlier `dj-skill` (no `s`) in these docs did not resolve. If you fork this, substitute your own
`<user-or-org>/<repo>`.

---

# ▶️ Running it

## `/code-review` — the one you'll use

Read-only. Never edits files, never runs auto-fixes.

```
/code-review                          # uncommitted + staged changes (default)
/code-review src/modules/billing      # a folder
/code-review src/api/users.ts         # specific files
/code-review feature/new-checkout     # a branch, diffed against main
/code-review 4f2a91c                  # a commit
/code-review 1284                     # a PR number
/code-review https://github.com/org/repo/pull/1284
```

Add free-text context after the scope and it reaches every agent:

```
/code-review focus on the migration safety, this ships Friday
```

**With no argument**, scope is inferred in this order:

1. Explicit branch / commit / PR / paths you passed
2. Uncommitted + staged changes (`git diff` plus `git diff --staged`)
3. Current feature branch vs `main`/`master`
4. The latest commit, if there's no active diff

**What you get back:** overall risk, test results *and* change coverage as separate lines, findings
ranked Critical → Low with `Current` vs `Recommended` code blocks, optional suggestions, and one
verdict — `Ready to Merge`, `Needs Attention`, or `Needs Work`.

## `/apply-approved-suite` — only after you've approved findings

Write-gated. This is the only command that can change your files.

```
/apply-approved-suite
/apply-approved-suite fix findings 1, 3 and 5 only
```

It runs `DatabaseAuditor → Tester → Critic`, then **stops** and shows you a consolidated brief.
Nothing is written until you reply `YES`. `TechLead` then implements exactly what you approved, and
`Validator` re-runs the tests.

Reply `NO` to any individual item to exclude it.

## Typical loop

```
/code-review                    # see what's wrong
                                # read the verdict, decide what you agree with
/apply-approved-suite           # approve the brief, let it fix and re-test
/code-review                    # confirm it's clean
```

---

## 🩺 Troubleshooting

**`/code-review` doesn't appear in the slash list**
`~/.claude/commands/code-review.md` is missing. Re-run `install.sh`, then restart the session —
commands are loaded at startup, not on demand.

**It runs, but says it can't find the playbooks / agents**
The skill body isn't linked, only the command. Check the chain resolves:
```bash
readlink -f ~/.claude/skills/testing-suite   # should print <your clone>/testing-suite
```
Earlier installs linked only the commands. Re-run `install.sh`.

**Updates aren't showing up**
Something is a copy rather than a symlink. `ls -l ~/.agents/skills/testing-suite` must show an
arrow. If it's a real directory, delete it and re-run `install.sh` — the installer refuses to
clobber real directories, so it will have warned you.

**Moved or renamed your clone**
Every link points at the old path. Re-run `install.sh` from the new location; stale links are
detected and repaired.

**A different review runs than the one you expected**
Project-local skills shadow global ones. If the repo has its own `.agents/skills/code-review/` or
`.claude/skills/code-review/`, that wins. Rename one of them.

**Findings are generic, or it flags your house style**
You haven't added `project-checkpoints.md` to the repo being reviewed. See below — this is the
single highest-value thing you can do.

**It flagged a property chain over a DTO as a Law of Demeter violation**
It shouldn't — that's explicitly excluded. Record the type as a data structure in your
`project-checkpoints.md` conventions section.

---

## 🎯 First thing to do in a new repo

Copy `project-checkpoints.example.md` into the root of the repository you want reviewed, as
`project-checkpoints.md`, and replace the examples with your own.

The agents ship **general craft**. Your repository ships **its own scar tissue** — ownership chains,
error-handling contracts, framework gotchas, flows that must stay consistent. Keeping those in the
repo rather than in an agent prompt is exactly what lets you hand this suite to someone else.

Every agent reads `project-checkpoints.md`, `AGENTS.md`, `CLAUDE.md`, and `.cursorrules` at runtime.
**Project conventions override generic book heuristics wherever they conflict.**

---

## 🛠️ How it works

Whatever scope you pass (see [Running it](#️-running-it)) resolves into two variables that are
handed to every agent:

- **`$TARGET_SCOPE`** — the files, diff, commit, or branch under review.
- **`$CONFINEMENT_POLICY`** — restricts all audits and edits strictly inside that scope. Findings
  outside it are vetoed, not reported.

Reviewers run in parallel where the runtime supports it, sequentially otherwise.

Two verdict rules are worth knowing up front, because they differ from most review tools:

- **Test results and test sufficiency are separate lines.** "Tests passed" does not mean "this
  change is covered."
- **"No tests applicable" is not an all-clear** — it is a coverage finding. New business logic
  shipped with no test lands at `Needs Work`.

---

## 🧭 What the reviewers actually check

| Agent | Lens |
|---|---|
| TestRunner | Results, duration, and E1/E2 — is the whole suite one command? is the build? |
| LinterStaticAnalysis | Lint, typecheck, LSP diagnostics; separates auto-fixable from manual |
| CodeReviewer | Naming, function size & abstraction (G34), arguments & flag/selector args, CQS, Law of Demeter, null hygiene, SRP |
| SecurityReviewer | Injection, authz, secrets, prompt boundaries, leaky error handling |
| QualityStyleReviewer | Duplication (G5) with named remedies, comments (C1–C5), dead code, consistency |
| TestQualityReviewer | F.I.R.S.T., single concept, sufficiency (T1–T9), pyramid placement, GUI-vs-API test targets |
| PerformanceReviewer | N+1s, blocking work, render churn, leaks, unbounded loads |
| DependencyDeploymentReviewer | Dependencies, boundary wrapping & learning tests, migrations, rollback, observability |
| SimplificationMaintainabilityReviewer | Beck's Four Rules in priority order, YAGNI, scope atomicity |

---

## Model & reasoning defaults

**Each agent's `model` and `thinkingLevel` frontmatter is the single source of truth.** Override it
there, per agent, in runtimes that support it. This README deliberately does not restate model names
— when it did, the two drifted apart.

Reasoning tiers, by the cost of being wrong:

| Tier | Agents |
|---|---|
| `low` | TestRunner, LinterStaticAnalysis |
| `medium` | CodeReviewer, QualityStyleReviewer, TestQualityReviewer, PerformanceReviewer, SimplificationMaintainabilityReviewer, Tester |
| `high` | SecurityReviewer, DependencyDeploymentReviewer, DatabaseAuditor, Critic, Orchestrator, TechLead, Validator |

**Escalate** the model or reasoning level when the change touches auth, money, migrations, data
integrity, public APIs, or production rollout — or when tests fail, an agent reports uncertainty, or
two agents conflict. Do not escalate for volume alone.

---

## Grounding, with the qualifiers intact

The heuristics come from *Clean Code* (2008) and *The Clean Coder* (2011), applied as the books
actually state them:

- The **Law of Demeter** applies to objects that hide data behind behaviour — **not** to data
  structures. Chains over DTOs, query rows, props, and config are not violations.
- The **Test Automation Pyramid** has **five** tiers (Unit, Component, Integration, System, Manual
  Exploratory), and its numbers are *coverage of the system*, not shares of test count.
- **Single Concept per Test** outranks "one assert per test" — multiple asserts verifying one
  concept are correct, and the book prefers them.
- The **Three Laws of TDD** govern the order code is written in, which a finished diff cannot show.
  Reviewers check sufficiency and timeliness instead of pretending otherwise.
- Functions: the bar is *"hardly ever 20 lines"*, and the real test is abstraction level and
  extractability, not a line count.

These are a school of thought, not laws of physics — Martin says so himself. A finding has to show a
real cost to reading or changing the code, not merely a difference from a book example.
