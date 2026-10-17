#!/usr/bin/env python3
"""Small static fixtures for the imported-XCI field and path gate."""

from __future__ import annotations

import importlib.util
import copy
import tempfile
from pathlib import Path


candidate = Path(__file__).with_name("verify_imported_xci.py")
spec = importlib.util.spec_from_file_location("verify_imported_xci", candidate)
assert spec and spec.loader
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)

original = {
    "schema": "fixture",
    "ip_inst": {
        "gen_directory": "../../old.gen/ip0",
        "component_reference": "xilinx.com:ip:floating_point:7.1",
        "parameters": {"CONFIG.ADD_SUB_VALUE": [{"value": "Add"}],
                       "runtime_parameters": {"OUTPUTDIR": [{"value": "../../old.gen/ip0"}]}},
        "boundary": {"ports": {"aclk": [{"direction": "in"}]}},
    },
    "checksum": "old",
}
imported = copy.deepcopy(original)
imported["ip_inst"]["gen_directory"] = "../../new.gen/ip0"
imported["ip_inst"]["parameters"]["runtime_parameters"]["OUTPUTDIR"][0]["value"] = "../../new.gen/ip0"
imported["checksum"] = "new"
allowed = {item["path"] for item in checker.differences(original, imported)}
assert allowed == checker.ALLOWED_DIFFS
assert checker.outputdir_value(imported) == "../../new.gen/ip0"
imported["ip_inst"]["parameters"] = {"CONFIG.ADD_SUB_VALUE": [{"value": "Subtract"}]}
changed = {item["path"] for item in checker.differences(original, imported)}
assert "/ip_inst/parameters/CONFIG.ADD_SUB_VALUE/0/value" in changed - checker.ALLOWED_DIFFS
malformed = copy.deepcopy(original)
malformed["ip_inst"]["parameters"]["runtime_parameters"]["OUTPUTDIR"] = [{"value": "x"}, {"value": "y"}]
try:
    checker.outputdir_value(malformed)
except ValueError:
    pass
else:
    raise AssertionError("multi-value OUTPUTDIR was accepted")

with tempfile.TemporaryDirectory(prefix="q8_xci_path_fixture_") as temp:
    base = Path(temp)
    root = base / "run"
    root.mkdir()
    (root / "ip0").mkdir()
    outside = base / "run_evil"
    outside.mkdir()
    (root / "link").symlink_to(outside, target_is_directory=True)
    assert checker.real_inside(root / "ip0" / "future.xci", root)
    assert not checker.real_inside(outside / "future.xci", root)
    assert not checker.real_inside(root / "link" / "future.xci", root)
    assert not checker.real_inside(root, root)

print("Q8_OOC_IMPORT_XCI_WHITELIST_PASS allowed=3 altered_parameter_rejected=1 malformed_outputdir_rejected=1 path_escape_rejected=1")
