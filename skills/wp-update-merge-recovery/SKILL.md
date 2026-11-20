---
name: wp-update-merge-recovery
description: Resolve an in-progress Git merge that conflicts because both branches carry different versions of tracked WordPress core, plugins, or themes. Use for overlapping vendor updates, including rename/rename and modify/delete conflicts in packaged assets.
---

# WordPress Update Merge Recovery

Work from the pasted terminal output or read-only Git output. Give Kevin one copy/paste step at a time and wait for the result. Verify the merge and its scope before suggesting changes. Kevin runs the commands in his checkout.

## Verify the merge

- Confirm the repository root, destination branch, and active incoming commit (`MERGE_HEAD`). Use `git status --short --branch` and `git diff --name-only --diff-filter=U` to identify the conflicted paths.
- Group conflicts by component. WordPress core can span `wp-admin`, `wp-includes`, and tracked core files at the root. Plugins and themes typically have one directory each. Use the actual paths from the merge.
- If both branches changed a component, compare `HEAD...MERGE_HEAD` history for the proposed paths. Inspect the relevant diffs for local fixes, customizations, and changes made in earlier merge commits. Check which packaged version should win. Commit subjects and version numbers alone do not establish that the incoming tree is safe to take wholesale.
- Take the incoming snapshot only for confirmed vendor paths. Restoring a whole directory replaces all tracked content there, including destination-only changes in files Git merged automatically. Flag custom changes or local work that would be overwritten and get Kevin's decision before replacing them. Scope root-level core files individually. Keep site configuration, custom code, and unrelated paths outside the replacement.

## Resolve the approved paths

Prefer a complete incoming package snapshot for a confirmed vendor update. This keeps PHP, generated manifests, and versioned assets from the same release together. `git restore --source=MERGE_HEAD --staged --worktree` can fail on unmerged paths absent from the incoming tree. Clear the selected conflict entries first, then restore the incoming trees in the same step.

Adapt this Bash block to the confirmed paths. The paths below are an example. Review the unmerged paths in those locations before giving Kevin the command. `git rm -f` removes only the listed unmerged paths from the index and working tree. The restore puts incoming files back and leaves incoming deletions absent.

```bash
(
  set -o pipefail
  paths=(wp-admin wp-includes wp-content/plugins/gravityforms wp-content/plugins/wordpress-seo)

  git rev-parse --verify 'MERGE_HEAD^{commit}' >/dev/null &&
    git diff --name-only --diff-filter=U -z -- "${paths[@]}" |
      xargs -0 -r git --literal-pathspecs rm -f -- &&
    git restore --source=MERGE_HEAD --staged --worktree -- "${paths[@]}" &&
    git diff --cached --exit-code MERGE_HEAD -- "${paths[@]}" &&
    git diff --exit-code -- "${paths[@]}" &&
    git diff --name-only --diff-filter=U
)
```

Read the output. The final command must list no unresolved paths. If a command fails, inspect the current status before retrying. If conflicts remain elsewhere, handle the next group separately. Review the final staged scope with `git diff --cached --stat` before committing.

## Finish the merge

Once the resolution and staged scope are confirmed, give Kevin `git commit --no-edit` as the next step. Wait for the commit output, then report the commit hash and subject. Push only if Kevin asks.
