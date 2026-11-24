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
#   - Source the bootstrap libraries (core, integrity)
#   - Initialize the core and integrity layers
#   - Configure error handling
#   - Load orchestrator components
#   - Load and execute the configured module pipeline
#
# Constraints:
#   - Bootstrap libraries are sourced here as definitions, then initialized.
#   - Before core is initialized, only raw printf/return is available.
#   - Call order in main is fixed: core, error handling, integrity,
#     orchestrator components, module loading, module execution.
# ==============================================================================

# ==============================================================================
# Project Paths
# ==============================================================================

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly PROJECT_DIR

readonly LIB_DIR="$PROJECT_DIR/lib"
readonly ORCHESTRATOR_PATH="$PROJECT_DIR/orchestrator"

# ==============================================================================
# Bootstrap Libraries
# ==============================================================================

readonly -a BOOTSTRAP_LIBRARIES=(
    "core/bootstrap_core.sh"
    "integrity/bootstrap_integrity.sh"
)

# ==============================================================================
# Orchestrator Components
# ==============================================================================

readonly -a ORCHESTRATOR_COMPONENTS=(
    "project_pipeline.sh"
    "project_orchestrator.sh"
)

# ==============================================================================
# Load Bootstrap Libraries
# ==============================================================================

load_libraries() {
    local library
    local library_path

    # Validate all bootstrap libraries before sourcing any of them.
    for library in "$@"; do
        library_path="$LIB_DIR/$library"

        if [[ ! -f "$library_path" || ! -r "$library_path" ]]; then
            printf '[FATAL] Library missing or unreadable: %s\n' \
                "$library_path" >&2
            return 1
        fi

        if ! bash -n "$library_path"; then
            printf '[FATAL] Syntax validation failed: %s\n' \
                "$library_path" >&2
            return 1
        fi
    done

    for library in "$@"; do
        library_path="$LIB_DIR/$library"

        # shellcheck source=/dev/null
        if ! source "$library_path"; then
            printf '[FATAL] Failed loading: %s\n' "$library_path" >&2
            return 1
        fi
    done
}

# ==============================================================================
# Error Handling
# ==============================================================================

load_error_handling() {
    trap 'trap_err "$?" "$BASH_COMMAND" "$LINENO" "${BASH_LINENO[0]}"' ERR
    trap 'exit 130' INT
    trap 'exit 143' TERM

    msg "Initialized: Error handling"
}

# ==============================================================================
# Load Orchestrator Components
# ==============================================================================

load_orchestrator_components() {
    load_components "$ORCHESTRATOR_PATH" "$@"
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    load_libraries "${BOOTSTRAP_LIBRARIES[@]}"

    init_core_libraries
    load_error_handling
    init_integrity_libraries
    load_orchestrator_components "${ORCHESTRATOR_COMPONENTS[@]}"

    success "Completed: Orchestrator bootstrap"

    load_pipeline_modules
    run_orchestrator
}

main "$@"
