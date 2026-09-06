#!/bin/bash
#
# closure_elf.sh -- the object reader of the v0.27.0 runtime-closure checker.
# Created at Step 1 with this contract and nothing else. Step 3 fills it, and
# until then the file has a body of zero lines, which the Step 1 harness suite
# measures rather than assumes.
#
# THIS MODULE OWNS, AND IS THE ONLY PLACE THAT MAY OWN:
#
#   the object reader      one `readelf -d -V` per shipped ELF, answering the
#                          dynamic entries and the version needs together. Four
#                          invariants asking separately would fork 2512 times
#                          where 628 suffice.
#   the provider index     the provider directories enumerated ONCE into a
#                          name-to-paths map, so resolving a DT_NEEDED name is a
#                          hash lookup and not a directory scan per name. The
#                          index is built OUTSIDE the object loop; built inside
#                          it, the walk would be O(n^2), which is the one shape
#                          this effort's complexity bound forbids.
#
# IT HAS NO VERDICT OF ITS OWN. It reads objects and answers questions about
# them; whether an answer is a refusal belongs to `closure_rules.sh`, which owns
# all four invariants. A reader that started refusing would put one invariant in
# two files.
#
# It is SOURCED by `closure_check.sh` and never executed.
