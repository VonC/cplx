"""Exercise persistence and fail-closed provider evidence without Linux dependencies."""

import contextlib
import importlib.util
import io
import itertools
import json
import os
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile
import types
import unittest
from unittest import mock


PROBE_PATH = (Path(__file__).resolve().parents[4]
              / "src/install/env/python/sqlite_probe.py")
SPEC = importlib.util.spec_from_file_location("sqlite_probe_under_test", PROBE_PATH)
probe = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(probe)
DEVICE_NUMBERS = probe.device_numbers


class SqliteProbeTests(unittest.TestCase):
    """Keep fixture identities independent of module observations and test refusals."""

    def setUp(self):
        self.contexts = contextlib.ExitStack()
        self.addCleanup(self.contexts.close)
        self.work = Path(self.contexts.enter_context(tempfile.TemporaryDirectory())).resolve()
        self.root = self.work / "python"
        self.executable = self.file("python/python-3.13/bin/python")
        self.extension = self.file("python/python-3.13/lib/lib-dynload/_sqlite3.so")
        self.provider = self.file("python/root/usr/lib64/libsqlite3.so.0.8.6")
        self.scratch = self.work / "scratch"
        self.scratch.mkdir()
        # NTFS has no Linux device major/minor; only synthetic mapping tests use this.
        if os.name != "posix":
            self.contexts.enter_context(mock.patch.object(probe, "device_numbers", return_value=(0, 7)))

    def file(self, relative):
        path = self.work / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(b"fixture")
        return path

    def link(self, path, target):
        path.parent.mkdir(parents=True, exist_ok=True)
        try:
            path.symlink_to(target, target_is_directory=target.is_dir())
        except OSError as error:
            if os.name == "nt" and getattr(error, "winerror", None) == 1314:
                self.skipTest("symbolic links require the Linux test run on this authoring host")
            raise
        return path

    def mapping(self, path=None, *, inode=None, suffix="", encoded=False):
        path = path or self.provider
        ident = probe.file_identity(path)
        major, minor, actual_inode = ident["identity"]
        name = path.as_posix()
        if encoded:
            name = name.replace("\\", "\\134").replace("\n", "\\012")
        return (f"1000-2000 r-xp 00000000 {major:x}:{minor:x} "
                f"{actual_inode if inode is None else inode} {name}{suffix}\n")

    def args(self, **changes):
        values = dict(stage="installed", expected_python_root=str(self.root),
                      expected_extension_root=str(self.extension.parent),
                      expected_provider=str(self.provider), scratch_dir=str(self.scratch),
                      expected_libpython=None)
        values.update(changes)
        return types.SimpleNamespace(**values)

    def run_probe(self, args=None, maps=None):
        native = types.SimpleNamespace(__file__=str(self.extension))
        def import_module(name):
            return native if name == "_sqlite3" else sqlite3
        with mock.patch.object(probe.sys, "executable", str(self.executable)), \
                mock.patch.object(probe.importlib, "import_module", side_effect=import_module), \
                mock.patch.object(probe, "read_maps", return_value=maps or self.mapping()) as reader:
            result = probe.assess(args or self.args())
        return result, reader

    def test_persistence_uses_two_connections_and_only_owned_cleanup(self):
        sentinel = self.scratch / "keep.txt"
        sentinel.write_text("keep", encoding="utf-8")
        events = []
        class Connection:
            """Record the real database connection lifecycle without simulating SQLite."""
            def __init__(self, connection):
                self.connection = connection
            def __getattr__(self, name):
                return getattr(self.connection, name)
            def commit(self):
                events.append("commit")
                self.connection.commit()
            def close(self):
                events.append("close")
                self.connection.close()
        def connect(path):
            events.append("connect")
            return Connection(sqlite3.connect(path))
        outcome = probe.database_roundtrip(types.SimpleNamespace(connect=connect), self.scratch)
        self.assertEqual(outcome, "passed")
        self.assertEqual(events, ["connect", "commit", "close", "connect", "close"])
        self.assertEqual(list(self.scratch.iterdir()), [sentinel])

    def test_database_error_cleans_owned_directory(self):
        module = types.SimpleNamespace(connect=mock.Mock(side_effect=OSError("database refused")))
        with self.assertRaises(OSError):
            probe.database_roundtrip(module, self.scratch)
        self.assertEqual(list(self.scratch.iterdir()), [])

    def test_wrong_reopened_record_refuses_database_success(self):
        connection = mock.Mock()
        connection.execute.return_value.fetchall.return_value = [(1, "wrong")]
        with self.assertRaises(probe.ProbeError):
            probe.database_roundtrip(types.SimpleNamespace(connect=lambda _: connection), self.scratch)
        self.assertEqual(connection.close.call_count, 2)
        self.assertEqual(list(self.scratch.iterdir()), [])

    def test_duplicate_segments_and_generated_permutations_keep_one_identity(self):
        unrelated = self.file("elsewhere/libother.so")
        lines = [self.mapping(), self.mapping(), self.mapping(unrelated),
                 "3000-4000 rw-p 00000000 00:00 0 [heap]\n"]
        for permutation in itertools.permutations(lines):
            with self.subTest(order=permutation):
                records = probe.parse_maps("".join(permutation))
                evidence = probe.match_library(records, self.provider, self.root, "sqlite")
                self.assertEqual(evidence["path"], str(self.provider.resolve()))

    def test_stat_work_does_not_grow_with_duplicate_map_segments(self):
        records = probe.parse_maps(self.mapping() * 100)
        with mock.patch.object(probe, "file_identity", wraps=probe.file_identity) as observe:
            probe.match_library(records, self.provider, self.root, "sqlite")
        self.assertLessEqual(observe.call_count, 2)

    def test_spaces_and_escaped_newline_in_provider_path(self):
        filenames = ["python/space dir/libsqlite3.so.0"]
        if os.name == "posix":
            filenames += ["python/new\nline/libsqlite3.so.0", "python/literal\\012/libsqlite3.so.0"]
        for filename in filenames:
            path = self.file(filename)
            with self.subTest(filename=filename):
                records = probe.parse_maps(self.mapping(path, encoded=True))
                self.assertEqual(probe.match_library(records, path, self.root, "sqlite")["path"], str(path))
        path = self.file("python/escaped space/libsqlite3.so.0")
        maps = self.mapping(path).replace("escaped space", "escaped\\040space")
        self.assertEqual(probe.match_library(probe.parse_maps(maps), path, self.root, "sqlite")["path"], str(path))

    def test_malformed_records_refuse_evidence(self):
        for content in ["nonsense", "1000-2000 r-xp 0 00:00 nope /libsqlite3.so", "",
                        "2000-1000 r-xp 0 00:00 1 /libsqlite3.so",
                        "1000-2000 xxxx 0 00:00 1 /libsqlite3.so"]:
            with self.subTest(content=content), self.assertRaises(probe.ProbeError):
                probe.parse_maps(content)

    def test_host_other_tool_and_competing_provider_fail(self):
        for relative in ["host/libsqlite3.so.0", "git/root/libsqlite3.so.0"]:
            other = self.file(relative)
            for maps in [self.mapping(other), self.mapping() + self.mapping(other)]:
                with self.subTest(relative=relative, maps=maps), self.assertRaises(probe.ProbeError):
                    probe.match_library(probe.parse_maps(maps), self.provider, self.root, "sqlite")

    def test_missing_deleted_and_mismatched_backing_files_fail(self):
        missing = self.file("python/root/missing/libsqlite3.so.0")
        missing_map = self.mapping(missing)
        missing.unlink()
        wrong = probe.file_identity(self.provider)["identity"][2] + 1
        for maps in [missing_map, self.mapping(suffix=" (deleted)"), self.mapping(inode=wrong),
                     "1000-2000 r-xp 0 00:00 0 [heap]\n"]:
            with self.subTest(maps=maps), self.assertRaises(probe.ProbeError):
                probe.match_library(probe.parse_maps(maps), self.provider, self.root, "sqlite")

    def test_device_mismatch_cannot_match_by_path(self):
        records = probe.parse_maps(self.mapping())
        records[0]["identity"] = (99999, 99999, records[0]["identity"][2])
        with self.assertRaises(probe.ProbeError):
            probe.match_library(records, self.provider, self.root, "sqlite")

    def test_unreadable_backing_file_cannot_pass(self):
        records = probe.parse_maps(self.mapping())
        with mock.patch.object(Path, "open", side_effect=PermissionError("denied")), \
                self.assertRaises(probe.ProbeError):
            probe.match_library(records, self.provider, self.root, "sqlite")

    def test_soname_and_root_symlinks_allow_only_contained_backing(self):
        soname = self.link(self.provider.parent / "libsqlite3.so.0", self.provider)
        alias = self.link(self.work / "alias", self.root)
        evidence = probe.match_library(probe.parse_maps(self.mapping()), soname, alias, "sqlite")
        self.assertEqual(evidence["path"], str(self.provider))
        outside = self.file("host/libsqlite3.so.0")
        escaped = self.link(self.root / "escape/libsqlite3.so.0", outside)
        with self.assertRaises(probe.ProbeError):
            probe.match_library(probe.parse_maps(self.mapping(outside)), escaped, self.root, "sqlite")

    def test_wrong_extension_root_and_executable_fail_before_maps(self):
        for args in [self.args(expected_extension_root=str(self.provider.parent)),
                     self.args(expected_python_root=str(self.provider.parent))]:
            result, reader = self.run_probe(args)
            self.assertEqual(result["outcome"], "failed")
            reader.assert_not_called()

    def test_installed_extension_symlink_escape_fails(self):
        self.extension = self.link(self.extension.parent / "escape.so", self.file("host/_sqlite3.so"))
        result, reader = self.run_probe()
        self.assertEqual(result["outcome"], "failed")
        reader.assert_not_called()

    def test_import_failure_returns_a_structured_failure(self):
        with mock.patch.object(probe.sys, "executable", str(self.executable)), \
                mock.patch.object(probe.importlib, "import_module", side_effect=ImportError("no _sqlite3")):
            result = probe.assess(self.args())
        self.assertEqual(result["outcome"], "failed")
        self.assertIn("no _sqlite3", result["error"])

    def test_maps_are_read_once_after_database_reopen(self):
        events = []
        actual_roundtrip = probe.database_roundtrip
        def database(*args):
            result = actual_roundtrip(*args)
            events.append("database closed")
            return result
        def maps():
            events.append("maps")
            return self.mapping()
        with mock.patch.object(probe, "database_roundtrip", side_effect=database), \
                mock.patch.object(probe, "read_maps", side_effect=maps):
            # run_probe owns its maps patch, so use the public assessment directly.
            native = types.SimpleNamespace(__file__=str(self.extension))
            with mock.patch.object(probe.sys, "executable", str(self.executable)), \
                    mock.patch.object(probe.importlib, "import_module", side_effect=[native, sqlite3]):
                result = probe.assess(self.args())
        self.assertEqual(result["outcome"], "passed", result)
        self.assertEqual(events, ["database closed", "maps"])
        self.assertEqual(result["database"], "passed")
        self.assertEqual(result["provider"]["path"], str(self.provider))

    def test_unavailable_proc_is_inconclusive(self):
        with mock.patch.object(Path, "read_text", side_effect=PermissionError("no maps")), \
                self.assertRaises(probe.ProbeError):
            probe.read_maps()

    def test_absent_expected_material_and_relative_paths_cannot_pass(self):
        for args in [self.args(expected_provider=str(self.root / "missing")),
                     self.args(expected_python_root="relative"),
                     self.args(scratch_dir=str(self.root / "missing"))]:
            result, _ = self.run_probe(args)
            self.assertNotEqual(result["outcome"], "passed")

    def test_operator_stage_and_cli_propagate_all_outcomes(self):
        result, _ = self.run_probe(self.args(stage="operator"))
        self.assertEqual(result["outcome"], "passed", result)
        arguments = ["--stage", "operator", "--expected-python-root", str(self.root),
                     "--expected-extension-root", str(self.extension.parent),
                     "--expected-provider", str(self.provider), "--scratch-dir", str(self.scratch)]
        for outcome, expected_status in [("passed", 0), ("failed", 2), ("inconclusive", 2)]:
            output = io.StringIO()
            with mock.patch.object(probe, "assess", return_value={"outcome": outcome}), \
                    contextlib.redirect_stdout(output):
                self.assertEqual(probe.main(arguments), expected_status)
            self.assertEqual(json.loads(output.getvalue())["outcome"], outcome)

    def test_build_links_and_expected_libpython_use_one_observation(self):
        source = self.root / "sources/Python-3.13.15"
        self.executable = self.file("python/sources/Python-3.13.15/python")
        libpython = self.file("python/sources/Python-3.13.15/libpython3.13.so.1.0")
        module = self.file("python/sources/Python-3.13.15/Modules/_sqlite3.so")
        self.extension = self.link(source / "build/lib.test/_sqlite3.so", module)
        args = self.args(stage="build", expected_libpython=str(libpython))
        maps = self.mapping() + self.mapping(libpython)
        result, reader = self.run_probe(args, maps)
        self.assertEqual(result["outcome"], "passed", result)
        self.assertEqual(result["libpython"]["path"], str(libpython))
        reader.assert_called_once_with()
        generated = self.extension
        self.extension = self.link(source / "elsewhere/_sqlite3.so", module)
        result, reader = self.run_probe(args, maps)
        self.assertEqual(result["outcome"], "failed")
        reader.assert_not_called()
        self.extension = generated
        result, _ = self.run_probe(args, self.mapping())
        self.assertEqual(result["outcome"], "inconclusive")
        stale = self.file("python/python-old/lib/libpython3.13.so.1.0")
        result, _ = self.run_probe(args, self.mapping() + self.mapping(stale))
        self.assertEqual(result["outcome"], "failed")
        self.extension.unlink()
        self.link(self.extension, self.file("python/sources/Python-3.13.15/stale/_sqlite3.so"))
        result, reader = self.run_probe(args, maps)
        self.assertEqual(result["outcome"], "failed")
        reader.assert_not_called()

    def test_missing_build_library_and_invalid_stage_fail(self):
        for args in [self.args(stage="build"), self.args(stage="invented")]:
            result, _ = self.run_probe(args)
            self.assertEqual(result["outcome"], "failed")

    def build_fixture(self):
        """Use plain files so source refusals run without symlink privileges."""
        self.executable = self.file("python/sources/Python-3.13.15/python")
        libpython = self.file("python/sources/Python-3.13.15/libpython3.13.so.1.0")
        self.extension = self.file("python/sources/Python-3.13.15/Modules/_sqlite3.so")
        return self.args(stage="build", expected_libpython=str(libpython))

    def assert_refused_before_maps(self, args, message, outcome="failed"):
        result, reader = self.run_probe(args)
        self.assertEqual(result["outcome"], outcome, result)
        self.assertIn(message, result["error"])
        reader.assert_not_called()

    def test_build_executable_must_be_beside_declared_libpython(self):
        args = self.build_fixture()
        self.executable = self.file("python/other/python")
        self.assert_refused_before_maps(args, "source executable differs")

    def test_build_library_root_must_stay_inside_python_tree(self):
        args = self.build_fixture()
        args.expected_libpython = str(self.file("outside/libpython3.13.so.1.0"))
        self.assert_refused_before_maps(args, "build root escapes")

    def test_generated_extension_root_must_stay_inside_build(self):
        args = self.build_fixture()
        self.extension = self.file("python/other/_sqlite3.so")
        args.expected_extension_root = str(self.extension.parent)
        self.assert_refused_before_maps(args, "generated extension directory escapes")

    def test_build_modules_directory_must_exist(self):
        args = self.build_fixture()
        self.extension.unlink()
        self.extension.parent.rmdir()
        self.extension = self.file("python/sources/Python-3.13.15/build/lib.test/_sqlite3.so")
        args.expected_extension_root = str(self.extension.parent)
        self.assert_refused_before_maps(args, "Modules", "inconclusive")

    def test_extension_backing_cannot_be_a_directory(self):
        self.extension.unlink()
        self.extension.mkdir()
        self.assert_refused_before_maps(self.args(), "extension backing is not a regular file")

    def test_existing_scratch_file_is_not_a_directory(self):
        args = self.args(scratch_dir=str(self.file("scratch-file")))
        self.assert_refused_before_maps(args, "directory required")

    def test_non_regular_backing_is_inconclusive(self):
        with self.assertRaises(probe.ProbeError) as caught:
            probe.file_identity(self.provider.parent)
        self.assertEqual(caught.exception.outcome, "inconclusive")
        # Exercise the opened descriptor check without opening a blocking FIFO.
        metadata = types.SimpleNamespace(st_mode=0o010600)
        with mock.patch.object(probe.os, "fstat", return_value=metadata), \
                self.assertRaises(probe.ProbeError) as caught:
            probe.file_identity(self.provider)
        self.assertEqual(caught.exception.outcome, "inconclusive")
        self.assertIn("regular backing file required", str(caught.exception))

    def test_unavailable_linux_device_identity_is_inconclusive(self):
        with mock.patch.object(probe, "os", types.SimpleNamespace()), \
                self.assertRaises(probe.ProbeError) as caught:
            DEVICE_NUMBERS(0)
        self.assertEqual(caught.exception.outcome, "inconclusive")

    def test_expected_and_competing_provider_are_inconclusive_in_both_orders(self):
        other = self.file("host/libsqlite3.so.0")
        for maps in [self.mapping() + self.mapping(other), self.mapping(other) + self.mapping()]:
            result, _ = self.run_probe(maps=maps)
            self.assertEqual(result["outcome"], "inconclusive", result)
            self.assertIn("ambiguous sqlite backing identities", result["error"])

    def test_only_wrong_provider_is_a_failure(self):
        other = self.file("host/libsqlite3.so.0")
        result, _ = self.run_probe(maps=self.mapping(other))
        self.assertEqual(result["outcome"], "failed", result)

    def test_cli_emits_one_json_failure_and_has_no_fixture_override(self):
        for arguments in [[], ["--maps", "fake"], ["--stage", "made-up"]]:
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                status = probe.main(arguments)
            self.assertNotEqual(status, 0)
            self.assertEqual(json.loads(output.getvalue())["outcome"], "failed")

    def test_missing_probe_material_is_nonzero(self):
        result = subprocess.run([sys.executable, str(self.work / "missing_probe.py")],
                                capture_output=True, check=False)
        self.assertNotEqual(result.returncode, 0)


if __name__ == "__main__":
    unittest.main()
