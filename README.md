# DJ Skills

Custom agentic coding skills, loadable into Claude Code, Codex, Pi, OhMyPi, or Cursor.

## Skills

| Skill | What it does |
|---|---|
| [`testing-suite`](./testing-suite) | 15 agents — multi-agent code review (`/code-review`, 9 reviewers) and approval-gated implementation (`/apply-approved-suite`, 6 agents), grounded in *Clean Code* & *The Clean Coder*. |

## Install & run

```bash
git clone https://github.com/djdiptayan1/dj-skills.git
cd dj-skills
chmod +x ./testing-suite/install.sh && ./testing-suite/install.sh
```

Restart your assistant session, then from inside any git repository:

```
/code-review              # read-only review of your current changes
/apply-approved-suite     # gated implementation, only after you approve findings
```

`/code-review` takes an optional scope — a path, branch, commit, or PR number — and any free-text
context after it:

```
/code-review src/modules/billing
/code-review 1284 focus on migration safety
```

### One copy, every runtime

The installer links each skill into a shared hub at `~/.agents/skills/`, then points every runtime
at that one location — Claude Code, Codex, Pi, and OhMyPi all read the same files:

```
~/.agents/skills/<skill> ─────────► <your clone>/<skill>    ← the single source
      ▲            ▲          ▲
~/.claude/skills  ~/.codex/skills  ~/.pi/skills
```

Nothing is copied, so `git pull` updates every assistant at once. Verify with:

```bash
readlink -f ~/.claude/skills/testing-suite    # → <your clone>/testing-suite
```

Full options, manual per-runtime setup, and troubleshooting are in
[`testing-suite/README.md`](./testing-suite/README.md).

## Sharing with others

```bash
npx skills add djdiptayan1/dj-skills
```

Matches the `origin` remote of this repository. Verify it from a clean machine before circulating
it — the earlier `dj-skill` (no `s`) in these docs did not resolve.

## Adding a skill to this repo

One directory per skill, each self-contained:

```
<skill-name>/
├── SKILL.md          # entry point: what it is, how to run it
├── README.md         # human-facing install + usage
├── install.sh        # runtime registration
├── agents/           # one file per agent
├── playbooks/        # sequencing; playbooks own control flow, agents do not
└── claude-commands/  # slash command definitions
```

Keep domain-specific rules **out** of skill files. A skill that hardcodes one project's entities
cannot be shared. Put those in the target repository instead — `testing-suite` reads
`project-checkpoints.md`, `AGENTS.md`, `CLAUDE.md`, and `.cursorrules` at runtime for exactly this
reason.
