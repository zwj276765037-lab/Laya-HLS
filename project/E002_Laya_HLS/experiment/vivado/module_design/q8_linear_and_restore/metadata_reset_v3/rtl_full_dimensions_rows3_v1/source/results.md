# Three-row full-dimension Scorer evidence and budgets

State on 2026-10-09: **source-only, awaiting independent review**. The [static contract](static_contract.json) was regenerated read-only into a temporary path and matched byte-for-byte (SHA-256 `7270c08d4a2c360b708ed1fe08bf164099f8be94ae382d3f1f9023247d1cee4c`). It verifies the original checkpoint slices and BO spans, 341 mapped pages, shape, offsets and work arithmetic. No three-row fixture, CPU output, compiled RTL, XSim command, synthesis, implementation or board measurement exists.

| Quantity | Source calculation or current status |
| --- | --- |
| Legal shape | B2/S128, batch 1, rows 13–15, K=N=1024, G=32, T=128; local trace row 2, column 8. |
| Per-RUN quantization | 3 × 32 = 96 groups; 3 × 1024 = 3,072 inputs. |
| Per-RUN compute | 3 × 1024 × 1024 = 3,145,728 valid integer MACs; one TM4 tile × 32 × 128 = 4,096 issue/retire groups. |
| Per-RUN output | 3 × 1024 × 4 = 12,288 useful bytes; 16-page backing capacity is 65,536 bytes. |
| Trace-on observed | 1,024-byte header + 3,072 A8 + 192 scales + 1,024 group trace = 5,312 useful bytes across fixed offsets; trace-off is 1,024 bytes. |
| Static pages | 341 × 4,096 = 1,396,736 bytes of mapped backing across nine AXI ports. This is testbench memory, not FPGA utilization. |
| CPU leaf | Source prepared, compilation and numerical run not executed. |
| RTL static elaboration and XSim | Source prepared, not executed. No three-row cycles, sustained issue rate or pass marker claimed. |
| Synthesis, route, board | Not executed; no resources, Fmax, shell fit or wall-time extrapolation claimed. |

The accepted one-row Scorer cycles are historical context in [its results](../../rtl_full_dimensions_v1/source/results.md). They cannot be multiplied by three as a three-row measurement. The source-only package and its checks are the next review gate. Later execution must keep one Laya heavy tool at a time, bind fresh inputs and logs, and stop on a numerical, traffic, guard or tool failure.
