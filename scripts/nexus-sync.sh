#!/bin/bash
# nexus-sync.sh - Link configurations to development tools

set -e

SOURCE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ACTION=$1 # "link" or "unlink"
TOOL=$2   # "claude" or "antigravity"
TARGET=$3 # Project path for antigravity

function link_antigravity() {
    local project_path=$1
    if [ -z "$project_path" ]; then
        echo "Error: Target project path required for antigravity"
        exit 1
    fi
    mkdir -p "$project_path/.agent/rules"
    mkdir -p "$project_path/.agent/skills"
    
    ln -sf "$SOURCE_DIR/rules/common" "$project_path/.agent/rules/nexus_common"
    ln -sf "$SOURCE_DIR/skills" "$project_path/.agent/skills/nexus_skills"
    echo "Linked Nexus configs to $project_path"
}

function link_claude() {
    mkdir -p ~/.claude/rules/common
    ln -sf "$SOURCE_DIR/rules/common" ~/.claude/rules/nexus_common
    echo "Linked Nexus configs to ~/.claude (global)"
}

case "$TOOL" in
    "antigravity")
        link_antigravity "$TARGET"
        ;;
    "claude")
        link_claude
        ;;
    *)
        echo "Usage: $0 link [claude|antigravity] [target_path]"
        ;;
esac
