---
name: wordpress-security
description: WordPress plugin and theme security auditing, vulnerability analysis, and targeted hardening. Use when reviewing or fixing authentication, authorization, nonces, REST/AJAX endpoints, input validation, output escaping, SQL, filesystem operations, uploads, or other security-sensitive WordPress code. Apply alongside wp-plugin or wp-theme for coding conventions.
---

# WordPress Security

Security auditing and hardening standards for Kevin's WordPress plugins and themes.

This skill focuses on identifying genuine security issues, understanding their impact, and implementing minimal, correct fixes.

Use `wp-plugin` or `wp-theme` for architecture, formatting, PHPDoc, and commenting conventions.

## Core Rules

- Read the actual code before identifying or proposing vulnerabilities.
- Never assume a vulnerability exists based solely on a function name or coding pattern.
- Trace the complete execution path, including callers, hooks, guards, and existing protections.
- Verify security controls before recommending changes.
- Prioritize genuine security issues over stylistic preferences.
- Preserve existing security mechanisms unless a verified flaw requires modifying them.
- Never weaken authentication, authorization, input validation, sanitization, escaping, or permission checks.
- Never trade security for compatibility, performance, or convenience without explicit approval.
- Never introduce external dependencies without approval.
- Never add tests or testing infrastructure.
- Do not modify unrelated functionality.

## Security Review Process

1. Identify the relevant files, classes, functions, hooks, and endpoints.
2. Determine how the functionality is reached.
3. Identify all untrusted input sources.
4. Trace input through validation, sanitization, authorization, processing, and output.
5. Identify existing protections, including those enforced by callers or WordPress itself.
6. Verify whether a real vulnerability exists.
7. Determine its prerequisites and potential impact.
8. Report the verified finding before modifying code.
9. Apply only the smallest necessary correction when authorized.

Never report theoretical vulnerabilities as confirmed findings.

Do not invent CVE identifiers, CVSS scores, exploitability claims, or severity ratings.

## Authentication and Authorization

- Distinguish authentication from authorization.
- Never assume an authenticated user is authorized to perform an operation.
- Check capabilities using `current_user_can()` with the capability appropriate to the action.
- Use object-specific capability checks where applicable.
- Separate permissions for read, create, update, delete, and administrative operations.
- Never use a broad capability check when a more restrictive operation-specific capability is required.
- Verify authorization before accessing or modifying protected resources.
- Preserve existing role and capability mappings unless explicitly changing them.
- Review multisite permissions separately where relevant.
- Never treat client-provided user IDs, roles, or capabilities as authoritative.

**Critical:** A valid nonce does not establish authorization.

## Nonces and CSRF

- Require appropriate CSRF protection for state-changing browser requests that use cookie authentication.
- Use `check_admin_referer()` for appropriate administrative form actions.
- Use `check_ajax_referer()` for WordPress AJAX handlers.
- Use `wp_verify_nonce()` where direct verification is required.
- Verify the nonce action matches the operation.
- Never reuse a generic nonce across unrelated sensitive operations.
- Sanitize and unslash submitted nonce values before manual verification.
- Preserve existing nonce behavior unless it is demonstrably incorrect.
- Check user capabilities independently of nonce verification.
- Do not add redundant nonce checks where the relevant authentication mechanism already provides appropriate protection.

## AJAX Security

Review callbacks registered through:

- `wp_ajax_*`
- `wp_ajax_nopriv_*`

For each callback:

- Verify whether unauthenticated access is intentional.
- Check nonce requirements based on the operation and authentication mechanism.
- Verify authorization before privileged operations.
- Validate and sanitize incoming parameters.
- Reject malformed or unauthorized requests.
- Escape any HTML returned by the handler.
- Use appropriate WordPress JSON response functions.
- Avoid returning sensitive information in errors.
- Do not expose administrative functionality through unauthenticated hooks.

## REST API Security

- Review every `register_rest_route()` registration.
- Require an explicit `permission_callback`.
- Use `__return_true` only for endpoints intentionally accessible to the public.
- Verify permissions against the specific operation and resource.
- Do not use `is_user_logged_in()` as a substitute for capability checks.
- Respect WordPress REST authentication, including application passwords and cookie authentication.
- Use WordPress REST nonce handling for cookie-authenticated requests.
- Do not require browser nonces for authentication methods that do not use them.
- Define appropriate argument validation and sanitization.
- Validate resource ownership and access rights.
- Prevent exposure of private post data, user information, credentials, or internal configuration.
- Return appropriate `WP_Error` responses and HTTP status codes.
- Preserve endpoint namespaces, routes, parameters, and response contracts when fixing existing functionality.

## Input Validation and Sanitization

Treat external input as untrusted, including:

- `$_GET`, `$_POST`, `$_REQUEST`, `$_COOKIE`
- Uploaded files
- REST and AJAX request parameters
- HTTP headers
- Webhooks and remote API responses
- Database values when their trustworthiness is not established

Rules:

- Validate expected types, formats, lengths, and permitted values.
- Reject invalid values where sanitization would obscure an error.
- Use `wp_unslash()` before sanitizing WordPress superglobal input.
- Use type-appropriate WordPress sanitizers.
- Use `sanitize_key()` for identifiers.
- Use `sanitize_text_field()` for ordinary single-line text.
- Use `sanitize_textarea_field()` for multiline plain text.
- Use `sanitize_email()` and `is_email()` for email addresses.
- Use `esc_url_raw()` or `sanitize_url()` for URLs being stored or processed, with additional destination validation where necessary.
- Use `absint()` for nonnegative integer identifiers where zero is acceptable.
- Validate arrays recursively according to their expected structure.
- Use allowlists for constrained identifiers, actions, and configuration values.
- Never trust sanitization alone to establish authorization.

### Filesystem Paths

- Never apply `sanitize_text_field()` to filesystem paths.
- Remove null bytes and reject path traversal.
- Resolve and validate canonical paths when accessing existing files.
- Constrain filesystem access to explicitly permitted directories.
- Account for symbolic links and directory boundaries.
- Do not rely on string-prefix comparisons alone to establish directory containment.
- Preserve existing path-security logic unless a concrete weakness is verified.

## Output Escaping and XSS

Escape dynamic output at the point of output.

- `esc_html()` for plain text.
- `esc_attr()` for HTML attribute values.
- `esc_url()` for HTML URL attributes.
- `esc_textarea()` for textarea content.
- `wp_kses_post()` for HTML restricted to permitted post markup.
- `wp_json_encode()` for JSON serialization, with safe embedding appropriate to the output context.

Additional rules:

- Review both stored and reflected XSS exposure.
- Examine HTML assembled through concatenation.
- Inspect template attributes, URLs, and inline scripts.
- Escape translated strings according to their output context.
- Do not blindly escape content that is intentionally processed through a verified safe HTML pipeline.
- Preserve legitimate HTML functionality while restricting unsafe markup.
- Do not assume database content is safe merely because it was previously sanitized.

## SQL Injection

- Review all direct `$wpdb` queries containing variable data.
- Use `$wpdb->prepare()` with appropriate placeholders.
- Use `%d`, `%f`, `%s`, and supported identifier placeholders where appropriate.
- Never interpolate untrusted values directly into SQL.
- Validate dynamic table names, column names, sort directions, and SQL fragments.
- Use explicit allowlists for SQL structures that cannot be safely parameterized.
- Review dynamically constructed `IN`, `ORDER BY`, and `LIMIT` clauses.
- Verify that prepared values remain prepared throughout query construction.
- Prefer WordPress query APIs when appropriate and consistent with existing code.
- Never replace safe prepared statements with manual escaping.

## Filesystem and Upload Security

- Verify permissions before file creation, modification, deletion, or download.
- Restrict operations to authorized directories and resources.
- Prevent directory traversal and arbitrary file access.
- Validate filenames, extensions, MIME types, and file contents as appropriate.
- Never rely exclusively on the extension or client-provided MIME type.
- Use WordPress upload and filesystem APIs where appropriate.
- Prevent executable files from being uploaded into publicly accessible locations.
- Protect sensitive generated files and logs from direct web access.
- Avoid world-writable permissions.
- Review archive extraction for path traversal and unsafe entries.
- Review symbolic-link handling.
- Never expose server filesystem paths unnecessarily.

### SVG Uploads

- Treat SVG content as potentially active content.
- Never consider a MIME allowlist alone sufficient protection.
- Require appropriate authorization and reliable SVG sanitization.
- Preserve existing SVG functionality while addressing verified security issues.
- Never introduce unrestricted SVG uploads as a convenience.

## Remote Requests and SSRF

- Validate externally supplied URLs before making requests.
- Prefer `wp_safe_remote_get()` and `wp_safe_remote_post()` when requests must be restricted to safe destinations.
- Do not allow user-controlled URLs to reach internal services or metadata endpoints.
- Review redirects and DNS resolution behavior.
- Restrict protocols and destination hosts where appropriate.
- Apply sensible timeouts and response-size limits.
- Never disable SSL certificate verification to work around connection failures.
- Avoid exposing remote request errors containing credentials or sensitive information.

## Redirects

- Use `wp_safe_redirect()` for redirects that should remain within permitted local destinations.
- Validate externally supplied redirect targets.
- Do not introduce open redirects.
- Review redirects based on query parameters, form submissions, and headers.
- Preserve existing safe redirect behavior.

## Secrets and Sensitive Data

- Never hardcode credentials, API keys, passwords, or authentication tokens.
- Never print or log sensitive credentials.
- Avoid exposing secrets through REST responses, AJAX handlers, HTML, or JavaScript localization.
- Review user data and configuration returned to unauthenticated clients.
- Never modify `.env` files, credentials, or deployment secrets unless explicitly requested.
- Do not expose sensitive details in publicly accessible logs.
- Preserve established encryption and credential-handling mechanisms.

## WordPress-Specific Security

- Review custom post type capabilities and `map_meta_cap` behavior.
- Verify ownership and permissions when editing post metadata.
- Review option updates and settings callbacks for authorization.
- Review shortcodes and blocks that output stored or user-controlled content.
- Inspect administrative forms, settings pages, and bulk operations.
- Review scheduled tasks that process untrusted data.
- Check multisite and network-administration boundaries.
- Preserve existing WordPress security APIs and default protections.
- Do not disable REST, XML-RPC, authentication mechanisms, or other WordPress features without a specific requirement and verified justification.

## Compatibility and Hardening

Security changes must preserve established contracts unless the vulnerability requires otherwise.

Review:

- Public functions and class methods
- WordPress hooks and filters
- REST routes and response formats
- AJAX action names
- Option and transient keys
- Database schemas and stored values
- Script handles and localized JavaScript data
- Existing integrations
- Multisite behavior

When security requires changing an existing contract, explicitly identify the compatibility impact before proceeding.

Do not perform unrelated modernization, refactoring, or formatting changes during a security fix.

## Reporting Findings

Report only findings supported by inspected code.

For each verified issue, identify:

- **Location:** File path, function, method, or hook.
- **Issue:** The specific vulnerability or security weakness.
- **Evidence:** The relevant execution path and missing or ineffective protection.
- **Impact:** What an attacker could realistically accomplish.
- **Prerequisites:** Authentication level, capabilities, configuration, or other necessary conditions.
- **Recommended correction:** The smallest effective fix.

Clearly distinguish:

- Confirmed vulnerabilities
- Potential concerns requiring further verification
- Existing protections that are functioning correctly

Never classify an issue as critical merely because it involves authentication, SQL, files, or sensitive operations.

Never claim a vulnerability was exploited without evidence.

## Fixing Security Issues

- Apply the smallest change that eliminates the verified vulnerability.
- Preserve established formatting, PHPDoc, and inline comments.
- Use the applicable `wp-plugin` or `wp-theme` skill.
- Keep authentication, authorization, and validation checks in the appropriate execution path.
- Never bypass security checks to make an operation succeed.
- Never replace restrictive checks with broader permissions.
- Never remove security controls unless they are proven redundant and removal is explicitly requested.
- Preserve existing functionality wherever safely possible.
- Avoid unnecessary dependency changes.
- Do not modify generated files, build scripts, deployment configuration, or version numbers without approval.
- Do not add tests or testing infrastructure.
- Follow AGENTS.md for incremental delivery, exact placement, and commit messages.

## Authoritative References

Use current WordPress developer documentation when behavior or API requirements need verification.

- https://developer.wordpress.org/apis/security/
- https://developer.wordpress.org/apis/security/nonces/
- https://developer.wordpress.org/apis/security/data-validation/
- https://developer.wordpress.org/apis/security/sanitizing/
- https://developer.wordpress.org/apis/security/escaping/
- https://developer.wordpress.org/rest-api/extending-the-rest-api/adding-custom-endpoints/
- https://developer.wordpress.org/themes/advanced-topics/security/
