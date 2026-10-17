#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VITIS_DIR="${XILINX_VITIS:-/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis}"
VIVADO_DIR="${XILINX_VIVADO:-/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado}"
report_tool() {
  local label="$1" executable="$2" path rc first
  path="$(command -v "$executable" 2>/dev/null || true)"
  if [[ -z "$path" ]]; then
    echo "$label MISSING executable=$executable"
    return
  fi
  first="$($path --version 2>&1)"; rc=$?
  first="$(printf '%s\n' "$first" | head -n 2 | tr '\n' ' ')"
  echo "$label FOUND path=$path exit=$rc version=$first"
}
report_path() {
  local label="$1" path="$2" arg="$3" output rc
  if [[ ! -x "$path" ]]; then echo "$label MISSING checked_path=$path"; return; fi
  output="$($path "$arg" 2>&1)"; rc=$?
  output="$(printf '%s\n' "$output" | head -n 2 | tr '\n' ' ')"
  echo "$label FOUND path=$path exit=$rc version=$output"
}
report_tool GXX g++
report_tool PYTHON python3
if command -v cmake >/dev/null 2>&1; then report_tool CMAKE cmake
else report_path CMAKE "$ROOT/reference/cmake-3.31.8-linux-x86_64/bin/cmake" --version; fi
if command -v ctest >/dev/null 2>&1; then report_tool CTEST ctest
else report_path CTEST "$ROOT/reference/cmake-3.31.8-linux-x86_64/bin/ctest" --version; fi
if [[ -n "${VIVADO_BIN:-}" ]]; then report_path VIVADO "$VIVADO_BIN" -version
elif command -v vivado >/dev/null 2>&1; then report_path VIVADO "$(command -v vivado)" -version
else report_path VIVADO "$VIVADO_DIR/bin/vivado" -version; fi
if [[ -n "${VPP_BIN:-}" ]]; then report_path VPP "$VPP_BIN" --version
elif command -v v++ >/dev/null 2>&1; then report_path VPP "$(command -v v++)" --version
else report_path VPP "$VITIS_DIR/bin/v++" --version; fi
if [[ -n "${VITIS_RUN_BIN:-}" ]]; then report_path VITIS_RUN "$VITIS_RUN_BIN" --version
elif command -v vitis-run >/dev/null 2>&1; then report_path VITIS_RUN "$(command -v vitis-run)" --version
else report_path VITIS_RUN "$VITIS_DIR/bin/vitis-run" --version; fi
for x in xbutil xbmgmt xclbinutil; do report_tool "XRT_${x^^}" "$x"; done
if [[ -n "${LAYA_PLATFORM:-}" ]]; then
  if [[ -f "$LAYA_PLATFORM" && "$LAYA_PLATFORM" == *.xpfm ]]; then
    echo "PLATFORM FOUND path=$LAYA_PLATFORM"
  else
    echo "PLATFORM MISSING specified=$LAYA_PLATFORM"
  fi
else
  echo "PLATFORM MISSING no LAYA_PLATFORM .xpfm specified; checked /opt/xilinx/platforms and local Vitis installation separately"
  for location in /opt/xilinx/platforms "$VITIS_DIR/platforms" "$ROOT/platforms"; do
    if [[ -d "$location" ]]; then
      find "$location" -maxdepth 3 -name '*.xpfm' -print | head -n 10 | sed 's/^/PLATFORM_CANDIDATE FOUND path=/'
    else echo "PLATFORM_SEARCH MISSING directory=$location"; fi
  done
fi
if [[ -n "${LAYA_PART:-}" ]]; then echo "PART PROVIDED value=$LAYA_PART"; else echo "PART MISSING LAYA_PART not specified"; fi
echo "DEVICE NOT_TESTED no board access attempted by P0 preflight"
echo "LICENSE NOT_TESTED no synthesis or link attempted by P0 preflight"
