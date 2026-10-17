# Ws DCP connectivity results

Status: **source preparation only**. The new extractor has not opened the DCP, generated a graph, or established capacity/address acceptance. No RTL, simulation, implementation, routed timing or board result is claimed here.

Source revision v1 is archived as exact preimages. Revision v2 incorporates independent review findings on hierarchical aliases and driver classification; only static checks and a temporary synthetic structural-auditor exercise are allowed in this phase. The synthetic exercise accepted all 536 required logical boundary pins and rejected a deliberately missing address bit; it is not DUT evidence.

The prior sealed DCP-only report recovery produced complete first-pass Ws inventory and OOC timing diagnostics, then timed out during the all-design primitive scan at 1,800.44 s. Its actual evidence is `../runs/top_dcp_report_recovery_v1_control/recovery_actual_result_evidence.json` (SHA256 `72e2c049186233e84a374c1e645bc0af21d6bcf2be56d00bf27b8fed5d67c843`). The new extractor removes that all-design per-cell scan and repeated peer expansion. The prior output remains untouched.

Target proof remains 8 × 20,992 × 16 effective bits, including every address 16,384–20,991. Primitive count, nominal block capacity and logical bit-14 presence are insufficient. OOC timing diagnostics are not routed Fmax, 150 MHz or board evidence. The default hierarchy utilization threshold of 50 is avoided only in the future auxiliary report, not asserted as a result now.
