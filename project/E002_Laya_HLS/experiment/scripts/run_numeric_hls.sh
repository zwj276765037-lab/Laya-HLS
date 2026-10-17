#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-run}"
if [[ "$MODE" != run && "$MODE" != --csim-only ]]; then
  echo "usage: run_numeric_hls.sh [--csim-only]" >&2
  exit 2
fi
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
OUT="$ROOT/results/engineering_p1/$RUN_ID"
BUILD="$ROOT/build/numeric-hls-$RUN_ID"
VITIS="${VITIS_RUN_BIN:-/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/vitis-run}"
mkdir -p "$OUT" "$BUILD"
if [[ ! -x "$VITIS" ]]; then
  echo "NUMERIC_HLS_FAIL vitis-run missing path=$VITIS" >&2
  exit 127
fi
printf 'run_id=%s\nroot=%s\nbuild=%s\nmode=%s\nvitis_run=%s\npart=%s\nclock_hz=%s\n' \
  "$RUN_ID" "$ROOT" "$BUILD" "$MODE" "$VITIS" \
  xcu55c-fsvh2892-2L-e 150000000 > "$OUT/metadata.txt"
"$VITIS" --version > "$OUT/vitis_version.txt" 2>&1
sha256sum "$ROOT/config/numeric_hls_layernorm.cfg" \
          "$ROOT/config/numeric_hls_quant.cfg" \
          "$ROOT/config/numeric_hls_linear.cfg" \
          "$ROOT/config/numeric_hls_quant.tcl" \
          "$ROOT/scripts/run_numeric_hls.sh" \
          "$ROOT/include/laya_numeric.h" \
          "$ROOT/include/laya_numeric_tasks.h" \
          "$ROOT/include/laya_tasks.h" \
          "$ROOT/hls/common/laya_numeric.cpp" \
          "$ROOT/hls/operators/layernorm_compute.cpp" \
          "$ROOT/hls/operators/activation_quantizer_compute.cpp" \
          "$ROOT/hls/operators/q8_linear_compute.cpp" \
          "$ROOT/tests/numeric_test_support.h" \
          "$ROOT/vivado/module_design/layernorm_engine/tb/numeric_tb.cpp" \
          "$ROOT/vivado/module_design/activation_quantizer/tb/numeric_tb.cpp" \
          "$ROOT/vivado/module_design/q8_linear_and_restore/tb/numeric_tb.cpp" \
          > "$OUT/source_hashes.sha256"

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
    echo "NUMERIC_HLS_FAIL step=$name evidence=$OUT" >&2
    exit "$code"
  fi
}

run_step csim_layernorm "$VITIS" --mode hls --csim \
  --config "$ROOT/config/numeric_hls_layernorm.cfg" \
  --work_dir "$BUILD/layernorm"
run_step csim_quant "$VITIS" --mode hls --csim \
  --config "$ROOT/config/numeric_hls_quant.cfg" \
  --work_dir "$BUILD/quant"
run_step csim_linear "$VITIS" --mode hls --csim \
  --config "$ROOT/config/numeric_hls_linear.cfg" \
  --work_dir "$BUILD/linear"
for entry in 'layernorm LN 29' 'quant QUANT 30' 'linear LINEAR 57'; do
  read -r name marker count <<< "$entry"
  if ! grep -q "NUMERIC_${marker}_TB_PASS cases=$count" "$OUT/csim_$name.log" ||
     ! grep -q 'CSim done with 0 errors' "$OUT/csim_$name.log"; then
    echo "NUMERIC_HLS_FAIL CSim marker $name evidence=$OUT" >&2
    exit 1
  fi
done
echo "NUMERIC_HLS_CSIM_PASS modules=3 cases=116 evidence=$OUT"

if [[ "$MODE" == --csim-only ]]; then exit 0; fi
# A single scalar slice is synthesized as a resource/port feasibility probe.
# This has no production platform, xo/xclbin link, or full-forward implication.
run_step synth_quant env LAYA_NUMERIC_HLS_SYNTH_PROJECT="$BUILD/quant_synth" \
  "$VITIS" --mode hls --tcl "$ROOT/config/numeric_hls_quant.tcl"
find "$BUILD/quant_synth" -type f \( -name '*csynth*.rpt' -o -name '*csynth*.xml' \) \
  -print | sort > "$OUT/synthesis_reports.txt"
REPORT="$BUILD/quant_synth/solution1/syn/report/activation_quantizer_compute_csynth.rpt"
if [[ ! -s "$OUT/synthesis_reports.txt" || ! -s "$REPORT" ]] ||
   ! grep -q 'Finished Command csynth_design' "$OUT/synth_quant.log"; then
  echo "NUMERIC_HLS_FAIL synthesis report missing evidence=$OUT" >&2
  exit 1
fi
cp "$REPORT" "$OUT/activation_quantizer_compute_csynth.rpt"
cp "${REPORT%.rpt}.xml" "$OUT/activation_quantizer_compute_csynth.xml"
echo "NUMERIC_HLS_SYNTH_PASS top=activation_quantizer_compute evidence=$OUT"
