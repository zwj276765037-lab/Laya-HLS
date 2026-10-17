#!/usr/bin/env bash
set -euo pipefail
b=$(realpath "$1")
g=$(dirname "$b")
mode=${2:-parent}
if [[ $mode == export ]];then
 run_name=${LAYA_GEGLU_BANK_EXPORT_GUARD_NAME:-guard_ooc_bank_core_export_01}
 tcl=geglu_row_bank_core_export.tcl
 marker='TANH_LIBM_GEGLU_BANK_CORE_EXPORT_PASS boundaries=51 ports=164 blackboxes=0'
else
 run_name=${LAYA_GEGLU_BANK_OOC_GUARD_NAME:-guard_ooc_bank_parent_01}
 tcl=geglu_row_bank_ooc.tcl
 marker='TANH_LIBM_GEGLU_BANK_OOC_COMPLETE boundaries=51 blackboxes=0 io_pads=0 banks=3 row_data_bits=251904'
fi
remaining=$(python3 - "$g" "$run_name" <<'PY'
from pathlib import Path
import sys,json,math
g=Path(sys.argv[1]);records=[]
for p in sorted(g.glob('guard_ooc_*/guard_result.json')):
 r=json.loads(p.read_text());records.append({'path':str(p),'elapsed_seconds':r['elapsed_seconds']})
spent=sum(r['elapsed_seconds'] for r in records);remaining=3600-spent
state={'schema':'laya-geglu-bank-original-cumulative-ooc-v1','budget_seconds':3600,'guards':records,'spent_seconds':spent,'remaining_seconds':remaining,'guard_timeout_seconds':max(0,math.floor(remaining-5)),'polling_reserve_seconds':5}
p=g/('budget_before_'+sys.argv[2]+'.json')
assert not p.exists();p.write_text(json.dumps(state,indent=2,sort_keys=True)+'\n')
print(state['guard_timeout_seconds'])
PY
)
if ((remaining<=0));then echo GEGLU_BANK_ORIGINAL_OOC_BUDGET_EXHAUSTED;exit 3;fi
mkdir -p "$b/ooc"
python3 "$b/frozen_source/tanh_libm_guard.py" --out "$g/$run_name" --cwd "$b/ooc" --rss-gib 24 --timeout-seconds "$remaining" -- \
 env LAYA_GEGLU_BANK_ATTEMPT="$b" /home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado \
 -mode batch -notrace -source "$b/frozen_source/$tcl" -log "$g/$run_name/vivado.log" -journal "$g/$run_name/vivado.jou"
rg -q "$marker" "$g/$run_name/vivado.log"
if rg -n '^ERROR:|^CRITICAL WARNING:' "$g/$run_name/vivado.log";then exit 1;fi
