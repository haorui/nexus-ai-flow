# Nexus-AI-Flow

Unified AI Agent Configuration Hub.

## Project Structure

- `agents/`: Specialized AI agent definitions.
- `commands/`: Markdown files defining available slash commands and workflows.
- `plugins/`: Integration code for extending functionality.
- `rules/`: Shared rules and guidelines for AI agents.
- `scripts/`: Tools for managing configurations and syncing.
- `skills/`: Reusable skill definitions and workflows.
- `templates/`: Boilerplate files for new projects (e.g., CLAUDE.md templates).

## Usage

The heart of this project is the `nexus-sync.sh` script, which uses symbolic links to share configurations across different tools without duplicating files.

### 1. Link to Claude Code (Global)

To make your rules available to Claude Code globally:

```bash
./scripts/nexus-sync.sh link claude [--rules <rules>] [--commands <commands>]
```

- **Default**: Links `rules/common` to `~/.claude/rules/nexus_common` and all commands to `~/.claude/commands`.
- **With `--rules`**: Links specific rule sets.
- **With `--commands`**: Links specific commands.

### 2. Link to Antigravity (Project-specific)

To apply configurations to a specific workspace for Antigravity:

```bash
./scripts/nexus-sync.sh link antigravity <project_path> [--rules <rules>] [--skills <skills>] [--agents <agents>] [--commands <commands>]
```

**Examples:**

```bash
# Default: Links common rules, ALL agents, and ALL commands (No skills linked by default)
./scripts/nexus-sync.sh link antigravity ./my-project

# Recommended: Link specific configurations
./scripts/nexus-sync.sh link antigravity ./my-project \
  --rules common,golang \
  --skills golang-testing \
  --agents code-reviewer,architect \
  --commands build-fix,checkpoint
```

This updates the `.agent` directory in the target project with symlinks to the selected configurations.

## Available Commands

The following commands are available as workflows in `.agent/workflows/` (symlinked from `commands/`):

| Command            | Description                                                                      |
| ------------------ | -------------------------------------------------------------------------------- |
| `/build-fix`       | Incrementally fix TypeScript and build errors                                    |
| `/checkpoint`      | Create or verify a checkpoint in your workflow                                   |
| `/code-review`     | Thoroughly review code changes against project rules                             |
| `/e2e`             | Generate and run end-to-end tests with Playwright                                |
| `/eval`            | Manage eval-driven development workflow                                          |
| `/evolve`          | Evolve code based on feedback loop                                               |
| `/go-build`        | Go build command wrapper                                                         |
| `/go-review`       | Go code review wrapper                                                           |
| `/go-test`         | Go test command wrapper                                                          |
| `/instinct-export` | Export learned instincts to a shareable format                                   |
| `/instinct-import` | Import instincts from a shared file                                              |
| `/instinct-status` | Show all learned instincts with their confidence levels                          |
| `/learn`           | Analyze project patterns and update rules                                        |
| `/multi-backend`   | Multi-model backend development workflow                                         |
| `/multi-execute`   | Execute multi-model implementation plans                                         |
| `/multi-frontend`  | Multi-model frontend development workflow                                        |
| `/multi-plan`      | Multi-model collaborative planning                                               |
| `/multi-workflow`  | Orchestrate complex multi-step workflows                                         |
| `/orchestrate`     | Orchestrate complex tasks across multiple agents                                 |
| `/plan`            | Create a comprehensive implementation plan                                       |
| `/pm2`             | Manage PM2 processes                                                             |
| `/python-review`   | Python code review wrapper                                                       |
| `/refactor-clean`  | Clean up and refactor code                                                       |
| `/sessions`        | Manage development sessions                                                      |
| `/setup-pm`        | Configure your preferred package manager (npm/pnpm/yarn/bun)                     |
| `/skill-create`    | Analyze local git history to extract coding patterns and generate SKILL.md files |
| `/tdd`             | Enforce test-driven development workflow                                         |
| `/test-coverage`   | Analyze test coverage and generate missing tests                                 |
| `/update-codemaps` | Analyze the codebase structure and update architecture documentation             |
| `/update-docs`     | Sync documentation from source-of-truth                                          |
| `/verify`          | Run comprehensive verification on current codebase state                         |

## Public Skills

You can find a wide range of community-contributed skills at [skills.sh](https://skills.sh/docs).

To use a public skill:

1.  Browse the [Skills Library](https://skills.sh/docs).
2.  Copy the skill content (typically a markdown file).
3.  Create a new file in your `skills/` directory (e.g., `skills/my-new-skill.md`).
4.  Run `nexus-sync.sh` again to link it to your project.

## How to Expand

1. Add a new rule in `rules/common/my-rule.md`.
2. Add a new command in `commands/my-command.md`.
3. Run the sync command again (if needed, though symlinks update automatically).
4. Your AI agents will instantly pick up the new instructions.
