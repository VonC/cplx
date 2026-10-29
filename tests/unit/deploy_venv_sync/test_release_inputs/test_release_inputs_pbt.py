"""Deterministic location permutations reject independent lock identity mutations."""

import copy
import itertools
import unittest

from .test_release_inputs_tdd import module


class TransportProperties(unittest.TestCase):
    """Every generated mapping is reversible and changes no dependency identity."""

    def test_location_permutations_and_mutations(self):
        transport = module("deploy_venv_transport")
        for order in itertools.permutations(range(4)):
            source = {"package": [{"name": f"p{i}", "version": "1.0", "marker": "sys_platform == 'linux'", "hash": "sha256:" + str(i) * 64, "url": f"https://example.org/{i}.whl"} for i in order]}
            mapping = {f"https://example.org/{i}.whl": f"file:///bundle/{i}.whl" for i in order}
            candidate = transport.rewrite(source, mapping)
            transport.validate(source, candidate, mapping)
            self.assertEqual(source, transport.rewrite(candidate, {v: k for k, v in mapping.items()}))
            for field in ("name", "version", "marker", "hash"):
                changed = copy.deepcopy(candidate)
                changed["package"][0][field] += "changed"
                with self.assertRaises(ValueError):
                    transport.validate(source, changed, mapping)
