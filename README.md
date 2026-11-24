# Corbel

Corbel is a reusable Bash framework for loading and executing an ordered set of
project modules. The framework separates bootstrap, integrity validation,
module loading, and module execution.

## Quick start

```bash
./corbel.sh
```

`corbel.sh` downloads the configured Corbel branch, validates the orchestrator
entry point, activates the downloaded project, and hands off to
`orchestrator/bootstrap_orchestrator.sh`.

To run an already downloaded working copy directly:

```bash
bash orchestrator/bootstrap_orchestrator.sh
```

## Project layout

```text
.
├── corbel.sh
├── README.md
├── lib/
│   ├── core/
│   │   ├── bootstrap_core.sh
│   │   ├── logging.sh
│   │   ├── error_handling.sh
│   │   ├── specialized_errors.sh
│   │   └── unexpected_command_errors.sh
│   └── integrity/
│       ├── bootstrap_integrity.sh
│       ├── integrity_component_loader.sh
│       ├── integrity_directory_checks.sh
│       ├── integrity_file_checks.sh
│       ├── integrity_function_checks.sh
│       └── integrity_module_loader.sh
├── orchestrator/
│   ├── bootstrap_orchestrator.sh
│   ├── project_pipeline.sh
│   └── project_orchestrator.sh
└── modules/
    └── template/
        ├── bootstrap_template.sh
        └── template_run.sh
```

## Execution model

The execution lifecycle is deliberately split into loading and running:

1. `bootstrap_orchestrator.sh` establishes project paths and shell options.
2. It sources the core and integrity bootstrap files.
3. `init_core_libraries()` loads logging and error-handling functions.
4. The ERR, INT, and TERM traps are installed.
5. `init_integrity_libraries()` loads the integrity functions.
6. `load_components()` validates and loads the orchestrator components.
7. `load_pipeline_modules()` loads and bootstraps each module in
   `PIPELINE_MODULES` order.
8. `run_orchestrator()` verifies every configured run function exists, then
   executes the functions in `ORCHESTRATOR_STEPS` order.

The pipeline never executes module run functions. The module loader never
executes a module run function. Execution belongs exclusively to the project
orchestrator.

## Integrity and component loading

`load_components()` performs these steps:

1. Validate the component directory.
2. Validate every requested file, including Bash syntax.
3. Only after all files pass validation, source the component files.
4. Report the successful component load.

The module loader validates the module name, directory, and bootstrap file;
checks that the bootstrap and run function names are not already claimed;
snapshots existing functions; sources and calls the module bootstrap; checks
that existing functions were not changed or removed; and verifies the module's
run function exists.

Module names currently use lowercase letters, digits, and underscores:
`^[a-z0-9_]+$`. This keeps generated function names such as `bootstrap_<name>`
and `run_<name>` valid Bash identifiers.

## Error handling

Corbel has two error paths:

- **Expected validation failures** call `fatal()`. It writes one structured
  `[FATAL]` report to stderr and the project log, then exits with status 1.
- **Unexpected command failures** are handled by `set -Eeuo pipefail` and the
  ERR trap. `trap_err()` reports the command, source location, caller, current
  module, and original exit status, then exits with that status.

During the earliest core bootstrap stage, before `fatal()` is available,
`core_fail()` prints a raw fatal message and returns failure. The top-level
bootstrap is called in an errexit-active context, so initialization stops.

Do not wrap action functions in `if`, `!`, `&&`, or `||` merely to test their
status. Bash suppresses `errexit` and ERR-trap behavior in conditional command
contexts, including functions called from those contexts. Use conditional
operators only when the condition is intentionally handled.

## Module context

`load_pipeline_modules()` sets `AG_CURRENT_MODULE` while each module is being
loaded and bootstrapped. `run_orchestrator()` sets it while the corresponding
`run_<module>` function executes. The variable is cleared after each phase
completes. Unexpected-command reports use it to identify the active module.

## Logging convention

The core logging functions are:

| Function | Prefix | Destination |
|---|---|---|
| `msg` | `[*]` | stdout and log |
| `success` | `[+]` | stdout and log |
| `warn` | `[!]` | stderr and log |
| `log_only` | none | log only |

Lifecycle messages describe the operation and its scope, for example:

```text
[*] Loaded: Core libraries
[*] Initialized: Core
[*] Initialized: Error handling
[*] Initialized: Integrity
[*] Loaded: Orchestrator components
[+] Completed: Orchestrator bootstrap

[*] Bootstrapping: template
[*] Loaded: Template components
[+] Completed: Template bootstrap
[+] Loaded module: template

[*] Running: run_template
[*] Checking template...
[+] Completed: Template module execution
```

## Adding a module

1. Create `modules/<name>/`.
2. Add `bootstrap_<name>.sh` and its component files.
3. Define `bootstrap_<name>()` in the bootstrap file.
4. Define `run_<name>()` in one of the module components.
5. Add the module name to `PIPELINE_MODULES` in
   `orchestrator/project_pipeline.sh`.
6. Add `run_<name>` to `ORCHESTRATOR_STEPS` in
   `orchestrator/project_orchestrator.sh`.

Module files should define functions and constants when sourced. Actual module
work belongs in `run_<name>()`. Prefix helper functions with `<name>_` to
reduce the risk of namespace collisions.

## Verification

Run syntax checks from the project root:

```bash
find . -type f -name '*.sh' -not -path './.git/*' -print0 \
    | xargs -0 -n1 bash -n
```

If ShellCheck is installed:

```bash
shellcheck corbel.sh lib/core/*.sh lib/integrity/*.sh \
    orchestrator/*.sh modules/*/*.sh
```

Then run the orchestrator directly and confirm the lifecycle output and exit
status. Test expected validation failures and unexpected command failures in a
temporary copy of the project, not in the working project.
