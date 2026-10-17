#!/usr/bin/env bash
set -euo pipefail
a=$1
f="$a/frozen"
cd "$a/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$f/laya_qkv_s128_request_v1.sv" "$f/laya_staged_ln_store_priority_peer_tb.sv"
"$bin/xelab" work.laya_staged_ln_store_priority_peer_tb --relax -mt off -s store_priority_sim
echo STORE_PRIORITY_STATIC_PASS
