#!/usr/bin/env bash

# ==============================================================================
# Project Module Loader
# ==============================================================================
# orchestrator/module_loader.sh
#
# Loads an individual Project module.
#
# Responsibilities:
#   - Locate the requested module
#   - Verify its launcher exists and is readable
#   - Validate its Bash syntax
#   - Source the module launcher
#   - Verify its entry function exists
# ==============================================================================

# ==============================================================================
# Module Loader
# ==============================================================================

load_module() {
    [[ $# -eq 1 ]]

    local module_name="$1"
    local module_dir="$PROJECT_DIR/modules/$module_name"
    local module_file="$module_dir/launch_${module_name}.sh"

    [[ "$module_name" =~ ^[a-zA-Z0-9_-]+$ ]]

    [[ -d "$module_dir" ]] ||
        err_missing_directory "$module_dir"

    declare -F "run_${module_name}" >/dev/null &&
        fatal "Module entry name already in use: run_${module_name}"

    core_check_file "$module_file"
    core_source_file "$module_file"

    declare -F "run_${module_name}" >/dev/null ||
        err_missing_function "run_${module_name}" "$module_file"

    success "Sourced: $module_file"
}
