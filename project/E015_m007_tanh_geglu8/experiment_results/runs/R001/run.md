# R001 — E015

Recorded: 2026-10-21T05:44:36.613223+00:00

Execution state: running
Verdict: unassessed

- Exact command and working directory: Every actual AT receipt records argv and project cwd; all compute uses vector_and_ffn/tb/m007_tanh_guard.py and the common project heavy lock through all owned descendants.
- Host, tool and platform versions: host user, Vivado2025.2/XSim. Small leaf OOC xcu55c-fsvh2892-2L-e, effective3.333ns, uncertainty0.1ns and complete0.5ns IO delays. Synthesis+opt only.
- Code identity (commit/hash), external constraints and IP identity: per-AT sources.tar.gz + source_sha256 + archive hash. The validated E014 process lifetime helper is reused read-only with explicit SHA. No shared arithmetic/storage RTL is edited.
- Input/data identity and reproducibility inputs: frozen independent E008 native SSE vectors, and AT007 original local Encoder0 all128-row WO/residual/LN/Wi/G reference. Original context and hidden, actual GGUF WO/Wi payloads and full_reference.py are hash-checked. AT007 report binds all output products.
- Start/end times: actual E015 implementation launch07:09:33 UTC; all command start/lock wait/child start/end timestamps are recorded individually. Waiting for the lock is not measured child compute.
- Exit status and infrastructure errors: AT001 syntax FAIL retained; AT002 build, AT003 add3, AT004 mul4, AT005 div12, AT006 OOC tool flow, AT007 reference EXIT_ZERO. AT006 setup/hold timing remains FAIL despite tool exit zero.
- Independent oracle, expected values and acceptance criteria: E008 native separate binary32 operations with FE_TONEAREST and FTZ/DAZ off; final TANH independent host libm and original array GELU. No expected values derive from DUT output. Actual3/4/12-stage leaves/II1 checked separately from physical timing.
- Evidence paths and qualified scope: attempts/AT003–005/work/report.json leaf numeric/protocol; AT006/work/report.json and timing.rpt first add3 timing FAIL; AT007/work/report.json real local reference only. Initial published three summaries track this scope.
- Observations and limitations: add3 WNS−0.956ns/54 setup failures, WHS−0.027ns/51 hold failures. Equivalent repartition keeps3 cycles. Single TANH,8lane/G, shared SFU/FFN and P&R/board remain unverified. E015 budgets900/1800/3000/1800s are independent; no E014 transfer.

A run record alone does not establish PASS or a method verdict.
