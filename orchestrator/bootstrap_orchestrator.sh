#!/usr/bin/env bash
set -Eeuo pipefail

# ==============================================================================
#  Project Orchestrator
# ==============================================================================
#  orchestrator/launch_orchestrator.sh
#
#  Prepares, validates, and runs the execution environment.
#
#  Responsibilities:
#    - Own the shell regime (options, traps)
#    - Declare and load shared libraries
#    - Verify and load orchestrator components
#    - Start the pipeline
# ==============================================================================

# ==============================================================================
# Initialization
# ==============================================================================

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly PROJECT_DIR

readonly LIB_DIR="$PROJECT_DIR/lib"
readonly ORCHESTRATOR_PATH="$PROJECT_DIR/orchestrator"

# ==============================================================================
# Componnent Array's
# ==============================================================================

declare -r SHARED_LIBS=(
    "core"
    "integrity"
)

declare -r ORCHESTRATOR_COMPONENTS=(
    "module_loader.sh"
    "project_pipeline.sh"
)

# ==============================================================================
# Load Libraries
# ==============================================================================

load_libraries() {
    local domain
    local bootstrap_file

    for domain in "${SHARED_LIBS[@]}"; do
        bootstrap_file="$LIB_DIR/$domain/bootstrap_$domain.sh"

        if [[ ! -f "$bootstrap_file" || ! -r "$bootstrap_file" ]]; then
            printf '[FATAL] Library bootstrap missing or unreadable: %s\n' \
                "$bootstrap_file" >&2
            exit 1
        fi

        # shellcheck source=/dev/null
        source "$bootstrap_file"
    done
}

# ==============================================================================
# Preparation
# ==============================================================================

load_error_handling() {
    trap 'trap_err "$?" "$BASH_COMMAND" "$LINENO" "${BASH_LINENO[0]}"' ERR
    trap 'exit 130' INT
    trap 'exit 143' TERM

    msg "Initialized Error Handling."
}

load_orchestrator() {
    load_components "$ORCHESTRATOR_PATH" "$@"
    init_components "$@"
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    load_core
    load_error_handling
    load_integrity
    load_orchestrator "${ORCHESTRATOR_COMPONENTS[@]}"

    msg "Orchestrator ready."
    run_pipeline
}

main
