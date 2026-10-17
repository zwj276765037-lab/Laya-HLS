#!/usr/bin/env bash
set -euo pipefail

stage=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/cpu_embedding_q8_validation_20261010
export LAYA_FRONT_TOP_SV="$stage/attempts/cpu_front_reject_adapter_01/work/cpu_front_reject_top.sv"
export LAYA_FRONT_SNAPSHOT=cpu_front_reject_static
exec /bin/bash "$stage/tb/build_cpu_front.sh" "$@"
