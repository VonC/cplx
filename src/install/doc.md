# Install process

## configure step

<https://rpm.pbone.net/index.php3>

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

<https://stackoverflow.com/questions/16710047/usr-bin-ld-cannot-find-lnameofthelibrary>

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

<https://github.com/python/cpython/issues/118034>

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

Implementation: <https://web.mit.edu/freebsd/head/contrib/compiler-rt/lib/popcountdi2.c>

<https://stackoverflow.com/questions/52161596/why-is-builtin-popcount-slower-than-my-own-bit-counting-function>

> Without specifying an appropriate "-march" on the command line gcc generates a call to the `__popcountdi2` function rather than the `popcnt` instruction. See: <https://godbolt.org/z/z1BihM>
>
> POPCNT is supported by Intel since Nehalem and AMD since Barcelona according to wikipedia: <https://en.wikipedia.org/wiki/SSE4#POPCNT_and_LZCNT>

<https://stackoverflow.com/questions/27252630/linker-error-hidden-symbol-popcountdi2>: This can be fixed with '-shared-libgcc' linked option

See <https://github.com/python/cpython/blob/c6b292cdeee689f0bfac6c1e2c2d4e4e01fa8d9e/Include/internal/pycore_bitutils.h#L87-L131> uses __builtin_popcount(x);

`export CFLAGS="-DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=${root} -fPIC -O -U_FORTIFY_SOURCE -m64"` means -march is specified: 64.

<!--- cSpell:disable --->
```bash
~/tools/root$ cat /proc/cpuinfo|grep -i arc
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon nopl xtopology tsc_reliable nonstop_tsc eagerfpu pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single ssbd rsb_ctxsw ibrs ibpb stibp ibrs_enhanced fsgsbase tsc_adjust bmi1 avx2 smep bmi2 invpcid rdseed adx smap xsaveopt arat md_clear spec_ctrl intel_stibp flush_l1d arch_capabilities
```
<!--- cSpell:enable --->

<https://github.com/python/cpython/issues/81476>: If I recompile with `-msse4.2`, then the POPCNT instruction *is* used, and I get an even more marginal improvement: a 1.7% speedup over the lookup-table-based version.

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

<https://github.com/python/cpython/blob/main/Include/internal/pycore_bitutils.h>

CPUID is not used, to test if x86 POPCNT instruction can be used, to keep the implementation simple.  
For example, Visual Studio __popcnt() is not used this reason.  
The clang and GCC builtin function can use the x86 POPCNT instruction if the target architecture has SSE4a or newer.

- export CFLAGS="-DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=${root} -fPIC -O -U_FORTIFY_SOURCE -m64"

- export CFLAGS="-DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=${root} -fPIC -O -U_FORTIFY_SOURCE -m64 -march=x86-64 -msse4.2"

### `undefined symbol: __umodti3`

```bash
[ERROR] _decimal failed to import: /home/vonc/cplx/tools/python/sources/v3.13.1/python-cpython-7795862/build/lib.linux-x86_64-3.13/_decimal.cpython-313-x86_64-linux-gnu.so: undefined symbol: __umodti3

find . -type f -name "*.so.[0-1]" -o -name "*.so" -o -name "*.a" 2>/dev/null | xargs nm -A -u 2>/dev/null | grep -i umodti3
```

<https://bugzilla.mozilla.org/show_bug.cgi?id=1631627>
<https://issues.chromium.org/issues/41334980>
<https://gcc.gnu.org/onlinedocs/gccint/Integer-library-routines.html>

Not blocking.

It seems you're encountering another undefined symbol error, this time with `__umodti3`. This function is related to 128-bit integer modulo division, which is not directly supported by some older CPUs.

Here's how you can determine which `compiler-rt` your GCC is using and address the `__umodti3` error:

**1. Check GCC's link options:**

- Use the `-###` flag to see the detailed commands GCC executes during compilation. This will reveal the libraries it's linking against, including `compiler-rt` if it's being used.

```bash
gcc -### -march=sse4.2... (rest of your compilation flags)
```

Look for a line similar to:

```txt
-lclang_rt.builtins-x86_64
```

This indicates that GCC is using `compiler-rt`. The exact library name might vary depending on your system and GCC configuration.

**2. Check for `compiler-rt` installation:**

- If the previous step confirms `compiler-rt` usage, locate its installation directory. It might be within your GCC installation or a separate location like `/usr/lib/clang/`.

**3. Address the `__umodti3` error:**

- **Upgrade GCC:** Newer GCC versions often include updated `compiler-rt` libraries with better support for extended integer operations. If possible, consider upgrading to a more recent GCC version.
- **Link `libgcc` explicitly:** In some cases, linking `libgcc` explicitly might resolve the issue, as it might contain the necessary definitions for `__umodti3`. Add `-lgcc` to your `LDFLAGS`.
- **Rebuild Python:** If you have access to the Python source code, rebuilding it with your updated GCC and `-march=sse4.2` flag might resolve the issue. This will ensure that the `_decimal` library is compiled with the necessary support for extended integer operations.

**Important notes:**

- **Compatibility:** If upgrading GCC or rebuilding Python is not feasible, you might need to explore alternative solutions or consider using a different Python version with better compatibility with your current environment.
- **Thorough investigation:** Carefully examine the output of the `-###` flag and the contents of your `compiler-rt` installation to pinpoint the exact cause of the error and identify the appropriate solution.

If you provide the output of the `-###` command and the location of your `compiler-rt` installation, I can offer more specific guidance.

No, `-lclang_rt.builtins-x86_64` should not be added to the `CLANG` variable.

Here's why:

- **`CLANG`**: This variable usually specifies the path to the Clang compiler executable, not linker flags or libraries.
- **Linker flags**: `-lclang_rt.builtins-x86_64` is a linker flag that tells the linker to link against the `clang_rt.builtins-x86_64` library.

**Where to add it:**

You should add `-lclang_rt.builtins-x86_64` to your `LDFLAGS` variable. This variable is specifically for passing flags to the linker.

**How to add it:**

```bash
export LDFLAGS="$LDFLAGS -lclang_rt.builtins-x86_64"
```

This will append the flag to your existing `LDFLAGS`.

**Important notes:**

- **Order matters:** The order of flags in `LDFLAGS` can be important. If you encounter any issues, try placing `-lclang_rt.builtins-x86_64` at the end of the `LDFLAGS` string.
- **Recompile:** After modifying `LDFLAGS`, make sure to recompile your entire project to ensure the changes take effect.

If you're still encountering the `__umodti3` undefined symbol error after adding this flag, please provide the following information so I can assist you further:

- **Full GCC command line:** The complete command line you're using to compile your project.
- **Output of `-###` flag:** The output of running your GCC command with the `-###` flag.
- **`compiler-rt` location:** The directory where `compiler-rt` is installed on your system.

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

So using `-lgcc_s` is key (see also <https://gcc.gnu.org/bugzilla/show_bug.cgi?id=16470>). with `-lgcc`, you would get:

```bash
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

### Modules to activate

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

<https://stackoverflow.com/questions/32779768/python-build-from-source-cannot-build-optional-module-sqlite3>

This link provided the solution for me building Python 3.5.  Specifically for Ubuntu but helped figure it out for CentOS6 as well.

[Install missing packages before compiling Python3][1]

  [1]: https://stackoverflow.com/questions/12023773/python-3-3-source-code-setup-modules-were-not-found-lzma-sqlite3-tkinter

More specifically for Ubuntu server 16.04:

`apt-get -y install build-essential zlib1g-dev libbz2-dev liblzma-dev libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev libgdbm-dev liblzma-dev tk8.5-dev lzma lzma-dev libgdbm-dev`

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
<https://gist.github.com/Bill-tran/5e2ab062a9028bf693c934146249e68c>

```bash
yum install -y make gcc perl-core pcre-devel wget zlib-devel
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib no-shared zlib-dynamic
```

wget <https://ftp.openssl.org/source/openssl-1.1.1k.tar.gz> Now <https://openssl-library.org/source/old/1.1.1/index.html>: <https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz>

openssl-3.2.2.tar.gz
<https://openssl-library.org/source/>
<https://github.com/openssl/openssl/releases/download/openssl-3.4.1/openssl-3.4.1.tar.gz>

But: <https://stackoverflow.com/questions/67972269/openssl-upgrade-centos-7/69187544#69187544>
<https://bugzilla.redhat.com/show_bug.cgi?id=1416715>
<https://bugzilla.redhat.com/show_bug.cgi?id=1792741> <https://src.fedoraproject.org/rpms/openssl11>
ftp://ftp.icm.edu.pl/packages/linux-pbone/archive.fedoraproject.org/epel/7.2020-10-05/x86_64/Packages/o/openssl11-libs-1.1.1c-2.el7.x86_64.rpm (<https://rpm.pbone.net/info_idpl_71941238_distro_redhatel7_com_openssl11-libs-1.1.1c-2.el7.x86_64.rpm.html>)

<https://download.fedora.devel.redhat.com/pub/archive/epel/7.8/x86_64/Packages/o/openssl11-devel-1.1.1c-2.el7.x86_64.rpm>
<https://download.fedora.devel.redhat.com/pub/archive/epel/7.8/x86_64/Packages/o/openssl11-libs-1.1.1c-2.el7.x86_64.rpm>

### decimal

<https://gitlab.com/redhat/centos-stream/rpms/mpdecimal/-/blob/c8s/mpdecimal.spec?ref_type=heads>
<http://www.bytereef.org/software/mpdecimal/releases/mpdecimal-2.5.1.tar.gz>

To hope resolve:

```bash
configure:14675: checking for --with-system-libmpdec
configure:14686: result: yes
configure:14695: checking for libmpdec >= 2.5.0
configure:14756: result: no
configure:14761: error: libmpdec >= 2.5.0 not found https://www.bytereef.org/mpdecimal/download.html https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-2.5.1.zip
```

<https://github.com/lucasLMT/libmpdec>: libmpdec is a fast C/C++ library for correctly-rounded arbitrary precision
decimal floating point arithmetic.  It is a complete implementation of
Mike Cowlishaw/IBM's General Decimal Arithmetic Specification. The full
specification is available here:

<http://speleotrove.com/decimal/> => <https://www.bytereef.org/mpdecimal/>

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

## Python exploitation

### pip/pip3 version and upgrade

```bash
[CPLX-DEV] vonc@voncfm:~$ python -m pip install --upgrade pip
Requirement already satisfied: pip in ./tools/python/bin/current/lib/python3.13/site-packages (24.3.1)
Collecting pip
  Downloading pip-25.0.1-py3-none-any.whl.metadata (3.7 kB)
Downloading pip-25.0.1-py3-none-any.whl (1.8 MB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 1.8/1.8 MB 33.2 MB/s eta 0:00:00
Installing collected packages: pip
  Attempting uninstall: pip
    Found existing installation: pip 24.3.1
    Uninstalling pip-24.3.1:
      Successfully uninstalled pip-24.3.1
Successfully installed pip-25.0.1
[CPLX-DEV] vonc@voncfm:~$ python -c "import pip; print(pip.__version__)"
25.0.1
[CPLX-DEV] vonc@voncfm:~$ python -m pip --version
pip 25.0.1 from /home/vonc/cplx/tools/python/bin/current/lib/python3.13/site-packages/pip (python 3.13)
```

### venv

```bash
python -m venv python_3.13.1
source python_3.13.1/bin/activate
```

### my-project

**Prompt**: I need to copy the my-project content, except my-project/venvs/ folder, to ssh centos8@/home/vonc/cplx/tests/my-project: can I use tar with pipe ssh tar for that?

**Assistant**: Yes, you can achieve this using `tar` with a pipe to `ssh` and another `tar`. Here's how:

```bash
tar --exclude='my-project/venvs' -cvf - my-project | ssh centos8@<IP_ADDRESS> "tar -C /home/vonc/cplx/tests -xvf -"
```

**Explanation:**

1. **`tar --exclude='my-project/venvs' -cvf - my-project`**: This command creates a tar archive.
    - `--exclude='my-project/venvs'` excludes the `venvs` directory and its contents.  Crucially, ensure the path is relative to the directory being archived (`my-project`).
    - `-c` creates an archive.
    - `-v` verbose mode (optional, but useful to see what's being archived).
    - `-f -` uses standard output (stdout) as the archive file, represented by `-`.  This is what allows piping to `ssh`.
    - `my-project` is the directory to be archived.

2. **`|`**: This is the pipe operator. It takes the standard output of the first command (the tar archive) and feeds it as standard input to the second command.

3. **`ssh centos8@<IP_ADDRESS>`**: This establishes an SSH connection to your remote server. Replace `<IP_ADDRESS>` with the actual IP address or hostname of your CentOS 8 server.

4. **`"tar -C /home/vonc/cplx/tests -xvf -"`**: This command is executed on the remote server.
    - `tar -xvf -` extracts the archive received from the pipe. The `-` signifies that the archive is being read from standard input.
    - `-C /home/vonc/cplx/tests`  This is the *crucial* part.  The `-C` option changes the directory *before* extracting the archive.  This ensures the `my-project` directory structure is created *within* `/home/vonc/cplx/tests`.  Without this, the `my-project` directory would be created at the root level.

**Example illustrating the `-C` option's importance:**

Let's imagine your `my-project` directory looks like this:

```txt
my-project/
├── file1.txt
└── subfolder/
    └── file2.txt
```

- **Without `-C`:**  The extraction would create these files on the remote server:

```txt
/my-project/
├── file1.txt
└── subfolder/
    └── file2.txt
```

- **With `-C /home/vonc/cplx/tests`:** The extraction would create these files:

```txt
/home/vonc/cplx/tests/my-project/
├── file1.txt
└── subfolder/
    └── file2.txt
```

**Important considerations:**

- **SSH Keys:** For convenient and secure access, set up SSH keys to avoid entering your password each time.
- **Permissions:** Ensure the user `centos8` has the necessary write permissions to `/home/vonc/cplx/tests`.
- **rsync Alternative:** `rsync` is often a more efficient option for transferring files, especially if you need to synchronize changes in the future.   The equivalent `rsync` command would be: `rsync -av --exclude='venvs/' my-project/ centos8@<IP_ADDRESS>:/home/vonc/cplx/tests/my-project`

This combined `tar` and `ssh` command provides a concise and effective way to copy your directory while excluding the `venvs` folder. Remember to replace the placeholder IP address with your server's actual IP address or hostname.

### my-project/venvs

<https://tsn.miraclelinux.com/en/node/15276> for <https://tsn.miraclelinux.com/system/files/AXS8/x86_64/UPDATE/RPMS/gcc-c%2B%2B-8.5.0-15.el8.x86_64.rpm>

climits means <https://rpm.pbone.net/content_idpl_77651986_distro_centos8_com_libstdc++-devel-8.5.0-4.el8_5.x86_64.rpm.html>

<https://tsn.miraclelinux.com/en/node/15276>
<https://tsn.miraclelinux.com/system/files/AXS8/x86_64/UPDATE/RPMS/libstdc%2B%2B-devel-8.5.0-15.el8.x86_64.rpm>

<https://stackoverflow.com/questions/66304331/usr-include-c-8-cstdlib7515-fatal-error-stdlib-h-no-such-file-or-directo>

```bash
(python_3.13.1) [CPLX-DEV] vonc@voncfm:~/tests/my-project$ export CPLUS_INCLUDE_PATH=/home/vonc/cplx/tools/tool/root/usr/include/c++/8
(python_3.13.1) [CPLX-DEV] vonc@voncfm:~/tests/my-project$ pip install -r requirements.txt
```

When using a sysroot (via --sysroot), GCC remaps system include paths relative to the sysroot. This tends to override or ignore environment variables like CPLUS_INCLUDE_PATH. Instead, you should add the directory explicitly to your compiler flags. For example, add an explicit -I flag:

```bash
g++ -I/home/vonc/cplx/tools/tool/root/usr/include/c++/8 --sysroot=/home/vonc/cplx/tools/tool/root ...
```

Alternatively, you can set the CPATH variable (which applies to both C and C++ code):

```bash
export CPATH=/home/vonc/cplx/tools/tool/root/usr/include/c++/8${CPATH:+:$CPATH}
```

Either method ensures that the folder is considered during inclusion.

<https://stackoverflow.com/questions/56318759/how-do-i-fix-the-include-next-of-stdlib-h-from-cstdlib>

I tried to fix this issue, but wasted 5 hours. Finally, I manually replaced #include_next with #include in three files.

Replaced #include_next <stdlib.h> with #include <stdlib.h> in cstdlib and std_abs.h

Same in <https://stackoverflow.com/questions/51350998/7515-fatal-error-stdlib-h-no-such-file-or-directory-include-next-stdlib-h>

CPPFLAGS=-I/home/vonc/cplx/tools/tool/root/usr/include/c++/8
CPLUS_INCLUDE_PATH=/home/vonc/cplx/tools/tool/root/usr/include/c++/8

Most complete explanation: <https://stackoverflow.com/questions/62055143/permanently-and-reliably-set-gcc-include-path-globally>

Here is a [minimal repro](https://stackoverflow.com/help/minimal-reproducible-example) of your problem on Ubuntu 20.04.

```bash
$ g++ --version
g++ (Ubuntu 9.3.0-10ubuntu2) 9.3.0
...

$ cat main.cpp
#include <cstdlib>

int main ()
{
    return EXIT_SUCCESS;
}

$ export CPLUS_INCLUDE_PATH="/usr/include"; g++ -c main.cpp
In file included from main.cpp:1:
/usr/include/c++/9/cstdlib:75:15: fatal error: stdlib.h: No such file or directory
    75 | #include_next <stdlib.h>
        |               ^~~~~~~~~~
compilation terminated.
```

Note that `export CPLUS_INCLUDE_PATH="/usr/include"` here has the same effect as your
identical setting in your `.bashrc`.

The error does not occur if we remove that environment setting:

```bash
$ export CPLUS_INCLUDE_PATH=; g++ -c main.cpp; echo Done
Done
```

The effect of that environment setting, as per [the GCC Manual: 3.21 Environment Variables Affecting GCC](https://gcc.gnu.org/onlinedocs/gcc/Environment-Variables.html)
is the same as:

```bash
$ g++ -isystem /usr/include -c main.cpp
In file included from main.cpp:1:
/usr/include/c++/9/cstdlib:75:15: fatal error: stdlib.h: No such file or directory
    75 | #include_next <stdlib.h>
        |               ^~~~~~~~~~
compilation terminated.
```

which accordingly reproduces the error.

The `-isystem` option is documented in [the GCC Manual: 3.16 Options for Directory Search](https://gcc.gnu.org/onlinedocs/gcc/Directory-Options.html)

The *general* solution to your problem is: *Don't run a `g++` compilation in any way
that has the effect of* `g++ ... -isystem /usr/include ...`

You *can* avoid running a `g++` command in such a way because the option
`-isystem /usr/include` is unnecessary. `/usr/include` is a default search directory
for the preprocessor. You don't need to tell it to look for system header files there -
either via environment settings, or via a VS Code configuration, or any other way.

See the preprocessor's default search order for C++:-

```bash
$ echo | g++ -x c++ -E -Wp,-v -
ignoring duplicate directory "/usr/include/x86_64-linux-gnu/c++/9"
ignoring nonexistent directory "/usr/local/include/x86_64-linux-gnu"
ignoring nonexistent directory "/usr/lib/gcc/x86_64-linux-gnu/9/include-fixed"
ignoring nonexistent directory "/usr/lib/gcc/x86_64-linux-gnu/9/../../../../x86_64-linux-gnu/include"
#include "..." search starts here:
#include <...> search starts here:
    /usr/include/c++/9
    /usr/include/x86_64-linux-gnu/c++/9
    /usr/include/c++/9/backward
    /usr/lib/gcc/x86_64-linux-gnu/9/include
    /usr/local/include
    /usr/include/x86_64-linux-gnu
    /usr/include           ### <- There it is ###
End of search list.
...
```

So your comment:

>I am pretty sure that all the .bashrc exports are already a dirty workaround

is on the money<sup>1</sup>. But what's worse, the `.bashrc` setting:

```bash
export CPLUS_INCLUDE_PATH="/usr/include"
```

turns the problem into *a persistent feature of your bash profile*.

**How does the error happen?**

The difference that is made to the preprocessor's search order by `-isystem /usr/include`
can be seen here:

```bash
$ echo | g++ -x c++ -isystem /usr/include -E -Wp,-v -
ignoring duplicate directory "/usr/include/x86_64-linux-gnu/c++/9"
ignoring nonexistent directory "/usr/local/include/x86_64-linux-gnu"
ignoring nonexistent directory "/usr/lib/gcc/x86_64-linux-gnu/9/include-fixed"
ignoring nonexistent directory "/usr/lib/gcc/x86_64-linux-gnu/9/../../../../x86_64-linux-gnu/include"
ignoring duplicate directory "/usr/include"
#include "..." search starts here:
#include <...> search starts here:
/usr/include           ### <- Was previously last, now is first ###
/usr/include/c++/9
/usr/include/x86_64-linux-gnu/c++/9
/usr/include/c++/9/backward
/usr/lib/gcc/x86_64-linux-gnu/9/include
/usr/local/include
/usr/include/x86_64-linux-gnu
End of search list.
...
```bash

As you see, `/usr/include` is detected now as a *duplicated* directory in the `<...>` search
order; the second occurrence - which was *last*, previously - is deleted and the first occurrence is
retained, coming *first* in the search order.

Now recall the diagnostic:

    /usr/include/c++/9/cstdlib:75:15: fatal error: stdlib.h: No such file or directory
       75 | #include_next <stdlib.h>
          |               ^~~~~~~~~~

The preprocessor directive `#include_next` is not a standard directive, it is
a GCC extension, documented in [the GCC manual: 2.7 Wrapper Headers](https://gcc.gnu.org/onlinedocs/cpp/Wrapper-Headers.html#Wrapper-Headers)

Whereas `#include <stdlib.h>` means:

*Include the first file called `stdlib.h` discovered in the `<...>` search order, starting from the start*

`#include_next <stdlib.h>` means:

*Include the next file called `stdlib.h` discovered in the `<...>` search order, starting from the
directory right after that of the file being processed now.*

The only directory in the `<...>` search order that contains `stdlib.h` is `/usr/include`. So,
if `#include_next <stdlib.h>` is encountered by the preprocessor in any file in any directory `dir` in the `<...>`
search order, while `/usr/include` is *first* in the `<...>` search order, there can be no directory
later than `dir` in the `<...>` search order where `<stdlib.h>` will be found. And so the error.

`#include_next <foobar.h>` can only work if the `<...>` search order places the directory containing
`<foobar.h>` after the one that contains the file that contains the directive. As a rule of thumb,
just don't mess with the `<...>` search order.

The problem just discussed was the subject of [a regression bug-report raised against GCC 6.0](https://gcc.gnu.org/bugzilla/show_bug.cgi?id=70129).
As you can see there, the resolution was `WONTFIX`.

<hr>
[1] All of your `.bashrc` exports as posted are, as you suspect, poor practice.

- It isn't necessary to tell the preprocessor about any search directories in
its default search order. You can only make things wrong.

- Directories that will *not* be found by default *should* be specified by
`-I dir` options specified on the commandline (typically injected via parameters
of the build configuration), so that these non-default options are visible in build logs
for trouble shooting. "Invisible hands" are to be avoided in build systems to the
utmost practical extent.

Try wheel:

```bash
(python_3.13.1) [CPLX-DEV] vonc@voncfm:~/tests/my-project$ python -m pip install pymupdf-1.25.3-cp39-abi3-manylinux2014_x86_64.manylinux_2_17_x86_64.whl
Processing ./pymupdf-1.25.3-cp39-abi3-manylinux2014_x86_64.manylinux_2_17_x86_64.whl
Installing collected packages: pymupdf
Successfully installed pymupdf-1.25.3
python -m pip install numpy-2.2.3-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
```

### pkg-config

pkgconf-pkg-config-1.4.2-1.el8.x86_64.rpm

~~

## openssl111

###

What does this gcc error means?

```bash
${LDCMD:-gcc} -pthread -m64 -Wa,--noexecstack -DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=/home/gitea2/cplx/tools/tool/root -fPIC -O -U_FORTIFY_SOURCE -m64 -march=x86-64 -msse4.2 -L.  -L/home/gitea2/cplx/tools/tool/root/usr/lib64 -L/home/gitea2/cplx/tools/tool/root/usr/lib64 -L/home/gitea2/cplx/tools/tool/root/usr/lib -L/home/gitea2/cplx/tools/tool/root/lib64 -L/home/gitea2/cplx/tools/tool/root/lib -L/home/gitea2/cplx/tools/tool/root/usr/lib/gcc/x86_64-redhat-linux/8 -nodefaultlibs -Wl,-rpath,/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib:/home/gitea2/cplx/tools/tool/root/lib64:/home/gitea2/cplx/tools/tool/root/lib -Wl,--export-dynamic -lc_nonshared -ldl -lgcc_s -lc -lm -lc_nonshared -lpthread -B/home/gitea2/cplx/tools/tool/root -B/home/gitea2/cplx/tools/tool/root/usr -B/home/gitea2/cplx/tools/tool/root/usr/lib64 -B/home/gitea2/cplx/tools/tool/root/usr/lib -B/home/gitea2/cplx/tools/tool/root/lib64 -B/home/gitea2/cplx/tools/tool/root/lib --sysroot=/home/gitea2/cplx/tools/tool/root -o apps/openssl apps/asn1pars.o apps/ca.o apps/ciphers.o apps/cms.o apps/crl.o apps/crl2p7.o apps/dgst.o apps/dhparam.o apps/dsa.o apps/dsaparam.o apps/ec.o apps/ecparam.o apps/enc.o apps/engine.o apps/errstr.o apps/gendsa.o apps/genpkey.o apps/genrsa.o apps/nseq.o apps/ocsp.o apps/openssl.o apps/passwd.o apps/pkcs12.o apps/pkcs7.o apps/pkcs8.o apps/pkey.o apps/pkeyparam.o apps/pkeyutl.o apps/prime.o apps/rand.o apps/rehash.o apps/req.o apps/rsa.o apps/rsautl.o apps/s_client.o apps/s_server.o apps/s_time.o apps/sess_id.o apps/smime.o apps/speed.o apps/spkac.o apps/srp.o apps/storeutl.o apps/ts.o apps/verify.o apps/version.o apps/x509.o apps/libapps.a -lssl -lcrypto -ldl -pthread 

./libcrypto.so: undefined reference to `atexit'
./libcrypto.so: undefined reference to `pthread_atfork'
collect2: error: ld returned 1 exit status
```

I do have a `/home/gitea2/cplx/tools/tool/root/usr/lib64/libc.a`, with:

```bash
[CPLX-OPENSSL111-DEV] gitea2@cactislux801:~/tools/tool/sources/1.1.1w$ nm -A /home/gitea2/cplx/tools/tool/root/usr/lib64/libc.a 2>/dev/null | grep -v " U " | grep atexit
/home/gitea2/cplx/tools/tool/root/usr/lib64/libc.a:exit.o:                 w __start___libc_atexit
/home/gitea2/cplx/tools/tool/root/usr/lib64/libc.a:exit.o:                 w __stop___libc_atexit
/home/gitea2/cplx/tools/tool/root/usr/lib64/libc.a:atexit.o:                 w __dso_handle
/home/gitea2/cplx/tools/tool/root/usr/lib64/libc.a:atexit.o:0000000000000000 T atexit
```

So why the error?

The error message:

```bash
./libcrypto.so: undefined reference to `atexit'
./libcrypto.so: undefined reference to `pthread_atfork'
collect2: error: ld returned 1 exit status
```

indicates that the linker (`ld`, invoked by `gcc`) cannot find the definitions for the functions `atexit` and `pthread_atfork` when trying to link the OpenSSL application.  Even though your `nm` output shows that `atexit` *is* present in `libc.a`, the linking process is failing.  Here's a breakdown of the likely causes and solutions, in order of probability:

**1. Linking Order and `-nodefaultlibs`:**

- **Problem:** The most common cause of this type of error is the incorrect order of libraries on the linker command line, especially when combined with `-nodefaultlibs`.  `-nodefaultlibs` tells the linker *not* to use the standard system libraries.  Because of this, you *must* explicitly list *all* necessary libraries, and in the correct order.  The linker processes libraries from left to right.  If a library `A` depends on symbols defined in library `B`, then `B` *must* appear *after* `A` on the command line.  Your command includes `-lc` (which is where `atexit` should reside) *before* the libraries that depend on it. This is almost certainly the root cause.

- **Solution:** Rearrange the linker command line.  Move `-lc -lm -lc_nonshared -lpthread` (and possibly `-ldl` and `-lgcc_s`, depending on dependencies, but *definitely* `-lc` and `-lpthread`) to the *end* of the command line, *after* `-lssl` and `-lcrypto`.  Something like this:

    ```bash
    ${LDCMD:-gcc} -pthread -m64 ... -o apps/openssl ... apps/libapps.a -lssl -lcrypto -ldl -pthread -lgcc_s -lc -lm -lc_nonshared
    ```

    Or, even better, and more specifically:

     ```bash
    ${LDCMD:-gcc} -pthread -m64 ... -o apps/openssl ... apps/libapps.a -lssl -lcrypto  -lgcc_s -ldl -lpthread -lc -lm -lc_nonshared
    ```

    The key change is placing `-lc` and `-lpthread` after the OpenSSL libraries.

**2. Static vs. Dynamic Linking Mismatch:**

- **Problem:** You have a mix of static (`.a`) and dynamic (`.so`) libraries. Your `nm` output shows that `atexit` is in the *static* archive `libc.a`, but the error message refers to `./libcrypto.so`, which is a *dynamic* library.  It's possible that `libcrypto.so` was built in a way that expects `atexit` to be in a dynamic `libc.so`, not a static `libc.a`. This happens when build environments are inconsistent. Because you're using `-nodefaultlibs` the dynamic linker won't automatically find the system's `libc.so`.

- **Solution:**
  - **Ideally, rebuild OpenSSL (libcrypto) consistently:** If you have control over how `libcrypto.so` is built, rebuild it using the *same* linking flags and libraries (specifically, your custom `libc.a`) as you're using in this final linking stage.  This ensures consistency. This is the *best* solution.
  - **If you can't rebuild libcrypto, try adding -static:**  If you can't rebuild `libcrypto.so`, add the `-static` flag to your `gcc` command line.  This forces static linking of *everything*, which *might* work, but it can lead to other issues (larger binaries, potential symbol conflicts if other parts of your system rely on dynamic linking).  It's a bit of a "hammer" approach:

    ```bash
    ${LDCMD:-gcc} -static -pthread -m64 ... -o apps/openssl ... apps/libapps.a -lssl -lcrypto -ldl -pthread  -lgcc_s -lc -lm -lc_nonshared
    ```

  - **If you can't rebuild libcrypto, and -static doesn't work, link dynamically against libc:** Find or build a *dynamic* version of your custom libc (`libc.so`). Then *remove* `-nodefaultlibs` and *remove* the explicit `-lc` (and similar) options from the linker flags. Instead, make sure the linker can find your custom `libc.so` using `-L` and (possibly, but probably already set correctly) `-Wl,-rpath`.  This allows the dynamic linker to resolve `atexit` correctly. This is a bit tricky because you need to make sure the linker uses your custom libc.so, and not the system one, while still allowing the dynamic linker to do its job. The rpath should help with that.

**3. Compiler/Linker Flag Incompatibilities:**

- **Problem:** Although less likely given the specifics of your error, subtle incompatibilities between compiler flags used to build `libcrypto.so` and your current linking command can sometimes cause these issues. For instance, flags affecting thread models or standard library implementations.

- **Solution:** Review the build process for `libcrypto.so` and ensure the flags are consistent with your current linking command, particularly those related to:
  - `-pthread`: You're using it, which is good. Make sure it was used when building `libcrypto.so` as well.
  - `-m64`, `-march`, `-msse4.2`: Architecture and CPU feature flags should match.
  - `-fPIC`: You are using `-fPIC`. Ensure `libcrypto.so` was also compiled with `-fPIC` (it likely was, as it's a shared library).
  - `-U_FORTIFY_SOURCE`: Make sure the fortification level (if any) is consistent.

**4. Corrupted Library Files:**

- **Problem:** In rare cases, the `libc.a` or `libcrypto.so` file itself could be corrupted.

- **Solution:** Rebuild both `libc.a` and `libcrypto.so` from their respective source code to rule out corruption.

**5. `pthread_atfork` Specific Issue:**

- **Problem:** `pthread_atfork` is a POSIX threads function. The `-lpthread` flag *should* link against the correct library. However, the error suggests it's not being found.  This is often related to the same root causes as `atexit` (linking order, static/dynamic mismatch).

- **Solution:** The solutions for `atexit` (particularly rearranging the linker command line and ensuring consistent static/dynamic linking) should also resolve the `pthread_atfork` issue. Make *sure* `-lpthread` is after `-lssl` and `-lcrypto`.

**Debugging Steps (Highly Recommended):**

1. **Verbose Linking:** Add `-v` (or even `-Wl,-v`) to your `gcc` command line. This will make the linker print out a lot more information about which libraries it's searching and in what order. This can be invaluable in identifying linking order issues.

2. **`ldd`:** After a *successful* build (if you can achieve one), run `ldd apps/openssl` (or the name of your final executable). This will show you which dynamic libraries the executable is linked against.  Make sure it's picking up your intended `libc.so` and not a system version.

3. **Simplify:** Temporarily remove *all* the extra `-L`, `-B`, and `-Wl,-rpath` flags, and the `-nodefaultlibs` flag.  Try linking with just a minimal set of libraries:

    ```bash
    gcc -pthread -m64 -o apps/openssl apps/asn1pars.o ... apps/libapps.a -lssl -lcrypto -lpthread -lc
    ```

    If *this* works, then you know the issue is with your custom library paths and options. Add them back one by one until you identify the culprit.

4. **Inspect the build environment variables:** Carefully inspect all environment variables that might influence compilation and linking, such as `LD_LIBRARY_PATH`, `LIBRARY_PATH`, `CFLAGS`, `LDFLAGS`, and `CC`. Inconsistent settings in these variables can cause surprising problems. Ensure these are set *consistently* for both the OpenSSL build and the linking of your final application. It looks like you're using a custom toolchain (`/home/gitea2/cplx/tools/tool/`), so double-check the environment is configured correctly to use it.

**In Summary:**

The most likely problem is the incorrect order of libraries on the linker command line due to the use of `-nodefaultlibs`.  Fixing this by putting `-lc`, `-lpthread` and potentially other related libraries *after* `-lssl -lcrypto` is the first and most important step. If that doesn't resolve the issue, carefully consider the other potential causes and solutions outlined above, especially the possibility of a mismatch between static and dynamic linking. Using verbose linking (`-v`) and `ldd` will greatly aid in debugging. Good luck!

Would those variable help, and would they include the right order?

```bash
export LDFLAGS="-L${ldpaths} -L${root}/usr/lib64 -L${root}/usr/lib -L${root}/lib64 -L${root}/lib -L${root}/usr/lib/gcc/x86_64-redhat-linux/8 -nodefaultlibs -Wl,-rpath,${ldpaths}:${root}/usr/lib64:${root}/usr/lib:${root}/lib64:${root}/lib -Wl,--export-dynamic -B${root} -B${root}/usr -B${root}/usr/lib64 -B${root}/usr/lib -B${root}/lib64 -B${root}/lib --sysroot=${root} -lssl -lcrypto -lgcc_s -ldl -lpthread -lc -lm -lc_nonshared"
export LIBS="-Wl,-rpath,${ldpaths}:${root}/lib64:${root}/lib:${root}/usr/lib64:${root}/usr/lib -Wl,--export-dynamic -lssl -lcrypto -lgcc_s -ldl -lpthread -lc -lm -lc_nonshared"
```

Would those variable help, and would they include the right order?

```bash
export LDFLAGS="-L${ldpaths} -L${root}/usr/lib64 -L${root}/usr/lib -L${root}/lib64 -L${root}/lib -L${root}/usr/lib/gcc/x86_64-redhat-linux/8 -nodefaultlibs -Wl,-rpath,${ldpaths}:${root}/usr/lib64:${root}/usr/lib:${root}/lib64:${root}/lib -Wl,--export-dynamic -B${root} -B${root}/usr -B${root}/usr/lib64 -B${root}/usr/lib -B${root}/lib64 -B${root}/lib --sysroot=${root} -lssl -lcrypto -lgcc_s -ldl -lpthread -lc -lm -lc_nonshared"
export LIBS="-Wl,-rpath,${ldpaths}:${root}/lib64:${root}/lib:${root}/usr/lib64:${root}/usr/lib -Wl,--export-dynamic -lssl -lcrypto -lgcc_s -ldl -lpthread -lc -lm -lc_nonshared"
```

Let's analyze these `LDFLAGS` and `LIBS` settings and whether they'll fix the problem and include the correct order.  Crucially, let's consider how they interact with the original command.

**Original Command (Simplified):**

```bash
${LDCMD:-gcc} ... [other options] ... apps/libapps.a -lssl -lcrypto ... -nodefaultlibs ... -lc -lm -lc_nonshared -lpthread ...
```

**Your `LDFLAGS` and `LIBS` Proposals:**

```bash
export LDFLAGS="-L${ldpaths} -L${root}/usr/lib64 -L${root}/usr/lib -L${root}/lib64 -L${root}/lib -L${root}/usr/lib/gcc/x86_64-redhat-linux/8 -nodefaultlibs -Wl,-rpath,${ldpaths}:${root}/usr/lib64:${root}/usr/lib:${root}/lib64:${root}/lib -Wl,--export-dynamic -B${root} -B${root}/usr -B${root}/usr/lib64 -B${root}/usr/lib -B${root}/lib64 -B${root}/lib --sysroot=${root} -lssl -lcrypto -lgcc_s -ldl -lpthread -lc -lm -lc_nonshared"

export LIBS="-Wl,-rpath,${ldpaths}:${root}/lib64:${root}/lib:${root}/usr/lib64:${root}/usr/lib -Wl,--export-dynamic -lssl -lcrypto -lgcc_s -ldl -lpthread -lc -lm -lc_nonshared"
```

**Analysis and Problems:**

1. **`LDFLAGS` Including Libraries:** The biggest problem is that your `LDFLAGS` variable *includes* library specifications (`-lssl`, `-lcrypto`, etc.).  `LDFLAGS` is traditionally meant for *linker flags* (options that control the linker's behavior, like `-L`, `-Wl,-rpath`, `-nodefaultlibs`), *not* for specifying which libraries to link. Including libraries here effectively *duplicates* the libraries on the command line and, more importantly, puts them *in the wrong place*.

2. **`LIBS` Duplication and Wrong Order:** The `LIBS` variable *also* includes `-lssl` and `-lcrypto`, again before `-lc` and `-lpthread`. This duplicates libraries *and* reinforces the incorrect linking order.  You've moved the `-Wl,-rpath` and `-Wl,--export-dynamic` here, but they don't belong in `LIBS` either.

3. **Overuse of `-B`:** The multiple `-B` options are likely redundant and could potentially even interfere with each other.  `--sysroot` usually handles specifying the root directory for the toolchain.

4. **Redundant `-Wl,-rpath`:** You've included the `-Wl,-rpath` in both `LDFLAGS` and `LIBS`. It only needs to be specified once.

**How These Variables Will Affect the Command:**

When you use `LDFLAGS` and `LIBS` in your build, the command executed will effectively become (assuming `${LDCMD:-gcc}` expands to `gcc`):

```bash
gcc ... [other options from the original command] ... ${LDFLAGS} ... apps/libapps.a ... [libraries from original command] ... ${LIBS}
```

Which, expanded, looks like (simplified, and noting the repeated libraries):

```bash
gcc ... [other options] ... -lssl -lcrypto -lgcc_s -ldl -lpthread -lc -lm -lc_nonshared ... apps/libapps.a ... -lssl -lcrypto -ldl -pthread -lgcc_s -lc -lm ... -lssl -lcrypto -lgcc_s -ldl -lpthread -lc -lm -lc_nonshared
```

Notice how `-lc` and `-lpthread` are *still* appearing before `-lssl` and `-lcrypto` (in `LDFLAGS`), and are also duplicated multiple times. This is *worse* than the original command.

**Corrected Approach:**

Here's how you should structure your `LDFLAGS` and `LIBS` (and you might not even need `LIBS`):

1. **`LDFLAGS` (Only Linker Flags):**

    ```bash
    export LDFLAGS="-L${ldpaths} -L${root}/usr/lib64 -L${root}/usr/lib -L${root}/lib64 -L${root}/lib -L${root}/usr/lib/gcc/x86_64-redhat-linux/8 -nodefaultlibs -Wl,-rpath,${ldpaths}:${root}/usr/lib64:${root}/usr/lib:${root}/lib64:${root}/lib -Wl,--export-dynamic --sysroot=${root}"
    ```

    - Removed all the `-l...` library specifications.
    - Removed the redundant `-B` options; `--sysroot` is sufficient.
    - Kept the `-Wl,-rpath` and `-Wl,--export-dynamic` (which are correct linker flags).
    - Kept `-nodefaultlibs`

2. **`LIBS` (Optional - You Can Put This Directly on the Command Line):**

    ```bash
    export LIBS="-lgcc_s -ldl -lpthread -lc -lm -lc_nonshared"  # Correct Order!
    ```

    - Contains *only* the libraries, in the *correct order*.  `libcrypto` and `libssl` will come from the original command line, *before* these.

3. **Corrected Build Command**

   Now your build command should look like (this is the most important part):

    ```bash
    ${LDCMD:-gcc} -pthread -m64 -Wa,--noexecstack -DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI -fPIC -O -U_FORTIFY_SOURCE -m64 -march=x86-64 -msse4.2 \
      -o apps/openssl apps/asn1pars.o apps/ca.o ... apps/x509.o \
      apps/libapps.a -lssl -lcrypto ${LIBS}
    ```

    - *All* the linker options (like `-L`, `-Wl,-rpath`, etc.) are now coming from `LDFLAGS` and are applied *before* the object files and libraries.
    - `-lssl -lcrypto` are *before* `${LIBS}`.
    - `${LIBS}` contains the remaining libraries in the correct order: `-lgcc_s -ldl -lpthread -lc -lm -lc_nonshared`.

**In Summary:**

The original `LDFLAGS` and `LIBS` variables were incorrect because they included library specifications (`-l...`) in `LDFLAGS` and had the wrong library order. The corrected approach separates linker *flags* into `LDFLAGS` and library *specifications* (in the correct order) into `LIBS` (or directly on the command line).  The critical change is ensuring that `-lssl -lcrypto` comes *before* `-lpthread -lc` in the final command executed by the shell.  The corrected build command above achieves this.  This separation and correct ordering are essential for successful linking.

Those are my current variables:

```bash
[CPLX-DEV] gitea2@cactislux801:~$ env|grep FL
CFLAGS=-DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=/home/gitea2/cplx/tools/tool/root -fPIC -O -U_FORTIFY_SOURCE -m64 -march=x86-64 -msse4.2
CPPFLAGS=-I/home/gitea2/cplx/tools/tool/root/usr/include
LDFLAGS=-L/home/gitea2/cplx/tools/tool/root/usr/lib64 -L/home/gitea2/cplx/tools/tool/root/usr/lib64 -L/home/gitea2/cplx/tools/tool/root/usr/lib -L/home/gitea2/cplx/tools/tool/root/lib64 -L/home/gitea2/cplx/tools/tool/root/lib -L/home/gitea2/cplx/tools/tool/root/usr/lib/gcc/x86_64-redhat-linux/8 -nodefaultlibs -Wl,-rpath,/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib:/home/gitea2/cplx/tools/tool/root/lib64:/home/gitea2/cplx/tools/tool/root/lib -Wl,--export-dynamic --sysroot=/home/gitea2/cplx/tools/tool/root
OPENSSL_LDFLAGS=-L/home/gitea2/cplx/tools/tool/root/usr/lib64

[CPLX-DEV] gitea2@cactislux801:~$ env|grep LIB
LD_LIBRARY_PATH=/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib:/home/gitea2/cplx/tools/tool/root/lib64:/home/gitea2/cplx/tools/tool/root/lib:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib64:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/lib64:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/lib
LIBPCREDIR=/home/gitea2/cplx/tools/tool/root/usr
LIBRARY_PATH=/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib:/home/gitea2/cplx/tools/tool/root/lib64:/home/gitea2/cplx/tools/tool/root/lib:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib64:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/lib64:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/lib
LIBS=-lgcc_s -ldl -lpthread -lc -lm -lc_nonshared
PERLLIB=:/home/gitea2/cplx/tools/tool/root/usr/share/autoconf:/home/gitea2/cplx/tools/tool/root/usr/lib64/perl5/vendor_perl
ZLIB_PATH=/home/gitea2/cplx/tools/tool/root/usr
```

I have modified LDFLAGS and LIBS per your recommendation.

But are the other variables compatibles with said recommendations? Or could they interfere?

Let's review your updated environment variables and their compatibility:

```bash
CFLAGS=-DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=/home/gitea2/cplx/tools/tool/root -fPIC -O -U_FORTIFY_SOURCE -m64 -march=x86-64 -msse4.2
CPPFLAGS=-I/home/gitea2/cplx/tools/tool/root/usr/include
LDFLAGS=-L/home/gitea2/cplx/tools/tool/root/usr/lib64 -L/home/gitea2/cplx/tools/tool/root/usr/lib64 -L/home/gitea2/cplx/tools/tool/root/usr/lib -L/home/gitea2/cplx/tools/tool/root/lib64 -L/home/gitea2/cplx/tools/tool/root/lib -L/home/gitea2/cplx/tools/tool/root/usr/lib/gcc/x86_64-redhat-linux/8 -nodefaultlibs -Wl,-rpath,/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib:/home/gitea2/cplx/tools/tool/root/lib64:/home/gitea2/cplx/tools/tool/root/lib -Wl,--export-dynamic --sysroot=/home/gitea2/cplx/tools/tool/root
OPENSSL_LDFLAGS=-L/home/gitea2/cplx/tools/tool/root/usr/lib64
LD_LIBRARY_PATH=/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib:/home/gitea2/cplx/tools/tool/root/lib64:/home/gitea2/cplx/tools/tool/root/lib:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib64:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/lib64:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/lib
LIBPCREDIR=/home/gitea2/cplx/tools/tool/root/usr
LIBRARY_PATH=/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib:/home/gitea2/cplx/tools/tool/root/lib64:/home/gitea2/cplx/tools/tool/root/lib:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib64:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/lib64:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/lib
LIBS=-lgcc_s -ldl -lpthread -lc -lm -lc_nonshared
PERLLIB=:/home/gitea2/cplx/tools/tool/root/usr/share/autoconf:/home/gitea2/cplx/tools/tool/root/usr/lib64/perl5/vendor_perl
ZLIB_PATH=/home/gitea2/cplx/tools/tool/root/usr
```

**Compatibility Analysis:**

- **`CFLAGS`**:  These are compiler flags and look fine. They're relevant to compiling the individual `.o` files, not the final linking stage, so they won't directly interfere.  They are appropriate for building with your custom toolchain and targeting a 64-bit architecture.
- **`CPPFLAGS`**: These are preprocessor flags (mostly for include paths).  Also fine and relevant to compiling, not linking. The `-I` flag correctly points to your toolchain's include directory.
- **`LDFLAGS`**:  This is now *correct* based on the previous discussion. It contains only linker flags, and the important `-nodefaultlibs` is present.
- **`OPENSSL_LDFLAGS`**: This variable is not used in your provided build command, so it's currently irrelevant.  It *could* be a problem if it were used *in addition to* the corrected `LDFLAGS`, as it would add another `-L` path, potentially interfering with the library search order.  If you aren't explicitly using it, it's best to unset it: `unset OPENSSL_LDFLAGS`.
- **`LD_LIBRARY_PATH`**: This is a runtime variable, *not* a compile-time variable. It tells the *dynamic linker* (which runs when you execute a program) where to find shared libraries. It won't affect the compilation/linking process itself, so it won't cause the `atexit` issue.  However, it *is* important that it includes the paths to your custom libraries, *if* you are using any shared libraries (.so) at runtime. Since your build uses `-nodefaultlibs` and you're likely linking with static libraries, this should not be a problem *during the build*, but will be important *after* a successful build if you are producing an executable that depends on any shared libraries. It's a good practice to keep this consistent with your compile-time library paths.  The paths to your custom openssl build should *not* be in here, if you are linking statically against libcrypto.a and libssl.a.
- **`LIBPCREDIR`**:  This is specific to `pkg-config` and helps it find `.pc` files. It shouldn't directly interfere with this linking issue.
- **`LIBRARY_PATH`**: This is similar to `LDFLAGS`'s `-L` options, but `LIBRARY_PATH` is often used during *compilation* to find libraries needed for building object files. It's generally *better* to use `-L` in `LDFLAGS` for the final linking stage.  Because `LDFLAGS` is explicitly used in your command, `LIBRARY_PATH` should not interfere *in this specific case*, but to avoid confusion and potential conflicts, it's best practice to keep `LIBRARY_PATH` and `LDFLAGS` consistent. You could remove your openssl paths from this variable.  In general, avoid setting both `LIBRARY_PATH` and using explicit `-L` flags.
- **`LIBS`**: This is now *correct*. It contains the libraries in the correct order.
- **`PERLLIB`**: This is specific to Perl and won't affect C/C++ linking.
- **`ZLIB_PATH`**: This looks like it's meant to point to a zlib installation.  Since your current issue is with `libc` and `pthread`, this won't directly interfere. If you needed to link against zlib, you'd typically use `-lz` in your `LIBS` (and ensure the correct `-L` path is in `LDFLAGS`).

**Key Recommendations:**

1. **Unset `OPENSSL_LDFLAGS`:** Since it's unused and could cause confusion, unset it: `unset OPENSSL_LDFLAGS`.

2. **Consider removing openssl paths from `LIBRARY_PATH` and `LD_LIBRARY_PATH`:** If you are linking statically against OpenSSL (as you should be, given your `-nodefaultlibs`), the paths to the OpenSSL libraries shouldn't be in `LIBRARY_PATH` or `LD_LIBRARY_PATH`.  This helps avoid accidental linking against the wrong version. Keep only the paths related to your custom toolchain in `LIBRARY_PATH` (if you *must* use it at all) and in `LD_LIBRARY_PATH` (for runtime).

3. **Double-Check Your Build Command:**
     Make absolutely certain you are using the build command from the previous answer:

    ```bash
    ${LDCMD:-gcc} -pthread -m64 -Wa,--noexecstack -DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI -fPIC -O -U_FORTIFY_SOURCE -m64 -march=x86-64 -msse4.2 \
      -o apps/openssl apps/asn1pars.o apps/ca.o ... apps/x509.o \
      apps/libapps.a -lssl -lcrypto ${LIBS}
    ```

4. **Verbose Linking (Again):**  Add `-v` (or `-Wl,-v`) to your `gcc` command line *when you try the build again*. This will provide extremely valuable debugging output.

With these changes, your environment variables and build command should be consistent and correctly configured for static linking with your custom toolchain, resolving the "undefined reference" errors. The verbose output will help confirm this.

You should modify `LDFLAGS` to include the `-Wl,-v` option. This is the correct place for linker-specific flags.

Here's why and how:

- **Why `LDFLAGS`?**  `LDFLAGS` is specifically designed for passing options to the linker.  `-Wl,` is a prefix that tells `gcc` to pass the following option directly to the linker (`ld` in this case). `-v` is the linker option for verbose output.

- **How to Modify:**  Update your `LDFLAGS` variable like this:

    ```bash
    export LDFLAGS="-L/home/gitea2/cplx/tools/tool/root/usr/lib64 -L/home/gitea2/cplx/tools/tool/root/usr/lib64 -L/home/gitea2/cplx/tools/tool/root/usr/lib -L/home/gitea2/cplx/tools/tool/root/lib64 -L/home/gitea2/cplx/tools/tool/root/lib -L/home/gitea2/cplx/tools/tool/root/usr/lib/gcc/x86_64-redhat-linux/8 -nodefaultlibs -Wl,-rpath,/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib:/home/gitea2/cplx/tools/tool/root/lib64:/home/gitea2/cplx/tools/tool/root/lib -Wl,--export-dynamic --sysroot=/home/gitea2/cplx/tools/tool/root -Wl,-v"
    ```

    I've simply added `-Wl,-v` to the *end* of your existing `LDFLAGS`.  It's generally safe to put it at the end, as the order of linker *flags* usually matters less than the order of libraries and object files.

- **Why NOT `CFLAGS` or other variables?**
  - `CFLAGS`: These are for the C *compiler*, not the linker.
  - `CPPFLAGS`: These are for the C *preprocessor*.
  - `LIBS`: This variable is for specifying the *libraries* to link against (e.g., `-lc`, `-lpthread`), not for linker flags.

- **Just `-v`?** You could also use just `-v` (without the `-Wl,` prefix) in `LDFLAGS`, as gcc *might* recognize it directly and pass it to the linker. *However*, `-Wl,-v` is the *more reliable and correct* way to ensure the option goes to the linker, especially in complex build environments. It avoids any ambiguity.

**After making this change, run your build command again.  You should see much more detailed output from the linker, showing exactly which files and libraries it's searching, in what order, and what symbols it's trying to resolve.** This verbose output is absolutely crucial for diagnosing any remaining linking problems.

 **Consider removing openssl paths from `LIBRARY_PATH` and `LD_LIBRARY_PATH`:** If you are linking statically against OpenSSL (as you should be, given your `-nodefaultlibs`), the paths to the OpenSSL libraries shouldn't be in `LIBRARY_PATH` or `LD_LIBRARY_PATH`.  This helps avoid accidental linking against the wrong version. Keep only the paths related to your custom toolchain in `LIBRARY_PATH` (if you *must* use it at all) and in `LD_LIBRARY_PATH` (for runtime).

Currently I have:

```bash
[CPLX-DEV] gitea2@cactislux801:~$ echo $LIBRARY_PATH
/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib:/home/gitea2/cplx/tools/tool/root/lib64:/home/gitea2/cplx/tools/tool/root/lib:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib64:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/lib64:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/lib

[CPLX-DEV] gitea2@cactislux801:~$ echo $LD_LIBRARY_PATH
/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib:/home/gitea2/cplx/tools/tool/root/lib64:/home/gitea2/cplx/tools/tool/root/lib:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib64:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/lib64:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib:/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/lib
```

What is the issue here?

The issue with your `LIBRARY_PATH` and `LD_LIBRARY_PATH` is that they include paths to your *separately built* OpenSSL installation (`/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/...`):

```bash
/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib64:
/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/lib64:
/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib:
/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/lib
```

You are linking statically against `libssl.a` and `libcrypto.a` that are part of your custom toolchain build (because of the `-L` flags in your `LDFLAGS` and the use of `-nodefaultlibs`). This is the correct setup.  Having these *separate* OpenSSL paths in `LIBRARY_PATH` and `LD_LIBRARY_PATH` creates the potential for conflicts and unintended behavior:

- **`LIBRARY_PATH` (Compile-Time):**  Even though you are using `-L` flags in `LDFLAGS` to specify the library search paths for the *final* linking stage, `LIBRARY_PATH` can still influence the compilation of individual `.o` files *if* any of those compilations need to link against libraries.  While this isn't the direct cause of the `atexit` error (which is a final linking issue), it introduces a risk.  The compiler *could* accidentally pick up headers or libraries from the separate OpenSSL installation if they are present and match what's being looked for.  This can lead to subtle inconsistencies.

- **`LD_LIBRARY_PATH` (Run-Time):** This is the *most dangerous* one in your current setup. `LD_LIBRARY_PATH` affects the *dynamic* linker at *runtime*.  You're building a largely static executable (because of `-nodefaultlibs` and linking with `.a` files). However:
  - If your final executable ends up having *any* dynamic dependencies (even indirectly), the dynamic linker will use `LD_LIBRARY_PATH` to find them.
  - If, for some reason, your build process *doesn't* completely statically link `libssl` and `libcrypto`, the runtime linker could pick up the shared libraries (`.so` files) from the separate OpenSSL installation in `LD_LIBRARY_PATH`.  This would lead to a mismatch between the libraries used at compile time (your custom-built ones) and the libraries used at runtime (the separate OpenSSL installation).  This can cause crashes, subtle bugs, or security vulnerabilities.
  - Even if *you* aren't using any shared openssl libraries, `libc` *itself* might have dynamic dependencies. It's generally best to have `LD_LIBRARY_PATH` only point to what you *absolutely* need at runtime.

**In short, the presence of the separate OpenSSL paths in `LIBRARY_PATH` and `LD_LIBRARY_PATH` is a potential source of conflicts and runtime errors, even if it's not the direct cause of the initial linking error you were facing.** It's a best practice to avoid having conflicting library paths like this.

**How to Fix It:**

1. **`LIBRARY_PATH`:**  Ideally, remove these OpenSSL paths from `LIBRARY_PATH`.  If you *absolutely need* `LIBRARY_PATH` for something else related to your custom toolchain, then keep *only* the toolchain paths:

    ```bash
    export LIBRARY_PATH=/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib:/home/gitea2/cplx/tools/tool/root/lib64:/home/gitea2/cplx/tools/tool/root/lib
    ```

    Or, even better, don't set `LIBRARY_PATH` at all if you can rely entirely on `-L` flags in `LDFLAGS` during compilation.

2. **`LD_LIBRARY_PATH`:** Remove the OpenSSL paths from `LD_LIBRARY_PATH`.  Again, if you need `LD_LIBRARY_PATH` for other runtime dependencies of your custom toolchain, keep only those paths:

    ```bash
    export LD_LIBRARY_PATH=/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib:/home/gitea2/cplx/tools/tool/root/lib64:/home/gitea2/cplx/tools/tool/root/lib
    ```

    Or, even better, avoid setting `LD_LIBRARY_PATH` globally.  Instead, use `-Wl,-rpath` in your `LDFLAGS` (which you already have!) to embed the necessary library search paths *within* the executable itself. This is generally the preferred approach for distributing applications with custom library dependencies, as it makes them self-contained and avoids relying on the user's environment.  Since you are already using `-Wl,-rpath` correctly, you *should* be able to completely unset `LD_LIBRARY_PATH`.

**After making these changes, run `echo $LIBRARY_PATH` and `echo $LD_LIBRARY_PATH` to verify that the OpenSSL paths are gone.** Then, rebuild your application. This will create a cleaner and more reliable build environment, eliminating the potential for conflicts with the separate OpenSSL installation. The verbose linker output (from adding `-Wl,-v`) will help confirm that the linker is only picking up libraries from your intended toolchain directories.

OK, but the idea of those *separately built* OpenSSL installation (`/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/...`) is that said OpenSSL folders are empty during build: they will be filled out only at the `make install` step. So they should not interfere with the compilation, right?

You are correct in that *if* the OpenSSL installation directories (`/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/...`) are truly *empty* during the build process (no `.so` files, no `.a` files, no header files), then they *shouldn't* directly interfere with the compilation and linking in the way I described before. The linker and compiler won't find anything to pick up from those empty directories.

However, even with empty directories, there are still a couple of reasons why it's better to remove them from `LIBRARY_PATH` and `LD_LIBRARY_PATH`:

1. **Future-Proofing and Avoiding Accidental Conflicts:** While they might be empty *now*, there's a risk that in the future, something might accidentally get placed in those directories *before* the `make install` step.  This could happen due to:
    - A mistake in the build process.
    - A partially failed build that leaves some files behind.
    - Changes to the build scripts or environment.
    - Another developer working on the project who isn't fully aware of this setup.

    By removing the paths, you eliminate this potential source of problems entirely.  It's a "defense in depth" approach.

2. **Clarity and Maintainability:**  Having those paths present, even if they're empty, makes the environment setup more complex and harder to understand. Someone else (or even your future self) looking at the environment variables might wonder why those paths are there and whether they're important.  Removing them makes the build environment cleaner and easier to reason about.

3. **`LD_LIBRARY_PATH` and Runtime Behavior:** This is still important even if the directories are empty during compilation.  `LD_LIBRARY_PATH` is a *runtime* variable. After the `make install` step, those directories *will* contain the shared libraries. If your final executable has *any* dynamic dependencies (even if you think it's fully static), the dynamic linker *will* search those directories.
    - If you are building openssl as part of the same process, then having openssl in `LD_LIBRARY_PATH` is likely *incorrect*, since, as you stated, the openssl you're compiling will install into the `/home/gitea2/cplx/tools/tool/root` prefix (due to your --sysroot setting). The openssl libraries installed into `/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/` will never be used, and might cause conflicts if some other application ever tried to load them.

**In summary, while empty directories *shouldn't* cause immediate problems during the build, removing the OpenSSL paths from `LIBRARY_PATH` and `LD_LIBRARY_PATH` is still the best practice for robustness, clarity, and preventing future runtime issues.** It's a small change that significantly improves the reliability and maintainability of your build environment.  Since you have correctly used `-Wl,-rpath` in `LDFLAGS`, you can and should remove those openssl directories from `LD_LIBRARY_PATH` to avoid potential runtime issues after openssl is installed.

OK, now I get this error:

```bash
${LDCMD:-gcc} -pthread -m64 -Wa,--noexecstack -DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=/home/gitea2/cplx/tools/tool/root -fPIC -O -U_FORTIFY_SOURCE -m64 -march=x86-64 -msse4.2 -L.  -L/home/gitea2/cplx/tools/tool/root/usr/lib64 -L/home/gitea2/cplx/tools/tool/root/usr/lib64 -L/home/gitea2/cplx/tools/tool/root/usr/lib -L/home/gitea2/cplx/tools/tool/root/lib64 -L/home/gitea2/cplx/tools/tool/root/lib -L/home/gitea2/cplx/tools/tool/root/usr/lib/gcc/x86_64-redhat-linux/8 -nodefaultlibs -Wl,-rpath,/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib:/home/gitea2/cplx/tools/tool/root/lib64:/home/gitea2/cplx/tools/tool/root/lib -Wl,--export-dynamic --sysroot=/home/gitea2/cplx/tools/tool/root -Wl,-v \
    -o apps/openssl apps/asn1pars.o apps/ca.o apps/ciphers.o apps/cms.o apps/crl.o apps/crl2p7.o apps/dgst.o apps/dhparam.o apps/dsa.o apps/dsaparam.o apps/ec.o apps/ecparam.o apps/enc.o apps/engine.o apps/errstr.o apps/gendsa.o apps/genpkey.o apps/genrsa.o apps/nseq.o apps/ocsp.o apps/openssl.o apps/passwd.o apps/pkcs12.o apps/pkcs7.o apps/pkcs8.o apps/pkey.o apps/pkeyparam.o apps/pkeyutl.o apps/prime.o apps/rand.o apps/rehash.o apps/req.o apps/rsa.o apps/rsautl.o apps/s_client.o apps/s_server.o apps/s_time.o apps/sess_id.o apps/smime.o apps/speed.o apps/spkac.o apps/srp.o apps/storeutl.o apps/ts.o apps/verify.o apps/version.o apps/x509.o \

     apps/libapps.a -lssl -lcrypto -ldl -pthread

collect2 version 4.8.5 20150623 (Red Hat 4.8.5-44)

/usr/bin/ld --sysroot=/home/gitea2/cplx/tools/tool/root --build-id --no-add-needed --eh-frame-hdr --hash-style=gnu -m elf_x86_64 -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o apps/openssl /home/gitea2/cplx/tools/tool/root/usr/lib64/../lib64/crt1.o /home/gitea2/cplx/tools/tool/root/usr/lib64/../lib64/crti.o /usr/lib/gcc/x86_64-redhat-linux/4.8.5/crtbegin.o -L. -L/home/gitea2/cplx/tools/tool/root/usr/lib64 -L/home/gitea2/cplx/tools/tool/root/usr/lib64 -L/home/gitea2/cplx/tools/tool/root/usr/lib -L/home/gitea2/cplx/tools/tool/root/lib64 -L/home/gitea2/cplx/tools/tool/root/lib -L/home/gitea2/cplx/tools/tool/root/usr/lib/gcc/x86_64-redhat-linux/8 -L/home/gitea2/cplx/tools/tool/root/usr/lib64/../lib64 -L/home/gitea2/cplx/tools/tool/root/lib64/../lib64 -L/usr/lib/gcc/x86_64-redhat-linux/4.8.5 -L/usr/lib/gcc/x86_64-redhat-linux/4.8.5/../../../../lib64 -L/home/gitea2/cplx/tools/tool/root/usr/lib64 -L/home/gitea2/cplx/tools/tool/root/lib64 -L/usr/lib/gcc/x86_64-redhat-linux/4.8.5/../../.. -rpath /home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib64:/home/gitea2/cplx/tools/tool/root/usr/lib:/home/gitea2/cplx/tools/tool/root/lib64:/home/gitea2/cplx/tools/tool/root/lib --export-dynamic -v apps/asn1pars.o apps/ca.o apps/ciphers.o apps/cms.o apps/crl.o apps/crl2p7.o apps/dgst.o apps/dhparam.o apps/dsa.o apps/dsaparam.o apps/ec.o apps/ecparam.o apps/enc.o apps/engine.o apps/errstr.o apps/gendsa.o apps/genpkey.o apps/genrsa.o apps/nseq.o apps/ocsp.o apps/openssl.o apps/passwd.o apps/pkcs12.o apps/pkcs7.o apps/pkcs8.o apps/pkey.o apps/pkeyparam.o apps/pkeyutl.o apps/prime.o apps/rand.o apps/rehash.o apps/req.o apps/rsa.o apps/rsautl.o apps/s_client.o apps/s_server.o apps/s_time.o apps/sess_id.o apps/smime.o apps/speed.o apps/spkac.o apps/srp.o apps/storeutl.o apps/ts.o apps/verify.o apps/version.o apps/x509.o apps/libapps.a -lssl -lcrypto -ldl /usr/lib/gcc/x86_64-redhat-linux/4.8.5/crtend.o /home/gitea2/cplx/tools/tool/root/usr/lib64/../lib64/crtn.o
GNU ld version 2.27-44.base.el7_9.1/usr/bin/ld: apps/openssl.o: undefined reference to symbol 'fflush@@GLIBC_2.2.5'
/home/gitea2/cplx/tools/tool/root/lib64/libc.so.6: error adding symbols: DSO missing from command line
collect2: error: ld returned 1 exit status
```

First, can you confirm my variables modifications are reflected in this new gcc command?
Then what can you tell from the ld error, considering the `-Wl,-v` debug option was used?

Let's break down the new error and confirm your variable changes.

**1. Variable Modifications Confirmation:**

Yes, your variable modifications are reflected in the `gcc` command you provided. Let's see how:

- **`LDFLAGS`:**  All the `-L` paths, `-nodefaultlibs`, `-Wl,-rpath`, `-Wl,--export-dynamic`, `--sysroot`, and now `-Wl,-v` are present, as expected from your updated `LDFLAGS`. This is good.
- **`LIBS`:** The original command line *explicitly* lists `-lssl -lcrypto -ldl -pthread`. Notice, there is *no* `-lgcc_s -lc -lm -lc_nonshared`. This indicates that your `LIBS` environment variable is either *not being used*, is empty, or the makefile is not using `${LIBS}` in the link command. This is the **primary reason** you are getting the new error.
- **`CFLAGS` and `CPPFLAGS`**: These are correctly reflected in the compilation options before the linking stage.

**2. Analyzing the `ld` Error with Verbose Output:**

The verbose output from `ld` (triggered by `-Wl,-v`) is *extremely* helpful:

```bash
GNU ld version 2.27-44.base.el7_9.1/usr/bin/ld: apps/openssl.o: undefined reference to symbol 'fflush@@GLIBC_2.2.5'
/home/gitea2/cplx/tools/tool/root/lib64/libc.so.6: error adding symbols: DSO missing from command line
collect2: error: ld returned 1 exit status
```

Here's the breakdown:

- **`apps/openssl.o: undefined reference to symbol 'fflush@@GLIBC_2.2.5'`:** This tells us that the object file `apps/openssl.o` (which is part of your OpenSSL application) needs the function `fflush`.  The `@@GLIBC_2.2.5` part is a symbol version, indicating that it specifically needs the version of `fflush` that was provided in GLIBC version 2.2.5 (or compatible).  `fflush` is a standard C library function (for flushing output streams), so it *should* be in `libc`.

- **`/home/gitea2/cplx/tools/tool/root/lib64/libc.so.6: error adding symbols: DSO missing from command line`:**  This is the *crucial* part.  The linker found a `libc.so.6` (a shared object, hence ".so") within your custom toolchain's root.  However, it says "DSO missing from command line."  This means the linker was *not instructed to link against this shared object*.  This happens precisely because you are using `-nodefaultlibs` and you are *not* including `-lc` (which would normally link against `libc`) *on the command line used by the linker*.

- **Why not `-lc`?:** As mentioned before, it is missing because `${LIBS}` is not being used. You *must* include `-lc` in the linking command to provide the standard C library functions, like `fflush`.
- **Why `libc.so.6` and not `libc.a`?:** The linker tried `libc.so.6`, a *shared* library, and not `libc.a`, the *static* library.  Even though you have `libc.a`, because `-nodefaultlibs` is used, the linker *only* considers libraries explicitly named on the command line.  Since you didn't specify `libc.a` explicitly, and since it encountered a `-lssl` and `-lcrypto`, it attempted to do dynamic linking. When it didn't find the needed symbols *dynamically* (because they weren't explicitly listed), it gave the "DSO missing" error.

**The Solution (and why it confirms your other changes):**

The core issue is still the linking order and the missing `-lc` (and other standard libraries). You *must* ensure your `LIBS` variable is used. There are two ways to do this, and I recommend both:

1. **Modify the Makefile (Best Solution):**  The *best* solution is to find where in your `Makefile` the final linking command is generated and ensure it includes `${LIBS}`:

    ```makefile
    # ... other Makefile rules ...

    apps/openssl: $(OBJECTS)
     $(LDCMD) $(LDFLAGS) -o $@ $(OBJECTS) apps/libapps.a -lssl -lcrypto $(LIBS)
     #^^^ Key change: Add $(LIBS) here, at the END
    ```

    This ensures that `-lgcc_s -ldl -lpthread -lc -lm -lc_nonshared` (from your `LIBS` variable) are added at the *end* of the linking command, *after* `-lssl` and `-lcrypto`. This is the correct, robust, and maintainable solution.

2. **Set LIBS and *force* its use:**
   If, and only if, modifying the makefile directly is difficult, you can set `LIBS` and also *add* the libraries from `LIBS` *explicitly to the command that you're running*. This is less ideal but will work:

    ```bash
    export LIBS="-lgcc_s -ldl -lpthread -lc -lm -lc_nonshared"

    ${LDCMD:-gcc} -pthread -m64 ... -Wl,-v \
      -o apps/openssl apps/asn1pars.o ... apps/x509.o \
      apps/libapps.a -lssl -lcrypto ${LIBS}
    ```

   This directly adds the contents of `LIBS` to the end of the linking command.

**In either case, the correct linking order will be achieved, and the linker will find `fflush` within your `libc.a` (because `-lc` will now pull in the correct C library).**  The `-Wl,-v` output should then show the linker successfully finding and using `libc.a` (or `libc.so.6` if you *remove* `-nodefaultlibs`, but I strongly recommend the static linking approach with `-nodefaultlibs` for consistency with your custom toolchain).

By making this change, you will be using your defined environment variables correctly, and you will see the linker use the correct libraries in the correct order, resolving the "undefined reference" and "DSO missing" errors.  The key is making sure the contents of your `LIBS` variable *actually get used* by the linker.

I confirm, fflush symbol is in libc.a:

```bash
[CPLX-OPENSSL111-DEV] gitea2@cactislux801:~/tools/tool/root$ nm -A ./usr/lib64/libc.a 2>/dev/null | grep fflush | grep -v " U "
./usr/lib64/libc.a:iofflush.o:0000000000000000 T _IO_fflush
./usr/lib64/libc.a:iofflush.o:000000000000013d t _L_lock_39
./usr/lib64/libc.a:iofflush.o:0000000000000158 t _L_unlock_113
./usr/lib64/libc.a:iofflush.o:0000000000000173 t _L_unlock_215
./usr/lib64/libc.a:iofflush.o:                 w __start___libc_IO_vtables
./usr/lib64/libc.a:iofflush.o:                 w __stop___libc_IO_vtables
./usr/lib64/libc.a:iofflush.o:0000000000000000 W fflush
./usr/lib64/libc.a:iofflush_u.o:                 w __start___libc_IO_vtables
./usr/lib64/libc.a:iofflush_u.o:                 w __stop___libc_IO_vtables
./usr/lib64/libc.a:iofflush_u.o:0000000000000000 T fflush_unlocked
```

From the Makefile, I see:

```bash
[CPLX-OPENSSL111-DEV] gitea2@cactislux801:~/tools/tool/sources/1.1.1w$ grep LIBS Makefile
LIBS=apps/libapps.a libcrypto.a libssl.a test/libtestutil.a
SHLIBS=libcrypto$(SHLIB_EXT) libssl$(SHLIB_EXT)
INSTALL_LIBS=libcrypto.a libssl.a
INSTALL_SHLIBS=libcrypto$(SHLIB_EXT) libssl$(SHLIB_EXT)
EX_LIBS=
CNF_EX_LIBS=-ldl -pthread
LIB_EX_LIBS=$(CNF_EX_LIBS) $(EX_LIBS)
DSO_EX_LIBS=$(CNF_EX_LIBS) $(EX_LIBS)
BIN_EX_LIBS=$(CNF_EX_LIBS) $(EX_LIBS)
        $(RM) $(LIBS)
        @set -e; for l in $(INSTALL_LIBS); do \
        @set -e; for l in $(INSTALL_LIBS); do \
        @set -e; for s in dummy $(INSTALL_SHLIBS); do \
libcrypto.pc libssl.pc openssl.pc: configdata.pm $(LIBS) libcrypto$(SHLIB_EXT_SIMPLE) libssl$(SHLIB_EXT_SIMPLE)
            echo 'Libs.private: $(LIB_EX_LIBS)'; \
                 $(LIB_EX_LIBS)
                 -lcrypto $(LIB_EX_LIBS)
```

LIBS seems hardcoded.

<https://wiki.openssl.org/index.php/Compilation_and_Installation#PREFIX_and_OPENSSLDIR> mentions a `./Configure` options:

- `-Lsomething`, `-lsomething`, `-Ksomething`, `-Wl,something`: Linker options, will become part of LDFLAGS.
- `-anythingelse`, `+anythingelse`: Compiler options, will become part of CFLAGS.

This is part of the options:

```bash
$ ./Configure --help
Usage: Configure [no-<cipher> ...] [enable-<cipher> ...] [experimental-<cipher> ...]
[-Dxxx] [-lxxx] [-Lxxx] [-fxxx] [-Kxxx] [no-hw-xxx|no-hw] [[no-]threads] [[no-]shared]
[[no-]zlib|zlib-dynamic] [no-asm] [no-dso] [no-krb5] [sctp] [386] [--prefix=DIR]
[--openssldir=OPENSSLDIR] [--with-xxx[=vvv]] [--test-sanity] os/compiler[:flags]
```

Can I use those to add the missing $LIB directives? (the -l, in specific order)

You're on the right track! Since the `Makefile` hardcodes `LIBS`, and you want to control the linking order and include `-lgcc_s -ldl -lpthread -lc -lm -lc_nonshared`, you need to use the `Configure` script's options to inject these into the generated `Makefile`.

Here's the breakdown and solution, combining the information from the OpenSSL wiki and your `Makefile` snippets:

1. **Understanding the `Makefile`:**

    - `LIBS`: This variable, as you observed, is hardcoded in the `Makefile` to `apps/libapps.a libcrypto.a libssl.a test/libtestutil.a`. This is why your environment variable `LIBS` wasn't being used.
    - `EX_LIBS`: This variable seems intended for *extra* libraries, and it's empty by default.
    - `CNF_EX_LIBS`: This variable contains `-ldl -pthread`, which *are* needed.
    - `LIB_EX_LIBS`, `DSO_EX_LIBS`, `BIN_EX_LIBS`:  These variables all include `$(CNF_EX_LIBS)` and `$(EX_LIBS)`. This is where we'll inject our additional libraries.
    - The crucial lines later in the `Makefile` (that you found) are where the `libcrypto.pc`, `libssl.pc`, and `openssl.pc` files are generated. These `.pc` files are used by `pkg-config` to provide information about the libraries. The relevant line is:

        ```makefile
        echo 'Libs.private: $(LIB_EX_LIBS)'; \
        ```

        This shows that `LIB_EX_LIBS` is what gets used for the "private" libraries (i.e., the ones that are needed for linking, but shouldn't be exposed to applications using OpenSSL via pkg-config).

2. **Using `./Configure`:**

    The OpenSSL `Configure` script allows you to pass linker options using `-l` (lowercase L).  Crucially, the order in which you specify these `-l` options *will be preserved* in the generated `Makefile`.  This gives you the control you need.

3. **The Solution: Modify your `./Configure` command:**

    You'll add `-l` options to your `./Configure` command *in the correct order*.  You'll be effectively setting `EX_LIBS` via the command line, and because `LIB_EX_LIBS` includes `$(EX_LIBS)`, your libraries will be included in the `Libs.private` section of the generated `.pc` files and, most importantly, used during the linking of the OpenSSL tools.

    Here's how your `./Configure` command should look (combining your existing options with the new `-l` options):

    ```bash
    ./Configure --prefix=/home/gitea2/cplx/tools/tool/root/usr --openssldir=/home/gitea2/cplx/tools/tool/root/usr/ssl --libdir=lib64 no-shared no-zlib no-async -DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI -fPIC -O -U_FORTIFY_SOURCE -m64 -march=x86-64 -msse4.2 linux-x86_64 -lgcc_s -ldl -lpthread -lc -lm -lc_nonshared
    ```

    - I used your CFLAGS inside Configure, because the `Makefile` generated would erase them.
    - I've added `-lgcc_s -ldl -lpthread -lc -lm -lc_nonshared` at the *end* of the `Configure` command. These are the libraries from your intended `LIBS` environment variable, and they are now in the correct order. The `linux-x86_64` is important: it must appear before the linker and compiler flags.
    - **Important:** The `no-shared` option is crucial here. It tells OpenSSL to build static libraries (`.a` files) instead of shared libraries (`.so` files). This aligns with your use of `-nodefaultlibs` and your intention to link statically.
    - **Important:** The `--libdir=lib64` is important to install in the lib64, instead of the lib folder.

4. **Complete Build Process**

    ```bash
    ./Configure --prefix=/home/gitea2/cplx/tools/tool/root/usr --openssldir=/home/gitea2/cplx/tools/tool/root/usr/ssl --libdir=lib64 no-shared no-zlib no-async -DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI -fPIC -O -U_FORTIFY_SOURCE -m64 -march=x86-64 -msse4.2 linux-x86_64 -lgcc_s -ldl -lpthread -lc -lm -lc_nonshared
    make clean
    make -j$(nproc)
    make install
    ```

5. **Verify (After Building):**

    After running `make`, check the generated `libcrypto.pc`, `libssl.pc`, and `openssl.pc` files (they should be in your build directory). They should contain a line like this:

    ```bash
    Libs.private: -lgcc_s -ldl -lpthread -lc -lm -lc_nonshared
    ```

    This confirms that your libraries have been correctly incorporated. Also, use `ldd` on any built binaries (like `apps/openssl`) to verify that they don't have unexpected dynamic dependencies.

By using the `-l` options in the `./Configure` command, you correctly inject the necessary libraries into the OpenSSL build process, overriding the hardcoded `LIBS` variable in the `Makefile` and achieving the correct linking order. This should definitively resolve the "undefined reference" and "DSO missing" errors. This is the preferred, clean, and reliable way to handle this situation.

You said: The `--libdir=lib64` is important to install in the lib64, instead of the lib folder. Should't I use the full path though? Like `/home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr/lib64`?

~~ ~~
