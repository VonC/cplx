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

### `openssl/ssl.h: No such file or directory`: openssl-devel

```bash
collect2: error: ld returned 1 exit status
conftest.c:449:10: fatal error: openssl/ssl.h: No such file or directory
configure:28229: error: --with-openssl-rpath "/home/vonc/cplx/tools/python/python-v3.13.1/usr/lib64" is not a directory
```

openssl-devel

## Compilation step

### `python undefined reference to __popcountdi2`: `-march=x86-64 -msse4.2`

```bash
gcc -std=gnu11 -c -fno-strict-overflow -Wsign-compare -DNDEBUG -g -O3 -Wall -DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=/home/gitea2/cplx/tools/root -fPIC -O -U_FORTIFY_SOURCE -m64 -DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=/home/gitea2/cplx/tools/root -fPIC -O -U_FORTIFY_SOURCE -m64  -std=c11 -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -Wstrict-prototypes -Werror=implicit-function-declaration -fvisibility=hidden  -I./Include/internal -I./Include/internal/mimalloc  -I. -I./Include -I/home/gitea2/cplx/tools/root/usr/include -I/home/gitea2/cplx/tools/root/usr/include -fPIC -DPy_BUILD_CORE -o Programs/_freeze_module.o Programs/_freeze_module.c
gcc -std=gnu11 -c -fno-strict-overflow -Wsign-compare -DNDEBUG -g -O3 -Wall -DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=/home/gitea2/cplx/tools/root -fPIC -O -U_FORTIFY_SOURCE -m64 -DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=/home/gitea2/cplx/tools/root -fPIC -O -U_FORTIFY_SOURCE -m64  -std=c11 -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -Wstrict-prototypes -Werror=implicit-function-declaration -fvisibility=hidden  -I./Include/internal -I./Include/internal/mimalloc  -I. -I./Include -I/home/gitea2/cplx/tools/root/usr/include -I/home/gitea2/cplx/tools/root/usr/include -fPIC -DPy_BUILD_CORE -o Modules/getpath_noop.o Modules/getpath_noop.c
gcc -std=gnu11 -L/home/gitea2/cplx/tools/root/usr/lib64 -L/home/gitea2/cplx/tools/root/lib64 -nodefaultlibs -Wl,-rpath,/home/gitea2/cplx/tools/root/usr/lib64:/home/gitea2/cplx/tools/root/lib64 -Wl,--export-dynamic -lc_nonshared -ldl -lc -lm -lc_nonshared -lpthread -B/home/gitea2/cplx/tools/root/usr  -B/home/gitea2/cplx/tools/root -B/home/gitea2/cplx/tools/root/usr/lib64 --sysroot=/home/gitea2/cplx/tools/root -L/home/gitea2/cplx/tools/root/usr/lib64 -L/home/gitea2/cplx/tools/root/lib64 -nodefaultlibs -Wl,-rpath,/home/gitea2/cplx/tools/root/usr/lib64:/home/gitea2/cplx/tools/root/lib64 -Wl,--export-dynamic -lc_nonshared -ldl -lc -lm -lc_nonshared -lpthread -B/home/gitea2/cplx/tools/root/usr  -B/home/gitea2/cplx/tools/root -B/home/gitea2/cplx/tools/root/usr/lib64 --sysroot=/home/gitea2/cplx/tools/root   -o Programs/_freeze_module Programs/_freeze_module.o Modules/getpath_noop.o Modules/getbuildinfo.o Parser/token.o  ... -ldl -Wl,-rpath,/home/gitea2/cplx/tools/root/usr/lib64:/home/gitea2/cplx/tools/root/lib64 -Wl,--export-dynamic -lc_nonshared -ldl -lc -lm -lc_nonshared -lpthread -lutil                          -lm
Objects/longobject.o: In function `_Py_popcount32':
/home/gitea2/cplx/tools/python/sources/current/./Include/internal/pycore_bitutils.h:101: undefined reference to `__popcountdi2'
/home/gitea2/cplx/tools/python/sources/current/./Include/internal/pycore_bitutils.h:101: undefined reference to `__popcountdi2'
Python/hamt.o: In function `_Py_popcount32':
/home/gitea2/cplx/tools/python/sources/current/./Include/internal/pycore_bitutils.h:101: undefined reference to `__popcountdi2'
/home/gitea2/cplx/tools/python/sources/current/./Include/internal/pycore_bitutils.h:101: undefined reference to `__popcountdi2'
/home/gitea2/cplx/tools/python/sources/current/./Include/internal/pycore_bitutils.h:101: undefined reference to `__popcountdi2'
Python/hamt.o:/home/gitea2/cplx/tools/python/sources/current/./Include/internal/pycore_bitutils.h:101: more undefined references to `__popcountdi2' follow
collect2: error: ld returned 1 exit status
make: *** [Programs/_freeze_module] Error 1
++ pwd
+ fatal 'Unable to make all in '\''/home/gitea2/cplx/tools/python/sources/
```

To check a symbol:

```bash
find /usr/lib -name "*.a" -o -name "*.so" -exec nm -A {} \; 2>/dev/null | grep __popcountdi2
locate __popcountdi2

~/tools/root$ find . -type f -name "*.so.[0-1]" -o -name "*.so" -o -name "*.a" 2>/dev/null | xargs nm -A -u 2>/dev/null | grep popc
find . -type f -name "*.so.[0-1]" -o -name "*.so" -o -name "*.a" 2>/dev/null | xargs nm -A -u 2>/dev/null | grep -i popc
./usr/lib/gcc/x86_64-redhat-linux/4.8.2/32/libgcov.a:_gcov.o:         U __popcountsi2
./usr/lib/gcc/x86_64-redhat-linux/4.8.2/32/libgomp.a:affinity.o:         U gomp_cpuset_popcount
./usr/lib/gcc/x86_64-redhat-linux/4.8.2/libgcov.a:_gcov.o:                 U __popcountdi2
./usr/lib/gcc/x86_64-redhat-linux/4.8.2/libgomp.a:affinity.o:                 U gomp_cpuset_popcount

~/tools/root$ grep -nRHIi popc[no] * 2>/dev/null
```

https://stackoverflow.com/questions/52161596/why-is-builtin-popcount-slower-than-my-own-bit-counting-function

> Without specifying an appropriate "-march" on the command line gcc generates a call to the `__popcountdi2` function rather than the `popcnt` instruction. See: https://godbolt.org/z/z1BihM
>
> POPCNT is supported by Intel since Nehalem and AMD since Barcelona according to wikipedia: https://en.wikipedia.org/wiki/SSE4#POPCNT_and_LZCNT

https://stackoverflow.com/questions/27252630/linker-error-hidden-symbol-popcountdi2: This can be fixed with '-shared-libgcc' linked option

See https://github.com/python/cpython/blob/c6b292cdeee689f0bfac6c1e2c2d4e4e01fa8d9e/Include/internal/pycore_bitutils.h#L87-L131 uses __builtin_popcount(x);

`export CFLAGS="-DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=${root} -fPIC -O -U_FORTIFY_SOURCE -m64"` means -march is specified: 64.

<!--- cSpell:disable --->
```bash
~/tools/root$ cat /proc/cpuinfo|grep -i arc
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon nopl xtopology tsc_reliable nonstop_tsc eagerfpu pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single ssbd rsb_ctxsw ibrs ibpb stibp ibrs_enhanced fsgsbase tsc_adjust bmi1 avx2 smep bmi2 invpcid rdseed adx smap xsaveopt arat md_clear spec_ctrl intel_stibp flush_l1d arch_capabilities
```
<!--- cSpell:enable --->

https://github.com/python/cpython/issues/81476: If I recompile with `-msse4.2`, then the POPCNT instruction *is* used, and I get an even more marginal improvement: a 1.7% speedup over the lookup-table-based version.

Note:

```bash
~/tools/root/usr/lib64/pkgconfig$ more ncursesw.pc
# vile:makemode

prefix=/usr
exec_prefix=/usr
libdir=/usr/lib64
includedir=/usr/include
major_version=5
version=5.9.20130511
```

Might need to replace paths...

This worked on cacreg, on RHEL 8.10 gcc (GCC) 8.5.0 20210514 (Red Hat 8.5.0-22)
```bash
gcc -pthread     -o Programs/_freeze_module Programs/_freeze_module.o Modules/getpath_noop.o Modules/getbuildinfo.o Parser/token.o ... -lpthread -ldl  -lutil                        -lm
```

https://github.com/python/cpython/blob/main/Include/internal/pycore_bitutils.h

CPUID is not used, to test if x86 POPCNT instruction can be used, to keep the implementation simple.  
For example, Visual Studio __popcnt() is not used this reason.  
The clang and GCC builtin function can use the x86 POPCNT instruction if the target architecture has SSE4a or newer.

-    export CFLAGS="-DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=${root} -fPIC -O -U_FORTIFY_SOURCE -m64"
+    export CFLAGS="-DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=${root} -fPIC -O -U_FORTIFY_SOURCE -m64 -march=x86-64 -msse4.2"