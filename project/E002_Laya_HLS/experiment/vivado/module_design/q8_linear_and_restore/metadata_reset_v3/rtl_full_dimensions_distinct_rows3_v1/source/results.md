# Three distinct valid Scorer rows: source and verification status

Status on 2026-10-09: source preparation only. The frozen B2/S128 request selects batch 1 rows 0–2 at marker indices 147, 163 and 174; all three marker-mask and corresponding attention-mask bytes are 1. The selected input and frozen output rows each have three different SHA-256 identities. The request, checkpoint full files and selected 12,288-byte intervals are bound by the source-preparation gate and the read-only static contract. No fixture, independent numerical result, CPU executable, RTL build, XSim run or new synthesis result exists for this case.

| Quantity | Source calculation or current status |
| --- | --- |
| Shape | B2/S128, batch 1 rows 0–2, K=N=1024, G=32, T=128; trace local row 2, column 8. |
| Quantization per RUN | 96 groups and 3,072 activation elements. |
| Compute per RUN | One partial TM4 tile: three active lanes and one inactive tail lane; 4,096 issue/retire groups and 3,145,728 valid integer MACs. |
| Output per RUN | 3,072 F32 words, 12,288 useful bytes; the fourth local row and all other mapped neighbors must retain sentinel bytes. |
| Trace | 5,312 useful observed bytes when enabled, including its header; 1,024 header bytes when disabled. |
| Backing pages | 341 sparse 4-KiB physical pages on nine AXI ports. This is testbench memory, not an FPGA resource measurement. |
| CPU leaf and RTL static/runtime | Sources prepared for separate review and execution gates; none run. |
| Synthesis, implementation, timing, board | Not executed for this successor. |

The existing rows 13–15 padding case and accepted one-row Scorer evidence remain separate frozen records. Later materialization must calculate full-N output independently with the original R0 reference and compare all 12,288 bytes with the frozen Scorer checkpoint before any CPU or RTL execution gate. Passing the 4,096-event passive observer alone cannot establish correct data for all three distinct rows.
