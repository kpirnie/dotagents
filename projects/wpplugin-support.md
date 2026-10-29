---
name: wpplugin-support
description: KP Support — WordPress support ticket + live chat plugin with front-end customer/agent portal, departments, internal notes, protected attachments, GitHub-release updater. Read before any work in kpirnie/wpplugin-support.
---

# KP Support

WordPress plugin (`kp-support`) providing a ticket system with AJAX threaded replies, internal notes, departments/priorities/categories, protected attachments, live chat (including guests), SMTP and notifications, and a front-end portal where agents can work entirely outside wp-admin. Distributed via GitHub Releases with its own updater. Repo: `kpirnie/wpplugin-support`. Skill: `wp-plugin` (current `src/` architecture).

## Stack
- PHP 8.2+ (`declare(strict_types=1)`), WP 6.8+, GPL-3.0-or-later
- Hand-rolled PSR-4 autoloader for `KP\Support\`; settings UI via `kevinpirnie/kpt-wpfieldframework ^1.7` (`Plugin::FRAMEWORK_ID = 'kp_support'`)
- `KP_SUPPORT_VERSION` is read from the plugin header at runtime (single source of version)
- Options: `kpts_settings`; caps version: `kpts_caps_version`

## Layout and build
- `source/` — plugin you edit; `distribute/` — build output (committed)
- `build.sh` (no version check): `rm -rf distribute/`, `composer install` at the root, copies PHP/readme/LICENSE and root `composer.json`, minifies each `source/assets/css/*.css` → `*.min.css` and `source/assets/js/*.js` → `*.min.js` with esbuild (`--target=es2017`), `wp i18n make-pot`, copies `vendor/`; optionally copies to `package.json` `production.path` when `production.shouldcopy` is true (currently `false`, path `/home/kpirnie/SVN/kp-support/trunk/`)
- `.github/workflows/release.yml` zips `distribute/` into a GitHub release on `v*` tags, which `source/src/Modules/Updater.php` picks up from `api.github.com/repos/kpirnie/wpplugin-support/releases/latest`

## Map
- `source/kp-support.php` — header, constants, autoloader, framework, `plugins_loaded` boot
- `source/src/Plugin.php` — singleton, option defaults/merge, module boot
- `source/src/Modules/` (each extends `AbstractModule`):
  - data: `PostTypes.php` (`kpts_ticket`, `kpts_chat`), `TermFields.php`, `Roles.php` (`kpts_customer`, `kpts_agent`, `kpts_manager` + `kpts_*` caps)
  - tickets: `Ajax.php` (portal AJAX, `verifyRequest()` → `check_ajax_referer('kpts_portal','nonce')`), `Replies.php`, `Attachments.php`, `Portal.php`, `Accounts.php`, `Dashboard.php`, `Admin.php`
  - chat: `ChatWidget.php`, `ChatAjax.php` (registers some `wp_ajax_nopriv_` actions for guests), `ChatAdmin.php`
  - `Notifications.php`, `Smtp.php`, `Updater.php`
- `source/src/Helpers/` — `Access.php` (all permission decisions: `isAgent`, `isManager`, `canViewTicket`, `canReply`, `canReplyInternal`, `canManageTicket`, `canSeeInternal`, department coverage), `Ticket.php`, `Chat*.php`, `MailLog.php`, `Template.php`
- `source/src/Settings/Settings.php`; `source/templates/` — portal/chat templates; `source/assets/` — admin/portal/chat CSS+JS

## Conventions
- Docblocks: `@package KP Support`, `@author Kevin Pirnie <me@kpirnie.com>`, `@since <plugin version>`
- Inline `// phpcs:ignore ... -- reason` on superglobal reads that are covered by `verifyRequest()`; keep the reason text accurate
- Conversational lowercase comments

## Behaviour in the code
- Ticket/chat permission decisions live in `Helpers\Access` and `Helpers\ChatAccess` (`canView`, `canPost`, `isChatAgent`, `agentCoversChats`)
- Internal notes are gated by `Access::canSeeInternal` / `canReplyInternal`
- Attachments: `Attachments::protectUploadDir()` writes deny-all `.htaccess` (and IIS `web.config`) into the upload dir; `handleDownload()` checks `ChatAccess::canView()` or `Access::canViewTicket()` before serving; size and type limits from `maxSize()` / `allowedTypes()`
- Portal AJAX handlers run `verifyRequest()` (`check_ajax_referer('kpts_portal', 'nonce', false)`) first; inline `phpcs:ignore` comments say so
- Chat AJAX: `kpts_chat_start`, `_send`, `_poll`, `_queue`, `_assign`, `_convert`, `_close`, `_offline_ticket`; only the guest subset is also registered `wp_ajax_nopriv_`, and guests carry a signed chat cookie (`Helpers\ChatGuest`); posting is throttled per actor via the `kpts_chat_rate_<id>` transient (`chat_rate_limit`, default 20)
- Reply HTML is sanitized with `wp_kses` in `Replies::add()`
- readme.txt: Contributors `kevp75`, Requires at least 6.8, Tested up to 7.1, Requires PHP 8.2, GPLv3 or later
