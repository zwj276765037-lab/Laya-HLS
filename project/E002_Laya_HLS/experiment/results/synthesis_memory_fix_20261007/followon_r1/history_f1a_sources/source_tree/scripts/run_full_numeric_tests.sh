#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
OUT="$ROOT/results/engineering_p2/$RUN_ID"
BUILD="$ROOT/build/full-numeric-$RUN_ID"
CM="$ROOT/reference/cmake-3.31.8-linux-x86_64/bin/cmake"
CT="$ROOT/reference/cmake-3.31.8-linux-x86_64/bin/ctest"
if command -v cmake >/dev/null 2>&1; then CM="$(command -v cmake)"; fi
if command -v ctest >/dev/null 2>&1; then CT="$(command -v ctest)"; fi
mkdir -p "$OUT" "$BUILD"

printf 'run_id=%s\nroot=%s\nbuild=%s\ncompiler=%s\nphase=P2_A_CPU\n' \
  "$RUN_ID" "$ROOT" "$BUILD" "$(command -v g++)" > "$OUT/metadata.txt"
"$CM" --version > "$OUT/cmake_version.txt" 2>&1
"$CT" --version > "$OUT/ctest_version.txt" 2>&1
g++ --version > "$OUT/compiler_version.txt" 2>&1
python3 -c 'import platform,sys; print("python",sys.version); print("libc",platform.libc_ver()); import numpy; print("numpy",numpy.__version__)' \
  > "$OUT/python_numeric_version.txt" 2>&1
getconf GNU_LIBC_VERSION > "$OUT/glibc_version.txt" 2>&1
"$ROOT/scripts/preflight.sh" > "$OUT/preflight.log" 2>&1

# Preserve the exact UTF-8 contract used by this run. Later B/C sections or
# final review text may change task.md without changing this P2 A preimage.
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

find "$ROOT/include" "$ROOT/hls/common" "$ROOT/hls/operators" "$ROOT/tests" \
     "$ROOT/vivado/module_design/embedding_engine/tb" \
     "$ROOT/vivado/module_design/rope_and_mask/tb" \
     "$ROOT/vivado/module_design/attention_and_fp_engine/tb" \
     "$ROOT/vivado/module_design/vector_and_ffn/tb" \
     "$ROOT/vivado/module_design/decision_scorer_act/tb" \
     -maxdepth 1 -type f \( -name '*.cpp' -o -name '*.h' -o -name '*.py' \) \
     -print0 | sort -z | xargs -0 sha256sum > "$OUT/source_hashes.sha256"
sha256sum "$ROOT/CMakeLists.txt" "$ROOT/config/full_numeric_sources.cmake" \
          "$ROOT/scripts/run_full_numeric_tests.sh" \
          >> "$OUT/source_hashes.sha256"
sha256sum "$ROOT/reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json" \
          "$ROOT/reference/runs/typed_q8_ref_20261005/gguf_inventory.json" \
          > "$OUT/fixture_roots.sha256"
python3 - "$ROOT/reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json" \
           "$OUT/model_path.txt" <<'PY'
import json
from pathlib import Path
import sys
m = json.loads(Path(sys.argv[1]).read_text())
Path(sys.argv[2]).write_text(m["model"]["path"] + "\n")
PY
sha256sum "$(cat "$OUT/model_path.txt")" >> "$OUT/fixture_roots.sha256"

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
    echo "FULL_NUMERIC_FAIL step=$name evidence=$OUT" >&2
    exit "$code"
  fi
}

run_step configure "$CM" -S "$ROOT" -B "$BUILD" \
  -DLAYA_ENABLE_FULL_NUMERIC=ON -DCMAKE_BUILD_TYPE=Release
run_step build "$CM" --build "$BUILD" -j 8
ldd "$BUILD/full_cli" > "$OUT/full_cli_linked_libraries.txt" 2>&1
run_step ctest "$CT" --test-dir "$BUILD" --output-on-failure -V \
  -R '^full_numeric_'
if ! grep -q '100% tests passed, 0 tests failed out of 5' "$OUT/ctest.log"; then
  echo "FULL_NUMERIC_FAIL direct test summary missing evidence=$OUT" >&2
  exit 1
fi
run_step fixture python3 "$ROOT/tests/full_fixture_test.py" \
  "$ROOT" "$BUILD/full_cli" "$OUT/fixture"
python3 - "$OUT/fixture/full_fixture_report.json" > "$OUT/summary.json" <<'PY'
import json
from pathlib import Path
import sys
report = json.loads(Path(sys.argv[1]).read_text())
assert report["status"] == "PASS"
assert len(report["cases"]) > 0
print(json.dumps({"status": "PASS", "phase": "P2_A_CPU",
                  "cases": len(report["cases"]),
                  "checked_reference_files": len(report["checked_reference_files"])},
                 indent=2))
PY
echo "FULL_NUMERIC_A_CPU_PASS evidence=$OUT"
