#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:---csim-only}"
if [[ "$MODE" != --csim-only && "$MODE" != --probe ]]; then
  echo 'usage: run_full_numeric_hls.sh [--csim-only|--probe]' >&2
  exit 2
fi
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
OUT="$ROOT/results/engineering_p2/$RUN_ID"
BUILD="$ROOT/build/full-hls-$RUN_ID"
VITIS="${VITIS_RUN_BIN:-/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/vitis-run}"
mkdir -p "$OUT" "$BUILD"
if [[ ! -x "$VITIS" ]]; then
  echo "FULL_NUMERIC_HLS_FAIL vitis-run missing path=$VITIS" >&2
  exit 127
fi
printf 'run_id=%s\nroot=%s\nbuild=%s\nmode=%s\nvitis_run=%s\npart=%s\nclock_hz=%s\n' \
  "$RUN_ID" "$ROOT" "$BUILD" "$MODE" "$VITIS" \
  xcu55c-fsvh2892-2L-e 150000000 > "$OUT/metadata.txt"
"$VITIS" --version > "$OUT/vitis_version.txt" 2>&1
python3 - "$ROOT/hardware_agent/task.md" "$OUT/contract_preimage.txt" <<'PY'
from pathlib import Path
import sys
source = Path(sys.argv[1]).read_text(encoding="utf-8")
start = source.index("## 12. ")
end = source.find("### 12.4 ", start)
if end < 0:
    end = len(source)
Path(sys.argv[2]).write_text("LAYA_P2_A_CONTRACT_V1\n" + source[start:end], encoding="utf-8")
PY
sha256sum "$OUT/contract_preimage.txt" "$ROOT/hardware_agent/task.md" \
  > "$OUT/contract_hashes.sha256"
sha256sum "$ROOT/config/full_hls_"*.cfg "$ROOT/config/full_hls_rope.tcl" \
          "$ROOT/config/full_hls_rope_cosim.tcl" \
          "$ROOT/scripts/run_full_numeric_hls.sh" \
          "$ROOT/include/laya_full_numeric.h" \
          "$ROOT/include/laya_numeric_tasks.h" \
          "$ROOT/include/laya_tasks.h" \
          "$ROOT/hls/common/laya_numeric.cpp" \
          "$ROOT/hls/operators/"*_full_compute.cpp \
          "$ROOT/hls/operators/full_rope_cosim_wrapper.cpp" \
          "$ROOT/vivado/module_design/embedding_engine/tb/full_numeric_tb.cpp" \
          "$ROOT/vivado/module_design/rope_and_mask/tb/full_numeric_tb.cpp" \
          "$ROOT/vivado/module_design/attention_and_fp_engine/tb/full_numeric_tb.cpp" \
          "$ROOT/vivado/module_design/vector_and_ffn/tb/full_numeric_tb.cpp" \
          "$ROOT/vivado/module_design/decision_scorer_act/tb/full_numeric_tb.cpp" \
          > "$OUT/source_hashes.sha256"
if [[ -f "$ROOT/vivado/module_design/rope_and_mask/tb/full_rope_cosim_tb.cpp" ]]; then
  sha256sum "$ROOT/vivado/module_design/rope_and_mask/tb/full_rope_cosim_tb.cpp" \
    >> "$OUT/source_hashes.sha256"
fi

run_step() {
  local name="$1"; shift
  printf '%q ' "$@" > "$OUT/$name.command"
  printf '\n' >> "$OUT/$name.command"
  if "$@" > "$OUT/$name.log" 2>&1; then
    printf '0\n' > "$OUT/$name.exit"
  else
    local code=$?
    printf '%s\n' "$code" > "$OUT/$name.exit"
    cat "$OUT/$name.log" >&2
    echo "FULL_NUMERIC_HLS_FAIL step=$name evidence=$OUT" >&2
    exit "$code"
  fi
}

for entry in embedding rope attention vector decision; do
  run_step "csim_$entry" "$VITIS" --mode hls --csim \
    --config "$ROOT/config/full_hls_$entry.cfg" \
    --work_dir "$BUILD/$entry"
done
for entry in 'embedding EMBEDDING 5' 'rope ROPE 4' \
             'attention ATTENTION 9' 'vector VECTOR 7' 'decision DECISION 5'; do
  read -r name marker count <<< "$entry"
  if ! grep -q "FULL_${marker}_PASS cases=$count" "$OUT/csim_$name.log" ||
     ! grep -q 'CSim done with 0 errors' "$OUT/csim_$name.log"; then
    echo "FULL_NUMERIC_HLS_FAIL CSim marker $name evidence=$OUT" >&2
    exit 1
  fi
done
echo "FULL_NUMERIC_A_HLS_CSIM_PASS modules=5 evidence=$OUT"

if [[ "$MODE" == --csim-only ]]; then exit 0; fi
# TCL batch mode resolves stored relative source paths from its launch cwd.
# The design files in this project live one level above build/.
pushd "$ROOT/build" > /dev/null
run_step synth_rope env LAYA_FULL_HLS_PROBE_PROJECT="$BUILD/rope_probe" \
  "$VITIS" --mode hls --tcl "$ROOT/config/full_hls_rope.tcl"
popd > /dev/null
REPORT="$BUILD/rope_probe/solution1/syn/report/rope_head_csynth.rpt"
if [[ ! -s "$REPORT" ]] ||
   ! grep -q 'Finished Command csynth_design' "$OUT/synth_rope.log"; then
  echo "FULL_NUMERIC_HLS_FAIL synthesis report missing evidence=$OUT" >&2
  exit 1
fi
cp "$REPORT" "$OUT/rope_head_csynth.rpt"
cp "${REPORT%.rpt}.xml" "$OUT/rope_head_csynth.xml"
echo "FULL_NUMERIC_A_HLS_SYNTH_PASS top=rope_head evidence=$OUT"

pushd "$ROOT/build" > /dev/null
run_step cosim_rope env LAYA_FULL_HLS_PROBE_PROJECT="$BUILD/rope_cosim" \
  "$VITIS" --mode hls --tcl "$ROOT/config/full_hls_rope_cosim.tcl"
popd > /dev/null
if ! grep -q 'C/RTL co-simulation finished: PASS' "$OUT/cosim_rope.log"; then
  echo "FULL_NUMERIC_HLS_FAIL cosim PASS marker missing evidence=$OUT" >&2
  exit 1
fi
echo "FULL_NUMERIC_A_RTL_COSIM_PASS top=full_rope_cosim_top evidence=$OUT"
