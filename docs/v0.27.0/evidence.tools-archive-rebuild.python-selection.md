# Python selection for the tools candidate, 2026-09-17

Select `CPLX_VERSION=3.13.15` explicitly. The Step 1 backend proof passed
before this review and refresh. This bounded review found no relevant blocking
3.13.15 regression that justifies 3.13.14; inconclusive findings do not select
the fallback. This decision does not replace the candidate's build, SQLite or
platform acceptance.

The review covered the [official release page](https://www.python.org/downloads/release/python-31315/),
the [source directory](https://www.python.org/ftp/python/3.13.15/),
the [release announcement](https://blog.python.org/2026/08/python-3147-31315/),
and CPython issue searches for 3.13.15 regressions, SQLite, SSL and crashes.
[Issue 156512](https://github.com/python/cpython/issues/156512) reports duplicate
`asyncio.connection_lost` calls when `resume_writing` closes the transport;
its reproduction also affects 3.13.14 and earlier releases, so reverting one
patch would not fix it. [Issue 156399](https://github.com/python/cpython/issues/156399)
concerns module attribute descriptors in 3.14 and later and explicitly reports
3.13.15 as unaffected.

| Official source | Bytes | SHA-256 |
| --- | --- | --- |
| `Python-3.13.15.tar.xz` | 23160540 | `1e66a7945a48390ee4c2a4268a0e4185884059a13c4aab6d148aa208deea4a76` |
| `Python-3.13.15.tgz` | 30106468 | `c28d9d213c09b5b5ab2c29812950e12f746999e099b82894231be954b26baed9` |

The isolated build input named `python-src-3.13.15.tar.gz` matched the official
TGZ size and SHA-256 before the refresh. The build acceptance driver also
compares the selected source archive and RPM payloads before and after the
reconfiguration build. The final candidate record binds this dated decision
to the resulting archive; no automatic tag selection is used.
