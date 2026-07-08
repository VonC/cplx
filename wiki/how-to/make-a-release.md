# How to make a release

<img src="../assets/logo-cplx-transparent.png" alt="" height="90" align="right">

Goal: turn the current `-SNAPSHOT` work into a tagged cplx release with a
regenerated changelog — or cleanly back out of a failed attempt.

Versioning is handled by the `dev_workflow` submodule around one file,
`version.txt`:

```text
0.26.0-SNAPSHOT -- Witty release title

Description line 1.
Description line 2.
```

## 📋 Steps

1. Make sure the tree is clean (`gs`): the release path refuses a dirty
   tree (exit 118), and files like `CHANGELOG.md` or `version.txt` are
   exempted from that check via `git/exempt-files.txt`.

2. Release:

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

3. Start the next iteration:

   ```cmd
   uv
   ```

   `update-version` proposes Fix / Minor / Major, asks for the new title
   and description (finish with `END`), writes the new `-SNAPSHOT`
   `version.txt` and commits `chore(release): prepare for new ...`.

4. Useful repairs:

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
