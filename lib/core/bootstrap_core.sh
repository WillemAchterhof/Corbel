#!/usr/bin/env bash

# ==============================================================================
# Project Core Bootstrap
# ==============================================================================
# lib/core/bootstrap_core.sh
#
# Bootstraps the core layer and hosts the raw file-loading primitives.
#
# Responsibilities:
#   - Define the shared validate/source/load primitives (raw layer)
#   - Create the log file
#   - Load core components
#
# Constraints:
#   - Deepest layer: sources nothing.
#   - Uses only raw printf/return before the logging and error libraries load.
#   - Higher layers call these primitives instead of re-implementing checks.
#   - Expects PROJECT_DIR and LIB_DIR to be set before this file is sourced.
#   - init_core_libraries must run exactly once.
# ==============================================================================

# ==============================================================================
# Core Components
# ==============================================================================

readonly LIB_CORE="$LIB_DIR/core"

readonly -a CORE_COMPONENTS=(
    "logging.sh"
    "error_handling.sh"
    "specialized_errors.sh"
    "unexpected_command_errors.sh"
)

# ==============================================================================
# Core Failure Handler
# ==============================================================================

core_fail() {
    if declare -F fatal >/dev/null; then
        fatal "$1"
    fi

    printf '[FATAL] %s\n' "$1" >&2
    return 1
}

# ==============================================================================
# Validate File
# ==============================================================================

core_check_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        core_fail "Missing file: $file"
        return 1
    fi

    if [[ ! -r "$file" ]]; then
        core_fail "Unreadable file: $file"
        return 1
    fi

    local syntax_error
    if ! syntax_error=$(bash -n "$file" 2>&1); then
        core_fail "Syntax validation failed: $file: $syntax_error"
        return 1
    fi
}

# ==============================================================================
# Source File
# =============================================================================

core_source_file() {
    local file="$1"

    # shellcheck source=/dev/null
    if ! source "$file"; then
        core_fail "Failed loading: $file"
        return 1
    fi
}

# ==============================================================================
# Load Files
# =============================================================================

core_load_files() {
    local directory="$1"
    shift

    local file

    for file in "$@"; do
        core_check_file "$directory/$file" || return 1
    done

    for file in "$@"; do
        core_source_file "$directory/$file" || return 1
    done
}

# ==============================================================================
# Initialize Core Libraries
# =============================================================================

init_core_libraries() {
    if [[ -n "${LOG_FILE:-}" ]]; then
        core_fail "Core libraries already initialized"
        return 1
    fi

    declare -g LOG_FILE="$PROJECT_DIR/install.log"

    if ! : > "$LOG_FILE"; then
        printf '[FATAL] Cannot create log file: %s\n' "$LOG_FILE" >&2
        return 1
    fi

    core_load_files "$LIB_CORE" "${CORE_COMPONENTS[@]}" || return 1

    msg "Loaded: Core libraries"
    msg "Initialized: Core"
}
