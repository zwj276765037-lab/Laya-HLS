#!/usr/bin/env bash
# Source only. Actual XSim runtime and offline audit need a separate gate.
set -euo pipefail
export LC_ALL=C PYTHONDONTWRITEBYTECODE=1
if [[ $# -ne 3 || ! -d "$1" || ! -d "$2" || ! -d "$3" ]]; then
  echo 'usage: run_adapter.sh VECTORS_DIR STATIC_BUILD_DIR FRESH_RUNTIME_DIR' >&2
  exit 2
fi
root="$(cd "$(dirname "$0")/.." && pwd)"
vectors="$(readlink -f "$1")"
build="$(readlink -f "$2")"
runtime="$(readlink -f "$3")"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
[[ -d "$build/xsim.dir" && -f "$build/source_snapshot_post.json" &&
   ! -e "$runtime/xsim.dir" && ! -e "$runtime/xsim.log" &&
   ! -e "$runtime/r0_adapter_raw.log" && ! -e "$runtime/source_pre.json" ]]
/usr/bin/python3 "$root/tb/verify_generated_vectors.py" "$vectors"
/usr/bin/python3 "$root/tb/verify_source_binding.py" "$root/source/source_packet.json" \
  --snapshot "$build/xsim.dir" \
  --expected-snapshot-report "$build/source_snapshot_post.json" \
  --out "$runtime/source_pre.json"
ln -s "$build/xsim.dir" "$runtime/xsim.dir"
cd "$runtime"
run_status=0
timeout -k 5 600 "$xbin/xsim" r0_adapter_probe -runall \
  -onerror quit -onfinish quit -log xsim.log || run_status=$?
binding_status=0
/usr/bin/python3 "$root/tb/verify_source_binding.py" "$root/source/source_packet.json" \
  --snapshot "$build/xsim.dir" \
  --expected-snapshot-report "$build/source_snapshot_post.json" \
  --allow-runtime-mutables --out "$runtime/source_post.json" || binding_status=$?
audit_status=0
if [[ -f "$runtime/r0_adapter_raw.log" ]]; then
  /usr/bin/python3 "$root/tb/audit_raw.py" "$vectors" "$runtime/r0_adapter_raw.log" \
    --xsim-log "$runtime/xsim.log" --out "$runtime/raw_audit.json" || audit_status=$?
else
  audit_status=1
fi
if [[ $run_status -ne 0 || $binding_status -ne 0 || $audit_status -ne 0 ]]; then
  echo "R0_ADAPTER_RUN_FAIL xsim=$run_status binding=$binding_status audit=$audit_status" >&2
  exit 1
fi
echo 'R0_ADAPTER_RUN_PASS'
