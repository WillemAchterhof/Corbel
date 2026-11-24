#!/usr/bin/env bash

# ==============================================================================
#  Project <Title> Module
# ==============================================================================
#  modules/template/template_copy_run.sh 
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

template_copy_check() {
    msg "Checking template_copy..."
}

# ==============================================================================
# Main
# ==============================================================================

run_template() {
    template_copy_check

    success "Template_copy module executed successfully."
}