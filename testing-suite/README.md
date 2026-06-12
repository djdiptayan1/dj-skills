# testing-suite 🍬

This testing-suite is a portable, multi-agent suite designed to run validation and implementations across codebases. It automates analysis by piping tasks through:
**DatabaseAuditor -> Tester -> Critic -> Orchestrator -> TechLead -> Validator**

### 📦 Installation Guide for Co-workers:

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
