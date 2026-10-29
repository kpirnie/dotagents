#!/usr/bin/env bash
#
# Link this repo's rules, skills, and project notes into the global
# locations Claude Code and Codex read from. Safe to re-run.
#
set -euo pipefail

# where this repo lives
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# back up anything real in the way, then symlink
link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "$dst.bak.$(date +%s)"
        echo "backed up $dst"
    fi
    ln -sfn "$src" "$dst"
    echo "linked $dst -> $src"
}

# repo-local skill links, in case the checkout dropped them
link ../skills "$REPO/.claude/skills"
link ../skills "$REPO/.agents/skills"

# shared rules
link "$REPO/AGENTS.md" "$HOME/.agents/AGENTS.md"
link "$REPO/AGENTS.md" "$HOME/.codex/AGENTS.md"

# claude's global file imports the shared rules
if [ -e "$HOME/.claude/CLAUDE.md" ] && ! grep -qx '@~/.agents/AGENTS.md' "$HOME/.claude/CLAUDE.md"; then
    mv "$HOME/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md.bak.$(date +%s)"
    echo "backed up $HOME/.claude/CLAUDE.md"
fi
mkdir -p "$HOME/.claude"
printf '@~/.agents/AGENTS.md\n' > "$HOME/.claude/CLAUDE.md"
echo "wrote $HOME/.claude/CLAUDE.md"

# project notes
link "$REPO/projects" "$HOME/.agents/projects"

# skills, one link per skill so other installed skills are left alone
for dir in "$REPO"/skills/*/; do
    name="$(basename "$dir")"
    link "$REPO/skills/$name" "$HOME/.claude/skills/$name"
    link "$REPO/skills/$name" "$HOME/.agents/skills/$name"
done
