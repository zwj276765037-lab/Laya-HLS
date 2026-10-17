#!/usr/bin/env bash
set -euo pipefail
a=$1
f="$a/frozen"
cd "$a/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" -sv "$f/laya_qkv_s128_request_v1.sv" "$f/laya_qkv_s128_peer_tb.sv"
"$bin/xelab" work.laya_qkv_s128_peer_tb --relax -mt off -s staged_ln_seq_peer
echo STAGED_LN_SEQ_STATIC_PASS
