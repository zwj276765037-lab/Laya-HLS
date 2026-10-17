#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
run_name=${LAYA_CANONICAL_OOC_GUARD_NAME:-guard_ooc_01}
guard="$attempt/frozen_source/tanh_libm_guard.py"
# Compute from all prior canonical OOC guards and fixed old-route actual cost.
remaining=$(python3 - "$attempt" <<'PY'
from pathlib import Path
import sys,json,math
attempt=Path(sys.argv[1]);schedule=json.loads((attempt/'schedule.json').read_text())
spent=schedule['prior_cumulative_ooc_seconds']
previous=[]
for path in sorted(attempt.glob('guard_ooc_*/guard_result.json')):
 result=json.loads(path.read_text());spent+=result['elapsed_seconds'];previous.append({'path':str(path),'elapsed_seconds':result['elapsed_seconds']})
remaining=max(0,3600-spent)
state={'schema':'laya-canonical-cumulative-ooc-v1','prior_actual_seconds':schedule['prior_cumulative_ooc_seconds'],'canonical_guards':previous,'spent_seconds':spent,'remaining_seconds':remaining,'polling_reserve_seconds':5,'guard_timeout_seconds':max(0,math.floor(remaining-5))}
name=f'budget_before_ooc_{len(previous)+1:02}.json';target=attempt/name
if target.exists():raise RuntimeError('budget record exists; require a fresh run name')
target.write_text(json.dumps(state,indent=2,sort_keys=True)+'\n')
print(state['guard_timeout_seconds'])
PY
)
if (( remaining <= 0 )); then echo TANH_LIBM_CANONICAL_OOC_CUMULATIVE_BUDGET_EXHAUSTED; exit 3; fi
mkdir -p "$attempt/ooc"
python3 "$guard" --out "$attempt/$run_name" --cwd "$attempt/ooc" --rss-gib 24 --timeout-seconds "$remaining" -- \
 env LAYA_CANONICAL_ATTEMPT="$attempt" /home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado \
 -mode batch -notrace -source "$attempt/frozen_source/tanh_libm_canonical_ooc.tcl" \
 -log "$attempt/$run_name/vivado.log" -journal "$attempt/$run_name/vivado.jou"
rg -q 'TANH_LIBM_CANONICAL_OOC_COMPLETE boundaries=42 add=23 mul=17 div=2 blackboxes=0' "$attempt/$run_name/vivado.log"
if rg -n '^ERROR:|^CRITICAL WARNING:' "$attempt/$run_name/vivado.log";then exit 1;fi
