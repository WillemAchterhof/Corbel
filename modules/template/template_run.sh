#!/usr/bin/env bash

# ==============================================================================
# Template Module
# ==============================================================================
# modules/template/template_run.sh
#
# Demonstrates the module execution contract.
#
# Responsibilities:
#   - Provide a simple template check
#
# Constraints:
#   - Definitions only at top level; all work happens in run_template.
#   - Helper functions are prefixed with template_ to avoid name clashes.
# ==============================================================================

# ==============================================================================
# Helpers
# ==============================================================================

template_check() {
    msg "Checking template..."
}

# ==============================================================================
# Main
# ==============================================================================

run_template() {
    template_check

    success "Completed: Template module execution"
}
