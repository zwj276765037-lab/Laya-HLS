#!/usr/bin/env python3
import pathlib
import subprocess
import sys

root = pathlib.Path(sys.argv[1])
run = subprocess.run([str(root / "scripts/run_hls.sh")], text=True, capture_output=True)
expected = {
    "top", "common", "kernel_wrapper", "forward_controller", "memory_map",
    "hbm_loader_and_cache", "embedding_engine", "layernorm_engine",
    "activation_quantizer", "q8_linear_and_restore", "rope_and_mask",
    "attention_and_fp_engine", "vector_and_ffn", "decision_scorer_act",
    "result_status",
}
missing = next((line.removeprefix("NUMERICAL_MODULES MISSING ").split()
                for line in run.stdout.splitlines()
                if line.startswith("NUMERICAL_MODULES MISSING ")), [])
if (run.returncode == 0 or "MISSING_PREREQUISITE" not in run.stderr
        or len(missing) != 15 or set(missing) != expected):
    raise SystemExit("full-forward HLS gate failed to reject incomplete P0")
print("HLS_GATE_CONTRACT_PASS full_forward_rejected=1 missing_modules=15")
