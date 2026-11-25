#!/usr/bin/env bash

# ==============================================================================
# Template Module Bootstrap
# ==============================================================================
# modules/template/bootstrap_template.sh
#
# Prepares the template module.
#
# Responsibilities:
#   - Establish module paths
#   - Load module components
#
# Constraints:
#   - Definitions only at top level; all work happens in bootstrap_template.
#   - Components are loaded, never executed.
#   - Inherits PROJECT_DIR, shell options and traps from the orchestrator.
# ==============================================================================

# ==============================================================================
# Module Environment
# ==============================================================================

readonly TEMPLATE_DIR="$MODULES_DIR/template"

# ==============================================================================
# Load Module Components
# ==============================================================================

load_template_components() {
    load_components "$TEMPLATE_DIR" "template_run.sh"
}

# ==============================================================================
# Bootstrap
# ==============================================================================

bootstrap_template() {
    load_template_components
    success "Completed: Template bootstrap"
}
