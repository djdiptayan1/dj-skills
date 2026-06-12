#!/bin/bash
# install.sh - Automated installer for the Testing Suite skill.

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SKILL_DIR")"

echo "🍬 Installing 'testing-suite' skill..."
echo "Local Path: $SKILL_DIR"

# 1. OhMyPi (OMP) Installation
OMP_CONFIG="$HOME/.omp/agent/config.yml"
if [ -f "$OMP_CONFIG" ]; then
    echo "🔍 Found OhMyPi configuration at: $OMP_CONFIG"
    
    # Check if custom directory already added
    if grep -q "$PARENT_DIR" "$OMP_CONFIG"; then
        echo "✅ Custom directory already registered in OhMyPi config."
    else
        echo "🔧 Registering custom directory in $OMP_CONFIG..."
        
        # Verify if skills block exists
        if grep -q "^skills:" "$OMP_CONFIG"; then
            # Check if customDirectories exists under skills
            if grep -q "  customDirectories:" "$OMP_CONFIG"; then
                # Append to existing list (inserting under the line matching customDirectories)
                sed -i.bak "/  customDirectories:/a\\
    - $PARENT_DIR" "$OMP_CONFIG" && rm -f "$OMP_CONFIG.bak"
            else
                # Append customDirectories to skills block
                sed -i.bak "s/^skills:/skills:\n  customDirectories:\n    - $(echo $PARENT_DIR | sed 's/\//\\\//g')/g" "$OMP_CONFIG" && rm -f "$OMP_CONFIG.bak"
            fi
        else
            # Append skills block to end of file
            echo -e "\nskills:\n  customDirectories:\n    - $PARENT_DIR" >> "$OMP_CONFIG"
        fi
        echo "✅ OhMyPi configuration updated successfully!"
    fi
else
    echo "⚠️  OhMyPi config not found at $OMP_CONFIG (Skipping OMP config update)."
fi

# 2. Claude Code (Project Local Symlinking)
echo "🔍 Checking for project-local agent directories..."
for dir in ".agents/skills" ".claude/skills"; do
    if [ -d "$dir" ]; then
        if [ -L "$dir/testing-suite" ] || [ -d "$dir/testing-suite" ]; then
            echo "✅ Skill already linked or copied in project $dir/testing-suite"
        else
            echo "🔧 Creating symlink in project $dir..."
            ln -s "$SKILL_DIR" "$dir/testing-suite"
            echo "✅ Created symlink: $dir/testing-suite -> $SKILL_DIR"
        fi
    fi
done

# 3. Codex & Pi CLI (User Global Directories)
echo "🔍 Registering global CLI paths..."
for path in "$HOME/.codex/skills" "$HOME/.pi/skills"; do
    parent_path="$(dirname "$path")"
    if [ -d "$parent_path" ]; then
        mkdir -p "$path"
        if [ -L "$path/testing-suite" ] || [ -d "$path/testing-suite" ]; then
            echo "✅ Skill already linked or copied in global $path/testing-suite"
        else
            echo "🔧 Creating symlink in global $path..."
            ln -s "$SKILL_DIR" "$path/testing-suite"
            echo "✅ Created symlink: $path/testing-suite -> $SKILL_DIR"
        fi
    fi
done

echo -e "\n🎉 Installation complete! Restart your coding assistant session to load 'testing-suite'."
