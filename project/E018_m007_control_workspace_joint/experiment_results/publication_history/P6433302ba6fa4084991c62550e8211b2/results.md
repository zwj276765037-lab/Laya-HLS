# E018 R002 results

Core producer cancellation and complete normal G are supported. Seven actual cancellation cases pass, covering wrong/inactive/duplicate identities, partial halves/blocks, real bank/FP/SFU/output debt, held output/bank valid17, observed peer8/numeric6, DONE held17, actual discard and no-reset newgen12288 original outputs. Additional tests count same-edge real fill/ACK, read/bank-return/FP/SFU events and enforce exact successor limits. A real-peer terminal candidate and cancel on the same edge yield exactly one cancelled DONE and complete discard/recovery.

Current production full normal G checks335872 outputs/3358720 nodes and retains every R001 metric: first185, full42171, maxblock697, read/output gaps1,20992 writes/ACKs,41984 reads and82 releases. Source accounting confirms exactly3 new FF, no identity copy,4036.375B/ceil4037B. All34 R001 receipt identities and math/layout/numeric sources remain unchanged.

Full successful-normal-terminal cancellation is OPEN: AT020 reaches335872/3358720 numerical checks then FAIL at the pre-fix normal FINAL_REAL_DEBT assertion, which did not allow cancellation needs_discard. Its raw debt vector is not printed, and qualified DONE/discard lifecycle is not validated by that run. The one-expression mode2 correction compiles; corrected normal held3 passes. Full replay after correction is NOT_RUN_COST_GATE with mandatory120s RTL reserve. The real-peer terminal short test is separate evidence, not a substitute for this full lifecycle.

AT025 audits24 prior receipts/archives. Final25 receipts retain23 EXIT_ZERO/2 FAIL (AT001 TB declaration; AT020 qualified assertion), all cleanup empty. Guarded costs reference0/static134.9347572419210356/RTL424.830515450041275/OOC0s, caps0/300/600/0; RTL175.169484549958725s remains.

[Final handoff](runs/R002/final_delivery.md), [machine/source packet](runs/R002/final_delivery.json), [audit](runs/R002/attempts/AT025_final_release_audit/work/report.json), [full normal](runs/R002/attempts/AT018_full_original_normal/work/report.json), [real-peer terminal](runs/R002/attempts/AT023_real_terminal_priority/work/report.json), [cost exit](runs/R002/cost_exit.md), [budget](runs/R002/final_budget.json). No complete FFN/Encoder/30layer, physical fit/DSP896/300MHz/P&R/board, or missing-real-return recovery claim.


---
Published: 2026-10-22T17:04:27.120709+00:00
Publication: P2087e843820f4c8c8269ebd3d97262e5
