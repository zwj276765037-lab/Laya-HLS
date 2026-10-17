#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL="${LAYA_FULL_MODEL_DIR:-$ROOT/build/model-p2-final}"
BUILD="${LAYA_FULL_BUILD_DIR:-$ROOT/build/full-final}"
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
OUT="${LAYA_FULL_TEST_RESULTS:-$ROOT/results/engineering_p2/$RUN_ID}"
CMAKE="${CMAKE_BIN:-$ROOT/reference/cmake-3.31.8-linux-x86_64/bin/cmake}"
CTEST="${CTEST_BIN:-$(dirname "$CMAKE")/ctest}"
FROZEN="$ROOT/reference/runs/typed_q8_ref_20261005/abi_replay/request_v1.bin"
mkdir -p "$OUT" "$BUILD"
if [[ ! -x "$CMAKE" || ! -x "$CTEST" ||
      ! -f "$MODEL/laya_model_layout_generated.h" ||
      ! -f "$MODEL/manifest.json" || ! -f "$FROZEN" ]]; then
  echo "FULL_TEST_FAIL missing CMake, generated model package or frozen request evidence=$OUT" >&2
  exit 2
fi
printf 'root=%s\nbuild=%s\nmodel=%s\nout=%s\ncmake=%s\n' \
  "$ROOT" "$BUILD" "$MODEL" "$OUT" "$CMAKE" > "$OUT/metadata.txt"
"$CMAKE" --version > "$OUT/cmake_version.txt" 2>&1
g++ --version > "$OUT/compiler_version.txt" 2>&1
sha256sum "$MODEL/manifest.json" "$MODEL/laya_model_layout_generated.h" \
  "$FROZEN" > "$OUT/input_hashes.sha256"
for name in embedding w_q0 w_q1 w_scale aux; do
  sha256sum "$MODEL/$name.bin" >> "$OUT/input_hashes.sha256"
done

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
    echo "FULL_TEST_FAIL step=$name exit=$code evidence=$OUT" >&2
    exit "$code"
  fi
}

CONFIGURE=("$CMAKE" -S "$ROOT" -B "$BUILD"
  -DLAYA_ENABLE_FULL_NUMERIC=ON
  -DLAYA_ENABLE_FULL_FORWARD=ON
  -DLAYA_FULL_MODEL_DIR="$MODEL"
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON)
BUILD_COMMAND=("$CMAKE" --build "$BUILD" -j 8)
{
  printf '%q ' "${CONFIGURE[@]}"; printf '\n'
  printf '%q ' "${BUILD_COMMAND[@]}"; printf '\n'
} > "$OUT/build_commands.txt"
run_step configure "${CONFIGURE[@]}"
run_step build "${BUILD_COMMAND[@]}"
run_step ctest "$CTEST" --test-dir "$BUILD" --output-on-failure
run_step model_package python3 "$ROOT/tests/full_model_package_test.py" \
  "$ROOT" "$MODEL" "$OUT/model_package" --strict-current-sources
run_step source_closure python3 "$ROOT/tests/full_source_closure.py" \
  "$ROOT" "$BUILD" "$MODEL" "$OUT/build_commands.txt" \
  "$OUT/source_closure"
run_step numeric_fixture python3 "$ROOT/tests/full_fixture_test.py" \
  "$ROOT" "$BUILD/full_cli" "$OUT/numeric_fixture"
run_step oracle python3 "$ROOT/tests/full_forward_oracle.py" \
  "$ROOT" "$OUT/oracle"
run_step front_fixture python3 "$ROOT/tests/full_front_fixture.py" \
  "$ROOT" "$OUT/front_fixture"
run_step matrix_fixture python3 "$ROOT/tests/full_matrix_fixture.py" \
  "$ROOT" "$OUT/matrix_fixture"
run_step attention_fixture python3 "$ROOT/tests/full_attention_fixture.py" \
  "$ROOT" "$OUT/attention_fixture"
run_step front_dut python3 "$ROOT/tests/full_front_dut_test.py" \
  "$ROOT" "$MODEL" "$FROZEN" \
  "$OUT/oracle/full_forward_oracle_report.json" \
  "$OUT/front_fixture" "$BUILD/full_front_dut" "$OUT/front_dut" \
  "$OUT/source_closure/full_source_closure_report.json"
run_step matrix_dut python3 "$ROOT/tests/full_matrix_dut_test.py" \
  "$ROOT" "$MODEL" "$FROZEN" \
  "$OUT/matrix_fixture" "$BUILD/full_matrix_dut" "$OUT/matrix_dut" \
  "$OUT/source_closure/full_source_closure_report.json"
run_step attention_dut python3 "$ROOT/tests/full_attention_dut_test.py" \
  "$ROOT" "$MODEL" "$FROZEN" \
  "$OUT/attention_fixture" "$BUILD/full_attention_dut" "$OUT/attention_dut" \
  "$OUT/source_closure/full_source_closure_report.json"
run_step shape_dut python3 "$ROOT/tests/full_shape_dut_test.py" \
  "$ROOT" "$MODEL" "$OUT/matrix_fixture" \
  "$BUILD/full_shape_dut_tb" "$OUT/shape_dut" \
  "$OUT/source_closure/full_source_closure_report.json"
run_step dut python3 "$ROOT/tests/full_forward_dut_run.py" \
  "$ROOT" "$MODEL" "$FROZEN" \
  "$BUILD/full_forward_dut_runner" "$OUT/dut" \
  "$OUT/source_closure/full_source_closure_report.json"
run_step compare python3 "$ROOT/tests/full_forward_dut_compare.py" \
  "$OUT/oracle/full_forward_oracle_report.json" "$MODEL" \
  "$OUT/dut/dut" "$OUT/compare"
run_step final_gate python3 "$ROOT/tools/full_final_gate.py" \
  "$ROOT" "$BUILD" "$MODEL" "$OUT"
echo "FULL_FORWARD_CPU_PASS evidence=$OUT"
