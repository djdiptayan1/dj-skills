#!/bin/bash
# install.sh — installs the testing-suite skill once into a shared hub, then points
# every detected runtime at that one copy.
#
#   ~/.agents/skills/testing-suite  ->  <this repo>/testing-suite     (the single source)
#   ~/.claude/skills/               ->  ../../.agents/skills/...      (Claude Code)
#   ~/.codex/skills/                ->  ~/.agents/skills/...          (Codex)
#   ~/.pi/skills/                   ->  ~/.agents/skills/...          (Pi)
#   ~/.omp/agent/config.yml         ->  customDirectories entry       (OhMyPi)
#   ~/.claude/commands/             ->  slash commands
#
# Safe to re-run: every step is idempotent and repairs a stale or missing link.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SKILL_DIR")"
HUB="$HOME/.agents/skills"
HUB_LINK="$HUB/testing-suite"

echo "🍬 Installing 'testing-suite'"
echo "   source: $SKILL_DIR"
echo

# link <target> <link_path> — create or repair a symlink, never clobber a real directory
link() {
    local target="$1" link_path="$2" label="$3"
    if [ -L "$link_path" ]; then
        if [ "$(readlink "$link_path")" = "$target" ]; then
            echo "   ✅ $label (already linked)"
            return
        fi
        rm "$link_path"
        ln -s "$target" "$link_path"
        echo "   🔧 $label (relinked, was stale)"
    elif [ -e "$link_path" ]; then
        echo "   ⚠️  $label — a real file/dir already exists at $link_path. Skipped."
        echo "      Remove it manually if you want the symlink instead."
    else
        ln -s "$target" "$link_path"
        echo "   ✅ $label"
    fi
}

# ── 1. Shared hub — the single copy everything else points at ───────────────────
echo "1. Shared hub"
mkdir -p "$HUB"
link "$SKILL_DIR" "$HUB_LINK" "~/.agents/skills/testing-suite"
echo

# ── 2. Claude Code ──────────────────────────────────────────────────────────────
echo "2. Claude Code"
if [ -d "$HOME/.claude" ]; then
    mkdir -p "$HOME/.claude/skills" "$HOME/.claude/commands"
    # relative link, matching how other skills in ~/.claude/skills reference the hub
    link "../../.agents/skills/testing-suite" "$HOME/.claude/skills/testing-suite" "~/.claude/skills/testing-suite"
    for cmd in code-review apply-approved-suite; do
        link "$SKILL_DIR/claude-commands/$cmd.md" "$HOME/.claude/commands/$cmd.md" "/$cmd"
    done
else
    echo "   ⏭  ~/.claude not found, skipping"
fi
echo

# ── 3. Codex & Pi ───────────────────────────────────────────────────────────────
echo "3. Codex / Pi"
for runtime_home in "$HOME/.codex" "$HOME/.pi"; do
    name="$(basename "$runtime_home")"
    if [ -d "$runtime_home" ]; then
        mkdir -p "$runtime_home/skills"
        link "$HUB_LINK" "$runtime_home/skills/testing-suite" "~/$name/skills/testing-suite"
    else
        echo "   ⏭  ~/$name not found, skipping"
    fi
done
echo

# ── 4. OhMyPi ───────────────────────────────────────────────────────────────────
echo "4. OhMyPi"
OMP_CONFIG="$HOME/.omp/agent/config.yml"
if [ -f "$OMP_CONFIG" ]; then
    if grep -qF "$PARENT_DIR" "$OMP_CONFIG"; then
        echo "   ✅ customDirectories already includes $PARENT_DIR"
    elif grep -q "^  customDirectories:" "$OMP_CONFIG"; then
        printf '    - %s\n' "$PARENT_DIR" >> "$OMP_CONFIG"
        echo "   ⚠️  appended to end of $OMP_CONFIG — verify it sits under customDirectories:"
    elif grep -q "^skills:" "$OMP_CONFIG"; then
        printf '  customDirectories:\n    - %s\n' "$PARENT_DIR" >> "$OMP_CONFIG"
        echo "   ⚠️  appended a customDirectories block — verify $OMP_CONFIG"
    else
        printf '\nskills:\n  customDirectories:\n    - %s\n' "$PARENT_DIR" >> "$OMP_CONFIG"
        echo "   ✅ added skills.customDirectories to $OMP_CONFIG"
    fi
else
    echo "   ⏭  $OMP_CONFIG not found, skipping"
fi
echo

# ── 5. Project-local (only if this repo is not the target) ──────────────────────
if [ "$PWD" != "$PARENT_DIR" ]; then
    for dir in ".agents/skills" ".claude/skills"; do
        if [ -d "$dir" ]; then
            echo "5. Project-local ($PWD)"
            link "$HUB_LINK" "$dir/testing-suite" "$dir/testing-suite"
            echo
            break
        fi
    done
fi

# ── Verify ──────────────────────────────────────────────────────────────────────
echo "Verifying…"
fail=0
for p in "$HUB_LINK" "$HOME/.claude/skills/testing-suite" "$HOME/.claude/commands/code-review.md"; do
    if [ -e "$p" ]; then
        echo "   ✅ $p"
    else
        echo "   ❌ $p  MISSING"
        fail=1
    fi
done
[ -f "$HUB_LINK/SKILL.md" ] && echo "   ✅ SKILL.md resolves through the hub" || { echo "   ❌ SKILL.md does NOT resolve through the hub"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
    echo "🎉 Installed. Restart your assistant session, then run:"
    echo "     /code-review              read-only review of your current changes"
    echo "     /apply-approved-suite     gated implementation, after you approve findings"
    echo
    echo "   Next: copy project-checkpoints.example.md into the repo you want reviewed,"
    echo "   as project-checkpoints.md, and fill in your own rules."
else
    echo "⚠️  Installation incomplete — see the ❌ lines above."
    exit 1
fi
