---
name: python
description: Kevin's Python coding style and conventions — comment-heavy,
  phpDoc-style docstrings, modular package layout, logging patterns,
  Docker-first deployment. Use when writing or editing any Python code.
---

# Kevin's Python Conventions

Reference implementations (current standard): kpirnie/kptv-weather,
kpirnie/wp-malware-scanner, kpirnie/visual-regressor, kpirnie/kp-wp-vulnscan.
kpirnie/kptv-restreamer is the older style (docstrings above the def,
`logging.basicConfig` in `main.py`); kpirnie/kptv-fast is older still
(short docstrings, unpinned requirements).

## File headers
Every module starts with shebang + docstring containing a title line,
a short description, and phpDoc-style tags:

    #!/usr/bin/env python3
    """
    Stream Service Module

    This module handles stream processing and delivery to clients.

    @package KPTV Restreamer
    @author Kevin Pirnie <me@kpirnie.com>
    @copyright Copyright (c) 2026
    """

## Comments — the defining trait
Comment-heavy, conversational, lowercase, one per logical step:

    # setup the imports
    # make sure it actually exists
    # now open it grab the data as yaml
    # loop over each stream in the groups

Nearly every block gets one. When editing existing code, match this
density and voice exactly — do not strip or formalize comments.

## Docstrings
phpDoc-tag style, placed INSIDE the def/class as the first statement
(standard Python placement — visible to help() and IDE hover):

    def load_config(config_path: str) -> AppConfig:
        """
        Load and parse configuration from YAML file

        Reads the specified YAML file and converts the data into
        structured configuration objects.

        @param config_path: str Path to the YAML configuration file
        @return AppConfig: Fully populated application configuration object
        @throws FileNotFoundError: When the config file does not exist
        """

Older code has docstrings placed above the def — when substantially
editing a function, move its docstring inside; otherwise leave as-is.

## Code style
- Type hints on signatures (params and return), `typing` imports as needed
- Related stdlib imports may combine on one line: `import logging, asyncio`
- Import order: stdlib, third-party, then app-local
- Blank line after `def`/`class` line before the body starts
- Defensive coding: existence checks before use, try/except version-compat
  fallbacks for third-party API differences, yaml.safe_load never yaml.load

## Structure
- Modular packages by responsibility: core/, services/, routes/ (or api/),
  models/, sources/, utils/ — with __init__.py exports
- Config: environment variables with a project prefix (`KPTVW_`, `VREG_`,
  `KPWPVS_`) read into typed config objects; kptv-restreamer reads a YAML
  file (`yaml.safe_load`) into dataclasses
- Async (FastAPI/aiohttp) for new service work; requests.Session with
  HTTPAdapter pooling + urllib3 Retry for sync HTTP

## Logging
- `logger = logging.getLogger(__name__)` at module level
- Central setup_logging() keyed on a DEBUG switch (the `DEBUG` env var in
  kptv-weather and wp-malware-scanner, a DB setting in visual-regressor):
  DEBUG level + verbose format (funcName:lineno) when true, INFO + clean
  format otherwise
- Third-party loggers (urllib3, requests, etc.) forced to WARNING in
  non-debug mode

## Deployment
- Docker-first: `Dockerfile` (kp-wp-vulnscan: `Containerfile`) plus a
  compose example in the repo root (`docker-compose-example.yaml`;
  visual-regressor: `compose-example.yaml`)
- requirements.txt with pinned versions for new projects
- readme.md (lowercase), LICENSE in root

## Rules
- Match the style of the file being edited, even where it predates these
  conventions (e.g. older KP_-prefixed class code) — no drive-by modernizing
- Minimal diffs; don't refactor unrelated code