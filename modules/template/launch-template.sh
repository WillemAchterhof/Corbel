#!/usr/bin/env bash

# ==============================================================================
#  Project <Title> Module
# ==============================================================================
#  modules/template/launch-template.sh
#
#  <One-line description of what this module does.>
#
#  Responsibilities:
#    - <what it does>
#
#  Constraints:
#    - Definitions only at top level; all work happens in run_<name>.
#    - Helper functions are prefixed with <name>_ to avoid name clashes.
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

template_check() {
    example_check

    success "Template module executed successfully."
}
