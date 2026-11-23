#!/usr/bin/env bash

# ==============================================================================
# Project Module Loader
# ==============================================================================
# orchestrator/module_loader.sh
#
# Loads an individual Project module.
#
# Responsibilities:
#   - Validate the module name
#   - Locate the requested module
#   - Load its launcher (existence, readability and syntax are verified
#     before it is sourced)
#   - Verify its entry function exists
#
# Dependencies:
#   - load_components()           (lib/core/component_loader.sh)
#   - err_missing_directory()     (lib/core/specialized_errors.sh)
#   - err_missing_function()      (lib/core/specialized_errors.sh)
#   - fatal(), success()
#
# Constraints:
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
    local module_launcher="bootstrap_${module_name}.sh"
    local entry_function="bootstrap_${module_name}"

    [[ -d "$module_dir" ]] ||
        err_missing_directory "$module_dir"

    if declare -F "$entry_function" >/dev/null; then
        fatal "Module entry name already in use: $entry_function"
    fi

    load_components "$module_dir" "$module_launcher"

    declare -F "$entry_function" >/dev/null ||
        err_missing_function "$entry_function" "$module_dir/$module_launcher"

    success "Loaded module: $module_name"
}