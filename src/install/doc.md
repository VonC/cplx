# Install process

## configure step

https://rpm.pbone.net/index.php3

### `libc_nonshared.a`: proper `--sysroot` in `LDFLAGS`

`cplx/tools/root/usr/bin/ld: cannot find /usr/lib64/libc_nonshared.a` means: glibc-devel

And:

```bash
[CPLX-DEV] vonc@voncfm:~/tools/tool/sources$ LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64 gcc t.c
/home/vonc/cplx/tools/root/usr/bin/ld: cannot find /usr/lib64/libc_nonshared.a
collect2: error: ld returned 1 exit status
```

`LD_LIBRARY_PATH` is used by the dynamic linker at runtime, not by `ld` during the link phase.  
The `gcc` you are using was built with built‑in search paths (in this case, `/usr/lib64` for `libc_nonshared.a`), so even if `LD_LIBRARY_PATH` contains the file, `ld` does not consider it when resolving static library dependencies. 

To override this behavior, you could pass additional library search directories via `LDFLAGS` (using the `-L` flag) when invoking gcc or modify the gcc spec file.

https://stackoverflow.com/questions/16710047/usr-bin-ld-cannot-find-lnameofthelibrary

```bash
ld -lc_nonshared --verbose
...
attempt to open //usr/x86_64-redhat-linux/lib64/libc_nonshared.so failed
attempt to open //usr/x86_64-redhat-linux/lib64/libc_nonshared.a failed
attempt to open //usr/lib64/libc_nonshared.so failed
attempt to open //usr/lib64/libc_nonshared.a failed
attempt to open //usr/local/lib64/libc_nonshared.so failed
attempt to open //usr/local/lib64/libc_nonshared.a failed
attempt to open //lib64/libc_nonshared.so failed
attempt to open //lib64/libc_nonshared.a failed
attempt to open //usr/x86_64-redhat-linux/lib/libc_nonshared.so failed
attempt to open //usr/x86_64-redhat-linux/lib/libc_nonshared.a failed
attempt to open //usr/local/lib/libc_nonshared.so failed
attempt to open //usr/local/lib/libc_nonshared.a failed
attempt to open //lib/libc_nonshared.so failed
attempt to open //lib/libc_nonshared.a failed
attempt to open //usr/lib/libc_nonshared.so failed
attempt to open //usr/lib/libc_nonshared.a failed
ld: cannot find -lc_nonshared

ld -lc_nonshared --verbose --sysroot="/home/vonc/cplx/tools/root"

attempt to open /home/vonc/cplx/tools/root/usr/x86_64-redhat-linux/lib64/libc_nonshared.so failed
attempt to open /home/vonc/cplx/tools/root/usr/x86_64-redhat-linux/lib64/libc_nonshared.a failed
attempt to open /home/vonc/cplx/tools/root/usr/lib64/libc_nonshared.so failed
attempt to open /home/vonc/cplx/tools/root/usr/lib64/libc_nonshared.a succeeded
ld: warning: cannot find entry symbol _start; not setting start address
```

Note: `--sysroot="/home/vonc/cplx/tools/root"` will fail, while `--sysroot=/home/vonc/cplx/tools/root` will work!

### `stdio.h: No such file or directory`: glibc-headers

`conftest.c:10:10: fatal error: stdio.h: No such file or directory` => see glibc-headers

### `linux/limits.h: No such file or directory`: kernel-headers

`/home/vonc/cplx/tools/root/usr/include/bits/local_lim.h:38:10: fatal error: linux/limits.h: No such file or directory`: see kernel-headers

### `ncursesw/panel.h: No such file or directory`: ncurses-devel

```bash
configure:26274: gcc -c -DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=/home/vonc/cplx/tools/root -fPIC -O -U_FORTIFY_SOURCE -m64 -I/home/vonc/cplx/tools/root/usr/include   conftest.c >&5
conftest.c:468:10: fatal error: ncursesw/panel.h: No such file or directory
 #include <ncursesw/panel.h>
 ```

### `openssl/ssl.h: No such file or directory`

```bash
collect2: error: ld returned 1 exit status
conftest.c:449:10: fatal error: openssl/ssl.h: No such file or directory
configure:28229: error: --with-openssl-rpath "/home/vonc/cplx/tools/python/python-v3.13.1/usr/lib64" is not a directory
```


