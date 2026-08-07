# Python versions by distribution

<img src="../assets/logo-cplx-download-transparent.png" alt="" height="90" align="right">

What the distributions officially offer, and what upstream currently
publishes. This is the reference behind
[Why recompile at all](../explanation/why-recompile.md): every line
below is a version somebody else decided, and the gaps are why cplx
compiles its own.

Checked on 2026-08-07. Every row carries the page that proves it, so
the table can be re-checked rather than trusted.

## Upstream Python lines

| Line | Latest | Released | Phase | End of life |
| --- | --- | --- | --- | --- |
| 3.9 | 3.9.25 (RHEL build) | see distro | upstream ended Oct 2025 | vendor-maintained only |
| 3.11 | see downloads page | 2022 | security-only | Oct 2027 |
| 3.12 | see downloads page | 2023 | security-only | Oct 2028 |
| 3.13 | 3.13.15 | 2026-08-05 | bugfix until ~Oct 2026 | Oct 2029 |
| 3.14 | 3.14.7 | 2026-08-05 | bugfix until ~Oct 2027 | Oct 2030 |

Maintenance releases never add features: a `X.Y.Z` bump buys bugfixes
and security fixes only. Check both facts on
[python.org downloads](https://www.python.org/downloads/) and
[the version status table](https://devguide.python.org/versions/).

## What each distribution ships

| Distribution | Default `python3` | Other official interpreters | 3.13? | Where to check |
| --- | --- | --- | --- | --- |
| RHEL 9 (through 9.8) | 3.9 | 3.11, 3.12, and 3.14 added in 9.8 (free-threading build in CRB) | no, skipped | [Installing and using Python (RHEL 9)](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/installing_and_using_dynamic_programming_languages/assembly_installing-and-using-python_installing-and-using-dynamic-programming-languages), [RHEL 9 package manifest](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/package_manifest/index) |
| RHEL 10 (through 10.2) | 3.12 | 3.14 added in 10.2 | no, skipped | [Installing and using Python (RHEL 10)](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/installing_and_using_dynamic_programming_languages/installing-and-using-python) |
| EPEL 9 (community, not Red Hat supported) | n/a | 3.13 | yes | [Install Python 3.13 on RHEL from EPEL](https://developers.redhat.com/articles/2025/09/22/install-python-313-red-hat-enterprise-linux-epel) |
| Fedora 43 and later | 3.14 on Fedora 44 | several parallel streams | yes | [Fedora packages](https://packages.fedoraproject.org/pkgs/python3.14/python3.14/) |
| Debian 12 bookworm | 3.11.2 | none | no | [bookworm python3](https://packages.debian.org/bookworm/python3) |
| Debian 13 trixie | 3.13.5 | none | yes | [python3.13 across suites](https://packages.debian.org/search?keywords=python3.13&searchon=names&suite=all&section=all) |

Two conventions explain most of the surprises in that table.

- On RHEL the *default* interpreter is frozen for the life of the major
  release (3.9 for the whole of RHEL 9, to 2032) and is the one the
  operating system itself uses. Newer interpreters arrive as optional
  application streams, installed alongside it by an administrator, and
  each stream has its own support window: the `python3.14` stream of
  RHEL 9.8 is supported through May 2029. Red Hat picks which upstream
  lines to carry and skipped both 3.10 and 3.13
  ([What's new in Python 3.14](https://developers.redhat.com/articles/2026/07/11/whats-new-in-python-3-14)).
- On Debian a stable release carries exactly one Python 3 version for
  its whole life, so the only way to a newer interpreter is the next
  Debian release (or a backport, when one exists).

## What this means for cplx

An unprivileged account cannot install an application stream anyway, so
the practical question is not "what could an administrator install?"
but "what is already there?". On a RHEL 9.8 server that is Python 3.9,
and on a Debian 12 container Python 3.11. Any project needing a newer
line has three options, the same three as for any missing piece
([Where a sandbox file comes from](../explanation/where-a-sandbox-file-comes-from.md)):
unpack an official package payload into a prefix when one exists for
that version, copy what the server has, or compile the interpreter.

For the 3.13 line specifically, no official package exists on either
RHEL 9 or Debian 12, which leaves compiling as the only route, and is
the reason cplx carries Python as a tool at all.

## 👉 Where to look next

- [Why recompile at all](../explanation/why-recompile.md): the reasoning
  this table supports.
- [Update a tool version](../how-to/update-a-tool-version.md): how to
  move cplx to another version once you picked one.
- [CPLX variables](cplx-variables.md): where the chosen version lives
  (`CPLX_VERSION`, `CPLX_URL`).
