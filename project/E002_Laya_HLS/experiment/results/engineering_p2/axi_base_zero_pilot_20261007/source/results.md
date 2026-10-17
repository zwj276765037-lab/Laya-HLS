# AXI base-zero pilot results: original production source

This report freezes the **pre-fix** pilot. The extracted production memory source
had SHA-256 `2db4eb270540bc36c04cc00d449d48e7ddcb8c85d30ba99a816f0fa2697d4d5f`.
The current production file may differ after the approved fix; the exact old
functions, their individual hashes, and source line numbers are in
[`extraction_manifest.json`](extraction_manifest.json). The generated source
hash is `048cc319a8020cbac298c181a09591f75edfc6e2ac1650c06386809eca25d847`.

## Configuration and stages

Vitis `v++` 2025.2 (build 6295257), xcu55c-fsvh2892-2L-e, requested 150 MHz
(6.667 ns), Vivado IP flow, and `syn.compile.pipeline_loops=0` were used. The
exact config is [`pilot.cfg`](pilot.cfg). The synthesis command was
`v++ --compile --mode hls --config results/engineering_p2/axi_base_zero_pilot_20261007/source/pilot.cfg --work_dir build/full-hls-axi-base-zero-pilot/work`.

| Stage | Observed result | Evidence and limit |
| --- | --- | --- |
| Source extraction | PASS: five function bodies and thirteen ordered ports | `extraction_manifest.json`; `input_hashes.sha256`. |
| CPU test | PASS: `PILOT_CSIM_PASS ports=13 reads=13`, exit 0 | All pointers were ordinary nonzero CPU addresses; this does **not** test physical AXI base zero. |
| HLS synthesis | PASS: exit 0; thirteen AXI master ports emitted | [`csynth.log`](../csynth.log), [`csynth.exit`](../csynth.exit); 13 port names at log lines 176–188. |
| Base-zero RTL path | FAIL: base zero is treated as absent and no read request is sent | Specific signal path below. This is generated-RTL inspection, not a driven RTL simulation. |
| RTL simulation/co-simulation | Not run on this pre-fix pilot | No dynamic AXI transaction result. |
| Place and route / timing | Not run | HLS timing is an estimate, not routed timing. |
| Board | Not run | No hardware measurement. |

The HLS report estimates 4.867 ns logic delay against the 6.667 ns target,
137–254 cycles latency, 10,121 FF, 12,655 LUT, and zero BRAM/DSP/URAM for
this small pilot. Those figures are specific to the pilot, not the full
kernel, and are not place-and-route results. The report hash is
`36ac02183e04cade0baf0db2ec583acf1fc7ffe3954227dc5af5bf778cbea625`.

## Generated RTL evidence

The three relevant generated Verilog files are copied to [`../rtl`](../rtl)
to preserve the old behavior independently of the build directory; their
SHA-256 hashes and the log hash are in [`../evidence.json`](../evidence.json).

1. The `embedding` AXI-lite register is 64 bits, exposed through
   `embedding_r`, at control offsets `0x10`/`0x14`
   ([`control_r_s_axi.v:55`](../rtl/axi_base_zero_pilot_control_r_s_axi.v#L55),
   [`:185`](../rtl/axi_base_zero_pilot_control_r_s_axi.v#L185),
   [`:375`](../rtl/axi_base_zero_pilot_control_r_s_axi.v#L375)).
2. The top captures that register into `embedding_r_read_reg_687`, then
   connects it to `full_read.m_embedding`
   ([`top.v:2873`](../rtl/axi_base_zero_pilot.v#L2873),
   [`:4124`](../rtl/axi_base_zero_pilot.v#L4124),
   [`:2244`](../rtl/axi_base_zero_pilot.v#L2244)).
3. `full_read` selects the named 64-bit base for each BO; its default is
   `m_embedding` for BO 0 ([`full_read.v:1440`](../rtl/axi_base_zero_pilot_full_read.v#L1440)).
   It compares the selected base with zero
   ([`:2167`](../rtl/axi_base_zero_pilot_full_read.v#L2167)).
4. If that comparison is true at start, the FSM goes from state 1 directly
   to state 11, bypassing state 2
   ([`:2079`](../rtl/axi_base_zero_pilot_full_read.v#L2079)). The embedding
   `ARVALID` is asserted only in state 2
   ([`:1789`](../rtl/axi_base_zero_pilot_full_read.v#L1789)).
5. That same branch sets return bits 0 and 2
   ([`:1479`](../rtl/axi_base_zero_pilot_full_read.v#L1479)), i.e. status 5,
   which is `E_BUFFER` in [`laya_types.h`](../../../../include/laya_types.h).

Thus a legal AXI base of zero causes `E_BUFFER` before an AXI read request in
this pilot. Astra xhigh independently reviewed this path and approved a
synthesis-only `present`/`mutable_present` change: validate named BO and write
permission rather than numeric address, while retaining CPU null-pointer and
capacity checks. The separate [`after` pilot](../after/source/results.md)
tests the changed production source.

## Thirteen-port map

Each BO maps in order to a distinct `m_axi offset=slave` interface and a
64-bit AXI-lite base register. The register offsets below are the low and
high halves of that base, not AXI data addresses.

| BO | Port | Base offsets |
| ---: | --- | --- |
| 0 | embedding | `0x10`, `0x14` |
| 1 | io | `0x1c`, `0x20` |
| 2 | w_q0 | `0x28`, `0x2c` |
| 3 | w_q1 | `0x34`, `0x38` |
| 4 | w_scale | `0x40`, `0x44` |
| 5 | aux | `0x4c`, `0x50` |
| 6 | state0 | `0x58`, `0x5c` |
| 7 | state1 | `0x64`, `0x68` |
| 8 | qkv0 | `0x70`, `0x74` |
| 9 | qkv1 | `0x7c`, `0x80` |
| 10 | ff0 | `0x88`, `0x8c` |
| 11 | ff1 | `0x94`, `0x98` |
| 12 | att_out | `0xa0`, `0xa4` |
