
#!/usr/bin/env bash
#
# Package all skills into a single ChatGPT/Codex plugin ZIP.
# Uses the portable Agent Plugins format.
#
set -euo pipefail

# where this repo lives
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# setup our output
DIST="$REPO/dist"
OUTPUT="$DIST/dotagents-plugin.zip"

# make sure our dependencies exist
command -v zip >/dev/null 2>&1 || {
    echo "error: zip is required" >&2
    exit 1
}

# make sure we actually have skills
if ! find "$REPO/skills" -mindepth 2 -maxdepth 2 -name SKILL.md -print -quit | grep -q .; then
    echo "error: no skills found" >&2
    exit 1
fi

# setup a temporary staging directory
STAGING="$(mktemp -d)"

# clean up when we're finished
trap 'rm -rf "$STAGING"' EXIT

# setup the plugin directory
mkdir -p "$STAGING/skills" "$DIST"

# create the portable plugin manifest
cat > "$STAGING/plugin.json" <<'EOF'
{
    "$schema": "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json",
    "name": "dotagents",
    "version": "1.0.0",
    "description": "Kevin Pirnie's AI development skills for PHP, Python, Go, WordPress, security, maintenance, and project workflows."
}
EOF

# copy each skill into the package
for dir in "$REPO"/skills/*/; do
    name="$(basename "$dir")"

    # skip directories without a skill definition
    if [ ! -f "$dir/SKILL.md" ]; then
        continue
    fi

    # copy the complete skill directory
    cp -R "$dir" "$STAGING/skills/$name"

    echo "packaged skills/$name"
done

# remove any previous plugin package
rm -f "$OUTPUT"

# build the plugin ZIP with the manifest at the root
(
    cd "$STAGING"
    zip -qr "$OUTPUT" plugin.json skills/
)

echo "built dist/dotagents-plugin.zip"
