#!/usr/bin/env python3
"""Tiny source-only parser and join failures; never opens the real checkpoint."""

from collections import defaultdict
import hashlib
from pathlib import Path
import tempfile
import unittest
from unittest import mock

import export_envelope
from export_envelope import bound_capsule, parse_enveloped_bytes
from funcsim_structure import (Expanded, Unsupported, parse_text, read_export,
                               MAX_HIERARCHY_INSTANCES)
from join_funcsim_graph import REQUIRED_RAM_INVERSIONS, bind_bank


BANK = "ws_U"
BASE = """module ws_U(input a, output q);
LUT2 #(.INIT(4'h0)) \\u.alias  (.I0(a), .I1(1'b0), .O(q));
endmodule"""
CONTRACT = {"LUT2": {"required_property_names": ["INIT"],
                     "parameters": [{"name": "INIT", "classification": "required_semantic_property"}],
                     "port_signature": {
                         "I0": {"direction": "IN", "indices": [0], "scalar": True},
                         "I1": {"direction": "IN", "indices": [0], "scalar": True},
                         "O": {"direction": "OUT", "indices": [0], "scalar": True}}}}


def expanded(text=BASE, refs=None):
    return Expanded(parse_text(text), refs or {"LUT2"}, BANK)


def dcp(*, init="", input_net="n_a", const="0"):
    root = {"id": "c0", "bank": BANK, "name": BANK,
            "reference": "ws_bank", "primitive": False}
    primitive = {"id": "c1", "bank": BANK, "name": BANK + "/u.alias",
                 "reference": "LUT2", "primitive": True}
    cells = {"c0": root, "c1": primitive}
    names = {BANK: root, primitive["name"]: primitive}
    pins = defaultdict(list, {"c0": [
        {"id": "p0a", "ref_pin": "a", "direction": "IN", "net": "n_a"},
        {"id": "p0q", "ref_pin": "q", "direction": "OUT", "net": "n_q"}],
        "c1": [
        {"id": "p1", "ref_pin": "I0", "direction": "IN", "net": input_net},
        {"id": "p2", "ref_pin": "I1", "direction": "IN", "net": "n_zero"},
        {"id": "p3", "ref_pin": "O", "direction": "OUT", "net": "n_q"}]})
    boundaries = defaultdict(dict, {BANK: {"a": "n_a", "q": "n_q"}})
    nets = {"n_a": "UNKNOWN", "n_zero": const, "n_q": "UNKNOWN"}
    props = defaultdict(dict, {"c1": {"INIT": {"raw": init,
                                                 "read_status": "OK"}}})
    return cells, names, pins, boundaries, nets, props


class SyntheticSourceChecks(unittest.TestCase):
    def test_explicit_default_zero_fills_empty_dcp_without_changing_gap(self):
        joined, graph = bind_bank(BANK, expanded(), dcp(), CONTRACT)
        self.assertEqual(joined[0]["decoded_value"], 0)
        self.assertEqual(joined[0]["provenance"], "EXPLICIT_FUNCSIM_OVERRIDE")
        self.assertEqual(joined[0]["dcp_original"]["raw"], "")
        self.assertEqual(len(graph), 3)

    def test_missing_explicit_and_empty_dcp_fails(self):
        e = expanded(BASE.replace(" #(.INIT(4'h0))", ""))
        with self.assertRaisesRegex(Unsupported, "required actual parameter absent"):
            bind_bank(BANK, e, dcp(), CONTRACT)

    def test_conflicting_dcp_and_export_fails(self):
        with self.assertRaisesRegex(Unsupported, "parameter conflict"):
            bind_bank(BANK, expanded(), dcp(init="4'h1"), CONTRACT)

    def test_unknown_inversion_or_parameter_fails(self):
        with self.assertRaises(Unsupported):
            expanded(BASE.replace("4'h0", "4'hx"))

    def test_escaped_instance_and_shared_module_expansion(self):
        text = """module leaf(input a, output q);
LUT2 #(.INIT(4'h0)) \\u.alias  (.I0(a), .I1(1'b0), .O(q)); endmodule
module ws_U(input a, output q); leaf core(.a(a),.q(q)); endmodule"""
        e = expanded(text)
        self.assertEqual(set(e.primitives), {"ws_U/core/u.alias"})

    def test_swapped_address_net_fails(self):
        text = """module ws_U(input [1:0] a, output q);
LUT2 #(.INIT(4'h0)) \\u.alias  (.I0(a[1]), .I1(a[0]), .O(q)); endmodule"""
        e = expanded(text)
        graph = dcp()
        graph[3][BANK] = {"a[1]": "n_a1", "a[0]": "n_a", "q": "n_q"}
        graph[4]["n_a1"] = "UNKNOWN"
        graph[2]["c0"][0:1] = [
            {"id": "p0a1", "ref_pin": "a[1]", "direction": "IN", "net": "n_a1"},
            {"id": "p0a0", "ref_pin": "a[0]", "direction": "IN", "net": "n_a"}]
        graph[2]["c1"][1]["net"] = "n_a1"
        with self.assertRaisesRegex(Unsupported, "splits|aliases"):
            bind_bank(BANK, e, graph, CONTRACT)

    def test_constant_mismatch_fails(self):
        with self.assertRaisesRegex(Unsupported, "constant identity"):
            bind_bank(BANK, expanded(), dcp(const="1"), CONTRACT)

    def test_pin_direction_mismatch_fails(self):
        graph = dcp()
        graph[2]["c1"][0]["direction"] = "OUT"
        with self.assertRaisesRegex(Unsupported, "pin direction"):
            bind_bank(BANK, expanded(), graph, CONTRACT)

    def test_duplicate_and_missing_named_entries_fail(self):
        with self.assertRaisesRegex(Unsupported, "duplicate/malformed named parameter"):
            expanded(BASE.replace(".INIT(4'h0)", ".INIT(4'h0),.INIT(4'h0)"))
        with self.assertRaisesRegex(Unsupported, "empty named parameter or port"):
            expanded(BASE.replace(".I0(a),", ".I0(a),,"))

    def test_all_eight_ram_inversions_need_explicit_one_bit_values(self):
        parameters = ",".join(f".{name}(1'b0)" for name in REQUIRED_RAM_INVERSIONS)
        text = BASE.replace("LUT2 #(.INIT(4'h0))", f"RAMB36E2 #({parameters})")
        contract = {"RAMB36E2": {
            "required_property_names": list(REQUIRED_RAM_INVERSIONS),
            "parameters": [{"name": name, "classification": "required_semantic_property"}
                           for name in REQUIRED_RAM_INVERSIONS],
            "port_signature": CONTRACT["LUT2"]["port_signature"]}}
        graph = dcp()
        graph[0]["c1"]["reference"] = "RAMB36E2"
        graph[1][BANK + "/u.alias"]["reference"] = "RAMB36E2"
        graph[5]["c1"] = {name: {"raw": "", "read_status": "MISSING"}
                           for name in REQUIRED_RAM_INVERSIONS}
        joined, _ = bind_bank(BANK, expanded(text, {"RAMB36E2"}), graph, contract)
        self.assertEqual(len(joined), 8)
        missing = text.replace(".IS_CLKARDCLK_INVERTED(1'b0),", "")
        with self.assertRaisesRegex(Unsupported, "explicit known one-bit override missing"):
            bind_bank(BANK, expanded(missing, {"RAMB36E2"}), graph, contract)
        with self.assertRaises(Unsupported):
            expanded(text.replace("1'b0", "1'bx", 1), {"RAMB36E2"})
        with self.assertRaisesRegex(Unsupported, "explicit known one-bit override missing"):
            bind_bank(BANK, expanded(text.replace("1'b0", "2'b00", 1), {"RAMB36E2"}), graph, contract)

    def test_duplicate_instance_and_unknown_syntax_fail(self):
        with self.assertRaisesRegex(Unsupported, "duplicate instance"):
            expanded(BASE.replace("endmodule", BASE.split("\n")[1] + "\nendmodule"))
        with self.assertRaises(Unsupported):
            expanded(BASE.replace(".I0(a)", ".I0(~a)"))

    def test_nonempty_missing_property_is_terminal(self):
        graph = dcp(init="4'h1")
        graph[5]["c1"]["INIT"]["read_status"] = "MISSING"
        with self.assertRaisesRegex(Unsupported, "nonempty MISSING"):
            bind_bank(BANK, expanded(), graph, CONTRACT)

    def test_failed_or_unknown_property_status_is_terminal(self):
        for status in ("ERROR", "TRUNCATED", "OTHER"):
            for raw in ("", "4'h1"):
                with self.subTest(status=status, raw=raw):
                    graph = dcp(init=raw)
                    graph[5]["c1"]["INIT"]["read_status"] = status
                    with self.assertRaisesRegex(Unsupported, "terminal DCP property status"):
                        bind_bank(BANK, expanded(), graph, CONTRACT)

    def test_nonempty_ok_must_parse_and_agree(self):
        for raw in ("4'hx", "4'hz", "x", "4'hg"):
            with self.subTest(raw=raw):
                with self.assertRaises(Unsupported):
                    bind_bank(BANK, expanded(), dcp(init=raw), CONTRACT)
        for raw, message in (("4'h1", "parameter conflict"),
                             ("8'h0", "width or signedness conflict"),
                             ("4'sh0", "width or signedness conflict")):
            with self.subTest(raw=raw):
                with self.assertRaisesRegex(Unsupported, message):
                    bind_bank(BANK, expanded(), dcp(init=raw), CONTRACT)
        joined, _ = bind_bank(BANK, expanded(), dcp(init="4'h0"), CONTRACT)
        self.assertEqual(joined[0]["dcp_original"],
                         {"raw": "4'h0", "read_status": "OK"})

    def test_variable_declarations_and_initializers_refused(self):
        for declaration in ("reg x=1'b0;", "logic x=1'b0;",
                            "reg x;", "logic x;"):
            with self.subTest(declaration=declaration):
                source = ("module ws_U(output q); " + declaration +
                          " assign q=x; endmodule")
                with self.assertRaisesRegex(Unsupported, "variable declaration"):
                    expanded(source)
        for kind in ("reg", "logic"):
            with self.subTest(port=kind):
                with self.assertRaisesRegex(Unsupported, "variable port declaration"):
                    expanded(f"module ws_U(output {kind} q); endmodule")
        with self.assertRaisesRegex(Unsupported, "variable declaration"):
            expanded("module ws_U(q); output reg q; endmodule")

    def test_continuous_net_initializers_and_aliases_remain_supported(self):
        source = BASE.replace(
            "LUT2 #", "wire x=1'b0; wire aliased; assign aliased=a; LUT2 #"
        ).replace(".I0(a)", ".I0(aliased)").replace(".I1(1'b0)", ".I1(x)")
        joined, mapping = bind_bank(BANK, expanded(source), dcp(), CONTRACT)
        self.assertEqual(joined[0]["decoded_value"], 0)
        self.assertEqual(len(mapping), 3)

    def test_literal_and_range_preallocation_caps(self):
        with self.assertRaisesRegex(Unsupported, "literal bit width cap"):
            expanded(BASE.replace("4'h0", "4097'h0"))
        with self.assertRaisesRegex(Unsupported, "literal digit cap"):
            expanded(BASE.replace("4'h0", "4'h" + "0" * 5000))
        with self.assertRaisesRegex(Unsupported, "bus index cap"):
            expanded("module ws_U(input [32768:0] a, output q); "
                     "assign q=a[32768]; endmodule")
        with self.assertRaisesRegex(Unsupported, "bus index cap"):
            expanded("module ws_U(input a, output q); "
                     "assign q=a[32768:0]; endmodule")

    def test_expanded_empty_shared_hierarchy_cap(self):
        instances = ",".join(
            f"i{index}(.a(a))" for index in range(MAX_HIERARCHY_INSTANCES + 1))
        source = ("module leaf(input a); endmodule "
                  "module ws_U(input a); leaf " + instances + "; endmodule")
        with self.assertRaisesRegex(Unsupported, "hierarchy instance cap"):
            expanded(source)

    def test_hierarchy_depth_and_identifier_caps(self):
        count = 18
        modules = ["module m0(input a); endmodule"]
        for index in range(1, count):
            modules.append(f"module m{index}(input a); "
                           f"m{index-1} child(.a(a)); endmodule")
        modules.append(f"module ws_U(input a); m{count-1} child(.a(a)); endmodule")
        with self.assertRaisesRegex(Unsupported, "hierarchy depth cap"):
            expanded(" ".join(modules))
        long_name = "x" * 1025
        with self.assertRaisesRegex(Unsupported, "identifier byte cap"):
            expanded(f"module ws_U(input {long_name}); endmodule")


class ExactGlblEnvelopeChecks(unittest.TestCase):
    """Synthetic structural text plus the exact bound installed support body."""

    def source(self, prefix=BASE, capsule=None):
        return (prefix + "\n").encode("ascii") + (
            bound_capsule() if capsule is None else capsule)

    def reject(self, raw):
        with self.assertRaises(Unsupported):
            parse_enveloped_bytes(raw, "<synthetic>")

    def test_exact_capsule_keeps_raw_literal_byte_spans(self):
        raw = self.source()
        modules, exclusion = parse_enveloped_bytes(raw, "<synthetic>")
        graph = Expanded(modules, {"LUT2"}, BANK)
        literal = graph.primitives[BANK + "/u.alias"].parameters["INIT"]
        self.assertEqual(raw[literal.start:literal.end].decode("ascii"), literal.raw)
        self.assertEqual(literal.raw, "4'h0")
        self.assertEqual(exclusion["state"], "EXCLUDED_EXACT_INSTALLED_GLBL_CAPSULE")
        self.assertEqual(exclusion["start_byte"], len(raw) - 1642)
        self.assertEqual(exclusion["end_byte"], len(raw))
        self.assertEqual(exclusion["capsule_sha256"], hashlib.sha256(bound_capsule()).hexdigest())
        self.assertEqual(exclusion["immutable_source_reference"]["header_skip_bytes"], 120)
        joined, mapping = bind_bank(BANK, graph, dcp(), CONTRACT)
        self.assertEqual(len(joined), 1)
        self.assertEqual(len(mapping), 3)
        with tempfile.TemporaryDirectory(prefix="ws_v7_synthetic_") as directory:
            path = Path(directory) / "synthetic.v"
            path.write_bytes(raw)
            production_reader = read_export(path, {"LUT2"}, BANK)
            self.assertEqual(production_reader.support_exclusion["start_byte"],
                             exclusion["start_byte"])
            self.assertEqual(production_reader.support_exclusion["raw_source"]["sha256"],
                             hashlib.sha256(raw).hexdigest())
            path.write_bytes(BASE.encode("ascii"))
            with self.assertRaisesRegex(Unsupported, "capsule required"):
                read_export(path, {"LUT2"}, BANK)

    def test_capsule_free_state_is_explicit_synthetic_only(self):
        raw = BASE.encode("ascii")
        self.reject(raw)
        modules, evidence = parse_enveloped_bytes(
            raw, "<synthetic>", allow_capsule_free_synthetic=True)
        self.assertEqual(set(modules), {BANK})
        self.assertEqual(evidence["state"], "ABSENT_SYNTHETIC_STRUCTURAL_SOURCE")

    def test_one_byte_capsule_drift_and_appended_token_fail(self):
        capsule = bytearray(bound_capsule())
        capsule[9] ^= 1
        self.reject(self.source(capsule=bytes(capsule)))
        self.reject(self.source() + b"wire extra;\n")

    def test_duplicate_capsule_and_changed_guard_fail(self):
        body = bound_capsule()
        self.reject(self.source() + body)
        self.reject(self.source(capsule=body.replace(b"GLBL", b"GLBx", 1)))

    def test_else_nested_and_early_prefix_directives_fail(self):
        body = bound_capsule()
        self.reject(self.source(capsule=body.replace(b"`endif\n", b"`else\n`endif\n")))
        self.reject(self.source(capsule=body.replace(
            b"`define GLBL\n", b"`define GLBL\n`ifdef OTHER\n", 1)))
        self.reject(self.source(prefix=BASE + "\n`define GLBL"))
        self.reject(self.source(prefix=BASE + "\n`ifdef OTHER"))
        self.reject(self.source(prefix=BASE + "\n`timescale GLBL"))
        self.reject(self.source(prefix=BASE + "\nwire GLBL;"))

    def test_unterminated_prefix_comment_string_and_comment_suffix_fail(self):
        self.reject(self.source(prefix=BASE + "\n/* never closed"))
        self.reject(self.source(prefix=BASE + '\n"never closed'))
        self.reject(BASE.encode("ascii") + b"//" + bound_capsule())

    def test_explicit_glbl_instance_root_duplicate_and_hierarchical_fail(self):
        self.reject(self.source(prefix=BASE.replace(
            "endmodule", "glbl support(); endmodule")))
        self.reject(self.source(prefix="module glbl(input a); endmodule"))
        self.reject(self.source(prefix=(
            "module glbl(input a); endmodule\n"
            "module glbl(input a); endmodule")))
        self.reject(self.source(prefix=(
            "module ws_U(input a, output q); wire \\glbl.GSR ; "
            "assign q=a; endmodule")))
        self.reject(self.source(prefix=(
            "module ws_U(input a, output q); wire \\top.glbl.GSR ; "
            "assign q=a; endmodule")))

    def test_caps_apply_before_capsule_lookup_or_slicing(self):
        with mock.patch.object(export_envelope, "MAX_FILE_BYTES", 3), \
             mock.patch.object(export_envelope, "bound_capsule",
                               side_effect=AssertionError("cap was too late")):
            with self.assertRaisesRegex(Unsupported, "byte cap"):
                parse_enveloped_bytes(b"1234", "<synthetic>")


if __name__ == "__main__":
    unittest.main()
