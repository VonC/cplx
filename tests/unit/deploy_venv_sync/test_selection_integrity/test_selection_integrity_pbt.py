"""Generated selection permutations retain identity and reject mutations."""

import json
import random
import unittest

from .test_selection_integrity_tdd import SelectionIntegrityTest


class SelectionPermutationTest(SelectionIntegrityTest):
    """Profile order cannot bless a changed lock, tag or wheel digest."""

    def test_generated_identity_mutations(self):
        rng = random.Random(271002)
        for _ in range(40):
            profile = json.loads(json.dumps(self.data))
            rng.shuffle(profile["tags"])
            rng.shuffle(profile["groups"])
            rng.shuffle(profile["extras"])
            self.profile.write_text(json.dumps(profile))
            self.selection.verify(self.lock, self.project, self.profile, self.wheels, self.site)
            mutation = rng.choice(("lock", "tag", "hash"))
            if mutation == "lock":
                profile["lock_sha256"] = "0" * 64
            elif mutation == "tag":
                profile["tags"] = ["cp399-none-other"]
            else:
                profile["selected"][0]["sha256"] = "0" * 64
            self.profile.write_text(json.dumps(profile))
            with self.assertRaises(ValueError):
                self.selection.verify(self.lock, self.project, self.profile, self.wheels, self.site)


if __name__ == "__main__":
    unittest.main()
