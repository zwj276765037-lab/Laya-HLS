#!/usr/bin/env bash
# Dormant until the separately reviewed distinct_rows3 CPU leaf execution gate.
set -euo pipefail
export LC_ALL=C

BASE=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
MODEL="$BASE/build/model-attention-rtl-repair-20261008"
if [[ $# -ne 2 || ! -x "$1/test_q8_scorer_distinct_rows3" || ! -f "$2/fixture_report.json" ]]; then
  echo 'usage: run_cpu_leaf.sh CPU_BUILD_DIRECTORY FIXTURE_DIRECTORY' >&2
  exit 2
fi
nice -n 19 ionice -c 3 "$1/test_q8_scorer_distinct_rows3" "$MODEL" "$2"
