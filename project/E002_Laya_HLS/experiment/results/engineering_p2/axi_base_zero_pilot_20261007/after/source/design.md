# AXI base-zero semantics pilot after the approved memory fix

This is a controlled rerun of the [original 13-port pilot](../../source/design.md).
It tests whether the synthesis-only `present` rule lets an AXI master base of
zero reach a real read transaction. The original pilot, its source, generated
RTL, and failure report remain frozen in the parent directory.

## Sources and authority

- [Production memory source](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/hls/common/laya_full_memory.cpp), functions `bad_bo`, `present`, `capacity`, `full_span`, and `full_read`; checked 2026-10-07 at SHA-256 `00b4374c6418ea939a44b9c8e358305eba4e9e7b87fb90f54b26caf63873e861`. These exact function bodies were extracted; [manifest](extraction_manifest.json) gives per-function hashes and line numbers.
- [Production wrapper](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/hls/platform/full_kernel_wrapper.cpp), thirteen `m_axi offset=slave` ports; checked 2026-10-07. The pilot uses the same named port order.
- [P2 task](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/hardware_agent/task.md), §12.5.1, defines the full request graph. This pilot covers only one-byte reads in the memory access path.
- Astra xhigh approved the production rule in this conversation: synthesis validates the named readable/writable BO rather than treating base zero as absent; CPU null-pointer checks, bounds checks, and host responsibility for supplying all thirteen BOs remain.

## Experiment and checks

The top has thirteen independent AXI master interfaces. Each `FullMemory`
capacity is 4096 bytes, and each BO receives one `full_read` at offset zero.
It writes a distinct four-byte diagnostic record to IO starting at 2048.
The CPU test checks thirteen status/data records but cannot represent the
hardware base-zero case.

The generated `full_read` helper RTL is then tested in XSim. Its BO 0 input
is held at `embedding`, with internal memory-request ready/valid/data driven by the independent
[SystemVerilog TB](../tb/full_read_axi_tb.sv). Two cases set the 64-bit
`m_embedding` base to `0x0` and `0x100`. Each must issue exactly one read
address handshake with `ARADDR == base + 0`, consume `0x53`, write that byte
to the destination, and finish within 40 cycles. The `0x100` case confirms
that the address path remains base-relative. This helper's request port has
an 8-bit data path and a 64-bit ARLEN count; the outer `m_axi` adapter and
its external AXI4 port are not instantiated in this TB. Consequently, the
test does not cover the complete top, the external AXI4 protocol, or host
control-register programming.

## Code and verification mapping

- `source/extract_pilot.py`: source-identity guard and exact function extraction.
- `source/pilot.cpp`: extracted functions and thirteen-port HLS top.
- `source/pilot.cfg`: Vitis 2025.2/xcu55c/150 MHz configuration.
- `tb/pilot_tb.cpp`: CPU sanity test.
- `tb/full_read_axi_tb.sv`: two driven AXI read transactions.
- `rtl/`: preserved generated RTL files for the reviewed signal path.
- `source/results.md`, `evidence.json`: stage results, RTL path, and hashes.
