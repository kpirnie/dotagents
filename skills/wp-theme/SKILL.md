---
name: wp-theme
description: Kevin's WordPress theme development standards — architecture, PHPDoc, templates, security, assets, performance, and WordPress conventions. Use when writing, modifying, or reviewing any WordPress theme PHP, templates, or supporting assets. For plugin development, use wp-plugin instead.
---

# Kevin's WordPress Theme Standards

Reference implementation: kpirnie/wptheme-kevinpirnie (develop branch).

These conventions closely follow the wp-plugin skill. The same PHPDoc standards, security requirements, naming conventions, and conversational commenting style apply to both.

Always inspect the current repository before making changes. Existing implementations take precedence over reference implementations.

## Architecture

- Keep theme functionality organized into focused classes, functions, and template partials.
- Follow the existing theme's architecture. Never introduce namespaces, autoloaders, or new organizational patterns unless requested.
- The reference theme uses a Composer classmap autoloader, a primary `KPT` class, and individual `KPT_*` classes for functionality.
- `functions.php` bootstraps the theme using the `after_setup_theme` hook.
- Theme functionality lives in `work/` and `work/inc/`.
- Template partials live in `partials/`, grouped by responsibility.
- Reusable templates use `get_template_part()` with arguments where appropriate.
- Use WordPress hooks and filters rather than modifying WordPress core or plugin internals.
- Preserve existing custom post types, taxonomies, shortcodes, hooks, filters, and integrations.
- Do not move functionality between a theme and plugin unless explicitly requested.

## File Conventions

- Every PHP file must have a properly formatted opening PHPDoc block.
- PHPDoc blocks include:
  - File or class name
  - Brief description
  - `@since`
  - `@author Kevin Pirnie` with the existing email address
  - `@package` matching the theme
- Class-level PHPDoc blocks must document the class independently of the file header.
- Method PHPDoc blocks include:
  - Method name
  - Description
  - `@since`
  - `@access`
  - `@param` when applicable
  - `@return` when applicable
  - `@throws` when applicable
- Keep PHPDoc tags properly formatted and consistently aligned with the surrounding code.
- Preserve the existing meaning of `@since`. Never invent version numbers.
- All PHP files must guard against direct access using the existing theme's convention:

      defined( 'ABSPATH' ) || die( 'No direct script access allowed' );

- Place the direct-access guard immediately after the opening PHPDoc block, allowing for an existing explanatory comment.
- Match existing PHP formatting, whitespace, naming, array syntax, and brace placement.
- Do not impose PSR-12 or another coding standard on files that follow different established conventions.
- Use typed parameters, return types, and properties where compatible with the project's supported PHP version and existing conventions.
- Never introduce PHP language features unsupported by the target project's declared PHP version.

## Comments

Comments are an important part of Kevin's coding style.

- Use formal PHPDoc blocks for files, classes, functions, and methods.
- Use conversational, generally lowercase comments within method and function bodies.
- Comment most logical steps, especially where state, behavior, or responsibilities change.
- Keep comments short, direct, and descriptive.
- Match the existing file's commenting voice.
- Do not strip existing comments or replace conversational comments with unnecessarily formal language.
- Avoid comments that merely repeat the immediately obvious code.

Examples of the established style:

    // fire us up
    // make sure this isn't already loaded in
    // setup our path
    // loop over each item
    // make sure the class actually exists
    // now we can clean up

## Templates

- Follow WordPress's existing template hierarchy.
- Preserve established template filenames and locations.
- Use `get_header()`, `get_footer()`, `get_sidebar()`, and `get_template_part()` where appropriate.
- Keep reusable markup in template partials.
- Avoid duplicating substantial template functionality.
- Preserve existing template arguments and their expected shapes.
- Use WordPress conditional tags for context-dependent behavior.
- Preserve the WordPress Loop and its expected global state.
- Use `wp_reset_postdata()` after custom `WP_Query` loops where necessary.
- Use `wp_reset_query()` only when correcting a modified main query.
- Preserve existing template hooks, markup structure, and CSS classes unless the task explicitly requires changing them.
- Do not replace working theme functionality with new abstractions.

## Theme Setup

- Register theme support through the appropriate WordPress lifecycle hooks.
- Use `after_setup_theme` for theme initialization and support registration.
- Register navigation menus with `register_nav_menus()`.
- Register widget areas using `widgets_init`.
- Register image sizes with `add_image_size()`.
- Preserve existing image sizes, crop behavior, menu locations, and registered sidebars.
- Preserve the theme's existing text domain.
- Do not globally disable WordPress features, REST endpoints, or editor functionality unless requested.
- Maintain compatibility with the project's existing WordPress configuration.

## Security

Follow the same security requirements as the wp-plugin skill.

- Escape output at the point of output using the appropriate function:
  - `esc_html()` for plain text
  - `esc_attr()` for HTML attributes
  - `esc_url()` for URLs
  - `esc_textarea()` for textarea values
  - `wp_kses_post()` for permitted post HTML
- Sanitize untrusted input according to its expected data type.
- Use `wp_unslash()` before sanitizing WordPress superglobal input.
- Never use `sanitize_text_field()` to sanitize filesystem paths. Validate paths against traversal and remove null bytes instead.
- Validate request parameters before using them.
- All state-changing form, AJAX, and REST operations require appropriate nonce verification and authorization.
- Use capability checks appropriate to the specific operation.
- Nonce verification is not a replacement for authorization.
- Use `$wpdb->prepare()` with placeholders for queries containing variable data.
- Never trust user-controlled filenames, paths, redirects, or external URLs.
- Use `wp_safe_redirect()` for redirects to permitted local destinations.
- Apply appropriate SVG sanitization and authorization if SVG uploads are supported.
- Preserve existing authentication, permissions, sanitization, and security defenses.
- Never weaken security code for convenience.

## Assets

- Register and enqueue styles and scripts through WordPress APIs.
- Use `wp_enqueue_style()` and `wp_enqueue_script()` rather than hardcoding asset tags.
- Use `get_stylesheet_directory_uri()` for child-theme-aware asset paths.
- Use `get_template_directory_uri()` when explicitly referencing parent-theme assets.
- Preserve existing asset handles and dependency relationships.
- Respect established development and production asset loading.
- Preserve the project's existing Tailwind, CSS, JavaScript, and bundling configuration.
- Never introduce additional frontend libraries or frameworks without approval.
- Prefer the project's existing vanilla JavaScript conventions.
- Do not modify minified or generated assets directly unless requested.
- Do not run asset builds or modify build configurations unless requested.
- Keep assets local unless the existing implementation or task explicitly requires external assets.

## Performance

- Avoid unnecessary database queries and repeated expensive operations.
- Preserve existing transient and object-cache behavior.
- Invalidate caches when underlying content changes.
- Avoid unnecessary frontend scripts, styles, and dependencies.
- Load functionality only where it is needed.
- Preserve existing lazy-loading and responsive-image behavior.
- Use WordPress image APIs and registered image sizes where appropriate.
- Avoid introducing render-blocking resources unnecessarily.
- Preserve existing asset-loading optimizations.
- Do not remove WordPress functionality solely for a perceived performance benefit.
- Never sacrifice security, accessibility, or correctness for performance.

## Accessibility

- Use semantic HTML appropriate to the content.
- Maintain a logical heading hierarchy.
- Preserve keyboard navigation and visible focus indicators.
- Provide accessible labels for interactive controls.
- Use meaningful alternative text for content images.
- Treat decorative imagery appropriately.
- Preserve existing ARIA attributes and accessible component behavior.
- Ensure interactive elements remain usable without a mouse.
- Do not replace accessible native elements with unnecessary JavaScript controls.

## WordPress Conventions

- Follow WordPress APIs and lifecycle hooks.
- Prefix custom global functions, classes, constants, options, transients, and asset handles.
- Use the theme's existing naming convention and prefixes.
- Use the theme's established text domain for translatable strings.
- Use WordPress internationalization functions for user-facing strings.
- Preserve established custom post types, taxonomies, metadata, and option keys.
- Use existing WordPress APIs for retrieving and displaying content.
- Preserve compatibility with supported WordPress and PHP versions.
- Never introduce activation or deactivation hooks into theme code.
- Do not assume a theme follows WordPress.org directory requirements unless it is intended for distribution there.

## Theme Metadata

- Preserve the existing `style.css` theme header.
- Keep Theme Name, Theme URI, Author, Version, License, and Text Domain consistent with the project.
- Do not change version numbers unless requested.
- Do not change licensing or attribution without explicit approval.
- Respect parent-theme and child-theme relationships where applicable.

## Rules

- Match the existing theme's architecture, conventions, and coding style.
- Use the wp-plugin skill for plugin-specific development.
- Apply shared WordPress security practices consistently across plugins and themes.
- Inspect existing functionality before proposing or implementing changes.
- Make minimal, targeted changes only.
- Never refactor unrelated functionality.
- Never introduce new dependencies without approval.
- Never modify deployment configuration, credentials, environment files, or generated artifacts unless requested.
- Do not add tests or testing infrastructure.
- Never silently change behavior, compatibility, or public interfaces.
- Preserve existing PHPDoc and conversational inline comments.
- When adding new PHP code, document it using the same conventions as the surrounding code.
- Follow AGENTS.md for workflow, output, and commit-message requirements.
