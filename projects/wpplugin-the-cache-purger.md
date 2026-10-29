---
name: wpplugin-the-cache-purger
description: The Cache Purger — wp.org WordPress plugin that purges plugin, WordPress, hosting, server (nginx/Varnish/PHP), memory and CDN/API caches on content changes. Legacy work/inc layout with trait modules and Action Scheduler. Read before any work in kpirnie/wpplugin-the-cache-purger.
---

# The Cache Purger

WordPress.org plugin (`the-cache-purger`) that clears every cache it can find when content changes: caching plugins, WordPress object/transient caches, managed-host caches, nginx/Varnish/PHP opcache, memory stores, PageSpeed, and CDN/API caches (Cloudflare, Fastly, etc.). Repo: `kpirnie/wpplugin-the-cache-purger`. Skill: `wp-plugin` (legacy-era plugin — match its style).

## Stack
- PHP 8.2+, GPLv3; Composer: `fastly/fastly`, `woocommerce/action-scheduler`, `kevinpirnie/kpt-wpfieldframework`; classmap `work/inc/`, `work/inc/modules/`
- Constants: `TCP_PATH`, `TCP_DIRNAME`, `TCP_FILENAME`; options: `kpcp_settings` (+ `kpcp_log_salt`)
- Scheduling via Action Scheduler: `kpcpc_the_purge` (recurring), `kpcpc_the_log_purge` (recurring), `kptcp_long_purge` (single, +5s)

## Layout and build
- `source/` — plugin you edit; `distribute/` — build output (committed, includes `vendor/`); `build.sh` checks header `Version` == readme `Stable tag`, copies source, runs `composer install --no-dev --classmap-authoritative` in `distribute/`, makes the `.pot`; release workflow zips `distribute/` on `v*` tags

## Map
- `source/the-cache-purger.php` — old-style header comment, constants, requires `work/common.php`
- `source/work/common.php` — activation guards (PHP version, no network activation), bootstrap
- `source/work/inc/kp-cache-purge-common.php` — `KP_Cache_Purge_Common` (aliased `KPCPC` via `class_alias` in `work/common.php`) static helpers: options, `write_log`, log file paths, `admin_post_tcp_cache_purge`, `admin_post_tcp_log_purge`, `wp_ajax_tcp_clear_log`, Action Scheduler wiring, list of hooks that trigger purges
- `source/work/inc/kp-cache-purge.php` — `KP_Cache_Purge` composed of module traits; `kp_do_purge()` runs groups by `caches_to_purge` (1 plugin, 2 WordPress, 3 server, 4 memory, 5 API); `kp_do_long_purge()`
- `source/work/inc/modules/` — one trait per group: `HOSTING`, `PLUGIN`, `WORDPRESS`, `PHP`, `PAGESPEED`, `NGINX`, `FILE`, `MEMORY`, `VARNISH`, `API` (files `hosting.php`, `plugin.php`, ...)
- `source/work/inc/kp-cache-purge-processor.php` — `KP_Cache_Purge_Processor`; `kp-cache-purge-admin.php` — settings via field framework, admin bar purge
- `source/work/doc.php` — in-admin docs

## Conventions
- Docblocks `@since 8.1`, `@author Kevin Pirnie <me@kpirnie.com>`, `@package The Cache Purger`
- Spaced call style (`$this -> method( )`, `get_current_blog_id( )`) in older files — match the file
- Traits guarded by `trait_exists`, classes by `class_exists`

## Behaviour in the code
- Manual purge (`admin_post_tcp_cache_purge` → `handle_manual_purge`): POST only (405 otherwise), `current_user_can(apply_filters('tcp_purge_capability', 'manage_options'))`, then `check_admin_referer('tcp_cache_purge')`; the admin-bar purge uses the same filtered capability
- Log purge (`admin_post_tcp_log_purge`) and `wp_ajax_tcp_clear_log`: always `manage_options`, plus `check_admin_referer` / `check_ajax_referer('tcp_log_purge')`
- Logs: `wp-content/uploads/the-cache-purger/<type>-<16 chars of wp_hash(type + kpcp_log_salt)>.log`, with `.htaccess` (`Require all denied`) and `index.php` guards in the directory; a legacy `wp-content/purge.log` / `purge-exceptions.log` is appended into the new file and deleted
- Fastly token and service ID are stored plain-text in options (the settings field descriptions say so)
- `caches_to_purge`: 1 plugin, 2 WordPress, 3 server, 4 memory, 5 API. `kp_do_purge()` runs plugin, WordPress, server (hosting, PHP, nginx, file) and memory purges; `kp_do_long_purge()` (Action Scheduler `kptcp_long_purge`, +5 s) runs PageSpeed + Varnish (group 3) and remote API purges (group 5)
- readme.txt: Contributors `kevp75`, Requires at least 6.2, Tested up to 7.1, Requires PHP 8.2, Stable tag 2.3.40
