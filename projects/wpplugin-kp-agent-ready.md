---
name: wpplugin-kp-agent-ready
description: KP Agent Ready — wp.org WordPress plugin publishing agent-readiness endpoints (well-known API catalog/agent skills/MCP card, llms.txt, Link headers, Markdown negotiation, robots.txt, WebMCP). Read before any work in kpirnie/wpplugin-kp-agent-ready.
---

# KP Agent Ready

WordPress.org plugin (`kp-agent-ready`) that makes a site discoverable by AI agents: RFC 8288 `Link` headers, `/.well-known/*` documents (API catalog, agent skills index, MCP server card), generated `llms.txt`, Markdown content negotiation, robots.txt additions, and WebMCP. Repo: `kpirnie/wpplugin-kp-agent-ready`. Skill: `wp-plugin` (this plugin is the skill's reference implementation).

## Stack
- PHP 8.2+, WP 6.8+, GPL-3.0-or-later, no runtime Composer deps (hand-rolled PSR-4 autoloader for `KP\AgentReady\`)
- Constants `KP_AGENT_READY_VERSION|FILE|DIR|URL`; options in one array under `Plugin::OPTION_KEY` = `kp_agent_ready`

## Layout and build
- `source/` — the plugin you edit
- `build.sh` (`npm run build`) — verifies plugin header `Version`, readme `Stable tag` and `KP_AGENT_READY_VERSION` all match, rsyncs PHP + readme + LICENSE into `distribute/`, runs `wp i18n make-pot` into `distribute/languages/`
- `distribute/` — build output, committed; `.github/workflows/release.yml` zips it into a GitHub release on `v*` tags
- Root `composer.json` and `package.json` also carry `"version"` (kept in step by hand; `build.sh` does not check them)

## Map
- `source/kp-agent-ready.php` — header, constants, autoloader, `plugins_loaded` → `Plugin::instance`, activation/deactivation, multisite network-activation guard
- `source/src/Plugin.php` — final singleton, loads options, boots modules
- `source/src/Modules/` — each extends `AbstractModule` (options injection + `opt()`) with `register()`:
  - `WellKnown.php` — serves on `parse_request` at `PHP_INT_MIN`: `/.well-known/api-catalog`, `agent-skills/index.json`, `mcp/server-card.json`, `openid-configuration`, `oauth-authorization-server`, `oauth-protected-resource`
  - `LinkHeaders.php` (`send_headers`), `MarkdownNegotiation.php` (`template_redirect`), `RobotsTxt.php` (`robots_txt` filter), `WebMCP.php` (front-end script)
  - `LlmsTxt.php` — generates llms.txt files on cron, post save/status change, settings save, and AJAX regenerate
- `source/src/Settings/SettingsPage.php` — admin menus, `register_setting` with `sanitize` callback, assets
- `source/src/Helpers/HtmlToMarkdown.php`
- `source/uninstall.php`, `source/readme.txt`

## Conventions
- Docblocks: `@since`, `@author Kevin Pirnie`, `@package KP Agent Ready` (file-level blocks use `<me@kpirnie.com>`, class-level `<iam@kevinpirnie.com>` — both exist; match the file)
- Conversational lowercase comments between docblocks

## Behaviour in the code
- `build.sh` exits non-zero unless the header `Version`, readme `Stable tag` and `KP_AGENT_READY_VERSION` all match, and if `Plugin Name` / `Text Domain` can't be read; it `rm -rf`s and rebuilds `distribute/` every run
- llms.txt AJAX regenerate (`LlmsTxt::ajaxRegenerate`): `check_ajax_referer(self::AJAX_ACTION, 'nonce')` (nonce `kp_agent_ready_regenerate_llms`) then `manage_options`; settings go through `register_setting(..., ['sanitize_callback' => [$this, 'sanitize']])`
- llms.txt only regenerates on transitions into/out of `publish` and queries `'post_status' => 'publish'`; Markdown negotiation returns early for password-protected posts
- Network activation is blocked: `admin_init` → `deactivate_plugins` + `wp_die`
- readme.txt: Contributors `kevp75`, Requires at least 6.8, Tested up to 7.1, Requires PHP 8.2, GPL-3.0-or-later
