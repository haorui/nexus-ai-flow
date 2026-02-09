# Nexus-AI-Flow

Unified AI Agent Configuration Hub.

## Project Structure

- `rules/`: Shared guidelines for AI agents.
- `agents/`: Specialized agent definitions.
- `skills/`: Reusable workflow definitions.
- `scripts/`: Tools for managing configurations.
- `links/`: Symlink management.

## Usage

The heart of this project is the `nexus-sync.sh` script, which uses symbolic links to share configurations across different tools without duplicating files.

### 1. Link to Claude Code (Global)

To make your rules available to Claude Code globally:

```bash
./scripts/nexus-sync.sh link claude
```

This links `rules/common` to `~/.claude/rules/nexus_common`.

### 2. Link to Antigravity (Project-specific)

To apply these configurations to a specific workspace for Antigravity:

```bash
./scripts/nexus-sync.sh link antigravity /Users/haoruili/Documents/workspaces/sso/smartdata
```

This creates/updates the `.agent` directory in the target project with links to your Nexus rules and skills.

## Directory Structure

- **`rules/common/`**: Guidelines that every AI agent should follow (style, git, etc).
- **`agents/`**: Multi-agent definitions.
- **`skills/`**: Reusable technical workflows (e.g., TDD, security review).
- **`scripts/`**: Utility scripts like the sync tool.

## How to Expand

1. Add a new rule in `rules/common/my-rule.md`.
2. Run the sync command again (if needed, though symlinks update automatically).
3. Your AI agents will instantly pick up the new instructions.
