#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
run_name=${LAYA_GEGLU_CANONICAL_OOC_GUARD_NAME:-guard_ooc_01}
remaining=$(python3 - "$attempt" <<'PY'
from pathlib import Path
import sys,json,math
attempt=Path(sys.argv[1]);spent=0;previous=[]
for path in sorted(attempt.glob('guard_ooc_*/guard_result.json')):
 result=json.loads(path.read_text());spent+=result['elapsed_seconds'];previous.append({'path':str(path),'elapsed_seconds':result['elapsed_seconds']})
remaining=max(0,3600-spent)
state={'schema':'laya-geglu-canonical-cumulative-ooc-v1','successful_helper_DCPs_EDIFs_read_only_reused':True,'canonical_tanh_cost_not_moved_here':True,'own_guards':previous,'spent_seconds':spent,'remaining_seconds':remaining,'polling_reserve_seconds':5,'guard_timeout_seconds':max(0,math.floor(remaining-5))}
target=attempt/f'budget_before_ooc_{len(previous)+1:02}.json'
if target.exists():raise RuntimeError('budget record exists; use a fresh guard')
target.write_text(json.dumps(state,indent=2,sort_keys=True)+'\n')
print(state['guard_timeout_seconds'])
PY
)
if (( remaining <= 0 ));then echo TANH_LIBM_GEGLU_CANONICAL_OOC_CUMULATIVE_BUDGET_EXHAUSTED;exit 3;fi
mkdir -p "$attempt/ooc"
python3 "$attempt/frozen_source/tanh_libm_guard.py" --out "$attempt/$run_name" --cwd "$attempt/ooc" --rss-gib 24 --timeout-seconds "$remaining" -- \
 env LAYA_GEGLU_CANONICAL_ATTEMPT="$attempt" /home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado \
 -mode batch -notrace -source "$attempt/frozen_source/geglu_canonical_ooc.tcl" \
 -log "$attempt/$run_name/vivado.log" -journal "$attempt/$run_name/vivado.jou"
rg -q 'TANH_LIBM_GEGLU_CANONICAL_OOC_COMPLETE boundaries=51 add=25 mul=24 div=2 blackboxes=0 io_pads=0' "$attempt/$run_name/vivado.log"
if rg -n '^ERROR:|^CRITICAL WARNING:' "$attempt/$run_name/vivado.log";then exit 1;fi
