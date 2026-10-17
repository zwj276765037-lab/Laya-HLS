#!/usr/bin/env python3
"""Bounded check that clock-only split markers cannot refresh semantic progress."""
import importlib.util
from pathlib import Path


GUARD = (Path(__file__).resolve().parents[2] /
         'q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py')
spec = importlib.util.spec_from_file_location('production_guard', GUARD)
guard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(guard)


def marker(work, writes, reads, rows):
    return (f'FULL_CURRENT_GATE_QUANT_SPLIT_PROGRESS work={work} phase=1 '
            f'vstate=2 loaded=3 issued=4 returned=5 next=1 rows=16 '
            f'writes={writes} reads={reads} qrows={rows}')


highwater = None
advanced, highwater = guard.semantic_progress_advances(marker(10, 10, 0, 0), highwater)
assert advanced and highwater == (10, 10, 0, 0)
for _ in range(1000):
    advanced, highwater = guard.semantic_progress_advances(marker(10, 10, 0, 0), highwater)
    assert not advanced and highwater == (10, 10, 0, 0)
advanced, highwater = guard.semantic_progress_advances(marker(11, 11, 0, 0), highwater)
assert advanced and highwater == (11, 11, 0, 0)
advanced, highwater = guard.semantic_progress_advances(marker(12, 11, 1, 0), highwater)
assert advanced and highwater == (12, 11, 1, 0)
for malformed in (
        'FULL_CURRENT_GATE_QUANT_SPLIT_PROGRESS cycles=999 phase=1 state=2',
        'FULL_CURRENT_GATE_QUANT_SPLIT_PROGRESS work=13 phase=1 writes=12 qrows=0',
        'FULL_CURRENT_GATE_QUANT_SPLIT_PROGRESS work=bad writes=12 reads=1 qrows=0'):
    advanced, highwater = guard.semantic_progress_advances(malformed, highwater)
    assert not advanced and highwater == (12, 11, 1, 0)
advanced, highwater = guard.semantic_progress_advances('MATRIX_PROGRESS work_ps0=512', highwater)
assert advanced and highwater == (12, 11, 1, 0)
print('GATE_SPLIT_PROGRESS_GUARD_PASS repeated_clock_lines=1000 malformed_split_lines=3 real_work_advances=2 other_progress=1')
