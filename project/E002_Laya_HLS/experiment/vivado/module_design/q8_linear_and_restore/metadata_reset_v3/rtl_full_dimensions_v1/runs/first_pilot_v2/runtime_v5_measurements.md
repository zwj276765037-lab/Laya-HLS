# Q8 full Scorer first-pilot RTL measurements

State on 2026-10-09: **three-command self-check passed; Astra independent acceptance pending**. This result is an additive report outside the immutable V6 source packet. The packet-bound `source/results.md` remains unchanged. The exact run, guards, post-binding, raw dumps, logs and offline checker are indexed in [the final self-check evidence](runtime_v5_final_evidence.json); the measured cycles come from [the full XSim log](runtime/xsim.log), and the offline check is in [the audit report](log_audit_v5.json).

The Scorer covers one Q8 module row at K=1024, N=1024: one LOAD and two RUN commands (trace on, then trace off), including 1,048,576 **logical integer MACs per RUN**. It is not a full Laya inference.

| Command | `ap_accept` → `ap_done` clocks | Conditional time at exactly 150 MHz | Issued / retired `(tile, group)` operations | Maximum observed issue gap |
| --- | ---: | ---: | ---: | ---: |
| LOAD | 1,496,042 | 9.973613 ms | 0 / 0 | 0 |
| RUN, trace on | 1,815,172 | 12.101147 ms | 4,096 / 4,096 | 478 clocks |
| RUN, trace off | 1,811,360 | 12.075733 ms | 4,096 / 4,096 | 437 clocks |

The time conversion is `measured RTL clocks ÷ 150,000 clocks/ms`. It is conditional on actually meeting a 150 MHz clock; no OOC/routed timing or board frequency was measured. The trace-off RUN's 1,048,576 logical MACs over 12.075733 ms would be 86.833 million logical MAC/s at that hypothetical clock. It is a one-row Q8 module figure, not a full-kernel or whole-model throughput result. The simulation testbench's total was 5,122,906 clocks across all three commands, including command gaps; it is not one inference latency.

The trace-on RUN had 4,225 PS reads, 4,096 PS writes and 4,096 dependent uses; the trace-off RUN had the same counts. Their observed issue spans were 1,766,588 and 1,765,132 clocks. The earlier 471-clock interval was a static source estimate for a selected no-wait core path, not a measured issue gap; the actual maxima above include the tested command path. The complete per-command observer phase, AXI, adapter, issue/retire and FP rows remain in the original log. In particular, raw `sub_done` counts include a sample where child `ap_done` was already high at the beginning of a command window; those counts cannot directly be read as completed subcalls.

The single finite XSim invocation exited 0 after 1,051.98 seconds under its 4 GiB/6,000-second guard, with 859,052 KiB peak owned RSS and no guard trigger. Its post-binding check matched 712 source files and the immutable compiled snapshot while archiving four allowed runtime-created snapshot files. One separately guarded 4 GiB/120-second `check_pilot.py` invocation returned `PASS` for all three commands and nine original observed/out0/out1 dumps. This self-check does not establish OOC resource use, Fmax, routed timing, U55C platform fit, board operation, or the whole Laya 50 ms target. Independent Astra review is still pending.
