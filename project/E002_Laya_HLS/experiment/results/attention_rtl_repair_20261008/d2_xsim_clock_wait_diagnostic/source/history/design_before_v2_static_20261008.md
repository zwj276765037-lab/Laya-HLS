# D2 minimal repeated clock-wait diagnostic

Astra xhigh design, 2026-10-08. Identity `d2_xsim_clock_wait_v1`. Implementation and one bounded static build after consolidated source review are released; runtime requires its actual source/snapshot gate. This is a minimal language/event test, not a replacement AXI VIP or a production simulator fix. Preloaded-QKV CPU/CSim work has priority; heavy tools remain serial within this Laya workflow.

## Evidence and precise question

The [accepted allocation observation](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_d2_axi_allocation_observation_review.json) reproduced own RSS146652→1765660KiB over100000 idle clocks, with zero AXI events and28 unchanged transfer constructors. The actual copied [monitor](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/rtl/axivip/axi_monitor.sv:88) repeatedly waits on `@(posedge vif.clk)`, and [slave sequence latency loops](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/rtl/axivip/axi_slave_seq_lib.sv:99) use the same wait followed by `#0.1`. The [AXI interface](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/rtl/axivip/axi_if.sv:13) itself contains signal declarations and no clocking block. These are source facts and mechanism candidates; the current logs do not isolate one loop or prove a leak.

Ask whether a fixed set of repeated clock waits reproduces growth when changed only between a module task, a class task with static clock reference, a class task with virtual-interface clock reference, and that virtual-interface class task plus the original short delay. No AXI transfers, UVM agents, dynamic queues, data pages or numeric DUT are needed.

## One snapshot, four fixed modes

Create `tb/clock_wait_diag_top.sv` and one small class/package if needed. Copy the exact real `axi_if.sv` into rtl, seven instances with64/4/8/3/1 parameters and the same common approximately6.66ns clock/reset shape. All interface signals are initialized to deterministic idle values; they are not protocol drivers. Copy the already reviewed RSS/HWM DPI C/shared object byte-for-byte.

Allocate exactly32 helper class objects before reset release in **every** mode, including module mode. Each has a fixed worker ID and one of the seven virtual interfaces assigned once, round-robin; no new object occurs in a clock loop. Use a common fixed top-level `longint unsigned ticks[32]` array and fixed completion flags, not queues. A bounded32-way fork starts one forever worker per slot after reset release. The only per-cycle work is its wait, optional delay and increment of its own fixed counter. Select the mode once, outside each forever loop; no per-clock strings, logging, object construction or retained event history.

| Mode | Worker location and repeated body |
| --- | --- |
| M | Module task: wait on direct top clock posedge; increment common ticks[id] |
| S | Class task: wait on the explicit static `$root.clock_wait_diag_top.clk` posedge; increment the identical common ticks[id] |
| V | Class task: wait on `vif.clk` posedge; increment the identical common ticks[id] |
| D | Class task: wait on `vif.clk` posedge; `#0.1`; increment the identical common ticks[id] |

Use distinct static branches/tasks so each comparison's actual wait expression remains visible in source and generated compile identity. All32 objects, seven interfaces, clock/reset, counter storage, DPI and sampling are common. Thirty-two is a chosen small fixed probe size, not a claim about the number of real VIP waiters. No UVM library/component is necessary for this minimal test; this deliberate boundary must be reported.

Each fresh process uses the same compiled snapshot and seed1 and executes exactly20000 postreset clocks. Record memory-ready after all32 objects are allocated, reset release and clocks1/16/256/1024/5000/10000/15000/20000. Sample at a fixed0.2ns after the edge, after mode D's0.1ns increment and before the next edge. At every sampled postreset clock require all32 counters equal the actual clock count. At20000 require all counters20000, constructor count32, no missing worker and no error; record own RSS/HWM/wall time, flush and emit `CLOCK_WAIT_MODE_PASS mode=<M|S|V|D> clocks=20000 workers=32`, then stop without another edge. No waveform or per-cycle logging.

## Interpretation and limits

Compare baseline-normalized RSS over the same clock interval and verify identical work counts first. M versus S examines class-task execution with a static clock; S versus V isolates the virtual-interface event expression within the chosen class body; V versus D isolates addition of the short delayed continuation. Growth only in V/D supports a virtual-interface-event candidate; growth in S/V/D but not M supports a class/task candidate; extra D growth supports a delayed-continuation candidate. If all are bounded, the real VIP loops remain unisolated. If all grow, shared clock/observation/simulator scheduling remains a candidate. None alone proves the precise allocator leak, predicts a strict whole-DUT bound, or authorizes a timing/driver rewrite.

## Gates and budgets

First freeze source, actual direct/static/virtual wait expressions, copied interface/DPI hashes, fixed object/counter budget, four exact argv and source diff for one consolidated Astra pre-review. One static compile/elaboration is then bounded by16GiB owned RSS/300s/4CPU. Keep the installation and original VIP files unchanged; use the already supported no-debug, no-wave, single-thread compile policy. Do not guess new undocumented tool optimization switches.

After successful source/snapshot binding review, at most four fresh runs in order M→S→V→D may be released, each4GiB owned tree RSS/30s/20000clocks/4CPU/nice19/idleIO/host MemAvailable≥192GiB/0.2s guard samples. They are **not yet released**. Any guard/assertion/fatal/nonzero/incomplete endpoint stops the remaining modes; preserve first evidence and do not repeat or increase limits. No production changes, Attention runtime, D3 or Q8 work is released here.

## Implementation mapping awaiting source review

`rtl/axivip/axi_if.sv` is a byte-identical copy of the reviewed interface. `tb/phase_rss.c` and `tb/phase_rss.so` are byte-identical copies of the reviewed RSS/HWM DPI pair. `tb/clock_wait_worker_pkg.sv` holds the single 32-object class type and the three distinct class wait expressions. `tb/clock_wait_diag_top.sv` holds the direct module wait, seven deterministic-idle interface instances, fixed counters/completion flags, mode selection, reset/clock schedule, stage samples and endpoint assertions. `tb/build_static.sh` names the exact two SystemVerilog source files plus the interface and uses the existing no-debug, no-wave, single-thread elaboration policy. The source binding packet under `source/` records copy equality, input hashes and the planned four fresh runtime commands. These are source facts; no static build or runtime has executed yet.
