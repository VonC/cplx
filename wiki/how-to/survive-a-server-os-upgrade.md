# How to survive a server OS upgrade

<img src="../assets/logo-cplx-bridge-transparent.png" alt="" height="90" align="right">

Goal: prepare dependencies after a minor upgrade, for example RHEL 9.6 to
9.8. Setup can reuse eligible curated lists and mirrors while generating an
index for the detected server. See
[The architecture key](../explanation/the-architecture-key.md) for the rules.

## 📋 Steps

1. Repeat connection validation after the upgrade, then confirm the new key:

   ```cmd
   findstr /b architecture= src\setups\setup.properties
   ```

   A completed connection step can be skipped; use the repetition controls in
   [Resume or repeat a step](resume-or-repeat-a-step.md) to refresh it. Once
   validation runs, the property holds the new value, for example
   `rhel_9.8_x86_64`. The old file set still carries the previous key in its names.

2. Check the available curated list for the selected tool and mirror values
   in active `src\setups\setup.properties`. Each selection prefers exact,
   highest lower minor, then lowest higher minor, within the same distribution,
   major and machine. Lists and mirrors can select different minors. The
   committed `setup.tpl.properties` does not override active local values.

   A missing list allows fallback. A present empty/comment-only list is
   intentional. A missing or whitespace-only mirror value allows fallback;
   duplicate keys use their first value. Unreadable present inputs fail.

3. Run the package flow for each tool you need:

   ```cmd
   sp
   ```

   For example, the reported selections may be `python_rhel_9.6_x86_64.txt`
   and `rhel_9_6_x86_64_pkgs_url`, while the generated file remains
   `src\setups\pkgs\packages_rhel_9.8_x86_64.txt`. Missing or empty detected
   indexes are rebuilt even with an old done marker. To explicitly refresh a
   nonempty index, use `sdpl`; either reload flag forces the same guard.

4. Check progress and completion. A legacy marker or changed architecture/list
   identity restarts from the first active entry, preserving cached downloads
   and installed-state reuse. A valid matching cursor resumes after its entry.
   The selected file is copied to the server as `dependencies.list`.

5. Add an exact list or active mirror property only when the new minor needs a
   different definition or no eligible definition exists. Resolve ordinary
   missing/ambiguous package names and unavailable downloads explicitly: setup
   does not retry metadata from another minor after these failures.

## ✅ Check

The log identifies any fallback, reports successful synchronization and remote
installation, and the nonempty index and cache retain the detected 9.8 key.
The copied `dependencies.list` matches the selected source file. An older minor's
generated index is never substituted. A failed refresh preserves the previous
index but fails the invocation; investigate its error before retrying.

## ⚠️ Two traps

- **Do not hand-edit the architecture property back** to the old value
  to avoid the work. The connection step recomputes it when repeated
  and your edit disappears, or worse it survives long enough to build
  against lists that no longer describe the machine.
- **A major upgrade is not this recipe.** Going from RHEL 8 to RHEL 9
  changes package names, not just the key: start from
  [Target a new Linux server](../tutorials/03-target-a-new-linux-server.md)
  and expect to adjust the lists as builds complain.

Related: [Add or fix a package mirror](add-or-fix-a-package-mirror.md)
when a mirror in the new list misbehaves, and
[Package list formats](../reference/package-list-formats.md) for every
artifact the key names.
