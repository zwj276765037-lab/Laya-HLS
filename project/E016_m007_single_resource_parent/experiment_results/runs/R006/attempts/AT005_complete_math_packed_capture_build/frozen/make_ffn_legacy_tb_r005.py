#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
s=(M/'tb/m007_single_parent_tb.sv').read_text().replace('module m007_single_parent_tb;','module m007_ffn_legacy_tb;').replace('dut.layer.','dut.layer.layer.')
(M/'tb/m007_ffn_legacy_tb.sv').write_text(s)
