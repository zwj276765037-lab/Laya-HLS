# D2 repeated clock-wait diagnostic results

**All four isolated wait modes completed once against the same XSim snapshot, but none reproduced sustained RSS growth over 20,000 clocks.** The real seven-port VIP observation remains unexplained. This minimal test does not establish a full-DUT memory bound.

The [v1 static build](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_xsim_clock_wait_diagnostic/runs/static_build_v1/failure_evidence.json) failed at `VRFC 10-1319` because XSim rejected `$root` from package scope. Astra released the exact module-scope v2 correction. The [v2 static evidence](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_xsim_clock_wait_diagnostic/v2/runs/static_build_v1/static_build_evidence.json) reports Vivado Simulator 2025.2 exit 0, zero ERROR/FATAL, snapshot `clock_wait_diag`, 4.29 s elapsed and peak owned RSS 194,940 KiB. The 18-file snapshot manifest binds xsimk SHA256 `5cb84b9bd80bcf25cbb397f625de7796b4d0edc349a079ee936a7b05d8dd257f`.

Astra's [runtime gate](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_d2_clock_wait_v2_snapshot_runtime_gate.json) released M→S→V→D, each fresh with seed 1, 32 workers, seven interfaces, exactly 20,000 postreset clocks, four CPUs, nice 19, idle I/O, 4 GiB owned RSS, 30 s wall time, a 192 GiB host memory floor and 0.2 s guard samples. Each mode passed ten exact counter samples, ten DPI RSS stages, the 32-constructor assertion and its mode-specific PASS marker; no fatal, guard trigger or policy mismatch occurred. The [four-mode evidence](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_xsim_clock_wait_diagnostic/v2/runs/four_mode_evidence.json), SHA256 `86f1694a8ed178a490608e760c480c9a5c09acd07995ad59c2ffbbeb4b8a2b3a`, binds all raw logs and 32 run files. Independent reviewer acceptance is pending.

| Mode | Actual wait | Own RSS at clock 1→20,000 (KiB) | RSS from memory-ready to endpoint | Guard peak owned RSS (KiB) | Wall time |
| --- | --- | ---: | ---: | ---: | ---: |
| M | Module direct `clk` | 76,484→76,484 | +108 KiB | 855,712 | 5.48 s |
| S | Class static `$root` clock | 76,372→76,372 | +120 KiB | 855,476 | 5.49 s |
| V | Class virtual-interface clock | 76,380→76,380 | +120 KiB | 855,516 | 5.49 s |
| D | Class virtual-interface clock plus `#0.1` | 76,372→76,372 | +120 KiB | 856,032 | 5.56 s |

The equal work counts and flat clock-1-to-endpoint RSS do not support repeated fixed clock waits alone as the source of the prior roughly 16.2 KiB/clock idle growth. The experiment omits UVM agents, transactions, queues and much of the actual VIP event environment, so those remain candidates; a retained allocation mechanism cannot be inferred or excluded here. No simulator or production RTL rewrite follows from this observation.

This root document is the current results entry. The pre-runtime exact bytes are preserved at `source/history/results_before_four_modes_20261008.md` (SHA256 `896a944b55aab5b26f08d142440deaa794dab42ac41a3e905cfdb3b93f0f90f7`). The v2 `source/results.md` remains the frozen source-review copy.
