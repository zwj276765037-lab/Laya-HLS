#!/usr/bin/env bash
set -euo pipefail
attempt=$1
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$attempt/work"
"$bin/xvlog" --sv "$attempt/frozen/laya_qkv_s128_request_v1.sv" "$attempt/frozen/laya_qkv_s128_peer_tb.sv"
"$bin/xelab" work.laya_qkv_s128_peer_tb --relax -mt off -s s128_peer_sim
echo S128_PEER_ELAB_PASS
