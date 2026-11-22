
#!/usr/bin/env bash

# ==============================================================================
#  Module Integrity Bootstrap
# ==============================================================================
#  lib/module_integrity/bootstrap_module_integrity.sh
#
#  Bootstraps the module integrity domain.
#
#  Responsibilities:
#    - Validate module integrity component files.
#    - Load module integrity components.
#
#  Constraints:
#    - Depends only on lib_check_file() from the core domain.
#    - Does not use core loading or sourcing primitives.
#    - Validates all component files before sourcing any.
#    - Owns the loading of its internal components.
#    - Expects LIB_DIR to be set by the entry point.
# ==============================================================================

# ==============================================================================
# Raw Primitives — usable before any logger exists
# ==============================================================================

# integrity_fail — report and stop. Delegates to fatal when the logging lib is
# loaded (single message, logged, no ERR-trap duplicate); falls back to a
# raw stderr line before that.
integrity_fail() {
    if declare -F fatal >/dev/null; then
        fatal "$1"      # exits; never falls through
    fi
    printf '[FATAL] %s\n' "$1" >&2
    return 1
}

integrity_check_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        integrity_fail "Required file missing: $file"
        return 1
    fi

    if [[ ! -r "$file" ]]; then
        integrity_fail "Required file is not readable: $file"
        return 1
    fi

    bash -n "$file"
}

integrity_source_file() {
    local file="$1"

    # shellcheck source=/dev/null
    source "$file" || {
        integrity_fail "Failed loading: $file"
        return 1
    }
}

# integrity_load_files DIR FILE...
# Validates every file first, then sources every file.
# FILE entries may be "<file>.sh" or "<domain>/<file>.sh".
integrity_load_files() {
    local dir="$1"
    shift

    local file

    # Validate all files before sourcing any.
    for file in "$@"; do
        integrity_check_file "$dir/$file"
    done

    # Source files only after all validations pass.
    for file in "$@"; do
        integrity_source_file "$dir/$file"
    done
}

# ==============================================================================
# Validate and Load Components
# ==============================================================================

init_module_integrity() {
    LIB_MODULE_INTEGRITY="$LIB_DIR/module_integrity"
    
    integrity_load_files "$LIB_MODULE_INTEGRITY/" \
        "check_file.sh" \
        "check_directory.sh"
        # "check_function.sh"
}
