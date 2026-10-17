#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
OUT="$ROOT/results/engineering_p0/$RUN_ID"
BUILD="$ROOT/build/contract-$RUN_ID"
mkdir -p "$OUT" "$BUILD"
CM="$ROOT/reference/cmake-3.31.8-linux-x86_64/bin/cmake"
CT="$ROOT/reference/cmake-3.31.8-linux-x86_64/bin/ctest"
if command -v cmake >/dev/null 2>&1; then CM="$(command -v cmake)"; fi
if command -v ctest >/dev/null 2>&1; then CT="$(command -v ctest)"; fi
echo "run_id=$RUN_ID" > "$OUT/metadata.txt"
echo "root=$ROOT" >> "$OUT/metadata.txt"
echo "build=$BUILD" >> "$OUT/metadata.txt"
echo "compiler=$(command -v g++)" >> "$OUT/metadata.txt"
"$CM" --version > "$OUT/cmake_version.txt" 2>&1
g++ --version > "$OUT/compiler_version.txt" 2>&1
python3 --version > "$OUT/python_version.txt" 2>&1
"$ROOT/scripts/preflight.sh" > "$OUT/preflight.log" 2>&1
python3 "$ROOT/scripts/record_fixture_hashes.py" "$ROOT" > "$OUT/fixture_hashes.sha256"
find "$ROOT/include" "$ROOT/hls" "$ROOT/host" "$ROOT/config" "$ROOT/scripts" "$ROOT/tests" "$ROOT/vivado/module_design" -type f \( -name '*.cpp' -o -name '*.h' -o -name '*.py' -o -name '*.sh' -o -name '*.cfg' \) -print0 | sort -z | xargs -0 sha256sum > "$OUT/source_hashes.sha256"
sha256sum "$ROOT/CMakeLists.txt" "$ROOT/config/module_sources.cmake" >> "$OUT/source_hashes.sha256"
run_step(){
  local name="$1"; shift
  printf '%q ' "$@" > "$OUT/$name.command"; echo >> "$OUT/$name.command"
  if "$@" > "$OUT/$name.log" 2>&1; then echo 0 > "$OUT/$name.exit"; else local code=$?; echo "$code" > "$OUT/$name.exit"; cat "$OUT/$name.log" >&2; echo "ENGINEERING_CONTRACT_FAIL step=$name evidence=$OUT" >&2; exit "$code"; fi
}
run_step configure "$CM" -S "$ROOT" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release
run_step build "$CM" --build "$BUILD" -j 8
run_step ctest "$CT" --test-dir "$BUILD" --output-on-failure -V
if ! grep -q '100% tests passed, 0 tests failed out of 20' "$OUT/ctest.log"; then
  echo 'ENGINEERING_CONTRACT_FAIL ctest summary missing' >&2; exit 1
fi
echo 20 > "$OUT/ctest_count.txt"
echo "ENGINEERING_CONTRACT_PASS tests=20 evidence=$OUT"
