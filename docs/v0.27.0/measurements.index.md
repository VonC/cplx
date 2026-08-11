# Measurement evidence for the rsync-cp-fallback review

Round 2 of the design review asked for M1, M2 and M3 to be measured before it
resumed, and for the raw outputs of both supported targets to be retained. They
are the `measurements.*.txt` files beside this index. This page carries the
complete M1 and M2 matrices and the scoped M3 result under "Measurement
answers", and says which raw file each row came from, so a reviewer can act
without opening all eight. Two probes are kept beside their outputs and are
rerunnable: `probe.manifest-forms.sh`, whose exit status is a gate, and
`probe.mtime-engines.sh`.

## Where each measurement lives

| File | Measurements | Host | Captured |
| --- | --- | --- | --- |
| `measurements.destination-shape.rhel.txt` | M1, M2 (both engines), M3 | RHEL 9.8 deployment server | 2026-08-09, by hand |
| `measurements.destination-shape.debian.txt` | M2 (copy engine only) | Debian 12 CI agent, build 32 | 2026-08-10, pipeline |
| `measurements.copy-form.rhel.txt` | M4, all three forms | RHEL 9.8 deployment server | 2026-08-10, by hand |
| `measurements.copy-form.debian.txt` | M4, all three forms | Debian 12 CI agent, build 32 | 2026-08-10, pipeline |
| `measurements.mirror-root.debian.txt` | transfer-root metadata, Q02 | Debian 12 CI agent, build 30 | 2026-08-09, pipeline |
| `measurements.installer-contract.debian.txt` | command and behavior contract, D4 | Debian 12 CI agent, build 30 | 2026-08-09, pipeline |
| `measurements.manifest-forms.rhel.txt` | C1 fractional mtime, C2 tool presence, C3 the exact manifest forms | RHEL 9.8 deployment server | 2026-08-11, by hand. Supersedes an earlier same-day capture taken before every C2 and C3 assertion fed the probe exit status |
| `measurements.mtime-engines.rhel.txt` | whether a fractional source mtime survives each engine, and whether the rsync quick check skips a populated destination | RHEL 9.8 deployment server, rsync 3.2.5 | 2026-08-11, by hand |

The two hosts are the supported targets of the archive: RHEL 9.8 with coreutils
8.32 and rsync 3.2.5, and the CI agent on Debian 12 with coreutils 9.1 and no
rsync at all. Every file names its own environment in its first lines.

## Measurement answers

Every measured shape has a row below, including the ones whose outcome is dull,
because a shape absent from the matrix cannot be told apart from one that was
never run. The rows are transcribed from the raw files named above, and each one
can be checked against its `--- M1 case:` or `--- M2 engine` block there.

### M1: `rsync -av --delete src/ dst/`, nine destination shapes

Measured on RHEL 9.8 with rsync 3.2.5. The Debian agent has no rsync, so M1
cannot be measured there and its file says so rather than skipping quietly.

| Destination shape | Exit | Destination after | External target | Outcome |
| --- | --- | --- | --- | --- |
| absent | 0 | directory | n/a | created, mirrors the source |
| empty real directory | 0 | directory | n/a | mirrors the source |
| populated real directory | 0 | directory | n/a | mirrors the source, the three stale entries deleted |
| regular file | 3 | regular file | n/a | refused, `cannot stat destination`, destination untouched |
| symlink to empty directory | 0 | symlink, followed | changed | wrote through the link into the external directory |
| symlink to populated directory | 0 | symlink, followed | changed | wrote through the link and deleted the external content |
| symlink to regular file | 3 | symlink, followed | unchanged | refused, `cannot stat destination` |
| dangling symlink | 11 | symlink, followed | n/a | refused, `mkdir failed: File exists` |
| FIFO | 3 | fifo | n/a | refused, `cannot stat destination` |

The three real-directory shapes all succeed and all end up mirroring the source.
The one destructive row is the symlink to a populated directory: exit 0, nothing
in the diagnostic to distinguish it from the ordinary case, and the external
content gone.

### M2: `rsync -av file prefix/` against `cp -a file prefix/`, eight shapes

Both engines, every shape, measured on RHEL 9.8. The shape named is that of
`prefix/<basename>` before the engine runs.

| Prefix entry shape | rsync exit | rsync result | cp exit | cp result |
| --- | --- | --- | --- | --- |
| absent | 0 | file created | 0 | file created |
| regular file | 0 | overwritten in place | 0 | overwritten in place |
| empty directory | 0 | directory replaced by the file | 1 | refused, directory intact |
| populated directory | 23 | refused, directory intact | 1 | refused, directory intact |
| symlink to directory | 0 | link replaced by the file, target untouched | 1 | refused, link and target intact |
| symlink to regular file | 0 | link replaced by the file, target untouched | 0 | link kept, external target overwritten |
| dangling symlink | 0 | link replaced by the file | 1 | refused, link intact |
| FIFO | 0 | FIFO replaced by the file | 124 | blocked, killed at 20s, FIFO intact |

The two engines agree on two shapes of eight. On five, rsync replaces what the
copy engine refuses. On one, the symlink to a regular file, they differ in the
way that matters: both return exit 0, but rsync replaces the link and leaves the
external file alone, while the copy engine keeps the link and overwrites the
file behind it.

The Debian agent reproduced the whole `cp` column identically under coreutils
9.1, against 8.32 on RHEL, so nothing in that column is version sensitive. Its
rsync column reads unavailable throughout, which is the Q19 evidence.

### M3: `<prefix>/tools` on real deployment prefixes

| Prefix | `<prefix>/tools` | Mode | Symlink |
| --- | --- | --- | --- |
| `/home/deploy-account` | real directory | `drwxrwxr-x+`, extended ACL | no |
| `/project/middleware1/refer/deploy-group` | real directory | `drwxr-xr-x.`, SELinux context | no |

Prefixes inspected: 2, corrected 2026-08-11. This entry previously said 1 and
listed only the first row, while the raw output it indexes records
"prefixes inspected: 2" and both rows. The correction was found when the
sensitive-term substitution pass opened the raw file. Both prefixes hold a real
directory, which is the shape both engines handle identically, and every other
prefix is still uninspected. The trailing `+` on the first is an extended ACL
and the trailing `.` on the second is an SELinux context: two different pieces
of the metadata class the equivalence deliberately excludes, both present in
production.

### M4: three root-file copy forms, eight shapes, both targets

The question was whether a copy form exists that closes the check-then-copy
window structurally, rather than narrowing it. Measured on RHEL 9.8 with
coreutils 8.32 and on the Debian agent with 9.1. The two targets agree in every
one of the twenty-four cells, so one table covers both; only the timings differ.

| Destination shape | F1 `cp -a` | F2 `--remove-destination` | F3 copy then `mv -f` |
| --- | --- | --- | --- |
| absent | file created | file created | file created |
| regular file | overwritten in place | overwritten in place | replaced |
| empty directory | nested inside, exit 0 | nested inside, exit 0 | nested inside as `.name.tmp`, exit 0 |
| populated directory | nested inside, exit 0 | nested inside, exit 0 | nested inside as `.name.tmp`, exit 0 |
| symlink to a regular file | followed, external target rewritten | link replaced, external target untouched | link replaced, external target untouched |
| symlink to a directory | followed, wrote into the external directory | followed, wrote into the external directory | followed, wrote into the external directory |
| dangling symlink | refused, exit 1 | link replaced by the file | link replaced by the file |
| FIFO | blocked, killed at 20 s | replaced in under 20 ms | replaced in under 30 ms |

The four cells the review named come out clean for both candidates. Against a
symlink to a regular file, F2 and F3 leave the external target byte-identical
with its mtime untouched, where F1 rewrites it. Against a FIFO, both replace it
in tens of milliseconds, where F1 blocks and is killed at twenty seconds.

Two shapes defeat both candidates, and neither was in the question. A symlink to
a directory is followed by all three forms: `--remove-destination` does not
unlink a link that points at a directory, and `mv -f` renames into the directory
the link points at. All three return exit 0 and write outside the prefix. A real
directory is not replaced by any of them either: with the explicit
`prefix/name` destination the forms use, the payload lands inside the directory
and the status is 0, and under F3 it lands there under the hidden temporary
name. That last point is a difference from M2 rather than a contradiction of it:
M2 measured `cp -a file prefix/`, which refuses a directory with exit 1, so the
explicit-name spelling is the less safe of the two.

## The result the requirement should act on

The two engines are unsafe in opposite places. On the mirror path rsync is the
destructive one, emptying an external directory through a link with exit 0. On
the root-file path the position reverses: rsync replaces the link, and a plain
copy follows it and overwrites the target, also with exit 0. A fallback built as
a plain copy is therefore safer than rsync on one path and more dangerous than
it on the other, and neither case is visible in an exit status.

One rule is correct on both paths: refuse a symlinked destination. On the mirror
path that makes the fallback safer than the engine it replaces; on the root-file
path it stops the fallback introducing a hazard rsync does not have. The
divergence it creates is from a different engine on each path, which is worth
stating in the requirement rather than leaving as an apparent inconsistency.

M3 adds that the refusal costs nothing on either prefix inspected, since both
carry a real directory.

M4 settles whether that refusal can be dropped in favour of a safer copy form,
and the answer is no. F2 and F3 close two of the four unsafe shapes, which is
worth having, but a symlink to a directory and a real directory both still end
with exit 0 and a payload written where it does not belong. A preflight
non-following type check is therefore still required, and the copy form cannot
carry the guarantee on its own. Between the two candidates F2 is the better
choice: it closes the same shapes as F3, it leaves nothing behind when it fails,
and it adds nothing to the host-tool contract, whereas F3 needs `mv`, which the
installer does not invoke today.

## Redaction and provenance

The M3 section of the RHEL file has its service account and group replaced by
`<account>` and `<group>`, which the review allows. The mode, the ACL marker,
the link count and the path shape are untouched, and they are what the
measurement establishes. Nothing else in any file was altered.

The Debian files are the build artifacts of develop#30, downloaded before the
pipeline rotated them: it keeps artifacts for one build only, so they had to be
copied out to be retained at all. That is the reason they live here rather than
being cited by build URL.

## What is not here

Two RHEL captures were read into the review thread rather than saved as files:
the installer contract check and the transfer-root check on the deployment
server. Their Debian counterparts are here, and their RHEL results are quoted in
the umbrella. Regenerating either takes one command on a host with access:

```sh
sh installer_contract_check.sh
sh installer_mirror_root_check.sh
```

## How to reproduce any of this

The probes live in the consuming project under `tools/`, and the same files run
on both targets, which is what makes the two columns comparable:

```sh
sh installer_destination_shape_check.sh                 # M1 and M2
sh installer_destination_shape_check.sh <prefix> ...    # adds M3, read only
sh installer_copy_form_check.sh                         # M4, no argument
```

The matrices above were transcribed by hand from the raw files, which were
captured before the probe could print them. The probe now ends with a
`measurement answers` section that emits the same three matrices from its own
records, one row per shape whatever the outcome, so any later run carries its
matrices inline and nothing has to be transcribed again.

M1 and M2 work entirely inside a scratch directory. M3 only reads: it runs `ls`,
`stat` and `readlink` on the prefixes named on the command line, and reports
itself unavailable when none is given.
