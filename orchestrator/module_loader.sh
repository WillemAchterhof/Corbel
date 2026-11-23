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

    if declare -F "$run_function" >/dev/null; then
        fatal "Module run name already in use: $run_function"
    fi

    [[ -d "$module_dir" ]] ||
        err_missing_directory "$module_dir"

    load_components "$module_dir" "$module_bootstrap"

    declare -F "$bootstrap_function" >/dev/null ||
        err_missing_function "$bootstrap_function" \
            "$module_dir/$module_bootstrap"

    # Run the bootstrap: this sources the module's own components,
    # which is what defines run_<name> for the orchestrator.
    "$bootstrap_function"

    success "Loaded module: $module_name"
}