# The runtime-closure configuration bundle

This directory holds the declaration the v0.27.0 runtime-closure checker reads,
and it states the digest domain beside the data that domain governs, so a second
implementation cannot get the domain wrong by reading the code instead.

## The two parts, and only one of them is hashed

| Part | Content | In the digest |
| --- | --- | --- |
| `closure-config.txt` | the five declarations, one document | yes, and nothing else is |
| the identity envelope | the document's digest, and the cplx commit that holds it | no, so the digest never covers itself |

The envelope IS committed here, as `closure-envelope.txt`, and step 5 of the
v0.27.0 effort is where that changed. An earlier version of this paragraph had
packaging produce it from the commit it was about to name, which assumed a cplx
checkout on the machine that runs `pkg.sh`. There is none: cplx reaches that
account as copied scripts, and `pkg.sh` has never known anything about Git. So
the envelope is written in the repository when the declaration changes, travels
to the build account the way every other cplx file travels, and packaging stages
the pair at `tools/closure/` inside the archive after verifying with
`sha256sum` that the two agree. The commit the `source` line names is a RECORD
of which reviewed version the declaration is: it is printed on the build
account and resolved only where cplx exists.

The maintenance rule for delivered bundles is one line, and the harness holds it:
**when the declaration changes, the envelope is regenerated in the same commit.** A
declaration edited without its envelope is a failing case rather than an archive
that ships a receipt for bytes it does not carry.

## The digest domain

**The digest is the SHA-256 of `closure-config.txt`'s exact committed bytes**:
the file as cplx stores it, UTF-8, LF line endings, no normalisation, no
canonicalisation pass and no re-serialisation, comment lines and the trailing
newline included. Hashing bytes rather than parsed content is what makes the
value reproducible by a party that cannot parse the format.

Two consequences follow, and both are asserted by the harness rather than left
as advice:

- the same declaration written with CRLF endings is a DIFFERENT document and
  produces a different digest;
- the same bytes read through a different path produce the SAME digest, because
  the domain is the content and never the location.

## The grammar is a separate contract from the digest

An exact-byte digest makes two parties agree on the bytes and not on their
meaning, so both contracts are required and `closure_config.sh` implements the
second for every party. The document is a `CPLX-CLOSURE/1` record stream: a
version line first, one record per line, fields separated by `|`, no empty
field, `%7C` for a literal `|` and `%25` for a literal `%` with any other `%`
sequence a refusal. Blank lines and `#` comment lines are ignored, because a
human authors this file. Unknown records, wrong field counts, duplicate keys and
unresolved cross-references all fail closed.

| Record | Shape |
| --- | --- |
| `root` | `root\|<root-name>` |
| `subdir` | `subdir\|<root-name>\|<subdir-name>` |
| `floor` | `floor\|<lookup-name>\|<location>` |
| `family` | `family\|<family-name>\|<soname-glob>\|<generations>` |
| `entrypoint` | `entrypoint\|<location>` |
| `waiver` | `waiver\|<lookup-name>\|<owning-requirement>` |

Ordering is significant for `root` and for nothing else: those records are the
loader's order and `python` comes first. A `subdir` names a declared root, a
`waiver` names a member the floor declares, and a `location` other than `any` is
exactly `tools/<root-name>` with a declared root.

An `entrypoint` location is a relative path of two to eight segments under
`tools/<declared-root>`, and every shipped ELF at or under it is a runtime entry
point. The set is DECLARED and never derived: the loading mechanism at issue,
the interpreter opening an extension module by path, leaves no static trace, so
a heuristic over `PT_INTERP`, a file name or a permission bit would be wrong in
both directions. It feeds the unreferenced finding and nothing else, so an
incomplete list widens that report rather than refusing anything.

## Self-describing is not the same as authoritative

An archive that carries this bundle answers "what does this archive claim to
owe". It cannot answer "is that what cplx reviewed", and the difference is the
reason the envelope names a commit:

| Party | Has cplx | Checks | Refuses on |
| --- | --- | --- | --- |
| packaging | no, see above | the committed envelope's digest is the committed declaration's digest, and both are staged whole | a bundle part that is absent, empty, or whose digest disagrees with its envelope |
| verification, the Debian agent | no | the embedded document hashes to the digest its envelope names | absent, substituted or corrupted configuration |
| publication | yes | the archive's envelope digest equals the digest of the configuration publication resolved ITSELF | any difference, and any active waiver |

The agent's check is INTERNAL CONSISTENCY and never authority, and its output
says so on every run. It catches substitution or corruption in transit; it
cannot catch a paired edit, where a floor entry is deleted in the same edit that
removes the payload and the document is re-hashed to match its own envelope, and
it cannot catch an authentic-but-wrong bundle. Both need cplx, and both are
caught by the two parties that have it.

## Ownership

The floor, the declared family list and the waiver list are established by
`docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md`, and the entry-point
list by design decision Q13 of
`docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md`. A later requirement
may add, change or remove an entry only by saying so in its own document:
`python-sqlite-support` replaces `python-3.13.9` with `python-3.13.15` and
removes the SQLite waiver while retaining its `tools/python` floor entry,
`root`, `current`, other entries and root ordering. `tools-archive-rebuild`
may add an entry if the rebuilt payload introduces one.

## Item 6 declaration identity and maintenance

The owning requirement is
[Python SQLite support](../../../../docs/v0.27.0/feature-request.v0.27.0.python-sqlite-support.md),
AC5. Its approved Step 3 uses a separate source snapshot so the envelope can
name a real commit without requiring a commit to contain its own hash.
The human authorized that auxiliary commit and its later retention merge on
2026-09-16.

| Identity | Value |
| --- | --- |
| Source path | `src/setups/env/closure/closure-config.txt` |
| Source snapshot | `13c80d572ba7bda91728806ad7dc11c53629a506` |
| Source parent | `3a1d1135a3e627b74d134db24694121e70ea6b14` |
| Committed declaration SHA-256 | `63a955f8bded96f6a469764c625e9653c0988abe03ebd8192fc541f802d9d5aa` |

The source snapshot changes only the declaration. It was created on
`sqlite-source-3.13.15-step3` in a separate clean worktree with the existing
`pre-commit` and `commit-msg` dispatchers active and the same sensitive-content
rules. Its retained previous envelope makes this snapshot unsuitable as a
delivered bundle. The implementation branch pairs the new declaration and
envelope in the normal reviewed bundle commit.

These commands extract the exact source blob and regenerate the pair from the
repository root; the digest comes from Git's blob bytes, not a Windows checkout:

```sh
source_sha=13c80d572ba7bda91728806ad7dc11c53629a506
path=src/setups/env/closure/closure-config.txt
git cat-file blob "$source_sha:$path" > a.sqlite-source-committed.txt
sha256sum a.sqlite-source-committed.txt
cmp a.sqlite-source-config.txt a.sqlite-source-committed.txt
cp a.sqlite-source-committed.txt "$path"
digest=$(sha256sum a.sqlite-source-committed.txt | cut -d ' ' -f 1)
printf 'CPLX-CLOSURE-ENVELOPE/1\ndigest|%s\nsource|%s|%s\n' \
    "$digest" "$path" "$source_sha" > src/setups/env/closure/closure-envelope.txt
```

`a.sqlite-source-config.txt` is the locally approved declaration used for the
creation-time byte comparison. Subsequent readers can compare the extracted
blob directly with the tracked declaration instead. To verify consistency and
authority without publishing anything, run:

```sh
source src/setups/env/bin/closure_config.sh
source src/setups/env/bin/closure_publish.sh
closure_envelope_check src/setups/env/closure/closure-config.txt \
    src/setups/env/closure/closure-envelope.txt
closure_config_authority_check "$PWD" src/setups/env/closure/closure-config.txt \
    src/setups/env/closure/closure-envelope.txt
```

After the bundle passes review and its grouped commit gate, the authorized
`git merge -s ours --no-ff` retains the source snapshot as an ancestor while
preserving the complete reviewed tree. A temporary `pre-merge-commit` calls
the existing `pre-commit`; Git also runs `commit-msg`. Record identical tree
IDs, hook traces and successful source resolution and authority checks from
a fresh single-branch clone before dropping the temporary source ref/worktree.
The implementation validation record holds the actual merge and clone evidence.

Item 7 must record both its final candidate cplx revision and this separate
envelope source revision. An all-ancestor traversal can encounter the source
snapshot with its previous envelope; only the reviewed branch bundle is a
delivery candidate. Item 7 must renew the pair and repeat final-archive
acceptance if it changes the permitted Python version or declaration. Step 3's
static fixtures do not establish dynamic SQLite capability or Step 4 acceptance.
