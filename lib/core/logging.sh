#!/usr/bin/env bash

# ==============================================================================
# Project Logging
# ==============================================================================
# lib/core/logging.sh
#
# Provides consistent message output to the terminal and project log.
#
# Responsibilities:
#   - Provide standard message output functions
#   - Distinguish stdout and stderr messages
#   - Write messages to the shared log file
#
# Constraints:
#   - Sourced library: definitions only.
#   - No set, trap, or source-time side effects.
#   - Logging failures must never interrupt execution.
#   - Expects LOG_FILE to be initialized by bootstrap_core.sh.
# ==============================================================================

# ==============================================================================
# Internal Log Emitter
# ==============================================================================

_log_emit() {
    local stream="$1"
    local message="$2"

    printf '%s\n' "$message" >&"$stream"
    { printf '%s\n' "$message" >> "$LOG_FILE"; } 2>/dev/null || true
}

# ==============================================================================
# Standard Messages
# ==============================================================================

msg() {
    _log_emit 1 "[*] $*"
}

success() {
    _log_emit 1 "[+] $*"
}

warn() {
    _log_emit 2 "[!] $*"
}

# ==============================================================================
# Log Only
# ==============================================================================

log_only() {
    { printf '%s\n' "$*" >> "$LOG_FILE"; } 2>/dev/null || true
}