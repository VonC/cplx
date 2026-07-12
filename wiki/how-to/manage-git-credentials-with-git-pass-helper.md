# How to manage git credentials with git-pass-helper

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

Goal: store, use, diagnose and, when a passphrase is lost, fully reset
the git credentials that `git-pass-helper.sh` keeps encrypted on a
build or deployed account.

The helper ships with the git tools
(`src/install/env/git/bin/git-pass-helper.sh`, promoted to
`~/tools/git/bin`) and plugs into git through:

```bash
git config -l | grep cred
# credential.helper=!~/tools/git/bin/git-pass-helper.sh $@
```

## How a credential flows through the helper

- On a push, git calls the helper's `get` with `protocol=` and `host=`
  lines on stdin. The helper decrypts
  `~/.secure/git-pass/<uid>/<host>.asc` and hands the stored
  `username=`/`password=` back to git. On a successful interactive
  authentication, git calls `store`, which encrypts what you typed
  into that same file.
- `<uid>` comes from `GIT_LOGIN`, then `GPG_UID`, then
  `GIT_AUTHOR_EMAIL`, then `USER`, first one set. One account can hold
  several uids (a corporate login and a public one such as `VonC`,
  for instance), each with its own GPG key pair and credential files.
- The GPG side lives in `GNUPGHOME=~/tools/certs`: the key pairs, the
  agent configuration (`gpg-agent.conf`), the pinentry wrapper, and
  the agent log (`gpg.log`).
- Decryption goes through `gpg-agent`, which caches the key passphrase
  for 24 hours (`default-cache-ttl` and `max-cache-ttl` 86400): you
  type the passphrase at most once a day, on the terminal, through
  `pinentry-tty`.

## Everyday commands for git-pass-helper

List what is stored:

```bash
git-pass-helper.sh list
```

Store credentials for a host (prefer letting `git push` prompt you
once and call `store` itself: a `printf` command line leaves the token
in the shell history):

```bash
printf "protocol=https\nhost=<host>\nusername=<user>\npassword=<token>\n" \
  | GIT_LOGIN=<uid> git-pass-helper.sh store
```

Check retrieval without pushing (prints the decrypted lines):

```bash
printf "protocol=https\nhost=<host>\n" | GIT_LOGIN=<uid> git-pass-helper.sh get
```

Erase one host's credentials:

```bash
printf "protocol=https\nhost=<host>\n" | GIT_LOGIN=<uid> git-pass-helper.sh erase
```

## The pinentry chain and its two traps

When the agent cache is empty, gpg-agent launches the program named by
`pinentry-program` in `~/tools/certs/gpg-agent.conf` to prompt on your
terminal. Two traps can break that launch, both fixed at the source:

1. GnuPG expands no variable in conf files: a
   `pinentry-program ${HOME}/...` line reaches `exec` verbatim and
   fails with `No pinentry`. The line must carry an absolute path; the
   installer's relocation text pass rewrites its `/home/<user>/`
   anchor on deployment.
2. The relocated `pinentry-tty` (under `tools/git/root/usr/bin`) needs
   `tools/git/root/usr/lib64` on the loader path, and gpg-agent execs
   it with no login environment. `pinentry-wrapper.sh`, shipped next
   to `gpg-agent.conf`, sets `LD_LIBRARY_PATH` and hands over; the
   conf points at the wrapper, never at the bare binary.

Both traps stay invisible while the 24-hour cache holds the
passphrase: they surface only when the agent restarts, so test the
prompt explicitly after touching this chain:

```bash
export GNUPGHOME=~/tools/certs GPG_TTY=$(tty)
gpg-connect-agent UPDATESTARTUPTTY /bye
gpg --homedir ~/tools/certs --decrypt ~/.secure/git-pass/<uid>/<host>.asc >/dev/null && echo DECRYPT-OK
```

A passphrase prompt must appear in the terminal; `DECRYPT-OK` also
means the cache is primed for the day.

## Fully reset when the passphrase is lost

A GPG passphrase cannot be recovered or removed without knowing it.
The way out is to recreate the key and re-store the credentials, which
only requires the git token (re-issued by the git server if needed).
Validated sequence:

1. See what is stored for the uid, so you know what to re-store:

   ```bash
   git-pass-helper.sh list
   ```

2. Delete the old key pair (the prompts ask twice for the secret key,
   then once for the public key; a second run finishes the public half
   when the first stops after the secret one):

   ```bash
   gpg --homedir ~/tools/certs --delete-secret-and-public-key <uid>
   ```

3. Remove the credential files encrypted to the dead key:

   ```bash
   rm -rf ~/.secure/git-pass/<uid>
   ```

4. Recreate the key and re-store in one go: run `git push`, let it
   prompt for username and token, and the helper creates the key
   (interactive choice: with or without a passphrase) then stores the
   credentials. The `printf ... | GIT_LOGIN=<uid> git-pass-helper.sh
   store` form works too, at the cost of the token landing in the
   shell history.

5. Prime the cache with the decrypt test of the previous section.

Choosing "no passphrase" at step 4 removes the prompt forever, but
leaves the token protected only by the file permissions of
`~/tools/certs` and `~/.secure`: make that a conscious decision.

## Troubleshooting the credential chain

| Symptom | Cause | Fix |
| --- | --- | --- |
| `No pinentry`, log shows `can't connect to the PIN entry module '${HOME}/...'` | conf carries the unexpanded literal | absolute `pinentry-program` path (the wrapper) |
| `No pinentry`, wrapper path correct | `pinentry-tty` missing its `libsecret-1.so.0` | launch through `pinentry-wrapper.sh`, never the bare binary |
| `Bad passphrase` after three prompts | wrong or forgotten passphrase | the full reset above |
| `Timeout` on the prompt | prompt sat unanswered (pinentry-tty waits on the tty) | rerun the command and answer |
| Pushes worked for months, then `No pinentry` out of nowhere | the long-lived agent held the cache and masked a broken pinentry; something killed the agent | fix the chain, prime the cache; keep maintenance scripts from killing `gpg-agent` |

The agent tells the whole story itself: `debug-level basic` and
`log-file` are set in the shipped conf, so
`tail -n 60 ~/tools/certs/gpg.log` shows the exact pinentry path the
agent tried and every failed decrypt.
