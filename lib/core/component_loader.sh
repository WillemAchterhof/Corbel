
#!/usr/bin/env bash

# ==============================================================================
# Project Core — Component Loader
# ==============================================================================
# lib/core/component_loader.sh
#
# Provides shared functions for loading and initializing project components.
#
# Responsibilities:
#   - Validate component files before loading
#   - Source component files into the current shell
#   - Initialize components by calling their corresponding functions
#
# Dependencies:
#   - integrity_check_files()
#   - success()
#   - fatal()
#
# Usage:
#   load_components "$COMPONENT_PATH" "${COMPONENTS[@]}"
#   init_components "${COMPONENTS[@]}"
#
# Constraints:
#   - Uses integrity_check_files() for file validation.
#   - Sources files only after all files pass validation.
#   - Expects each component file to define a function matching its filename
#     without the .sh extension.
# ==============================================================================

# ==============================================================================
# Load Components
# ==============================================================================

load_components() {
    local directory="$1"
    shift

    local component

    integrity_check_files "$directory" "$@"

    for component in "$@"; do
        # shellcheck source=/dev/null
        source "$directory/$component"
    done

    success "Components loaded."
}

# ==============================================================================
# Initialize Components
# ==============================================================================

init_components() {
    local component
    local function_name

    for component in "$@"; do
        function_name="${component%.sh}"

        if ! declare -F "$function_name" >/dev/null; then
            fatal "Component initializer not found: $function_name"
        fi

        "$function_name"
    done

    success "Components initialized."
}
