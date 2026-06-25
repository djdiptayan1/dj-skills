# testing-suite 🍬

This testing-suite is a portable, multi-agent suite designed to run read-only code review, validation, and approval-gated implementations across codebases.

Read-only review mode uses 9 focused reviewers:
**TestRunner + LinterStaticAnalysis + CodeReviewer + SecurityReviewer + QualityStyleReviewer + TestQualityReviewer + PerformanceReviewer + DependencyDeploymentReviewer + SimplificationMaintainabilityReviewer -> Orchestrator**

Approved-fix mode keeps the write-gated flow:
**DatabaseAuditor -> Tester -> Critic -> Orchestrator -> TechLead -> Validator**

### 📦 Installation Guide:

#### Option A: Automatic Installation (Highly Recommended)

They can clone your repository and run:

```bash
chmod +x ./testing-suite/install.sh && ./testing-suite/install.sh
```

This script handles the config additions and directory symlinking automatically.

#### Option B: Manual Setup by Agent Runtime

##### 1. PlotCode

PlotCode dynamically discovers skills in the project's local `.agents/skills` or `.claude/skills` directory:

```bash
mkdir -p .agents/skills/testing-suite
cp -R /path/to/testing-suite/* .agents/skills/testing-suite/
```

##### 2. Codex CLI (rtk)

Register the suite via your global configuration:

```bash
mkdir -p ~/.codex/skills/
cp -R testing-suite ~/.codex/skills/testing-suite
```

##### 3. Pi CLI

Register the suite globally in the user configuration folder:

```bash
mkdir -p ~/.pi/skills/
cp -R testing-suite ~/.pi/skills/testing-suite
```

##### 4. OhMyPi (OMP)

Add the parent directory directly to `~/.omp/agent/config.yml` (our `install.sh` handles this automatically if run):

```yaml
skills:
  customDirectories:
    - /path/to/parent/folder/dj skills
```

##### 5. Global Command (Any Supported Agent)

If you place this suite in a shared Git repository, co-workers can install it directly by running:

```bash
npx skills add <your-github-org>/testing-suite
```

## 🛠️ How it Works

This testing-suite abstracts the target scope dynamically:

* **`$TARGET_SCOPE`**: Can be set to git uncommitted files (`git diff`), a specific feature folder (e.g. `src/modules/billing`), or the whole repository.
* **`$CONFINEMENT_POLICY`**: Restricts edits and audits strictly inside the designated target scope.

## Normal Use

Use `skill://testing-suite/playbooks/code-review.md` for almost everything. It is read-only and targets the code people usually want reviewed: uncommitted files, PR files, or the current branch.

It infers scope in this order:

1. Explicit branch, commit, PR, or file paths from the user.
2. Uncommitted files in the current workspace (`git diff` plus `git diff --staged`).
3. Current feature branch diff vs `main` or `master`.
4. Latest commit when there is no active diff.

The review agents should run in parallel when the runtime supports it, with a sequential fallback. This mode does not edit files or run auto-fixes.

Use `skill://testing-suite/playbooks/apply-approved-suite.md` only after you approve fixes from the review.

## The Two Commands

### `code-review.md`: 9-agent read-only review

Use this when someone says "review my code", "check my PR", "review my uncommitted changes", or points at files/commits/branches. It never edits files.

Flow:
`TestRunner + LinterStaticAnalysis + CodeReviewer + SecurityReviewer + QualityStyleReviewer + TestQualityReviewer + PerformanceReviewer + DependencyDeploymentReviewer + SimplificationMaintainabilityReviewer -> Orchestrator`

### `apply-approved-suite.md`: 6-agent approved implementation/testing

Use this only after the review findings are approved and you want the agent to fix them. `TechLead` is the only writer.

Flow:
`DatabaseAuditor -> Tester -> Critic -> TechLead -> Validator -> Orchestrator`

That is the whole command surface. The old `run-all-subagents*` commands were removed because `code-review.md` covers normal review better and `apply-approved-suite.md` covers approved fixes/testing.

## Model And Reasoning Defaults

The agents are portable prompts. The `model` frontmatter is only the Gemini-compatible default; override it in runtimes like Claude Code when supported.

| Agent type | Reasoning | Gemini | Claude |
| --- | --- | --- | --- |
| TestRunner, LinterStaticAnalysis | low | Gemini 3.5 Flash | Sonnet |
| CodeReviewer, QualityStyleReviewer, TestQualityReviewer, PerformanceReviewer, SimplificationMaintainabilityReviewer, Tester | medium | Gemini 3.5 Flash | Sonnet |
| DatabaseAuditor, SecurityReviewer, DependencyDeploymentReviewer, Critic, Orchestrator, TechLead, Validator | high | Gemini 3.5 Flash | Opus for high-risk work, Sonnet for low-risk work |

Escalate to Opus when the change touches auth, payments, migrations, data integrity, public APIs, production deployment, or failed tests. Otherwise start with Sonnet/Gemini Flash to save tokens.
