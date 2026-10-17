#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-run}"
if [[ "$MODE" != run && "$MODE" != --check ]]; then echo "usage: run_hls.sh [--check]" >&2; exit 2; fi
mapfile -t missing < <(grep -oE '\{"[^"]+",false,"contract_only"\}' "$ROOT/hls/laya_forward.cpp" | sed -E 's/^\{"([^"]+)",false,"contract_only"\}$/\1/')
if ((${#missing[@]})); then printf 'NUMERICAL_MODULES MISSING %s\n' "${missing[*]}"; else echo 'NUMERICAL_MODULES FOUND registry marks complete; review real top source before launch'; fi
if [[ -z "${LAYA_PART:-}" ]]; then echo 'PART MISSING LAYA_PART'; else echo "PART PROVIDED $LAYA_PART"; fi
if [[ -z "${LAYA_PLATFORM:-}" || ! -f "${LAYA_PLATFORM:-/nonexistent}" || "${LAYA_PLATFORM:-}" != *.xpfm ]]; then echo 'PLATFORM MISSING valid LAYA_PLATFORM .xpfm'; else echo "PLATFORM FOUND $LAYA_PLATFORM"; fi
VPP="${VPP_BIN:-$(command -v v++ 2>/dev/null || true)}"
if [[ -z "$VPP" && -x /home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/v++ ]]; then VPP=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/v++; fi
if [[ -z "$VPP" ]]; then echo 'VPP MISSING v++'; else echo "VPP FOUND $VPP"; fi
if [[ "$MODE" == --check ]]; then echo 'HLS_CHECK_ONLY no synthesis attempted'; exit 0; fi
echo 'MISSING_PREREQUISITE full numerical forward source and/or frozen part/platform are absent; no xo/xclbin emitted' >&2
exit 2
