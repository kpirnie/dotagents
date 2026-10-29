---
name: wp-plugin
description: Kevin's WordPress plugin development standards and wp.org
  compliance — architecture, security, naming, docblocks, readme.txt.
  Use when writing or reviewing any WordPress plugin PHP.
---

# Kevin's WordPress Plugin Standards

Reference implementation: kpirnie/wpplugin-kp-agent-ready (current standard;
kpirnie/wpplugin-support follows it too).
Older plugins (wpplugin-the-cache-purger, wpplugin-security-header-generator,
wpplugin-stargazers) use a legacy `work/` + `work/inc/` layout with
`KCP_*` / `KP_*` / `SGU_*` classes autoloaded by a Composer classmap — match
their existing style when editing them; use the current standard for new work.

Repo layout for all of them: the plugin lives in `source/`; `build.sh`
(also `npm run build` where `package.json` defines it) regenerates
`distribute/` (committed), and
`.github/workflows/release.yml` zips `distribute/` into a GitHub release on
`v*` tags. kpirnie/wpplugin-kp-file-manager is the exception: no build, the
repo root is the plugin, classes in `includes/class-kfm-*.php`.

## Architecture (current standard)
- Namespaced: `KP\<PluginName>\` with a hand-rolled spl_autoload_register
  PSR-4 autoloader in the main file (no composer dependency at runtime)
- `source/src/` layout: Plugin.php (final, singleton via instance(), hooked
  on plugins_loaded), Modules/ (each extends AbstractModule: abstract
  register(), protected opt()), Settings/, Helpers/
- Constants: `defined('X') || define('X', ...)` pattern for VERSION,
  FILE, DIR, URL — prefixed KP_<PLUGIN>_
- register_activation_hook / register_deactivation_hook on Plugin class
- Options: single serialized option array under one OPTION_KEY constant,
  accessed via an opt($key, $default) helper
- PHP 8.2+ features expected: constructor property promotion, readonly,
  typed properties, `mixed`, nullsafe, match

## File conventions
- Every PHP file: `defined('ABSPATH') || die('No direct script access
  allowed');` immediately after the opening docblock
- File-level AND class-level phpDoc blocks, both carrying:
  @since, @author Kevin Pirnie, @package <Plugin Name> (both
  `<me@kpirnie.com>` and `<iam@kevinpirnie.com>` appear — match the file)
- Method docblocks: description, @since, @access, @param (aligned),
  @return — full and formal
- Between the formal docblocks, comments are conversational and
  lowercase: "// setup the namespace", "// fire us up!", "// make sure
  we're actually supposed to be doing this". Match this voice; comment
  most logical steps.
- uninstall.php: guard with WP_UNINSTALL_PLUGIN check + plugin_basename
  match, register its OWN autoloader (plugin bootstrap is not loaded),
  remove all options, generated files, and scheduled events

## Security (wp.org review + Wordfence will catch violations)
- Escape ALL output at point of output: esc_html(), esc_attr(),
  esc_url(), wp_kses_post(). Late escaping, always.
- Sanitize ALL input on receipt with the sanitizer matching the data
  type: sanitize_key(), sanitize_file_name(), absint(), etc.
  EXCEPTION: file/dir paths are NOT run through sanitize_text_field()
  (it corrupts legitimate path characters) — strip null bytes and
  validate against traversal instead. Preserve existing comments
  explaining this; do not "fix" it.
- Every AJAX/form/REST handler with side effects: check_ajax_referer()
  or wp_verify_nonce() AND a capability check. The capability must
  match the sensitivity of the operation — a read op and a write op
  never share a blanket check (a capability/operation mismatch here
  earned a CVE once; treat this as the highest-priority review item)
- File writes (logs, generated files): correct permission checks before
  writing, output outside webroot or guarded, no world-writable modes
- $wpdb: always ->prepare() with placeholders
- wp_unslash() before sanitizing superglobal input

## wp.org compliance
- readme.txt in proper wp.org format: Contributors kevp75, Tags,
  Requires at least, Tested up to, Requires PHP, Stable tag, License,
  == Description ==, == Changelog ==
- All user-facing strings translatable with the plugin's literal text
  domain; languages/ dir present
- No CDN-loaded assets; everything enqueued via wp_enqueue_* from
  bundled files
- Prefix everything global: options, transients, hooks, script handles
- GPL-compatible license header matching readme.txt

## Rules
- Match the era/style of the plugin being edited; no cross-era
  refactoring unless asked
- Multisite awareness: kp-agent-ready blocks network activation with an
  admin_init deactivate + wp_die guard, and The Cache Purger and Security
  Header Generator wp_die on
  network activation in their activation hook — preserve/replicate this.
  kp-file-manager is the exception: it supports network activation with a
  per-site disable list (`kfm_disabled_sites`)
- Minimal diffs; never touch version numbers, `distribute/`, or `build.sh`
  unless asked. When a version bump is asked for, move every place it lives
  together (header `Version`, readme `Stable tag`, and the `*_VERSION`
  constant where the plugin defines one — the current-standard `build.sh`
  fails on a mismatch)