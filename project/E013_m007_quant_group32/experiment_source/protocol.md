# E013 / R001 QUANT-03 protocol

Authority: M007 contract and SM010 QUANT-03, actual A001 followup after E009
delivery. Owner A008; actual model/effort remain unverified, desiredGPT-6.1-Sol/xhigh.
No E009 budget transfers. Common project heavy lock, CPU0–3/nice19/idle,
MemAvailable>192GiB. Reference900s/RSS16GiB, static1800s/RSS24GiB,
RTL2400s/RSS8GiB, local OOC600s/RSS24GiB. Initial guard caps every child120s;
future longer runs require same-version cost evidence within the contract maxima.
All attempts preserve complete source/archive, input hashes, command, policy,
stdout/stderr, actual resources, exit and self-check marker. No installation,
whole-array long OOC, P&R, board or full-model new gold.

Only new activation_quantizer/laya_m007_* and m007_* sources are writable.
Legacy quant16/Host/math gold are read-only. Shared div/mul sources are owned
by A007; A cache/W/matrix by A010. No copied divide array or fake TB division.

Frozen arithmetic: tests/full_reference.py SHA
fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784.
Actual128x1024 input is original B1_from_b0_S128/embedding_norm.f32.bin,
524288B/SHA5d88293829ae60ee880f931cb863fcccfa82aa41dd8ed46f791ec2e484213056.
Original first4 fixture source/Q/half identities supplied by A001 are hash-pinned
in m007_quant_reference.py and compared bytewise to the actual input prefix and
new independent quantize output. For all4096 groups, original quantize_many and
quantize_rows16-row chunks must agree. K2624/4096 use seeded independent diagnostic
128-row tensors; they are not copied model trajectories. Native GGML Q8_0 scratch
is not hardware Q8-F gold. Reference never imports the new RTL/math functions.

Test sequence: independent actual/diagnostic/edge/format fixtures; local amax and
format RTL; real shared-div group pipeline; no-stall full128 rows eachK; bounded
input/output stalls and hold, saturation128/block129, wrong identity/coordinates,
release/debt barriers and active common reset/new-generation recovery. Numerical
errors accept/reserve and retire explicit errors; protocol rejects reserve zero.
Outputs include Q low256/F16 high16, request/gen/source epoch,row/group,opaque tag,
local status/stage/source element. No A cache publication is fabricated.

Strict32-value finite domain, max(abs), fullF32 d=amax/127, inverse=1/d except
zero, exact F32 product then ties-away q and IEEE F16 RNE. No clamp/FTZ/FMA or
reusing saved-half inverse. Scalar-stage errors identify the group scalar element0;
input/product/round stages retain their first failing source element. Parent
global error ordering/Check and failure-cancel A slot remain later integration.

Performance counts from first input handshake through last real output handshake,
including all fixed stage/sync/finite queues. First<=128, every unstalled group
accepted/retiredII1 and full128 rows<=4*K+128. Memory count separates raw<=16384B,
packed<=4352B, metadata<=8192B and total group state<=32768B, including all physical
arithmetic/return holdings once; no whole tensor buffer. Functional simulation,
capacity OOC, timing/300MHz and board results remain separate judgments.
