# E015/R002 TANH-IDLE-CE-26 protocol

Authority: SM011 D-M007-TANH-IDLE-CE-26 and
`source/m007_residual_encoder30_20261023.md` §13 / JSON `tanh_idle_ce`.
A008 owns only new TANH core_v2/tanh8_v2, necessary TB/runner/source additions
and this R002 evidence. Frozen v1, G, shared resources, joint and parent remain
read-only. No catalog work and no old budget transfer.

The v2 core adds `core_ce` input and combinational `token_empty` output from
all152 valid bits. One CE controls2447 original core sequential blocks and42
leaf aclken inputs, with original reset priority and no new initialization of
unreset data. Wrapper public ports remain unchanged. Its only new parameter
is `FORCE_CORE_CE=0`, used as1 in one verification control instance; no new FF.
Lease/credit/tag/results/handshake/fault logic and actual clock are not gated.
CE is reset OR lease_active OR lease_fire OR req_fire OR pending!=0 OR
inflight!=0 OR any full token pipe nonempty OR protocol_fault. Active lease
always runs, including bubbles, held responses and release waiting.

Build archives exact selected sources, verifies frozen v1/leaf schedule SHA,
checks the reversible mathematical transform and all sequential/leaf CE/reset
coverage, then compiles v1, v2 forcedCE1 and v2 automaticCE in one runtime.
No production joint or second physical production TANH array is created.

Original independent inputs are R001 AT007 `tanh_vectors.hex` and AT018
`nodes.hex`, with immutable reports/SHAs; schedule is AT052. No new reference
or gold. A bounded4096-scalar main sample selects all384 original corners then
3712 real values. Other original phases cover256 full credits, held return and
external-release debt,17 actual in-flight vectors reset,64 post-reset vectors,
six nonfinite lanes plus two masked lanes. Added idle/reset/no-reset-newgen
phases check64 more scalars. Expected total real checked consumption is6726;
invalid data is not compared across versions. All42 original nodes remain
checked on each active reference lane in the original checker.

Compare every public control/handshake event and valid response data/status/
tag/mask across all three versions. Measure core commit152 real cycles
separately from wrapper first actual consumption153 cycles. Confirm continuous
II1, true idle CE0 under arbitrary input toggles, complete token empty view,
first/middle/last tokens keep CE1, pending with empty pipe keeps CE1, active
and frozen reset, immediate re-lease, and no-reset newgeneration recovery.
Fault/status records use original public rejected/nonfinite stimuli; internal
alignment/credit corruption is not forced and remains explicitly NOT_RUN if
unreachable by legal public requests.

Independent reference0/static600/RTL900/OOC0 seconds. Static/unknown RTL single
cap120s; RSS24/8GiB, CPU0–3/nice19/idle I/O, MemAvailable>192GiB and project
`.research-agent/m007_heavy.lock` cover all actual owned descendants. Preserve
at least120s RTL recovery/archive reserve and all failures. Immutable guard
records own SHA at startup/lock, verified owned PID/start_ticks policy samples,
raw logs, source/input/build identity, semantic checked-consume JSONL, exit,
RSS/available memory and complete owned cleanup. Real checked consumption
renews120s semantic stall; no synthetic progress. A010/A007 ready windows are
coordinated before launch, never queued blindly behind another heavy tool.

Functional equivalence does not prove simulation speedup. A007 alone later
selects one TANH version in the real joint and measures same-input/cycle/machine
v1/v2 computation and fixed costs under its own original cost gate. No OOC,
P&R, installation, full unchanged mathematical suite or board work here.
