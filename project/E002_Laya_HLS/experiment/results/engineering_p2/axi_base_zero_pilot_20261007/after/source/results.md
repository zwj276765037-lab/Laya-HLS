# AXI base-zero pilot results: after the memory fix

**Pilot verdict: PASS for the repaired base-zero read-helper path.** Generated
RTL enters its read-request state independently of the numerical base, and
XSim exercised an internal read request at base `0x0` with address `0x0` and returned data
`0x53`. A second transaction at base `0x100` likewise used address
`0x100`. This is an isolated interface result, not full-kernel RTL or
numeric acceptance. The [old pilot](../../source/results.md) preserves the
base-zero rejection before the fix.

## Configuration and stages

The extracted production memory source was SHA-256
`00b4374c6418ea939a44b9c8e358305eba4e9e7b87fb90f54b26caf63873e861`;
the generated pilot source was
`1bd073cf61ccaac5b30898b8360f970eeef5f335ad43aef7549152e2028b982c`.
The [manifest](extraction_manifest.json) records hashes and line spans for
all five extracted functions. [Input hashes](../input_hashes.sha256) include
the wrapper, headers, config, and both testbenches.

Vitis `v++` 2025.2 (build 6295257), xcu55c-fsvh2892-2L-e, requested 150
MHz (6.667 ns), Vivado IP flow, and `syn.compile.pipeline_loops=0` were
used. The exact config is [`pilot.cfg`](pilot.cfg). The command was
`v++ --compile --mode hls --config results/engineering_p2/axi_base_zero_pilot_20261007/after/source/pilot.cfg --work_dir build/full-hls-axi-base-zero-pilot-after/work`.

| Stage | Result | Evidence and boundary |
| --- | --- | --- |
| Source extraction | PASS; five exact function bodies, thirteen ports | [Manifest](extraction_manifest.json), [input hashes](../input_hashes.sha256). |
| CPU test | PASS; `PILOT_CSIM_PASS ports=13 reads=13` | Exit 0, ordinary CPU pointers. This does not test physical base zero. |
| HLS synthesis | PASS; exit 0, thirteen independent `m_axi` ports | [Log](../csynth.log), [exit](../csynth.exit); port list at log lines 175–187. |
| Generated RTL review | PASS; no base-zero rejection; direct base-to-ARADDR path | Precise line evidence below; three key files preserved in [`rtl/`](../rtl). |
| XSim helper-interface read | PASS; two cases, base `0x0` and `0x100`, each one internal AR handshake and one data write | [TB](../tb/full_read_axi_tb.sv), [compile](../xvlog.log), [elaboration](../xelab.log), and [simulation](../xsim.log) logs. This tests only generated `full_read`. |
| Full-top RTL co-simulation | Not run in this pilot | Complete top and host AXI-lite transactions are outside this test. |
| Place and route / timing | Not run | HLS estimate is not routed timing. |
| Board | Not run | No hardware result. |

The isolated pilot's HLS report estimates 4.867 ns logic delay against the
6.667 ns target, 254 cycles latency, 10,112 FF, 12,509 LUT, and zero
BRAM/DSP/URAM. These are HLS estimates for this small pilot only; the full
kernel has a separate acceptance gate.

## Generated RTL path

The AXI-lite `embedding` base remains a 64-bit register at offsets
`0x10`/`0x14` ([control file:55](../rtl/axi_base_zero_pilot_control_r_s_axi.v#L55),
[185](../rtl/axi_base_zero_pilot_control_r_s_axi.v#L185)).
The top captures it and connects it to `full_read.m_embedding`
([top:2878](../rtl/axi_base_zero_pilot.v#L2878),
[4129](../rtl/axi_base_zero_pilot.v#L4129),
[2250](../rtl/axi_base_zero_pilot.v#L2250)).

In `full_read`, state 1 proceeds to state 2 whenever started, without a
selected-base equality check ([lines 1965–1978](../rtl/axi_base_zero_pilot_full_read.v#L1965)).
For BO 0, state 2 asserts embedding `ARVALID`
([lines 1677–1682](../rtl/axi_base_zero_pilot_full_read.v#L1677)).
The module registers `m_embedding` directly
([line 1419](../rtl/axi_base_zero_pilot_full_read.v#L1419)), and that register
drives embedding `ARADDR`
([line 2174](../rtl/axi_base_zero_pilot_full_read.v#L2174)).
The XSim TB supplies `ARREADY`, then `RVALID`/`RDATA=0x53`, and asserts
both request count and observed data at the helper boundary. This internal
interface has 8-bit data and a 64-bit ARLEN count. The external AXI4 port
after the top's `m_axi` adapter has a different width (32-bit data and
8-bit ARLEN) and was not simulated here.

The generated `full_read` instance has no error-status output after HLS
specializes the pilot's thirteen valid BO calls. That optimization does not
prove invalid-BO behavior in the full graph. The production source retains
`full_span` bounds validation; final CPU and full-kernel gates cover the
broader contract.
