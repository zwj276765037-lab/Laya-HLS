#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:---check}"
case "$MODE" in
  --check|--csim|--csynth|--cosim|--compile|--link|--deploy) ;;
  *) echo 'usage: run_full_hls.sh [--check|--csim|--csynth|--cosim|--compile|--link|--deploy]' >&2; exit 2 ;;
esac
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
OUT="${LAYA_FULL_HLS_RESULTS:-$ROOT/results/engineering_p2/$RUN_ID}"
BUILD="${LAYA_FULL_HLS_BUILD:-$ROOT/build/full-hls-$RUN_ID}"
MODEL="${LAYA_FULL_MODEL_DIR:-$ROOT/build/model-repair}"
REQUEST="${LAYA_FULL_REQUEST:-}"
ORACLE="${LAYA_FULL_ORACLE:-}"
PART="${LAYA_FULL_PART:-xcu55c-fsvh2892-2L-e}"
PLATFORM="${LAYA_PLATFORM:-}"
VITIS="${VITIS_RUN_BIN:-/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/vitis-run}"
VPP="${VPP_BIN:-/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/v++}"

if [[ "$MODE" == --check ]]; then
  printf 'mode=%s\nmodel=%s\nrequest=%s\noracle=%s\npart=%s\nplatform=%s\nvitis_run=%s\nvpp=%s\n' \
    "$MODE" "$MODEL" "$REQUEST" "$ORACLE" "$PART" "${PLATFORM:-MISSING}" "$VITIS" "$VPP"
  [[ -x "$VITIS" && -f "$MODEL/laya_model_layout_generated.h" ]]
  exit $?
fi
mkdir -p "$OUT" "$BUILD"
printf 'mode=%s\nroot=%s\nbuild=%s\nmodel=%s\nrequest=%s\noracle=%s\npart=%s\nplatform=%s\nvitis_run=%s\nvpp=%s\n' \
  "$MODE" "$ROOT" "$BUILD" "$MODEL" "$REQUEST" "$ORACLE" "$PART" \
  "${PLATFORM:-MISSING}" "$VITIS" "$VPP" > "$OUT/metadata.txt"

if [[ ! -f "$MODEL/laya_model_layout_generated.h" || ! -f "$MODEL/manifest.json" ]]; then
  echo "FULL_HLS_FAIL generated model package missing path=$MODEL evidence=$OUT" >&2
  exit 2
fi
if [[ "$MODE" == --deploy ]]; then
  HOST="${LAYA_XRT_HOST_BIN:-$ROOT/build/full-xrt-host/laya_host}"
  XCLBIN="${LAYA_FULL_XCLBIN:-}"
  XCLBIN_SHA256="${LAYA_FULL_XCLBIN_SHA256:-}"
  RESULT="${LAYA_FULL_RESULT:-}"
  TIMEOUT_MS="${LAYA_FULL_TIMEOUT_MS:-}"
  DEVICE_INDEX="${LAYA_FULL_DEVICE_INDEX:-0}"
  if [[ ! -x "$HOST" || ! -f "$XCLBIN" || ! -f "$REQUEST" ||
        -z "$XCLBIN_SHA256" || -z "$RESULT" || -z "$TIMEOUT_MS" ]]; then
    echo "FULL_HLS_FAIL deployment needs a built laya_host, real xclbin, request, expected xclbin SHA, result path and timeout evidence=$OUT" >&2
    exit 2
  fi
  sha256sum "$HOST" "$XCLBIN" "$REQUEST" "$MODEL/manifest.json" \
    "$MODEL/laya_model_layout_generated.h" > "$OUT/input_hashes.sha256"
  DEPLOY_COMMAND=("$HOST" --xclbin "$XCLBIN"
    --xclbin-sha256 "$XCLBIN_SHA256" --package "$MODEL"
    --request "$REQUEST" --result "$RESULT" --timeout-ms "$TIMEOUT_MS"
    --device "$DEVICE_INDEX")
  printf '%q ' "${DEPLOY_COMMAND[@]}" > "$OUT/deploy.command"
  printf '\n' >> "$OUT/deploy.command"
  if "${DEPLOY_COMMAND[@]}" > "$OUT/deploy.log" 2>&1; then
    printf '0\n' > "$OUT/deploy.exit"
    echo "FULL_TOP_DEPLOY_COMPLETE evidence=$OUT result=$RESULT"
    exit 0
  else
    code=$?
    printf '%s\n' "$code" > "$OUT/deploy.exit"
    tail -80 "$OUT/deploy.log" >&2
    echo "FULL_HLS_FAIL deployment exit=$code evidence=$OUT" >&2
    exit "$code"
  fi
fi
if [[ "$MODE" == --cosim ]]; then
  echo "FULL_HLS_FAIL complete-top RTL cosim requires an RTL-readable result-frame testbench; the current callback testbench is CSim-only evidence=$OUT" >&2
  exit 2
fi
if [[ "$MODE" == --link || "$MODE" == --compile ]]; then
  if [[ -z "$PLATFORM" || ! -f "$PLATFORM" ]]; then
    echo "FULL_HLS_FAIL actual .xpfm platform missing; xo/xclbin cannot be produced evidence=$OUT" >&2
    exit 2
  fi
  if [[ ! -x "$VPP" ]]; then
    echo "FULL_HLS_FAIL v++ missing path=$VPP evidence=$OUT" >&2
    exit 127
  fi
elif [[ "$MODE" == --csynth ]]; then
  if [[ ! -x "$VPP" ]]; then
    echo "FULL_HLS_FAIL v++ missing path=$VPP evidence=$OUT" >&2
    exit 127
  fi
else
  if [[ ! -x "$VITIS" ]]; then
    echo "FULL_HLS_FAIL vitis-run missing path=$VITIS evidence=$OUT" >&2
    exit 127
  fi
fi
if [[ "$MODE" == --csim ]]; then
  if [[ ! -f "$REQUEST" || ! -f "$ORACLE/final18.f32.bin" ]]; then
    echo "FULL_HLS_FAIL real B2 request or independent oracle missing evidence=$OUT" >&2
    exit 2
  fi
fi

SOURCES=()
while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]*(hls/[^[:space:]\)]*) ]]; then
    SOURCES+=("${BASH_REMATCH[1]}")
  fi
done < "$ROOT/config/full_sources.cmake"
if [[ ${#SOURCES[@]} -lt 20 ]]; then
  echo "FULL_HLS_FAIL incomplete production source list count=${#SOURCES[@]} evidence=$OUT" >&2
  exit 2
fi
for source in "${SOURCES[@]}"; do
  if [[ ! -f "$ROOT/$source" ]]; then
    echo "FULL_HLS_FAIL missing production source=$source evidence=$OUT" >&2
    exit 2
  fi
done

CFG="$BUILD/full_top.cfg"
{
  if [[ "$MODE" == --compile ]]; then
    printf 'platform=%s\nfreqhz=150000000\n[hls]\n' "$PLATFORM"
  else
    printf 'part=%s\nfreqhz=150000000\n[hls]\n' "$PART"
  fi
  if [[ "$MODE" == --compile ]]; then
    printf 'flow_target=vitis\npackage.output.format=xo\npackage.output.file=%s/laya_typed_q8_forward.xo\n' "$BUILD"
  else
    printf 'flow_target=vivado\n'
  fi
  printf 'syn.top=laya_typed_q8_forward\n'
  # F0 is intentionally serial. Disable tool-inferred loop pipelining so the
  # very large controller graph is synthesized without automatic expansion.
  printf 'syn.compile.pipeline_loops=0\n'
  # The full-top pilot expanded to 63M temporary instructions during
  # throughput-driven array partitioning; F0 has no parallel array contract.
  printf 'syn.array_partition.throughput_driven=off\n'
  printf 'syn.array_partition.complete_threshold=0\n'
  for source in "${SOURCES[@]}"; do printf 'syn.file=%s/%s\n' "$ROOT" "$source"; done
  if [[ "$MODE" == --csim ]]; then
    printf 'syn.cflags=-I%s/include -I%s/hls -I%s/hls/platform -I%s -std=c++17 -O2 -fno-fast-math -ffp-contract=off\n' \
      "$ROOT" "$ROOT" "$ROOT" "$MODEL"
    printf 'csim.stdmath=true\n'
  else
    printf 'syn.cflags=-I%s/include -I%s/hls -I%s/hls/platform -I%s -std=c++17 -fno-fast-math -ffp-contract=off\n' \
      "$ROOT" "$ROOT" "$ROOT" "$MODEL"
  fi
  printf 'tb.file=%s/hls/platform/full_kernel_csim_tb.cpp\n' "$ROOT"
  if [[ "$MODE" == --csim ]]; then
    printf 'tb.cflags=-I%s/include -I%s/hls -I%s/hls/platform -I%s -std=c++17 -O2 -fno-fast-math -ffp-contract=off\n' \
      "$ROOT" "$ROOT" "$ROOT" "$MODEL"
  else
    printf 'tb.cflags=-I%s/include -I%s/hls -I%s/hls/platform -I%s -std=c++17 -fno-fast-math -ffp-contract=off\n' \
      "$ROOT" "$ROOT" "$ROOT" "$MODEL"
  fi
} > "$CFG"
printf '%s\n' "${SOURCES[@]}" > "$OUT/hls_sources.txt"
sha256sum "$CFG" "$ROOT/config/full_sources.cmake" \
  "$ROOT/config/full_module_registry.json" \
  "$ROOT/hls/platform/full_kernel_csim_tb.cpp" \
  "$ROOT/hls/platform/full_kernel_wrapper.h" \
  "$ROOT/scripts/run_full_hls.sh" "$MODEL/laya_model_layout_generated.h" \
  "$MODEL/manifest.json" > "$OUT/input_hashes.sha256"
for source in "${SOURCES[@]}"; do sha256sum "$ROOT/$source"; done \
  >> "$OUT/input_hashes.sha256"
while IFS= read -r header; do sha256sum "$header"; done \
  < <(rg --files "$ROOT/include" "$ROOT/hls" -g '*.h' -g '*.hpp' | sort -u) \
  >> "$OUT/input_hashes.sha256"
for name in embedding w_q0 w_q1 w_scale aux; do
  sha256sum "$MODEL/$name.bin" >> "$OUT/input_hashes.sha256"
done
if [[ "$MODE" == --csim ]]; then
  mapfile -t ORACLE_FILES < <(rg --files "$ORACLE" -g '*.f32.bin' | sort)
  if [[ ${#ORACLE_FILES[@]} -ne 47 ]]; then
    echo "FULL_HLS_FAIL expected 47 independent oracle files evidence=$OUT" >&2
    exit 2
  fi
  sha256sum "$REQUEST" "${ORACLE_FILES[@]}" >> "$OUT/input_hashes.sha256"
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
    tail -80 "$OUT/$name.log" >&2
    echo "FULL_HLS_FAIL step=$name exit=$code evidence=$OUT" >&2
    exit "$code"
  fi
}

case "$MODE" in
  --csim)
    run_step csim env LAYA_FULL_HLS_PACKAGE="$MODEL" \
      LAYA_FULL_HLS_REQUEST="$REQUEST" LAYA_FULL_HLS_ORACLE="$ORACLE" \
      "$VITIS" --mode hls --csim --config "$CFG" \
      --work_dir "$BUILD/csim"
    ldd "$BUILD/csim/hls/csim/build/csim.exe" > "$OUT/csim_linked_libraries.txt"
    readelf --dyn-syms --wide "$BUILD/csim/hls/csim/build/csim.exe" \
      > "$OUT/csim_dynamic_symbols.txt"
    cp "$BUILD/csim/hls/csim/build/csim.mk" "$OUT/csim.mk"
    if rg -q 'libhlsm-GCC46' "$OUT/csim_linked_libraries.txt" ||
       ! rg -q 'libm.so.6' "$OUT/csim_linked_libraries.txt" ||
       ! rg -q 'csim.stdmath=true' "$CFG" ||
       ! rg -q -- '-O2 -fno-fast-math -ffp-contract=off' "$OUT/csim.mk"; then
      echo "FULL_HLS_FAIL standard-libm/strict-FP CSim configuration absent evidence=$OUT" >&2
      exit 1
    fi
    if ! rg -q 'FULL_KERNEL_CSIM_PASS checkpoints=47 values=9047192 tasks=37158' "$OUT/csim.log" ||
       ! rg -q 'CSim done with 0 errors' "$OUT/csim.log"; then
      echo "FULL_HLS_FAIL full top CSim PASS markers absent evidence=$OUT" >&2
      exit 1
    fi
    echo "FULL_TOP_CSIM_PASS evidence=$OUT"
    ;;
  --csynth)
    run_step csynth "$VPP" --compile --mode hls --config "$CFG" \
      --work_dir "$BUILD/csynth"
    rg --files "$BUILD/csynth" | rg 'csynth\.(rpt|xml)$' \
      > "$OUT/csynth_reports.txt" || true
    if [[ ! -s "$OUT/csynth_reports.txt" ]]; then
      echo "FULL_HLS_FAIL full top synthesis report absent evidence=$OUT" >&2
      exit 1
    fi
    echo "FULL_TOP_CSYNTH_COMPLETE reports=$OUT/csynth_reports.txt"
    ;;
  --cosim)
    run_step cosim "$VITIS" --mode hls --cosim --config "$CFG" \
      --work_dir "$BUILD/cosim"
    echo "FULL_TOP_COSIM_COMPLETE evidence=$OUT"
    ;;
  --compile)
    run_step compile "$VPP" --compile --mode hls \
      --config "$CFG" --work_dir "$BUILD/compile"
    if [[ ! -s "$BUILD/laya_typed_q8_forward.xo" ]]; then
      echo "FULL_HLS_FAIL production XO absent evidence=$OUT" >&2
      exit 1
    fi
    echo "FULL_TOP_XO_COMPLETE evidence=$OUT"
    ;;
  --link)
    XO="${LAYA_FULL_XO:-}"
    if [[ ! -f "$XO" ]]; then
      echo "FULL_HLS_FAIL existing production xo missing evidence=$OUT" >&2
      exit 2
    fi
    run_step link "$VPP" -l -t hw --platform "$PLATFORM" \
      --config "$ROOT/config/u55c_link.cfg" \
      -o "$BUILD/laya_typed_q8_forward.xclbin" "$XO"
    echo "FULL_TOP_XCLBIN_COMPLETE evidence=$OUT"
    ;;
esac
