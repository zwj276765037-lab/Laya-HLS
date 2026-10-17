#!/usr/bin/env python3
"""Targeted adversarial checks against the accepted actual Ws graph and export.

Each case starts from a fresh parsed bank. Frozen source files are read only.
"""
from __future__ import annotations

import copy
import json
from pathlib import Path
import unittest
from unittest.mock import patch

import join_funcsim_graph as join
from funcsim_structure import Literal, Unsupported, read_export

BASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
GRAPH = BASE / ('vivado/module_design/q8_linear_and_restore/metadata_reset_v3/'
                'ooc_v1/ws_dcp_connectivity_v6/runs/export_graph_v1/reports')
BANK = 'ws_U'


class ActualJoinAdversarialChecks(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        raw = json.loads(join.CONTRACT.read_text())
        cls.contract = {e['reference']: e for e in raw['primitive_contracts']}
        for entry in cls.contract.values():
            entry['port_signature'] = join.unisim_port_signature(entry)
        cls.base_dcp = join.graph_tables(GRAPH)

    def fresh(self):
        expanded = read_export(GRAPH / 'funcsim' / f'{BANK}.v',
                               set(self.contract), BANK)
        return expanded, copy.deepcopy(self.base_dcp)

    def bind(self, expanded, dcp):
        return join.bind_bank(BANK, expanded, dcp, self.contract, GRAPH)

    def test_real_parent_constant_and_default_pass(self):
        expanded, dcp = self.fresh()
        semantic, _, boundaries, _ = self.bind(expanded, dcp)
        self.assertEqual(len(boundaries), 1)
        self.assertEqual({b['key'] for b in boundaries[0]['boundaries']},
                         {'ce1[0]', 'reset[0]'})
        defaults = [r for r in semantic if r['provenance'] ==
                    'MATCHED_UNISIM_DECLARATION_DEFAULT']
        self.assertEqual(len(defaults), 96)
        self.assertTrue(all(r['dcp_original'] == {'raw': '', 'read_status': 'MISSING'}
                            and r['decoded_value'] == 0 for r in defaults))

    def test_missing_and_multiple_parent_drivers_fail(self):
        real_rows = join.rows
        for mode in ('missing', 'multiple'):
            with self.subTest(mode=mode):
                expanded, dcp = self.fresh()
                def altered(root, name):
                    data = list(real_rows(root, name))
                    if name == 'net_drivers':
                        selected = [r for r in data if r['net_id'] == 'n32']
                        self.assertEqual(len(selected), 1)
                        if mode == 'missing':
                            data = [r for r in data if r['net_id'] != 'n32']
                        else:
                            data.append(dict(selected[0]))
                    return data
                with patch.object(join, 'rows', side_effect=altered):
                    with self.assertRaisesRegex(Unsupported, 'unique exact driver'):
                        self.bind(expanded, dcp)

    def test_wrong_parent_bit_and_direction_fail(self):
        for field, value in (('ref_pin', 'reset[1]'), ('direction', 'OUT')):
            with self.subTest(field=field):
                expanded, dcp = self.fresh()
                root = dcp[1][BANK]
                pin = next(p for p in dcp[2][root['id']] if p['ref_pin'] == 'reset')
                pin[field] = value
                with self.assertRaises(Unsupported):
                    self.bind(expanded, dcp)
        expanded, dcp = self.fresh()
        del dcp[3][BANK]['ce1']
        with self.assertRaisesRegex(Unsupported, 'boundary bit bijection'):
            self.bind(expanded, dcp)

    def test_opposing_literal_and_distinct_net_alias_fail(self):
        expanded, dcp = self.fresh()
        expanded.components.add(expanded.boundaries['ce1[0]'], 1)
        with self.assertRaisesRegex(Unsupported, 'conflicts with HDL literal'):
            self.bind(expanded, dcp)
        expanded, dcp = self.fresh()
        dcp[3][BANK]['reset'] = dcp[3][BANK]['address0[0]']
        with self.assertRaises(Unsupported):
            self.bind(expanded, dcp)

    def test_default_conflict_and_model_identity_drift_fail(self):
        expanded, dcp = self.fresh()
        ram = dcp[1][BANK + '/ram_reg_bram_0']
        dcp[5][ram['id']]['IS_CLKARDCLK_INVERTED'] = {
            'raw': "1'b1", 'read_status': 'OK'}
        with self.assertRaisesRegex(Unsupported, 'DCP/UNISIM inversion default conflict'):
            self.bind(expanded, dcp)
        expanded, dcp = self.fresh()
        ram = dcp[1][BANK + '/ram_reg_bram_0']
        expanded.primitives[ram['name']].parameters['IS_CLKARDCLK_INVERTED'] = \
            Literal("1'b1", 1, False, 'integer', 1, 0, 4)
        dcp[5][ram['id']]['IS_CLKARDCLK_INVERTED'] = {
            'raw': "1'b0", 'read_status': 'OK'}
        with self.assertRaisesRegex(Unsupported, 'DCP/export parameter conflict'):
            self.bind(expanded, dcp)
        entry = copy.deepcopy(self.contract['RAMB36E2'])
        entry['semantics_file']['sha256'] = '0' * 64
        with self.assertRaisesRegex(Unsupported, 'identity drift'):
            join.matched_ramb_inversion_default(entry, 'IS_CLKARDCLK_INVERTED')


if __name__ == '__main__':
    unittest.main(verbosity=2)
