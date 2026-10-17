#!/usr/bin/env python3
"""Fast binary16 and real ACT padded-address checks on isolated scale bytes."""
from __future__ import annotations

import json
from pathlib import Path
import unittest

from t3_static_model import PackageError, independent_half_truth, scan_matrix_scale


PACKAGE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/build/model-cpu-embedding-ln-v4-20261010')


class ScaleTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        manifest = json.loads((PACKAGE / 'manifest.json').read_bytes())
        cls.act = next(w for w in manifest['weights'] if w['name'] == 'act_fc2.weight')
        cls.scale = bytearray((PACKAGE / manifest['bo']['w_scale']['file']).read_bytes())

    def test_all_half_patterns_independent_decoder(self) -> None:
        result = independent_half_truth()
        self.assertEqual(result['checked_bit_patterns'], 65536)
        self.assertTrue(result['negative_zero_accepted'])

    def test_real_act_padded_lanes_are_included(self) -> None:
        record, _ = scan_matrix_scale(self.scale, self.act)
        self.assertEqual(record['N'], 2)
        self.assertEqual(record['padded_N'], 8)
        self.assertEqual(record['padding_halves'], 48)
        self.assertEqual(record['halves_checked'], 64)

    def test_first_bad_act_padding_address_is_reported(self) -> None:
        scale = self.scale.copy()
        n, g = 2, 0
        G = self.act['K'] // 32
        offset = self.act['scale_base'] + 2 * (((n // 8) * G + g) * 8 + n % 8)
        scale[offset:offset + 2] = bytes.fromhex('00bc')  # binary16 -1
        with self.assertRaises(PackageError) as raised:
            scan_matrix_scale(scale, self.act)
        error = json.loads(str(raised.exception))
        self.assertEqual(error['WeightKey'], [self.act['family'], self.act['layer']])
        self.assertEqual((error['name'], error['n'], error['g'], error['offset'], error['half']),
                         ('act_fc2.weight', n, g, offset, '0xbc00'))

    def test_negative_zero_and_positive_subnormal_are_legal(self) -> None:
        scale = self.scale.copy()
        base = self.act['scale_base']
        scale[base:base + 2] = bytes.fromhex('0080')
        scale[base + 2:base + 4] = bytes.fromhex('0100')
        record, cats = scan_matrix_scale(scale, self.act)
        self.assertEqual(record['halves_checked'], 64)
        self.assertGreaterEqual(cats['negative_zero'], 1)
        self.assertGreaterEqual(cats['positive_subnormal'], 1)

    def test_wrong_scale_span_and_k_rejected(self) -> None:
        for change in ({'scale_span': self.act['scale_span'] - 2},
                       {'K': self.act['K'] - 1}):
            with self.subTest(change=change), self.assertRaises(PackageError):
                scan_matrix_scale(self.scale, {**self.act, **change})


if __name__ == '__main__':
    unittest.main()
