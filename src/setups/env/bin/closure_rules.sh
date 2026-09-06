#!/bin/bash
#
# closure_rules.sh -- the invariants of the v0.27.0 runtime-closure checker.
# Created at Step 1 with this contract and nothing else. Step 3 starts filling
# it with the derived membership half, Step 4 adds the other three and the
# aggregation, and Step 5 adds the waiver outcomes. Until then the file has a
# body of zero lines, which the Step 1 harness suite measures rather than
# assumes.
#
# THIS MODULE OWNS ALL FOUR INVARIANTS, THE DERIVED MEMBERSHIP HALF INCLUDED:
#
#   membership   in two halves that cannot substitute for each other. The
#                derived half lands HERE and not in `closure_check.sh`:
#                membership is an invariant, so it lives where the other three
#                do, and `closure_check.sh` gains the call and nothing else.
#   coherence    version needs resolved through the provider the object names.
#                It STILL EVALUATES when rule 1 refuses, against the first
#                candidate in scope order, because loader selection is
#                deterministic and refusing the ambiguity is not a reason to
#                throw away a real result.
#   rule 1       duplicate providers, in the loader's terms.
#   rule 2       declared family generations, in terms nothing in the file can
#                supply, which is why the family list is declared configuration.
#
# IT ALSO OWNS THE TWO OUTCOMES THAT ARE NOT PASS OR FAIL:
#
#   the waiver outcomes   a waiver is an exception with an expiry condition and
#                         never a mute. Its subjects are FLOOR MEMBERS ONLY: an
#                         UNEXPECTED directory or root is UNWAIVABLE, and no
#                         code path here may reach one.
#   UNDETERMINED          reserved for ONE thing, an input that could not be
#                         obtained. It is neither a pass nor a failure, it is
#                         reported with the input it lacked, and it never counts
#                         toward a green. Suppression follows data availability
#                         alone, never the presence of another refusal.
#
# It is SOURCED by `closure_check.sh` and never executed.
