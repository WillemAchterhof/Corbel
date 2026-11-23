#!/usr/bin/env bash
set -Eeuo pipefail

# ==============================================================================
#  Project Orchestrator
# ==============================================================================
#  orchestrator/bootstrap_orchestrator.sh
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
# Core Bootstrap
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
# Componnent Array's
# ==============================================================================

declare -r ORCHESTRATOR_COMPONENTS=(
    "module_loader.sh"
    "project_pipeline.sh"
)

# ==============================================================================
# Load Error Handling
# ==============================================================================

load_error_handling() {
    trap 'trap_err "$?" "$BASH_COMMAND" "$LINENO" "${BASH_LINENO[0]}"' ERR
    trap 'exit 130' INT
    trap 'exit 143' TERM

    msg "Initialized Error Handling."
}

# ==============================================================================
# Load Components
# ==============================================================================

load_orchestrator_components() {
    load_components "$ORCHESTRATOR_PATH" "$@"
    init_components "$@"

    msg "Orchestrator ready."
}

# ==============================================================================
# Bootstrapper Handover
# ==============================================================================

start_project_bootstrapper() {
    if [[ ! -f "$BOOTSTRAPPER_PATH" || ! -r "$BOOTSTRAPPER_PATH" ]]; then
        fatal "Project bootstrapper missing or unreadable: $BOOTSTRAPPER_PATH"
    fi

    msg "Orchestrator preparation complete."
    msg "Handing over execution to project bootstrapper."

    # Replace the current process.
    exec bash "$BOOTSTRAPPER_PATH"
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    load_core_libraries
    load_error_handling
    load_orchestrator_components "${ORCHESTRATOR_COMPONENTS[@]}"
    start_project_bootstrapper
}

main
