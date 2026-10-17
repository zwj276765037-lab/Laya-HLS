#!/usr/bin/env python3
"""Tiny source-only parser and join failures; never opens the real checkpoint."""

from collections import defaultdict
import unittest

from funcsim_structure import Expanded, Unsupported, parse_text
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


if __name__ == "__main__":
    unittest.main()
