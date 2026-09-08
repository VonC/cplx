# The runtime-closure configuration bundle

This directory holds the declaration the v0.27.0 runtime-closure checker reads,
and it states the digest domain beside the data that domain governs, so a second
implementation cannot get the domain wrong by reading the code instead.

## The two parts, and only one of them is hashed

| Part | Content | In the digest |
| --- | --- | --- |
| `closure-config.txt` | the five declarations, one document | yes, and nothing else is |
| the identity envelope | the document's digest, and the cplx commit that holds it | no, so the digest never covers itself |

The envelope is NOT committed here, and cannot be: it names the commit SHA that
holds the document, a value that does not exist until that commit does.
Packaging produces it from the exact commit it is about to name and stages the
pair at `tools/closure/` inside the archive, as `closure-config.txt` and
`closure-envelope.txt`.

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
| packaging | yes | the document it embeds is byte-identical to the source at the commit it names | mismatch, or a source that is not a committed state |
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
`python-sqlite-support` removes the sqlite waiver rather than the floor entry,
and `tools-archive-rebuild` may add an entry if the rebuilt payload introduces
one.
