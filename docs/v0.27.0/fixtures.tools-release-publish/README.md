# Historical publication regression inputs

These two files are exact blobs from cplx commit
`3a1d1135a3e627b74d134db24694121e70ea6b14`, paths
`src/setups/env/closure/closure-config.txt` and
`src/setups/env/closure/closure-envelope.txt`.

The frozen closure Step 5 suite expects their active SQLite waiver. The current
declaration intentionally retired it. The preceding SQLite effort recorded
15 failures with the current pair and 254 passing controls with this original
pair in its [validation record](../plan.v0.27.0.python-sqlite-support.validation.md).

The tools runner checks these files' SHA-256, copies current implementation
scripts into an owned temporary tree, substitutes only this input pair, and
passes the tree through the harness's documented `--shipped-dir` selector.
It also runs the current SQLite declaration fixtures. No shipped declaration,
waiver policy, frozen harness or live installation is changed. These controls
do not establish candidate acceptance or current source ancestry.
