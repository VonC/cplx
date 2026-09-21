"""Exercise agent evidence refusals with isolated files and explicit observations.

These integration fixtures cover multiple CI entry points, not application
classes. Permuted provider observations test set semantics without a PBT package.
"""

import importlib.util
import json
import os
from pathlib import Path
import sys
from types import SimpleNamespace
from unittest.mock import patch


def module(path):
    spec = importlib.util.spec_from_file_location(path.stem, path)
    loaded = importlib.util.module_from_spec(spec)
    sys.modules[path.stem] = loaded
    spec.loader.exec_module(loaded)
    return loaded


def expect(label, function, *args, fail=False):
    try:
        function(*args)
    except (ValueError, OSError) as error:
        if not fail:
            raise AssertionError(label) from error
    else:
        if fail:
            raise AssertionError(label + " accepted")
    print("PASS " + label)


def helper_accounting(abi, tools, venv, trace, loader_map, scratch):
    helper = tools / "bin/helper"
    helper.parent.mkdir()
    helper.write_bytes(b"\x7fELFhelper")
    loader = tools / "python/root/lib64/ld-linux-x86-64.so.2"
    loader.parent.mkdir(parents=True)
    loader.write_bytes(b"loader")
    base = tools / "python/bin/python"
    base.parent.mkdir()
    base.write_bytes(b"python")
    (venv / "bin").mkdir()
    (venv / "bin/python").symlink_to(base)
    interpreter = "/lib64/ld-linux-x86-64.so.2"
    helper_map = None
    mapped = []

    def observe(args, output, env=None):
        if args[0] == "readelf":
            result = "Type: DYN\n(NEEDED) libc.so.6\n"
            if args == ["readelf", "-d", str(base)]:
                result += "(RPATH) Library rpath: [" + str(tools) + "]\n"
            if args[-1] == str(helper):
                result += "[Requesting program interpreter: " + interpreter + "]\n"
        elif "--list" in args:
            mapped.append(args[-1])
            result = helper_map if args[-1] == str(helper) and helper_map is not None else loader_map
        elif env and "LD_DEBUG_OUTPUT" in env:
            Path(env["LD_DEBUG_OUTPUT"] + ".123").write_text(trace)
            result = "wheels load\n"
        else:
            result = json.dumps({"prefix": str(venv), "base": str(base)})
        output.write_text(result)
        return result

    evidence = scratch / "helper-evidence"
    with patch.dict(os.environ, {"PDFSS_RUNTIME_LIB_PATH": str(tools)}), patch.object(abi, "command", observe):
        abi.run(tools.parent, venv, evidence)
    assert "system-interpreter-helper|" + str(helper) in (evidence / "providers.txt").read_text()
    assert str(helper) not in mapped
    # The retained-helper exception does not authorize every system-loader ELF.
    # Q08 requires qualification outside tools/bin: an explicit forced map,
    # labelled availability, must reject a host provider rather than exempt it.
    helper.rename(tools / "runtime-helper")
    helper = tools / "runtime-helper"
    outside = scratch / "system-object-evidence"
    with patch.dict(os.environ, {"PDFSS_RUNTIME_LIB_PATH": str(tools)}), patch.object(abi, "command", observe):
        abi.run(tools.parent, venv, outside)
    rows = (outside / "providers.txt").read_text()
    assert "system-interpreter-helper|" + str(helper) not in rows
    assert str(helper) in mapped
    assert "availability|" in rows
    helper_map = "libc.so.6 => /usr/lib/libc.so.6 (0x1)"
    with patch.dict(os.environ, {"PDFSS_RUNTIME_LIB_PATH": str(tools)}), patch.object(abi, "command", observe):
        expect("system-interpreter-host-provider-refused", abi.run,
               tools.parent, venv, scratch / "host-object-evidence", fail=True)
    helper_map = None
    # An arbitrary external interpreter is still refused, in either location.
    interpreter = "/lib64/host-loader.so"
    with patch.object(abi, "command", observe):
        expect("outside-interpreter-runtime-refused", abi.run, tools.parent, venv,
               scratch / "runtime-evidence", fail=True)
    helper.unlink()
    print("PASS system-interpreter-helper-accounting")


def main():
    app, scratch = map(Path, sys.argv[1:])
    abi = module(app / "ci/tools_abi_scan.py")
    tests = module(app / "ci/tools_test_evidence.py")
    tools = scratch / "prefix/tools"
    venv = scratch / "prefix/venv"
    tools.mkdir(parents=True)
    venv.mkdir(parents=True)
    (tools / "libc.so.6").write_bytes(b"provider")
    (tools / "ld-linux.so").write_bytes(b"loader")
    (tools / "alias").symlink_to(tools / "libc.so.6")
    (tools / "outside").symlink_to(scratch / "bundle.tar.gz")
    good = ["linux-vdso.so.1 (0x1)", "libc.so.6 => " + str(tools / "alias") + " (0x2)",
            str(tools / "ld-linux.so") + " (0x3)"]
    for i, lines in enumerate((good, good[::-1], good + good)):
        expect("loader-alias-order-" + str(i), abi.validate_list, "\n".join(lines), tools, venv)
    for label, text in (
        ("empty-list", ""), ("missing-version", "version `GLIBC_999' not found"),
        ("unresolved", "libmissing.so => not found"),
        ("outside-provider", "libbad.so => /usr/lib/libbad.so (0x1)"),
        ("outside-alias", "libbad.so => " + str(tools / "outside") + " (0x1)"),
        ("unparsed-loader", "unrecognized loader diagnostic"),
        ("monitor-only", "liboneagentproc.so => /opt/dynatrace/oneagent/agent/liboneagentproc.so (0x1)"),
    ):
        expect(label, abi.validate_list, text, tools, venv, fail=True)
    monitoring = "liboneagentproc.so => /opt/dynatrace/oneagent/agent/liboneagentproc.so (0x1)"
    expect("visible-monitoring", abi.validate_list, "\n".join(good + [monitoring]), tools, venv)
    trace = ("1: checking for version `GLIBC_2.34' in file " + str(tools / "libc.so.6") + " [0] required by file python [0]\n"
             "1: calling init: " + str(tools / "libc.so.6") + "\n"
             "1: calling init: " + str(venv / "lib/site-packages/pymupdf/_mupdf.so") + "\n"
             "1: calling init: " + str(venv / "lib/site-packages/pikepdf/_core.so") + "\n")
    for name in ("pymupdf/_mupdf.so", "pikepdf/_core.so"):
        path = venv / "lib/site-packages" / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(b"wheel")
    expect("direct-venv-trace", abi.validate_trace, trace, tools, venv)
    expect("empty-trace", abi.validate_trace, "", tools, venv, fail=True)
    expect("probe-attempt-only", abi.validate_trace, trace.replace("calling init:", "trying file="), tools, venv, fail=True)
    expect("host-trace", abi.validate_trace, trace + "1: calling init: /usr/lib/libc.so.6\n", tools, venv, fail=True)
    expect("trace-version-error", abi.validate_trace, trace + "version lookup error: bad\n", tools, venv, fail=True)
    expect("host-version-provider", abi.validate_trace, trace.replace(str(tools / "libc.so.6") + " [0]", "/usr/lib/libc.so.6 [0]"), tools, venv, fail=True)
    expect("unparsed-version", abi.validate_trace, trace + "1: checking for version unknown\n", tools, venv, fail=True)
    expect("trace-visible-monitoring", abi.validate_trace, trace + "1: calling init: /opt/dynatrace/oneagent/agent/liboneagentproc.so\n", tools, venv)
    expect("whole-tree-outside-alias", abi.inventory, tools, venv, [], fail=True)
    (tools / "outside").unlink()
    expect("empty-elf-inventory", abi.inventory, tools, venv, [], fail=True)
    (tools / "libc.so.6").write_bytes(b"\x7fELFfixture")
    assert abi.inventory(tools, venv, []) == [tools / "libc.so.6"]
    (tools / "missing-alias").symlink_to("missing-target")
    dangling = []
    assert abi.inventory(tools, venv, dangling) == [tools / "libc.so.6"]
    assert dangling == ["dangling-link|" + str(tools / "missing-alias") + "|missing-target"]
    expect("missing-runtime-provider-refused", abi.validate_list,
           "missing.so => " + str(tools / "missing-alias") + " (0x1)", tools, venv, fail=True)
    print("PASS inventory-canonical-once")
    helper_accounting(abi, tools, venv, trace, "\n".join(good), scratch)

    report = {"collected": 4, "executed": 4, "deselected": 0, "setup_skipped": 0,
              "plugins": {"pytest-cov": "7", "pytest-testmon": "2.2.0"},
              "testmon": {"collect": True, "select": False},
              "guarded": {name: {"collected": 2, "passed": 2, "skipped": 0}
                          for name in tests.GUARDED}, "exit": 0}
    cov = scratch / "coverage.xml"
    cov.write_text('<coverage lines-valid="10" lines-covered="10" line-rate="1"/>')
    expect("full-coverage-selection", tests.validate, report, cov)
    expect("accounted-platform-skip", tests.validate, dict(report, collected=5, setup_skipped=1), cov)
    for key, value in (("collected", 0), ("executed", 0), ("deselected", 1), ("exit", 5), ("plugins", {}),
                       ("testmon", {"collect": False, "select": False})):
        changed = dict(report, **{key: value})
        expect("test-evidence-" + key, tests.validate, changed, cov, fail=True)
    changed = json.loads(json.dumps(report))
    changed["guarded"][tests.GUARDED[0]]["skipped"] = 1
    expect("sqlite-suite-skipped", tests.validate, changed, cov, fail=True)
    expect("coverage-missing", tests.validate, report, scratch / "missing.xml", fail=True)
    cov.write_text('<coverage lines-valid="10" lines-covered="9" line-rate="0.9"/>')
    expect("coverage-below-gate", tests.validate, report, cov, fail=True)
    plugin_fixtures(app, scratch)


def wheel_fixtures(app, scratch):
    capture = module(app / "ci/tools_wheel_capture.py")
    print("PASS application-venv helper import: tools_wheel_capture")
    site = scratch / "wheel-site"
    info = site / "fixture-1.0.dist-info"
    info.mkdir(parents=True)
    (info / "METADATA").write_text("Name: fixture\nVersion: 1.0\n")
    (info / "WHEEL").write_text("Tag: py3-none-any\n")
    wheel = {"url": "https://fixture/fixture-1.0-py3-none-any.whl", "hash": "sha256:" + "a" * 64}
    lock = {"package": [{"name": "fixture", "wheels": [wheel]}]}
    result = capture.identify(lock, site)
    assert result == [("fixture-1.0-py3-none-any.whl", "a" * 64, wheel["url"])]
    print("PASS exact-installed-wheel")
    lock["package"][0]["wheels"].append(dict(wheel, url="https://other/fixture-1.0-py3-none-any.whl"))
    expect("ambiguous-wheel", capture.identify, lock, site, fail=True)
    lock["package"][0]["wheels"].pop()
    # Playwright's generic WHEEL metadata does not match its platform filename.
    # Supply explicit platform ranks so this contract is host-independent.
    linux = dict(wheel, url="https://fixture/fixture-1.0-py3-none-manylinux1_x86_64.whl")
    windows = dict(wheel, url="https://fixture/fixture-1.0-py3-none-win_amd64.whl")
    choices = lock["package"][0]["wheels"]
    choices[:] = [windows, linux]
    supported = ["py3-none-manylinux1_x86_64", "py3-none-win_amd64", "py3-none-any"]
    result = capture.identify(lock, site, supported)
    assert result == [("fixture-1.0-py3-none-manylinux1_x86_64.whl", "a" * 64, linux["url"])]
    print("PASS generic-wheel-ranked-fallback")
    expect("unsupported-wheel-platform", capture.identify, lock, site, ["py3-none-any"], fail=True)
    choices.append(dict(linux, url="https://other/fixture-1.0-py3-none-manylinux1_x86_64.whl"))
    expect("tied-wheel-fallback", capture.identify, lock, site, supported, fail=True)
    choices[:] = [linux, wheel]
    result = capture.identify(lock, site, supported)
    assert result == [("fixture-1.0-py3-none-any.whl", "a" * 64, wheel["url"])]
    print("PASS exact-wheel-precedes-fallback")
    (info / "METADATA").write_text("Name: fixture\nVersion: 2.0\n")
    expect("absent-wheel-release", capture.identify, lock, site, supported, fail=True)
    (info / "METADATA").write_text("Name: fixture\nVersion: 1.0\n")
    (info / "direct_url.json").write_text('{"dir_info":{"editable":true}}')
    expect("unlocked-editable", capture.identify, lock, site, fail=True)


def plugin_fixtures(app, scratch):
    # Invoke pytest's documented hooks with a configuration double. The native
    # application walk, not this dependency-free fixture, executes real tests.
    pytest = SimpleNamespace(hookimpl=lambda **kw: lambda function: function, UsageError=ValueError,
                             Config=SimpleNamespace, Item=SimpleNamespace,
                             Session=SimpleNamespace, TestReport=SimpleNamespace)
    sys.path.insert(0, str(app))
    with patch.dict(sys.modules, pytest=pytest):
        plugin = module(app / "ci/tools_test_plugin.py")
    options = dict(testmon=True, testmon_noselect=True, cov_source=["src/pdfss"],
                   cov_fail_under=100, file_or_dir=["src/pdfss/tests"])
    config = SimpleNamespace(pluginmanager=SimpleNamespace(hasplugin=lambda name: True),
                             getoption=lambda name, default=None: options.get(name, default),
                             testmon_config=SimpleNamespace(collect=True, select=False))
    with patch.object(plugin, "version", return_value="fixture"):
        expect("plugin-full-walk", plugin.pytest_configure, config)
        for key, value in (("no_cov", True), ("testmon_noselect", False), ("keyword", "subset"),
                           ("ignore", ["some-tests"]), ("cov_fail_under", 99)):
            with patch.dict(options, {key: value}):
                expect("plugin-refuses-" + key, plugin.pytest_configure, config, fail=True)
        config.testmon_config.collect = False
        expect("plugin-inactive-testmon", plugin.pytest_configure, config, fail=True)
    session = SimpleNamespace(items=[SimpleNamespace(path=Path("src/pdfss/tests/unit") / name)
                                     for name in plugin.GUARDED for _ in range(2)])
    plugin.pytest_collection_finish(session)
    plugin.pytest_deselected([])
    for item in session.items:
        plugin.pytest_runtest_logreport(SimpleNamespace(nodeid=str(item.path) + "::test_case", when="call",
                                                        passed=True, skipped=False))
    output = scratch / "hook-tests.json"
    with patch.dict(os.environ, TOOLS_TEST_EVIDENCE=str(output)):
        plugin.pytest_sessionfinish(0)
    coverage = scratch / "hook-coverage.xml"
    coverage.write_text('<coverage lines-valid="10" lines-covered="10" line-rate="1"/>')
    evidence = module(app / "ci/tools_test_evidence.py")
    expect("hook-evidence-roundtrip", evidence.validate, json.loads(output.read_text()), coverage)
    plugin.pytest_runtest_logreport(SimpleNamespace(nodeid="platform.py::windows_only", when="setup",
                                                    passed=False, skipped=True, longrepr="Windows only"))
    assert plugin.record["setup_skipped"] == 1
    assert plugin.record["skipped"][0]["reason"] == "Windows only"
    print("PASS hook-platform-skip-evidence")


if __name__ == "__main__":
    if len(sys.argv) == 4 and sys.argv[3] == "--wheels":
        wheel_fixtures(Path(sys.argv[1]), Path(sys.argv[2]))
    else:
        main()
