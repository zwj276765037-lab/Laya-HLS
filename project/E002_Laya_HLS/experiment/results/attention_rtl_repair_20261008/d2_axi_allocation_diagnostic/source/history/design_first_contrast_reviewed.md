# D2 AXI allocation diagnostic — first bounded contrast

Status: Astra xhigh design frozen 2026-10-08. Sol max may implement and run static elaboration under the limits below. The two runtime invocations require independent review of the concrete source/binding packet. Production sources and all prior evidence stay unchanged.

## Authority and question

This follows [repair contract §7.9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/repair_contract.md#79-真实完整xsim环境的被动阶段观测), the [accepted phase observation](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_d2_phase_probe_v5_observation_review.json) and its [identity addendum](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_d2_phase_probe_v5_observation_addendum.json). The full environment initialized, kernel clocks and actual AXI traffic advanced, and RSS increased while sampled queues were at most one. It did not identify an allocator or prove a leak. This experiment asks whether the copied generated AXI VIP/memory stack exhibits growth with idle clocks, completed transactions, or neither when the Attention DUT is absent.

Actual copied source references, reviewed 2026-10-08:
- [Monitor handshake allocation and callbacks](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_xsim_phase_probe/rtl/verilog/axivip/axi_monitor.sv:88).
- [Slave sequences and clocked latency bookkeeping](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_xsim_phase_probe/rtl/verilog/axivip/axi_slave_seq_lib.sv:99).
- [AW driver handshake completion](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_xsim_phase_probe/rtl/verilog/axivip/axi_slave_awdrv.sv:28), [W driver](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_xsim_phase_probe/rtl/verilog/axivip/axi_slave_wdrv.sv:28), [AR driver](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_xsim_phase_probe/rtl/verilog/axivip/axi_slave_ardrv.sv:28).
- [Actual state queues and callbacks](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_xsim_phase_probe/rtl/verilog/axivip/axi_state.sv:145).
- [Backing array/read-write semantics](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_xsim_phase_probe/rtl/verilog/file_agent/mem_model.sv:20) and [actual page initialization](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_xsim_phase_probe/rtl/verilog/file_agent/mem_model.sv:160).

Copy these actual packages and transitive includes to this isolated rtl directory and hash originals/copies. Include source/design/results and actual tool argv in the packet.

## Concrete entry and common environment

Build tb/axi_allocation_diag_top.sv plus tb/axi_allocation_diag_test.sv. Use original axi_pkg, original generated slave agents/sequences/drivers/monitor/state and original mem_model#(8) backing arrays. Instantiate seven axi_env#(64,4,8,3,1) with the actual v3 slave latency/reset configuration, and seven 65536-byte memory pages initialized to a deterministic nonuniform pattern. Bind original read/write state callbacks to those pages; copy the generated callback routing without changing read/write semantics. Preserve original per-channel delays and responses. Use the original approximately 6.667 ns clock/reset shape. No Attention RTL or numeric IP is needed in this diagnostic; this exclusion is the controlled boundary, not a modified production implementation.

Same compiled snapshot and initialization serve two fresh processes selected by +DIAG_MODE=idle or traffic; fixed seed 1. Both run exactly 100000 reset-released clocks and finish at the same cycle. Memory format, number of ports, slave settings, observations and tool options are identical. Record baseline at memory ready and reset release. No wave/transaction recording, payload trace or retained transaction handles.

Idle: master VALID outputs remain zero and response READY outputs one for the full 100000 clocks. Require zero accepted AW/W/B/AR/R events and zero completed workload items.

Traffic: begin after 10000 clocks. On port qkv0 only, issue exactly 1024 ordered pairs of (one single-byte write, then one aligned 32-bit readback). Other six ports remain idle. Use ID0, AWLEN=0, AWSIZE=0, WLAST=1 and exactly one legal WSTRB bit matching AWADDR low bits. Let address = 4*(i%256)+(i%4); write byte = (0x5a XOR i XOR (i>>8))&255. Drive AW and W independently, retain VALID/payload until their actual READY handshake, and wait for successful B. Then ARADDR=address&~3, ARLEN=0, ARSIZE=2; wait for actual R/RLAST and require OKAY and all four returned bytes equal the independent software/SV expected memory. Never infer handshake from elapsed clocks. Update an independent 65536-byte expected image only for accepted writes. After all 1024 pairs, drive idle through clock100000. Require all work and queues drained by clock90000; otherwise fail at that boundary without extending the cap. Final complete byte comparison of backing memory to expected image must pass; untouched ports and all unaffected bytes remain initial pattern.

## Fixed observation and assertions

Reuse the accepted fixed-ring AXI handshake counters, actual per-ID queue summaries and own-process RSS/HWM DPI in both modes. Take samples at baseline, reset, clocks 1/16/256/1024/10000 and then each10000, and at traffic completion/drain/final. Report exact cycle, cumulative accepted transactions, queue lengths and active mode. Final samples must flush before finish so the paired endpoint is complete.

A single observer-only static uint64 counter in the copied axi_transfer constructor may count actual constructor calls (including direct new and clones). Do not pool/reuse/change objects or count destructor calls that SystemVerilog does not expose. Both modes must contain the identical increment. Report this as allocations requested, not live objects or bytes. Keep per-cycle observation storage constant; no object/payload history. Count original driver item_done calls if a fixed scalar hook is useful, with exact source diff and identical behavior otherwise.

Required outcomes: idle zero traffic; traffic exactly1024 AW/W/B and1024 AR/R/RLAST/WLAST, byte readback and full-memory checks pass, final queues empty, no protocol/ring/errors. Emit distinct DIAG_IDLE_PASS / DIAG_TRAFFIC_PASS after all checks. These markers prove harness checks only, never Attention numerical correctness. If a guard interrupts, retain partial data and classify it as incomplete.

## Budget and release sequence

1. Implement/source-check and prepare exact diff, common configuration, include closure, seed, assertion list, expected memory algorithm and observer budget. No production edits.
2. Static compile/elaboration: one build, 4 CPUs, nice19, idleIO, 16 GiB owned tree RSS, 300 s, host MemAvailable>=192 GiB, 0.2 s sampling. Fix a concrete compile/source error only after preserving its first result; no repeated unchanged builds.
3. Independent Astra source/snapshot gate before runtime. Then exactly two fresh invocations in order idle then traffic, each 100000 clocks / 4 GiB owned tree RSS / 90 s / 4 CPUs, with the same nice/IO/host-floor/sampling policy. Stop on fatal/assertion/guard; no automatic retry, budget increase, or further full Attention run.
4. Compare baseline-normalized RSS versus clock and constructor/accepted/completed counts, including post-drain idle. Idle growth supports a clock/event/VIP-side candidate; extra traffic-dependent growth supports a transaction-path candidate; a post-drain plateau is observed allocator/high-water behavior only. Neither contrast proves a particular allocation leak. If both remain bounded, the full DUT/event environment remains unisolated. Report all limits and do not extrapolate a finite full-run upper bound.

This experiment does not release D3/full-top HLS, an additional original Attention runtime, a simulator rewrite or joint-Q8 implementation.
