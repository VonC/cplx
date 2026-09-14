# Resolve the architecture key across server minors

- Type: feature-request
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Requirement: [architecture-minor-fallback](feature-request.v0.27.0.architecture-minor-fallback.md)

## Selected umbrella entry

| Order | Type | Key title | Slug | Status | Requirement | Validation plan |
| --- | --- | --- | --- | --- | --- | --- |
| 5 | Feature-request | Resolve the architecture key across server minors | `architecture-minor-fallback` | pending | `docs/v0.27.0/feature-request.v0.27.0.architecture-minor-fallback.md` | - |

## Need inherited from item 5

`setup.sh` recomputes the server architecture on connection validation. The
upgrade from RHEL 9.6 to 9.8 therefore changes exact-name dependency lookups
to `rhel_9.8_x86_64`. Missing per-tool lists stop synchronization with fatal 9
before the later remote-copy check that can fail with fatal 902. Missing index
and mirror definitions also prevent dependency preparation.

The temporary recovery on 7 August 2026 copied the Python and Git lists,
added a 9.8 mirror property and regenerated the package index. Item 5 removes
repeated copying on minor upgrades while retaining genuinely distinct exact
overrides. Commit `18c251d` subsequently documented an incompatible older
index and corrected the Python dependency from `zlib-dev` to `zlib-devel`.

## D9 refinement approved on 14 September 2026

The consolidated requirement records Q01 option D, Q06 option C and option A
for the remaining nine questions. Its confirmed rules supersede the original
three-lookup closest-minor shorthand:

1. Resolve curated lists and mirror definitions independently: exact first,
  then highest lower minor, otherwise lowest higher minor. Compare integer
  minors within the same distribution, major and complete machine component,
  and report each substitution. Exact major-only keys remain supported but
  do not participate in minor fallback.
2. Generate a missing or zero-length index for the detected key from its
  resolved mirrors, regardless of an earlier completion marker. Either reload
  flag also regenerates. Never reuse another minor's index; generation and
  corresponding downloads use the same resolved mirrors. This applies to
  ordinary and single-package setup.
3. Honor synchronization progress only for the same selected list file and
  detected key. Changed selections, changed keys and legacy unkeyed progress
  restart at the first active entry and report the restart. Existing package
  download and copy reuse remain available.
4. Correct the retained 9.6 Python list to `zlib-devel`, prove equivalence and
  accepted setup, then remove the redundant 9.8 Python/Git lists and tracked
  mirror key. Preserve generated indexes and operator-local properties.
  Distinct exact overrides remain valid, and generated indexes can exist per
  minor; this is not a one-file-per-major inventory rule.

The RHEL 9.8 acceptance environment has no exact local mirror override and
retains pre-upgrade synchronization state. Setup must report fallback and
restart, process all active Python/Git dependencies and use a generated 9.8
index. Missing required metadata fails with actionable diagnostics; present
invalid inputs retain ordinary errors, and retrieval failures do not trigger
another minor selection. The requirement specifies the per-kind absence rules.

## Scope boundary with items 4, 6 and 7

Item 4 already checks the tools runtime payload during packaging. Item 5
improves dependency selection upstream and has no technical dependency on
that checker. RHEL prepares and packages tools and the private application,
and deploys their archives. Jenkins Debian consumes existing tools, checks
the application out from source, runs tests, and packages and publishes only
the application to Nexus. Debian compilation is outside this feature.

Item 6 owns Python SQLite integration, its rebuild and waiver removal. Item 7
owns the final tools refresh, rebuild, cross-platform validation and release.
RHEL 9 seeds for new-tool creation remain a separate pre-existing gap.
Implementation of item 5 is pending; the requirement is settled.

## Documentation affected by architecture resolution

- [The architecture key](../../wiki/explanation/the-architecture-key.md)
- [Survive a server OS upgrade](../../wiki/how-to/survive-a-server-os-upgrade.md)
- [Package list formats](../../wiki/reference/package-list-formats.md)
