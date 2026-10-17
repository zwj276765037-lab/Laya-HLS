#!/usr/bin/env bash
set -euo pipefail
root=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
module=$root/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512
[[ $# == 2 && $1 =~ ^t2_act_production_rtl_[0-9]+$ && -f $2/manifest.json ]]
attempt=$root/results/compute_throughput_optimization_20261010/attempts/$1
fixture=$(realpath "$2")
[[ ! -e $attempt ]]
exec 9>"$root/results/compute_throughput_optimization_20261010/control/heavy_tool.lock"
flock -n 9
mkdir -p "$attempt/work"
python3 - "$root" "$module" "$fixture" "$attempt" <<'PY'
import hashlib,json,sys
from pathlib import Path
root,module,fixture,attempt=map(Path,sys.argv[1:])
def rec(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
m=json.loads((fixture/'manifest.json').read_text())
for record in m['files'].values():
 p=Path(record['path']);assert rec(p)==record
sources=[]
for folder,names in (
 (module/'rtl',('tm1tn8_integer_tree_lut','tm1tn8_signed_pack_pair','tm1tn8_integer_tree_packed','tm4tn8_tag_v1','tm4tn8_reserved_store_v1','tm4tn8_fp_restore_v1','tm4tn8_row_pipeline_v1','tm4tn8_microbench_v1','tm1tn8_bias_output','tm1tn8_axi512_writer','laya_act_production_v1')),
 (root/'vivado/module_design/activation_quantizer/rtl',('quant16_slot_banks','quant16_amax16','quant16_half_rne','quant16_tiny_div127','quant16_divider_service','quant16_stream_row')),
 (root/'vivado/module_design/hbm_loader_and_cache/rtl',('t4_w_reader_port_v1','t4_three_port_reader_v1','t4_aux_bias_reader_v1','t4_dual_w_cache_v1'))):
 sources += [folder/(name+'.sv') for name in names]
sources += [root/'vivado/module_design/q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv',module/'tb/laya_act_production_tb.sv',module/'tb/create_fp_ip.tcl',module/'tb/run_act_production.tcl',module/'tb/run_act_production.sh',module/'tb/production_guard.py',root/'tools/hls_guard_helpers.py',fixture/'manifest.json']
ipdir=root/'results/compute_throughput_optimization_20261010/attempts/quant16_hls_syn_03/work/quant16_project/solution1/syn/verilog'
sources += [ipdir/n for n in ('laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl','laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl')]
(attempt/'input_manifest.json').write_text(json.dumps({'schema':'laya_act_production_run_v1','fixture':rec(fixture/'manifest.json'),'inputs':[rec(p) for p in sources]},indent=2,sort_keys=True)+'\n')
PY
python3 "$module/tb/production_guard.py" --out "$attempt/guard" --cwd "$root" --rss-gib 8 --timeout-seconds 3600 --semantic-stall-seconds 120 -- /home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado -mode batch -nolog -nojournal -source "$module/tb/run_act_production.tcl" -tclargs "$attempt/work" "$fixture"
