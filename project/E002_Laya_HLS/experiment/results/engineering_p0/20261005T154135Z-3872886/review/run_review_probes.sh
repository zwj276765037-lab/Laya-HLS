#!/usr/bin/env bash
set -euo pipefail
REVIEW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$REVIEW_DIR/../../../.." && pwd)"
REVIEW_BUILD="$ROOT/build/astra-review-20261005T154135Z"
mkdir -p "$REVIEW_BUILD"
cd "$ROOT"
run() {
  printf 'COMMAND'
  printf ' %q' "$@"
  printf '\n'
  "$@"
  printf 'EXIT 0\n'
}
run g++ --version
run g++ -std=c++17 -Wall -Wextra -Wpedantic -Iinclude -Ihls/control -Ihls/operators -Ihls/memory "$REVIEW_DIR/core_probe.cpp" hls/control/forward_controller.cpp hls/common/laya_tasks.cpp hls/operators/layernorm_engine.cpp hls/operators/activation_quantizer.cpp hls/operators/q8_linear_and_restore.cpp hls/operators/attention_and_fp_engine.cpp hls/operators/vector_and_ffn.cpp hls/memory/hbm_loader_and_cache.cpp -o "$REVIEW_BUILD/core_probe"
run "$REVIEW_BUILD/core_probe"
run g++ -std=c++17 -Wall -Wextra -Wpedantic -Iinclude -Ihls/control "$REVIEW_DIR/reset_probe.cpp" hls/control/forward_controller.cpp hls/common/laya_tasks.cpp -o "$REVIEW_BUILD/reset_probe"
run "$REVIEW_BUILD/reset_probe"
sha256sum "$REVIEW_DIR/core_probe.cpp" "$REVIEW_DIR/reset_probe.cpp" "$REVIEW_DIR/run_review_probes.sh" > "$REVIEW_DIR/review_source_hashes.sha256"
echo 'ASTRA_P0_REVIEW_PROBES_PASS checks=38 numerical_forward=NOT_RUN'
