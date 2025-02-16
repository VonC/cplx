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

### `stdatomic.h`

https://github.com/python/cpython/issues/118034

CPython now requires #include <stdatomic.h> (an optional C11 feature) or MSVC. (Mimalloc can use C++ atomics, C11 atomics, or MSVC atomics. And pyatomic.h requires C11 atomics, MSVC atomics, or GCC atomics. The intersection is C11 or MSVC.)

This means CPython can't compile with GCC 4.8, as [C11 atomics were added in GCC 4.9](https://gcc.gnu.org/wiki/C11Status)

You can build CPython with GCC 4.8. Mimalloc is optional in the default build and is disabled by configure if stdatomic.h is not available.

### /lib64/liboneagentproc.so

Dynatrace OneAgent changed the "`/etc/ld.so.preload`" file in OS:

```bash
/$LIB/liboneagentproc.so

cat /etc/ld.so.preload
/lib64/liboneagentproc.so
```

"`/etc/ld.so.preload`" and env variable "`LD_PRELOAD`" are used to preload specified lib when starting new process.

=> For now, skip that check in install_package#check_ldd() `local exclude_tokens=("libm" "libc" "libdl" "ld-linux" "linux-vdso" "liboneagentproc")`

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

Implementation: https://web.mit.edu/freebsd/head/contrib/compiler-rt/lib/popcountdi2.c

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

### `undefined symbol: __umodti3`

```bash
[ERROR] _decimal failed to import: /home/vonc/cplx/tools/python/sources/v3.13.1/python-cpython-7795862/build/lib.linux-x86_64-3.13/_decimal.cpython-313-x86_64-linux-gnu.so: undefined symbol: __umodti3

find . -type f -name "*.so.[0-1]" -o -name "*.so" -o -name "*.a" 2>/dev/null | xargs nm -A -u 2>/dev/null | grep -i umodti3
```

https://bugzilla.mozilla.org/show_bug.cgi?id=1631627
https://issues.chromium.org/issues/41334980
https://gcc.gnu.org/onlinedocs/gccint/Integer-library-routines.html

Not blocking.

It seems you're encountering another undefined symbol error, this time with `__umodti3`. This function is related to 128-bit integer modulo division, which is not directly supported by some older CPUs.

Here's how you can determine which `compiler-rt` your GCC is using and address the `__umodti3` error:

**1. Check GCC's link options:**

* Use the `-###` flag to see the detailed commands GCC executes during compilation. This will reveal the libraries it's linking against, including `compiler-rt` if it's being used.

```bash
gcc -### -march=sse4.2... (rest of your compilation flags)
```

Look for a line similar to:

```
-lclang_rt.builtins-x86_64
```

This indicates that GCC is using `compiler-rt`. The exact library name might vary depending on your system and GCC configuration.

**2. Check for `compiler-rt` installation:**

* If the previous step confirms `compiler-rt` usage, locate its installation directory. It might be within your GCC installation or a separate location like `/usr/lib/clang/`.

**3. Address the `__umodti3` error:**

* **Upgrade GCC:** Newer GCC versions often include updated `compiler-rt` libraries with better support for extended integer operations. If possible, consider upgrading to a more recent GCC version.
* **Link `libgcc` explicitly:** In some cases, linking `libgcc` explicitly might resolve the issue, as it might contain the necessary definitions for `__umodti3`. Add `-lgcc` to your `LDFLAGS`.
* **Rebuild Python:** If you have access to the Python source code, rebuilding it with your updated GCC and `-march=sse4.2` flag might resolve the issue. This will ensure that the `_decimal` library is compiled with the necessary support for extended integer operations.

**Important notes:**

* **Compatibility:** If upgrading GCC or rebuilding Python is not feasible, you might need to explore alternative solutions or consider using a different Python version with better compatibility with your current environment.
* **Thorough investigation:** Carefully examine the output of the `-###` flag and the contents of your `compiler-rt` installation to pinpoint the exact cause of the error and identify the appropriate solution.

If you provide the output of the `-###` command and the location of your `compiler-rt` installation, I can offer more specific guidance.

No, `-lclang_rt.builtins-x86_64` should not be added to the `CLANG` variable. 

Here's why:

* **`CLANG`**: This variable usually specifies the path to the Clang compiler executable, not linker flags or libraries.
* **Linker flags**: `-lclang_rt.builtins-x86_64` is a linker flag that tells the linker to link against the `clang_rt.builtins-x86_64` library.

**Where to add it:**

You should add `-lclang_rt.builtins-x86_64` to your `LDFLAGS` variable. This variable is specifically for passing flags to the linker.

**How to add it:**

```bash
export LDFLAGS="$LDFLAGS -lclang_rt.builtins-x86_64"
```

This will append the flag to your existing `LDFLAGS`.

**Important notes:**

* **Order matters:** The order of flags in `LDFLAGS` can be important. If you encounter any issues, try placing `-lclang_rt.builtins-x86_64` at the end of the `LDFLAGS` string.
* **Recompile:** After modifying `LDFLAGS`, make sure to recompile your entire project to ensure the changes take effect.

If you're still encountering the `__umodti3` undefined symbol error after adding this flag, please provide the following information so I can assist you further:

* **Full GCC command line:** The complete command line you're using to compile your project.
* **Output of `-###` flag:** The output of running your GCC command with the `-###` flag.
* **`compiler-rt` location:** The directory where `compiler-rt` is installed on your system.

With this information, I can help you pinpoint the exact cause of the error and suggest the most appropriate solution.


Note: Fro gcc-8.5.0-22.el8.x86_64.list:

```bash
[CPLX-DEV] vonc@voncfm:~/tools/tool/root$ nm ./usr/lib/gcc/x86_64-redhat-linux/8/libgcc.a|grep mod
_moddi3.o:
0000000000000000 T __modti3
_divmoddi4.o:
0000000000000000 T __divmodti4
_umoddi3.o:
0000000000000000 T __umodti3
_udivmoddi4.o:
0000000000000000 T __udivmodti4
0000000000000000 B __cpu_model
```

So using `-lgcc_s` is key (see also https://gcc.gnu.org/bugzilla/show_bug.cgi?id=16470). with `-lgcc`, you would get:

```
5788 configure:14804: gcc -o conftest -DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=/home/vonc/cplx/tools/tool/root -fPIC -O -U_FORTIFY_SOURCE -m64 -march=x86-64 -msse4.2 -I/home/vonc/cplx/tools/tool/root/incl      ude -DCONFIG_64=1 -DANSI=1 -DHAVE_UINT128_T=1 -I/home/vonc/cplx/tools/tool/root/usr/include -L/home/vonc/cplx/tools/tool/root/usr/lib64 -L/home/vonc/cplx/tools/tool/root/usr/lib64 -L/home/vonc/cplx/tools      /tool/root/usr/lib -L/home/vonc/cplx/tools/tool/root/lib64 -L/home/vonc/cplx/tools/tool/root/lib -L/home/vonc/cplx/tools/tool/root/usr/lib/gcc/x86_64-redhat-linux/8 -nodefaultlibs -Wl,-rpath,/home/vonc/c      plx/tools/tool/root/usr/lib64:/home/vonc/cplx/tools/tool/root/usr/lib64:/home/vonc/cplx/tools/tool/root/usr/lib:/home/vonc/cplx/tools/tool/root/lib64:/home/vonc/cplx/tools/tool/root/lib -Wl,--export-dynamic -lc_nonshared -ldl -lgcc -lc -lm -lc_nonshared -lpthread -B/home/vonc/cplx/tools/tool/root -B/home/vonc/cplx/tools/tool/root/usr -B/home/vonc/cplx/tools/tool/root/usr/lib64 -B/home/vonc/cplx/tools/to      ol/root/usr/lib -B/home/vonc/cplx/tools/tool/root/lib64 -B/home/vonc/cplx/tools/tool/root/lib --sysroot=/home/vonc/cplx/tools/tool/root conftest.c -L/home/vonc/cplx/tools/tool/root/lib -lmpdec -L/home/vo      nc/cplx/tools/tool/root/lib64 -lm -L/home/vonc/cplx/tools/tool/root/usr/lib/gcc/x86_64-redhat-linux/8 -lgcc -ldl -Wl,-rpath,/home/vonc/cplx/tools/tool/root/usr/lib64:/home/vonc/cplx/tools/tool/root/lib64      :/home/vonc/cplx/tools/tool/root/lib:/home/vonc/cplx/tools/tool/root/usr/lib64:/home/vonc/cplx/tools/tool/root/usr/lib -Wl,--export-dynamic -lc_nonshared -ldl -lc -lm -lc_nonshared -lpthread >&5
 5789 /home/vonc/cplx/tools/tool/root/usr/bin/ld: conftest: hidden symbol `__umodti3' in /home/vonc/cplx/tools/tool/root/usr/lib/gcc/x86_64-redhat-linux/8/libgcc.a(_umoddi3.o) is referenced by DSO
 5790 /home/vonc/cplx/tools/tool/root/usr/bin/ld: final link failed: Bad value
 5791 collect2: error: ld returned 1 exit status
 ```
with:

```c
5943 | /* end confdefs.h.  */
 5944 |
 5945 |
 5946 |         #include <mpdecimal.h>
 5947 |         #if MPD_VERSION_HEX < 0x02050000
 5948 |         #  error "mpdecimal 2.5.0 or higher required"
 5949 |         #endif
 5950 |
 5951 | int
 5952 | main (void)
 5953 | {
 5954 | const char *x = mpd_version();
 5955 |   ;
 5956 |   return 0;
 5957 | }>
 ```

 -shared-libgcc? Or simply -lgcc_s, which works.

### Modules to activate:

```bash
The following modules are *disabled* in configure script:
_sqlite3

The necessary bits to build these optional modules were not found:
_bz2                      _ctypes                   _ctypes_test
_curses                   _curses_panel             _dbm
_gdbm                     _hashlib                  _lzma
_ssl                      _tkinter                  _uuid
readline                  zlib
To find the necessary bits, look in configure.ac and config.log.
```

### sqlite3

https://stackoverflow.com/questions/32779768/python-build-from-source-cannot-build-optional-module-sqlite3

This link provided the solution for me building Python 3.5.  Specifically for Ubuntu but helped figure it out for CentOS6 as well.

[Install missing packages before compiling Python3][1]


  [1]: https://stackoverflow.com/questions/12023773/python-3-3-source-code-setup-modules-were-not-found-lzma-sqlite3-tkinter

More specifically for Ubuntu server 16.04:

    apt-get -y install build-essential zlib1g-dev libbz2-dev liblzma-dev libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev libgdbm-dev liblzma-dev tk8.5-dev lzma lzma-dev libgdbm-dev

Note that none of these packages will be found on RedHat/Fedora.

possible include directories for sqlite3 is taken from setup.py (for Python-3.5.0):

To fix the issue, add in `/path/to/my/personal/sqlite/include` into the above sqlite_inc_paths array:
```ini
sqlite_inc_paths = ['/path/to/my/personal/sqlite/include',
                   ...]
```

### bz2

LDFLAGS and LIBS serve different purposes during the linking phase:

- **LDFLAGS** are passed to the linker to specify options such as library search paths (`-L/path/to/libs`), linker behavior (e.g., `-Wl,option`), and other flags that affect the linking process.

- **LIBS** are used to indicate which libraries to link against (e.g., `-lbz2`, `-lm`, etc.). They are typically appended after your object files so that the linker can resolve symbols.

For a RHEL 7 compilation with gcc 4.8.5, if your code uses functions from libbz2 (the bzip2 library), you would need to supply `-lbz2` in **LIBS**, but only if your build system doesn't already include it, or if the library is in a nonstandard location (in which case you’d also add an appropriate `-L` flag in LDFLAGS).

Usually, you add `-lbz2` in LIBS rather than LDFLAGS. In short, if your code requires libbz2, and it’s not automatically linked, add it to LIBS; there’s no need to specify it in LDFLAGS unless you also need to adjust the library search path.

=> I did not add -lbz2, it was still picked up, after installing bzip2, bzip2-libs and bzip2-devel packages

### ctypes: libffi

### openssl_hashlib

```bash
  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether OpenSSL provides required hashlib module APIs" >&5
printf %s "checking whether OpenSSL provides required hashlib module APIs... " >&6; }
if test ${ac_cv_working_openssl_hashlib+y}
then :
  printf %s "(cached) " >&6
else $as_nop

    cat confdefs.h - <<_ACEOF >conftest.$ac_ext
/* end confdefs.h.  */

      #include <openssl/opensslv.h>
      #include <openssl/evp.h>
      #if OPENSSL_VERSION_NUMBER < 0x10101000L
        #error "OpenSSL >= 1.1.1 is required"
```

But:

```bash
~/tools/root$ rgrep OPENSSL_VERSION_NUMBER
usr/share/doc/openssl-devel-1.0.2k/CHANGES:11285:  *) Added OPENSSL_VERSION_NUMBER to crypto/crypto.h and
usr/include/openssl/crypto.h:152:# define SSLEAY_VERSION_NUMBER   OPENSSL_VERSION_NUMBER
usr/include/openssl/opensslv.h:33:# define OPENSSL_VERSION_NUMBER  0x100020bfL
```

Your defined version (0x100020bfL) is lower than 0x10101000L. In other words, your OpenSSL version is older than the minimum expected (1.1.1 or newer).

=> Must recompile OpenSSL on RHEL 7.x!
https://gist.github.com/Bill-tran/5e2ab062a9028bf693c934146249e68c

```bash
yum install -y make gcc perl-core pcre-devel wget zlib-devel
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib no-shared zlib-dynamic
```

wget https://ftp.openssl.org/source/openssl-1.1.1k.tar.gz Now https://openssl-library.org/source/old/1.1.1/index.html: https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz

openssl-3.2.2.tar.gz
https://openssl-library.org/source/
https://github.com/openssl/openssl/releases/download/openssl-3.4.1/openssl-3.4.1.tar.gz

But: https://stackoverflow.com/questions/67972269/openssl-upgrade-centos-7/69187544#69187544
https://bugzilla.redhat.com/show_bug.cgi?id=1416715
https://bugzilla.redhat.com/show_bug.cgi?id=1792741 https://src.fedoraproject.org/rpms/openssl11
ftp://ftp.icm.edu.pl/packages/linux-pbone/archive.fedoraproject.org/epel/7.2020-10-05/x86_64/Packages/o/openssl11-libs-1.1.1c-2.el7.x86_64.rpm (https://rpm.pbone.net/info_idpl_71941238_distro_redhatel7_com_openssl11-libs-1.1.1c-2.el7.x86_64.rpm.html)

https://download.fedora.devel.redhat.com/pub/archive/epel/7.8/x86_64/Packages/o/openssl11-devel-1.1.1c-2.el7.x86_64.rpm
https://download.fedora.devel.redhat.com/pub/archive/epel/7.8/x86_64/Packages/o/openssl11-libs-1.1.1c-2.el7.x86_64.rpm


### decimal

https://gitlab.com/redhat/centos-stream/rpms/mpdecimal/-/blob/c8s/mpdecimal.spec?ref_type=heads
http://www.bytereef.org/software/mpdecimal/releases/mpdecimal-2.5.1.tar.gz

To hope resolve:

```bash	
configure:14675: checking for --with-system-libmpdec
configure:14686: result: yes
configure:14695: checking for libmpdec >= 2.5.0
configure:14756: result: no
configure:14761: error: libmpdec >= 2.5.0 not found https://www.bytereef.org/mpdecimal/download.html https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-2.5.1.zip
```

https://github.com/lucasLMT/libmpdec: libmpdec is a fast C/C++ library for correctly-rounded arbitrary precision
decimal floating point arithmetic.  It is a complete implementation of
Mike Cowlishaw/IBM's General Decimal Arithmetic Specification. The full
specification is available here:

http://speleotrove.com/decimal/ => https://www.bytereef.org/mpdecimal/

But:

```bash
pkg_failed=no
{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for libmpdec >= 2.5.0" >&5
printf %s "checking for libmpdec >= 2.5.0... " >&6; }

if test -n "$LIBMPDEC_CFLAGS"; then
    pkg_cv_LIBMPDEC_CFLAGS="$LIBMPDEC_CFLAGS"
 elif test -n "$PKG_CONFIG"; then
    if test -n "$PKG_CONFIG" && \
    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libmpdec >= 2.5.0\""; } >&5
  ($PKG_CONFIG --exists --print-errors "libmpdec >= 2.5.0") 2>&5
  ac_status=$?
  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
  test $ac_status = 0; }; then
  pkg_cv_LIBMPDEC_CFLAGS=`$PKG_CONFIG --cflags "libmpdec >= 2.5.0" 2>/dev/null`
                      test "x$?" != "x0" && pkg_failed=yes
else
  pkg_failed=yes
fi
 else
    pkg_failed=untried
fi
```

## install

### modules

```bash
[CPLX-PYTHON-DEV] vonc@voncfm:~/tools/python/sources/v3.13.1/python-cpython-7795862$ ./python -c "import sys; print(sys.builtin_module_names)"
('_abc', '_ast', '_codecs', '_collections', '_functools', '_imp', '_io', '_locale', '_operator', '_signal', '_sre', '_stat', '_string', '_suggestions', '_symtable', '_sysconfig', '_thread', '_tokenize', '_tracemalloc', '_typing', '_warnings', '_weakref', 'atexit', 'builtins', 'errno', 'faulthandler', 'gc', 'itertools', 'marshal', 'posix', 'pwd', 'sys', 'time')
```

### python test: cannot find /usr/lib64/libc_nonshared.a


```bash
0:10:04 load avg: 0.00 Re-running 2 failed tests in verbose mode in subprocesses
0:10:04 load avg: 0.00 Run 2 tests in parallel using 2 worker processes (timeout: 10 min, worker timeout: 15 min)
0:10:04 load avg: 0.00 [1/2/1] test_ctypes failed (2 errors)
Re-running test_ctypes in verbose mode (matching: test_null_dlsym, test_find_on_libpath)
test_null_dlsym (test.test_ctypes.test_dlerror.TestNullDlsym.test_null_dlsym) ... ERROR
test_find_on_libpath (test.test_ctypes.test_find.FindLibraryLinux.test_find_on_libpath) ... /home/vonc/cplx/tools/tool/root/usr/bin/ld: cannot find /usr/lib64/libc_nonshared.a
collect2: error: ld returned 1 exit status
```

And:

```bash
[CPLX-DEV] vonc@voncfm:~/tools/tool/sources/v3.13.1/python-cpython-7795862/Lib$ rg "'gcc'"
ctypes/util.py:121:        c_compiler = shutil.which('gcc')
_osx_support.py:235:    elif os.path.basename(cc).startswith('gcc'):
test/test_ctypes/test_dlerror.py:81:            args = ['gcc', '-fPIC', '-Wl,--sysroot=/home/vonc/cplx/tools/tool/root', '-shared', '-o', dstname, srcname]
test/test_ctypes/test_find.py:86:            p = subprocess.Popen(['gcc', '--version'], stdout=subprocess.PIPE,
test/test_ctypes/test_find.py:100:            cmd = ['gcc', '-o', dstname, '--shared',

[CPLX-DEV] vonc@voncfm:~/tools/tool/sources/v3.13.1/python-cpython-7795862$ python3 /home/vonc/cplx/tools/python/sources/v3.13.1/python-cpython-7795862/Lib/test/test_ctypes/test_find.py
s../home/vonc/cplx/tools/tool/root/usr/bin/ld: cannot find /usr/lib64/libc_nonshared.a
collect2: error: ld returned 1 exit status
```

Works by adding `-Wl,--sysroot=/home/vonc/cplx/tools/tool/root'`, as in: `cmd = ['gcc', '-o', dstname, '--shared', '-Wl,-soname,lib%s.so' % libname, '-Wl,--sysroot=/home/vonc/cplx/tools/tool/root', srcname]`