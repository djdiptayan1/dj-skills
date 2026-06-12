# DJ Skills Repository

This repository contains custom Agentic Coding Skills that can be loaded into AI coding assistants like Oh My Pi, Claude Code, or Cursor.

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
    - /Users/djdiptayan/Documents/Developer/dj skills
```

##### 5. Global Command (Any Supported Agent)

If you place this suite in a shared Git repository, co-workers can install it directly by running:

```bash
npx skills add djdiptayan1/dj-skill
```
