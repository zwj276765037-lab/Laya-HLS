#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
OUT="$ROOT/results/engineering_p1/$RUN_ID"
BUILD="$ROOT/build/numeric-$RUN_ID"
CM="$ROOT/reference/cmake-3.31.8-linux-x86_64/bin/cmake"
CT="$ROOT/reference/cmake-3.31.8-linux-x86_64/bin/ctest"
if command -v cmake >/dev/null 2>&1; then CM="$(command -v cmake)"; fi
if command -v ctest >/dev/null 2>&1; then CT="$(command -v ctest)"; fi
mkdir -p "$OUT" "$BUILD"

printf 'run_id=%s\nroot=%s\nbuild=%s\ncompiler=%s\n' \
  "$RUN_ID" "$ROOT" "$BUILD" "$(command -v g++)" > "$OUT/metadata.txt"
"$CM" --version > "$OUT/cmake_version.txt" 2>&1
"$CT" --version > "$OUT/ctest_version.txt" 2>&1
g++ --version > "$OUT/compiler_version.txt" 2>&1
python3 -c 'import platform,sys,numpy; print("python",sys.version); print("numpy",numpy.__version__); print("libc",platform.libc_ver())' \
  > "$OUT/python_numeric_version.txt" 2>&1
"$ROOT/scripts/preflight.sh" > "$OUT/preflight.log" 2>&1

find "$ROOT/include" "$ROOT/hls/common" "$ROOT/hls/operators" \
     "$ROOT/tests" "$ROOT/vivado/module_design/layernorm_engine/tb" \
     "$ROOT/vivado/module_design/activation_quantizer/tb" \
     "$ROOT/vivado/module_design/q8_linear_and_restore/tb" \
     "$ROOT/vivado/module_design/top/tb" \
     -maxdepth 1 -type f \( -name '*.cpp' -o -name '*.h' -o -name '*.py' \) \
     -print0 | sort -z | xargs -0 sha256sum > "$OUT/source_hashes.sha256"
sha256sum "$ROOT/CMakeLists.txt" "$ROOT/config/numeric_sources.cmake" \
          "$ROOT/scripts/run_numeric_tests.sh" >> "$OUT/source_hashes.sha256"
sha256sum "$ROOT/reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json" \
          "$ROOT/reference/runs/typed_q8_ref_20261005/gguf_inventory.json" \
          > "$OUT/fixture_roots.sha256"

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
    echo "NUMERIC_SLICE_FAIL step=$name evidence=$OUT" >&2
    exit "$code"
  fi
}

run_step configure "$CM" -S "$ROOT" -B "$BUILD" \
  -DLAYA_ENABLE_NUMERIC=ON -DCMAKE_BUILD_TYPE=Release
run_step build "$CM" --build "$BUILD" -j 8
ldd "$BUILD/numeric_cli" > "$OUT/numeric_cli_linked_libraries.txt" 2>&1
run_step ctest "$CT" --test-dir "$BUILD" --output-on-failure -V \
  -R '^numeric_'
if ! grep -q '100% tests passed, 0 tests failed out of 3' "$OUT/ctest.log"; then
  echo "NUMERIC_SLICE_FAIL numeric test summary missing evidence=$OUT" >&2
  exit 1
fi
run_step fixture python3 "$ROOT/vivado/module_design/top/tb/numeric_fixture_test.py" \
  "$ROOT" "$BUILD/numeric_cli" "$OUT/fixture"
python3 - "$OUT/fixture/numeric_fixture_report.json" > "$OUT/summary.json" <<'PY'
import json, pathlib, sys
report = json.loads(pathlib.Path(sys.argv[1]).read_text())
assert report["status"] == "PASS" and len(report["cases"]) == 31
total_trace = sum(c["oracle_exact"].get("trace_groups", 0) for c in report["cases"])
assert total_trace == 132128
print(json.dumps({"status": "PASS", "cases": len(report["cases"]),
                  "trace_groups": total_trace,
                  "checked_reference_files": len(report["checked_reference_files"]),
                  "numeric_version": report["numeric_version"],
                  "experimental_tags_hex": report["experimental_tags_hex"]}, indent=2))
PY
echo "NUMERIC_SLICE_PASS cases=31 trace_groups=132128 evidence=$OUT"
