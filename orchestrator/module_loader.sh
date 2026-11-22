
#!/usr/bin/env bash

# ==============================================================================
# Corbel Module Loader
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

    # Validate module name.
    [[ "$module_name" =~ ^[a-zA-Z0-9_-]+$ ]]

    # Verify module directory.
    if [[ ! -d "$module_dir" ]]; then
        err_missing_directory "$module_dir"
    fi

    # Prevent duplicate entry functions.
    if declare -F "run_${module_name}" >/dev/null; then
        _err_die \
            "Module entry name already in use." \
            "Function" \
            "run_${module_name}" \
            "${BASH_SOURCE[0]}" \
            "${BASH_LINENO[0]}" \
            "${FUNCNAME[0]}"
    fi

    # Verify and source module launcher.
    core_check_file "$module_file"
    core_source_file "$module_file"

    # Verify module entry function.
    if ! declare -F "run_${module_name}" >/dev/null; then
        err_missing_function "run_${module_name}" "$module_file"
    fi

    success "Sourced: $module_file"
}