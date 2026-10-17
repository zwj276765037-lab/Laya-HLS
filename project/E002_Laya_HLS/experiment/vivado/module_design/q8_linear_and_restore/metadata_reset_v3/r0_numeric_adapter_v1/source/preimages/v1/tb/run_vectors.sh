#!/usr/bin/env bash
# Source only. Running the independent R0 reference requires a separate gate.
set -euo pipefail
export LC_ALL=C PYTHONDONTWRITEBYTECODE=1
if [[ $# -ne 1 || -e "$1" ]]; then
  echo 'usage: run_vectors.sh FRESH_OUTPUT_DIRECTORY' >&2
  exit 2
fi
root="$(cd "$(dirname "$0")/.." && pwd)"
out="$(realpath -m "$1")"
timeout -k 5 120 /usr/bin/python3 "$root/tb/generate_vectors.py" "$out"
/usr/bin/python3 "$root/tb/verify_generated_vectors.py" "$out"
