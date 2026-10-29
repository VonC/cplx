# How to make a release

<img src="../assets/logo-cplx-transparent.png" alt="" height="90" align="right">

Goal: turn the current `-SNAPSHOT` work into a tagged cplx release with a
regenerated changelog, or cleanly back out of a failed attempt.

This is the release of the cplx **source repository**. Building and
publishing the toolchain itself, the `tools` archive a consumer pins, is a
different procedure with its own gates:
[Rebuild and publish the tools archive](rebuild-and-publish-the-tools-archive.md).

Versioning is handled by the `dev_workflow` submodule around one file,
`version.txt`:

```text
0.27.0-SNAPSHOT -- Witty release title

Description line 1.
Description line 2.
```

## 📋 Steps

1. Make sure the tree is clean (`gs`): the release path refuses a dirty
   tree (exit 118), and files like `CHANGELOG.md` or `version.txt` are
   exempted from that check via `git/exempt-files.txt`.

2. Complete the release's outstanding acceptance gates against the prepared
   `main` candidate. Record its full commit identity with the evidence before
   tagging. For v0.27.0, integration completion does not close
   [deploy-venv-sync AC19](../../docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md#integration-completion-and-pre-tag-acceptance-2026-10-28):
   actual production delivery, historical recovery readiness and external
   acceptance remain required. Fixture and rehearsal results do not replace
   that production evidence. AC18 is deferred to a later effort.

3. Once those gates are closed, release:

   ```cmd
   brel
   ```

   which chains: strip `-SNAPSHOT` from `version.txt`, regenerate
   `CHANGELOG.md` with git-cliff (conventional commits grouped with
   emojis, typo fixes from `.changelog.fixes` applied, header from
   `changelog-header.md`), commit
   `chore(release): set new 'vX.Y.Z' ...`, create the annotated tag
   `vX.Y.Z` with `version.txt` as its message, then run the build. A
   successful build stamps `[valid]` into the tag message; a failed one
   *cancels the release* (`git reset @~1` + tag deletion) so nothing
   half-released survives.

4. Start the next iteration:

   ```cmd
   uv
   ```

   `update-version` proposes Fix / Minor / Major, asks for the new title
   and description (finish with `END`), writes the new `-SNAPSHOT`
   `version.txt` and commits `chore(release): prepare for new ...`.

5. Useful repairs:

   ```cmd
   crel        &:: cancel the last release: delete tag, reset the commit
   uc          &:: regenerate CHANGELOG.md without releasing
   gv          &:: print the current version
   utm v0.25.0 &:: re-create or re-date an annotated tag from version.txt
   ```

## ✅ Check

`git describe` answers the new tag, `git tag -n1 vX.Y.Z` shows the
version title with `[valid]`, and `CHANGELOG.md` opens with the new
section.

Related: [Commands](../reference/commands.md); the changelog pipeline
details live in `tools/dev_workflow/readme.md`.
