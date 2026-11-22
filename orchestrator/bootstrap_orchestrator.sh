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
# Shared libraries
# ==============================================================================

# Domain libraries under lib/, as "<domain>/<file>" entries.
# Rule: lib/ contains only domains; domains contain only files.
# A domain crossing 10 files splits into sibling domains, never nests.
declare -r SHARED_LIBS=(
    "core"
)

# ==============================================================================
# Load Libraries
# ==============================================================================

source_lib_bootstraps() {
    local domain
    local bootstrap_file

    for domain in "${SHARED_LIBS[@]}"; do
        bootstrap_file="$LIB_DIR/$domain/bootstrap_$domain.sh"
        printf "bootstrap_file"

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

install_traps() {
    trap 'trap_err "$?" "$BASH_COMMAND" "$LINENO" "${BASH_LINENO[0]}"' ERR
    trap 'exit 130' INT
    trap 'exit 143' TERM

    msg "Initialized Error Handling."
}

load_shared_libs() {
    local entry

    for entry in "${SHARED_LIBS[@]}"; do
        lib_load_files "$LIB_DIR" "$entry"
    done

    msg "Shared libraries loaded."
}

orch_load_components() {
    lib_load_files "$ORCHESTRATOR_PATH" \
        "module_loader.sh" \
        "project_pipeline.sh"

    success "Orchestrator components loaded."
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    init_libraries
    msg "Libraries loaded."

    install_traps
    load_shared_libs
    orch_load_components

    msg "Orchestrator ready."
    run_pipeline
}

main