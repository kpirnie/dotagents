#!/usr/bin/env bash
#
# Build one upload zip per skill (folder at the zip root) into dist/,
# for the claude.ai and ChatGPT skill uploaders.
#
set -euo pipefail

# where this repo lives
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# start clean
rm -rf "$REPO/dist"
mkdir -p "$REPO/dist"

# zip each skill folder
cd "$REPO/skills"
for dir in */; do
    name="${dir%/}"
    zip -qr "$REPO/dist/$name.zip" "$name"
    echo "built dist/$name.zip"
done
