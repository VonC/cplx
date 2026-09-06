#!/bin/bash
#
# closure_config.sh -- the configuration module of the v0.27.0 runtime-closure
# checker. Created at Step 1 with this contract and nothing else. Step 2 fills
# it, and until then the file has a body of zero lines, which the Step 1 harness
# suite measures rather than assumes.
#
# WHY IT EXISTS BEFORE IT HAS A BODY. The module set of this effort is FIXED AND
# UNCONDITIONAL: four modules, created together at Step 1, each with one owner
# and one responsibility. A topology that could still gain a module, or move a
# responsibility, is not a contract, and an implementer following it would have
# two boundaries to choose between. So the four files land in one step, and the
# step that owns a responsibility fills its file.
#
# THIS MODULE OWNS, AND IS THE ONLY PLACE THAT MAY OWN:
#
#   closure_config_parse           the ONE grammar parser every party uses. An
#                                  exact-byte digest makes two parties agree on
#                                  the bytes and not on their meaning, so the
#                                  grammar is a separate contract from the
#                                  digest and both are required. Unknown and
#                                  duplicate records fail closed.
#   closure_config_digest          SHA-256 over the configuration document's
#                                  exact committed bytes, never over parsed
#                                  content, so a party that cannot parse the
#                                  format can still reproduce the value.
#   closure_envelope_check         the agent-side check, which is INTERNAL
#                                  CONSISTENCY and not authority, and whose
#                                  output states that limit itself.
#   closure_config_resolve_commit  the cplx-side resolution, refusing a
#                                  reference that is not a commit SHA.
#
# It is SOURCED by `closure_check.sh` and by `closure_publish.sh`, and never
# executed. Keeping it apart from the invariants is what lets publication reuse
# the parser and the digest without pulling in the four archive rules.
