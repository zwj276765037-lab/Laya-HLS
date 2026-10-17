# 13-port AXI base-zero semantics pilot

This isolated HLS experiment asks whether a legal AXI master base address of
zero is rejected by the current `present(pointer != nullptr)` check after
`m_axi offset=slave` lowering. It does not validate the full graph, numeric
results, or final implementation timing.

## Sources and authority

- [Current full-memory implementation](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/hls/common/laya_full_memory.cpp), functions `bad_bo`, `present`, `capacity`, `full_span`, and `full_read`; checked 2026-10-07. The pilot preserves these function bodies byte-for-byte in one standalone translation unit. This source defines the behavior under test, not a desired base-zero rule.
- [Current 13-port wrapper](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/hls/platform/full_kernel_wrapper.cpp), top signature and `m_axi offset=slave` pragmas; checked 2026-10-07.
- [Current P2 task](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/hardware_agent/task.md), §12.5.1, defines the full request graph; this pilot does not execute it.
- [Explicit-memory source review](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/p2_environment_20261007/explicit_memory_refactor_source_review.json), `pending`, explicitly leaves AXI base-zero semantics for actual HLS inspection.
- Astra xhigh pilot assignment in this conversation specifies 13 ports, exact source-function extraction, 4096-byte local capacities, real `full_read` calls, xcu55c and 150 MHz.

## Interface and experiment

`axi_base_zero_pilot` has exactly thirteen byte-pointer arguments, ordered
`embedding, io, w_q0, w_q1, w_scale, aux, state0, state1, qkv0, qkv1, ff0,
ff1, att_out`, each on its own `m_axi offset=slave` bundle. The local
`FullMemory` assigns all thirteen named pointers and sets each byte capacity
to 4096. For every `Bo`, the top calls the extracted
`full_read(memory, bo, 0, &value, 1)`. It writes each status and returned byte
to a distinct four-byte record in `io[2048 + 4*i ... 2051 + 4*i]` after all
reads, so the IO read at offset zero is observed before diagnostics change it.

The decision requires generated RTL/IR showing the path from an AXI-lite base
register value of zero through the `present` predicate to the status and
read-request controls. A passing C test alone cannot decide this hardware
question. The pilot source, extraction hashes, command, log, and generated RTL
remain in this isolated directory/build; no production DUT source is changed.

## Code and verification mapping

- `source/pilot.cpp`: extracted functions plus the thirteen-port pilot top.
- `tb/pilot_tb.cpp`: CPU/C simulation sanity check for thirteen reads and
  nonoverlapping diagnostics. It is not base-zero hardware evidence.
- `rtl/`: generated RTL stays under the separate build directory; this
  directory records the reviewed RTL paths after synthesis.
- `source/results.md`: tool settings, actual stage status, and evidence.
