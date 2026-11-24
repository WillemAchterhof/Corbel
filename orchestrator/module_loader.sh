#!/usr/bin/env bash

# ==============================================================================
# Project Module Loader
# ==============================================================================
# orchestrator/module_loader.sh
#
# Loads an individual project module.
#
# Responsibilities:
#   - Validate the module name
#   - Locate the requested module
#   - Verify the module's bootstrap and run names are not already claimed
#   - Verify its bootstrap file, then its bootstrap function
#   - Run the bootstrap, which loads the module's components
#   - Verify the module defined run_<name> and redefined nothing that
#     already existed
#
# Dependencies:
#   - load_components()           (lib/core/component_loader.sh)
#   - err_missing_directory()     (lib/core/specialized_errors.sh)
#   - err_missing_function()      (lib/core/specialized_errors.sh)
#   - fatal(), success()
#
# Constraints:
#   - Loads modules only; never calls run_<name>.
#   - Call only in errexit-active context (not inside if, ||, or !).
# ==============================================================================

# ==============================================================================
# Function Snapshot
# ==============================================================================

# Fills the caller's associative array (name passed as $1) with
# function name -> function body for every function currently defined.
_module_snapshot_functions() {
    local -n snapshot_ref="$1"
    local fn

    snapshot_ref=()

    while IFS= read -r fn; do
        snapshot_ref["$fn"]="$(declare -f "$fn")"
    done < <(compgen -A function)
}

# ==============================================================================
# Module Loader
# ==============================================================================

load_module() {
    [[ $# -eq 1 ]] ||
        fatal "load_module expects exactly one argument"

    local module_name="$1"

    [[ "$module_name" =~ ^[a-zA-Z0-9_-]+$ ]] ||
        fatal "Invalid module name: $module_name"

    local module_dir="$PROJECT_DIR/modules/$module_name"
    local module_bootstrap="bootstrap_${module_name}.sh"
    local bootstrap_function="bootstrap_${module_name}"
    local run_function="run_${module_name}"

    # Namespace guards: every module claims bootstrap_<name> and run_<name>
    # exactly once. Checked before touching the filesystem.
    if declare -F "$bootstrap_function" >/dev/null; then
        fatal "Module bootstrap name already in use: $bootstrap_function"
    fi

    [[ -d "$module_dir" ]] ||
        err_missing_directory "$module_dir"

    # Snapshot before anything of the module is sourced, so a redefinition
    # in the bootstrap file or in its components is caught the same way.
    local -A functions_before=()
    _module_snapshot_functions functions_before

    load_components "$module_dir" "$module_bootstrap"

    declare -F "$bootstrap_function" >/dev/null ||
        err_missing_function "$bootstrap_function" \
            "$module_dir/$module_bootstrap"

    # Run the bootstrap: this sources the module's own components,
    # which is what defines run_<name> for the orchestrator.
    "$bootstrap_function"

    if declare -F "$run_function" >/dev/null; then
        fatal "Module run name already in use: $run_function  ($module_name)"
    fi

    declare -F "$run_function" >/dev/null ||
        fatal "Module: $module_name - did not define its run function: $run_function"

    local fn
    for fn in "${!functions_before[@]}"; do
        [[ "$(declare -f "$fn")" == "${functions_before[$fn]}" ]] ||
            fatal "Module '$module_name' redefined existing function: $fn"
    done

    success "Loaded module: $module_name"
}