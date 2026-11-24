#!/usr/bin/env bash

# ==============================================================================
# Integrity Module Loader
# ==============================================================================
# lib/integrity/integrity_module_loader.sh
#
# Loads and bootstraps individual project modules.
#
# Responsibilities:
#   - Validate module names
#   - Verify module directories
#   - Verify and load module bootstrap files
#   - Verify and call module bootstrap functions
#   - Verify module run functions are not already claimed
#   - Protect previously defined functions from redefinition
#
# Dependencies:
#   - integrity_check_directory()
#   - integrity_check_file()
#   - integrity_check_function()
#   - integrity_snapshot_functions()
#   - integrity_check_functions_unchanged()
#   - load_components()
#   - fatal()
#   - success()
#
# Constraints:
#   - Loads and bootstraps modules only.
#   - Never executes module run functions.
#   - Module bootstraps validate and load their own internal components.
#   - Pre-load guards claim bootstrap_/run_ names early; the snapshot
#     comparison is the general backstop for any other function.
# ==============================================================================

# ==============================================================================
# Load Module
# ==============================================================================

load_module() {
    [[ $# -eq 1 ]] ||
        fatal "load_module expects exactly one argument"

    local module_name="$1"
    local module_directory="$PROJECT_DIR/modules/$module_name"
    local bootstrap_file="$module_directory/bootstrap_${module_name}.sh"
    local bootstrap_function="bootstrap_${module_name}"
    local run_function="run_${module_name}"

    # --------------------------------------------------------------------------
    # Validate module name
    # --------------------------------------------------------------------------

    [[ "$module_name" =~ ^[a-z0-9_]+$ ]] ||
        fatal "Invalid module name: $module_name"
    
    # --------------------------------------------------------------------------
    # Pre-load namespace guards
    # --------------------------------------------------------------------------

    if declare -F "$bootstrap_function" >/dev/null; then
        fatal "Module bootstrap name already in use: $bootstrap_function"
    fi

    if declare -F "$run_function" >/dev/null; then
        fatal "Module run name already in use: $run_function"
    fi

    # --------------------------------------------------------------------------
    # Validate module directory and bootstrap file
    # --------------------------------------------------------------------------

    integrity_check_directory "$module_directory"
    integrity_check_file "$bootstrap_file"

    # --------------------------------------------------------------------------
    # Protect existing functions
    # --------------------------------------------------------------------------

    local -A functions_before=()

    integrity_snapshot_functions functions_before

    # --------------------------------------------------------------------------
    # Load module bootstrap
    # --------------------------------------------------------------------------

    # shellcheck source=/dev/null
    source "$bootstrap_file"

    integrity_check_function "$bootstrap_function" "$bootstrap_file"

    # --------------------------------------------------------------------------
    # Run module bootstrap
    # --------------------------------------------------------------------------

    "$bootstrap_function"

    # --------------------------------------------------------------------------
    # Verify module integrity
    # --------------------------------------------------------------------------

    integrity_check_functions_unchanged \
        functions_before \
        "Module '$module_name'"

    integrity_check_function "$run_function" "$bootstrap_file"

    success "Module loaded: $module_name"
}