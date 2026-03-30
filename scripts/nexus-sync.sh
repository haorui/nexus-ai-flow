#!/bin/bash
# nexus-sync.sh - Link configurations to development tools

set -euo pipefail

# --- Configuration ---
SOURCE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Logging ---
function log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

function log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

function log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

function usage() {
    echo "Usage:"
    echo "  $0 link [antigravity|claude] [target_path] [--skills skill1,skill2] [--rules rule1,rule2] [--agents agent1,agent2] [--commands cmd1,cmd2]"
    echo "  $0 unlink [antigravity|claude] [target_path]"
    echo ""
    echo "Examples:"
    echo "  $0 link antigravity ./my-project --skills tdd-workflow --rules golang --agents code-reviewer --commands build-fix"
    echo "  $0 unlink antigravity ./my-project"
    echo "  $0 unlink claude"
    exit 1
}

# --- Core Logic ---

function sync_rules() {
    local target_dir="$1"
    local rules_csv="$2"
    
    mkdir -p "$target_dir"
    
    if [ -n "$rules_csv" ]; then
        # When using specific rules, ensure the default common link is removed
        rm -f "$target_dir/nexus_common"
        
        IFS=',' read -ra RULES <<< "$rules_csv"
        for rule in "${RULES[@]}"; do
            if [ -d "$SOURCE_DIR/rules/$rule" ]; then
                # Clean up existing link if it exists to avoid confusion
                rm -f "$target_dir/$rule"
                ln -sf "$SOURCE_DIR/rules/$rule" "$target_dir/$rule"
                log_info "Linked rule set: $rule"
            else
                log_warn "Rule set '$rule' not found in $SOURCE_DIR/rules/"
            fi
        done
    else
        # Default behavior: link common
        rm -f "$target_dir/nexus_common"
        ln -sf "$SOURCE_DIR/rules/common" "$target_dir/nexus_common"
        log_info "Linked common rules to $target_dir/nexus_common"
    fi
}

function sync_skills() {
    local target_base="$1"
    local skills_csv="$2"
    
    mkdir -p "$target_base"
    
    if [ -n "$skills_csv" ]; then
        IFS=',' read -ra SKILLS <<< "$skills_csv"
        for skill in "${SKILLS[@]}"; do
            if [ -d "$SOURCE_DIR/skills/$skill" ]; then
                ln -sf "$SOURCE_DIR/skills/$skill" "$target_base/$skill"
                log_info "Linked skill: $skill"
            else
                log_warn "Skill '$skill' not found in $SOURCE_DIR/skills/"
            fi
        done
    else
        # Default behavior: no skills linked by default
        # Remove any existing nexus_skills link to ensure clean state
        rm -f "$target_base/nexus_skills"
        log_info "No skills specified. Use --skills to link specific skills."
    fi
}

function sync_agents() {
    local target_base="$1"
    local agents_csv="$2"
    
    # Always start with a clean state for agents to avoid stale links
    rm -rf "$target_base"
    mkdir -p "$target_base"
    
    if [ -n "$agents_csv" ]; then
        IFS=',' read -ra AGENTS <<< "$agents_csv"
        for agent in "${AGENTS[@]}"; do
            # Handle potential file extension in input or add it
            if [[ "$agent" != *".md" ]]; then
                agent_filename="${agent}.md"
            else
                agent_filename="$agent"
            fi
            
            if [ -f "$SOURCE_DIR/agents/$agent_filename" ]; then
                ln -sf "$SOURCE_DIR/agents/$agent_filename" "$target_base/$agent_filename"
                log_info "Linked agent: $agent_filename"
            else
                log_warn "Agent '$agent' not found in $SOURCE_DIR/agents/"
            fi
        done
    else
        # Default behavior: link all agents
        for agent_file in "$SOURCE_DIR/agents/"*.md; do
            if [ -f "$agent_file" ]; then
                agent_name=$(basename "$agent_file")
                ln -sf "$agent_file" "$target_base/$agent_name"
                log_info "Linked agent: $agent_name"
            fi
        done
    fi
}

function sync_commands() {
    local target_base="$1"
    local commands_csv="$2"
    
    # Always start with a clean state
    rm -rf "$target_base"
    mkdir -p "$target_base"
    
    if [ -n "$commands_csv" ]; then
        IFS=',' read -ra CMDS <<< "$commands_csv"
        for cmd in "${CMDS[@]}"; do
            # Handle potential file extension in input or add it
            if [[ "$cmd" != *".md" ]]; then
                cmd_filename="${cmd}.md"
            else
                cmd_filename="$cmd"
            fi
            
            if [ -f "$SOURCE_DIR/commands/$cmd_filename" ]; then
                ln -sf "$SOURCE_DIR/commands/$cmd_filename" "$target_base/$cmd_filename"
                log_info "Linked command: $cmd_filename"
            else
                log_warn "Command '$cmd' not found in $SOURCE_DIR/commands/"
            fi
        done
    else
        # Default behavior: link all commands
        for cmd_file in "$SOURCE_DIR/commands/"*.md; do
            if [ -f "$cmd_file" ]; then
                cmd_name=$(basename "$cmd_file")
                ln -sf "$cmd_file" "$target_base/$cmd_name"
                log_info "Linked command: $cmd_name"
            fi
        done
    fi
}

function init_project_meta() {
    local project_path="$1"
    local template_path="$SOURCE_DIR/templates/AGENTS.template.md"
    local target_agents_md="$project_path/AGENTS.md"
    
    if [ ! -f "$target_agents_md" ]; then
        if [ -f "$template_path" ]; then
            cp "$template_path" "$target_agents_md"
            log_info "Initialized AGENTS.md in $project_path"
        else
            log_error "Template not found at $template_path"
            return 1
        fi
    else
        log_info "AGENTS.md already exists. Skipping initialization."
    fi
    
    # Ensure .cursorrules links to project AGENTS.md
    (cd "$project_path" && ln -sf "AGENTS.md" ".cursorrules")
    log_info "Updated .cursorrules link"
}

function remove_nexus_links() {
    local target_dir="$1"

    if [ ! -d "$target_dir" ]; then
        return
    fi

    local found=false
    for link in "$target_dir"/*; do
        if [ -L "$link" ]; then
            local link_target
            link_target="$(readlink "$link")"
            if [[ "$link_target" == "$SOURCE_DIR"* ]]; then
                rm -f "$link"
                log_info "Removed link: $(basename "$link") -> $link_target"
                found=true
            fi
        fi
    done

    if [ "$found" = false ]; then
        log_info "No nexus links found in $target_dir"
    fi

    # Remove directory if empty
    if [ -d "$target_dir" ] && [ -z "$(ls -A "$target_dir")" ]; then
        rmdir "$target_dir"
        log_info "Removed empty directory: $target_dir"
    fi
}

function unlink_antigravity() {
    local project_path="$1"

    if [ -z "$project_path" ]; then
        log_error "Target project path required for antigravity"
        usage
    fi

    if [ ! -d "$project_path" ]; then
        log_error "Target directory does not exist: $project_path"
        exit 1
    fi

    log_info "Unlinking Antigravity config from: $project_path"

    remove_nexus_links "$project_path/.agents/rules"
    remove_nexus_links "$project_path/.agents/skills"
    remove_nexus_links "$project_path/.agents/agents"
    remove_nexus_links "$project_path/.agents/workflows"

    # Remove .agents directory if empty
    if [ -d "$project_path/.agents" ] && [ -z "$(ls -A "$project_path/.agents")" ]; then
        rmdir "$project_path/.agents"
        log_info "Removed empty directory: $project_path/.agents"
    fi

    # Remove .cursorrules if it's a symlink to AGENTS.md
    if [ -L "$project_path/.cursorrules" ]; then
        local cursorrules_target
        cursorrules_target="$(readlink "$project_path/.cursorrules")"
        if [[ "$cursorrules_target" == "AGENTS.md" ]]; then
            rm -f "$project_path/.cursorrules"
            log_info "Removed .cursorrules symlink"
        fi
    fi

    log_info "Unlink complete! (AGENTS.md preserved if present)"
}

function unlink_claude() {
    log_info "Unlinking Claude Code global config..."
    remove_nexus_links "$HOME/.claude/rules"
    remove_nexus_links "$HOME/.claude/commands"
    log_info "Global unlink complete!"
}

function sync_antigravity() {
    local project_path="$1"
    local skills="$2"
    
    if [ -z "$project_path" ]; then
        log_error "Target project path required for antigravity"
        usage
    fi
    
    if [ ! -d "$project_path" ]; then
        log_error "Target directory does not exist: $project_path"
        exit 1
    fi

    log_info "Syncing Antigravity config to: $project_path"
    
    sync_rules "$project_path/.agents/rules" "$RULES_ARG"
    sync_skills "$project_path/.agents/skills" "$skills"
    sync_agents "$project_path/.agents/agents" "$AGENTS_ARG"
    sync_commands "$project_path/.agents/workflows" "$COMMANDS_ARG"
    init_project_meta "$project_path"
    
    log_info "Sync complete!"
}

function sync_claude() {
    log_info "Syncing Claude Code global config..."
    sync_rules "$HOME/.claude/rules" "$RULES_ARG"
    sync_commands "$HOME/.claude/commands" "$COMMANDS_ARG"
    log_info "Global sync complete!"
}

# --- Argument Parsing ---

ACTION=""
TOOL=""
TARGET=""
SKILLS_ARG=""
RULES_ARG=""
AGENTS_ARG=""
COMMANDS_ARG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        link|unlink)
            ACTION="$1"
            shift
            ;;
        antigravity|claude)
            TOOL="$1"
            shift
            ;;
        --skills)
            SKILLS_ARG="$2"
            shift 2
            ;;
        --rules)
            RULES_ARG="$2"
            shift 2
            ;;
        --agents)
            AGENTS_ARG="$2"
            shift 2
            ;;
        --commands)
            COMMANDS_ARG="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [ -z "$TARGET" ] && [ "$TOOL" == "antigravity" ]; then
                TARGET="$1"
                shift
            else
                log_error "Unknown argument: $1"
                usage
            fi
            ;;
    esac
done

# --- Execution ---

if [ -z "$ACTION" ] || [ -z "$TOOL" ]; then
    usage
fi

case "${ACTION}_${TOOL}" in
    "link_antigravity")
        sync_antigravity "$TARGET" "$SKILLS_ARG"
        ;;
    "link_claude")
        sync_claude
        ;;
    "unlink_antigravity")
        unlink_antigravity "$TARGET"
        ;;
    "unlink_claude")
        unlink_claude
        ;;
esac
