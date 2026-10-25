# LN-05 frozen scoped handoff

E014/R001, A008, runtime `/root/m007_host_tail_engineering`.
Desired model/effort gpt-6.1-sol/xhigh; actual configuration remains unverified.

Pure engine:
`E002/experiment/vivado/module_design/layernorm_engine/rtl/laya_m007_layernorm32_v1.sv`,
SHA256 `2799427bb0fe36ddb45da21357868ff04a415fbda62c7dca11a4912d0266c263`.
Exact scalar file SHA256
`7fffa46ff225bc6a4739ac9360ce9931ccc143dfd54d1fd9d3cb9873faab84be`.
Actual compiled shell/source/snapshot identity is AT035; final independent audit
AT046 binds current files, archive bytes and actual immutable compiled artifacts.
See `release_evidence_v1.json` and AT046 receipt. Generated xsimSettings.ini and
xsim_script.tcl changes are recorded separately from immutable compiled files.

| Original complete128-row case | First output | Done available | Actual done retirement |
| --- | ---: | ---: | ---: |
| plain encoder00, AT042 |322|16612|16618|
| encoder27 + original final_norm_w, AT043 |330|16620|16626|

Cycles include command acceptance and real input/output handshakes. Retirement
includes the deliberately held done response; both meet16704. Each case checks
131072 final F32,261888 tree nodes, all delta/square/norm values, seven stats per
row and real bank payload. Gamma equals the original saved final_norm throughout.
Input row launch II is exactly128; every output row interval is≤128. Measured
pass1/2/3 maxima113/197/42 or50; tree tail80; div1024 and sqrt including scheduling
2/26, direct inverse32. Independent scalar availability is1/25 cycles.

AT033 proves four real occupied contexts, blocked fifth-row reuse,1865 held-output
cycles and finite input/FP/bank stalls, with actual add/mul peaks27/54 and exact
recovery. Its a0975679 source differs only in two idle gamma-admission gates;
AT046 checks the source delta and preserves this boundary. Active dataflow is
unchanged after fully loaded gamma. AT038 current-source gamma/identity/reset and
simultaneous loader/command arbitration pass. AT039–041 observe input Inf,
square overflow and level1 tree overflow, drain in3/9/9 cycles, then complete
normal four-row new-generation commands without reset. Held done blocks release.

The caller binds one sharedFP256, one sharedDIV8 and one LN-exp entity before
asserting cmd_valid. All use phase6/head0 and the same request/gen/epoch; connect
the engine's held op identity to service operation fields. Shared ADD is one
atomic group0 request/response; other groups are inactive. DIV uses lane0 only,
direct1/root. Return credits belong to the shared services and are not copied.
The real TB contains exactly one instance of each service; this does not claim
parent phase physical sharing.

Input/output are32 F32 with element0 in the low32 bits, ordered row then chunk.
Each opaque96-bit input tag returns unchanged. Production uses cmd_rows128;
smaller rows are diagnostic/pilot shapes. The command retains request64,
generation32, source epoch32 and gamma model64/key32. Real1024 output consumption
and all per-context arithmetic/read/write/scalar debts gate context reuse.
debt_clear additionally requires inactive command and consumed done response;
the caller then releases actual FP/DIV leases. Do not switch phase on done
availability alone.

The unique32KiB LN-exp mapping is bank=(ctx*2+raw_or_delta)*32+element%32,
address=element//32. Only actual write ack commits coverage. Payload is not reset
cleared. Gamma is one4096B coefficient copy,32 real load chunks with finite and
coverage checks, bound to model/key; gamma_begin wins a simultaneous command.
Gamma is immutable during active LN. Metadata/holding/tag and both scalar leaves
total44761 bits/5596 bytes rounded, below8192B, with no duplicate row payload.

Local numerical completion reports observed stage/level/row/node and drains real
accepted work. Stage codes are input0/tree1=1/mean2/delta3/square4/tree2=5/
variance6/eps7/root8/inverse9/norm10/gamma11. Original layernorm_many checks a
16-row tile's source finite domain before per-row arithmetic; this local abort
does not prove original tile/all-model first-error order. Parent LN→quant→matrix,
partial-output/A-fill cancellation and60 LN invocations remain joint work.

Two small scalar synthesis+opt OOCs use xcu55c-fsvh2892-2L-e, effective3.333ns,
0.1ns uncertainty and complete0.5ns IO delays. AT044 sqrt is347LUT/340FF,
WNS+0.344ns/TNS0; AT045 div1024 is195LUT/130FF,WNS+0.605ns/TNS0; both0DSP,
0latch/blackbox. Both WHS−0.027ns; sqrt THS−2.248ns/166 hold endpoints and div
THS−0.035ns/2 endpoints. Hold violations are retained. No placement/routing,
whole-engine synthesis, board timing or physical300MHz completion is claimed.

Final measured costs: reference1.720864s/static95.861117s/RTL134.939409s/
OOC297.863061s. AT018 actual wall time is UNKNOWN and separately reserves120s
static; total static budget debit215.861117s. It is not a measured120s run.
All original failures remain: reserved-word/build-entry and ledger parsers,
AT018 monitor early unlock, AT020 overlapping audit, AT022 harness lock-race
assertion, AT036 batch COST_STOP/unsupported XDC. The corrected subreaper/finally
guard is verified with real orphan, sampler/write exception and KeyboardInterrupt
cases AT026–029, then used for later work. No owned E014 process remains.

The authorized successor is TANH-G8-08 / E015, with a new independent budget and
write scope. E013, shared FP/DIV/storage, legacy LN, model/gold remain read-only.
