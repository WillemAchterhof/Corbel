#!/usr/bin/env bash
set -Eeuo pipefail

# ==============================================================================
# Project Orchestrator Bootstrap
# ==============================================================================
# orchestrator/bootstrap_orchestrator.sh
#
# Prepares the shared execution environment for the project.
#
# Responsibilities:
#   - Establish project paths
#   - Load core libraries
#   - Configure error handling
#   - Load orchestrator components
# ==============================================================================

# ==============================================================================
# Project Environment
# ==============================================================================

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly PROJECT_DIR

readonly LIB_DIR="$PROJECT_DIR/lib"
readonly ORCHESTRATOR_PATH="$PROJECT_DIR/orchestrator"

# ==============================================================================
# Core Libraries
# ==============================================================================

load_core_libraries() {
    local bootstrap_file="$LIB_DIR/core/bootstrap_core.sh"

    if [[ ! -f "$bootstrap_file" || ! -r "$bootstrap_file" ]]; then
        printf '[FATAL] Core bootstrap missing or unreadable: %s\n' \
            "$bootstrap_file" >&2
        exit 1
    fi

    # shellcheck source=/dev/null
    source "$bootstrap_file"

    init_core_libraries
}

# ==============================================================================
# Orchestrator Components
# ==============================================================================

declare -r ORCHESTRATOR_COMPONENTS=(
    "module_loader.sh"
    "project_pipeline.sh"
)

# ==============================================================================
# Error Handling
# ==============================================================================

load_error_handling() {
    trap 'trap_err "$?" "$BASH_COMMAND" "$LINENO" "${BASH_LINENO[0]}"' ERR
    trap 'exit 130' INT
    trap 'exit 143' TERM

    msg "Initialized Error Handling."
}

# ==============================================================================
# Load Orchestrator Components
# ==============================================================================

load_orchestrator_components() {
    load_components "$ORCHESTRATOR_PATH" "$@"

    msg "Orchestrator ready."
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    load_core_libraries
    load_error_handling
    load_orchestrator_components "${ORCHESTRATOR_COMPONENTS[@]}"
}

main
