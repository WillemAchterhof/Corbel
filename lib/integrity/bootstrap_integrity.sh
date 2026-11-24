#!/usr/bin/env bash

# ==============================================================================
# Project Integrity Bootstrap
# ==============================================================================
# lib/integrity/bootstrap_integrity.sh
#
# Initializes the project integrity layer.
#
# Responsibilities:
#   - Define the integrity component loading order
#   - Load integrity components through the core file-loading primitives
#
# Dependencies:
#   - core_load_files()    (lib/core/bootstrap_core.sh)
#
# Constraints:
#   - Sourced after the core layer has been initialized.
#   - Definitions only; initialization happens through init_integrity_libraries().
#   - Does not use load_components(), which belongs to this layer.
#   - Must be initialized exactly once.
# ==============================================================================

# ==============================================================================
# Integrity Components
# ==============================================================================

readonly LIB_INTEGRITY="$LIB_DIR/integrity"

readonly -a INTEGRITY_COMPONENTS=(
    "integrity_component_loader.sh"
    "integrity_directory_checks.sh"
    "integrity_file_checks.sh"
    "integrity_function_checks.sh"
    "integrity_module_loader.sh"
)

# ==============================================================================
# Initialize Integrity Libraries
# ==============================================================================

init_integrity_libraries() {
    if [[ -n "${INTEGRITY_INITIALIZED:-}" ]]; then
        fatal "Integrity libraries already initialized"
        return 1
    fi

    core_load_files "$LIB_INTEGRITY" "${INTEGRITY_COMPONENTS[@]}"

    declare -g INTEGRITY_INITIALIZED=1

    success "Initialized: Integrity"
}