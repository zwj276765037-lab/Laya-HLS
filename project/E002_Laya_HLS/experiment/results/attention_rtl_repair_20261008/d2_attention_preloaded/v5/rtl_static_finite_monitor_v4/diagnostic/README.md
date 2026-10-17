# No-DUT record-boundary probe (source only)

This is a separate 1 ns/1 ps, seven-port, synthetic connection probe. It uses the same `att_r_boundary_diagnostic.svh` collection source as the full v4 testbench. It has no generated or production DUT, AXI memory, fixture, oracle, host numerical call, random stimulus, or open-ended wait. The X injection exists only here.

## Exact connection equivalence

| Boundary | Frozen v3 declaration or connection | Probe equivalent |
| --- | --- | --- |
| Owner output | `tb/att_axi_monitor.sv:42-47` declares `r_count` as `output logic [31:0]` and `accepted_r_record` as `output logic [118:0]`. `:109-116` resets both to zero; `:223-226` writes a whole record and increments the count with blocking assignments. | `record_boundary_probe.sv:3-29` declares those exact output types, resets both, and writes one deterministic whole record/count pair in a positive-edge owner block. This owner is synthetic; it models no AXI acceptance. |
| Named owner-to-wrapper connection | `tb/att_axi_port.sv:86` declares the two internal 119-bit wrapper records; `:203-208` and `:224-229` connect monitor records/counts by name. | `record_boundary_probe.sv:39-49` uses the same internal record names and `.accepted_r_record(...)`/`.r_count(...)` connections on two named `dut_mon`/`ram_mon` instances. |
| Wrapper output | `tb/att_axi_port.sv:56-62` declares the direct `ram_r_count` output and 119-bit `ram_accepted_r_record` output; `:90` continuously assigns the RAM monitor record. | `record_boundary_probe.sv:35-43` uses matching output directions, widths and `assign ram_accepted_r_record = ram_monitor_accepted_r_record;`. RAM count is the direct named owner output. |
| Top array and seven names | `tb/att_finite_base_h15_r63_top.sv:730,738` declares `logic [31:0] ram_r_count [0:6]` and `logic [118:0] ram_accepted_r_record [0:6]`; `:742-1292` binds named `u_port_descriptor`, `io`, `aux`, `qkv0`, `qkv1`, `att_out`, `observed` to literal indices 0–6. | `record_boundary_probe.sv:56-89` repeats those exact unpacked array directions/ranges and the same named instances/literal element connections. No packed-array substitution is made. |
| Observation | `tb/att_finite_control.svh:534-542` uses the variable `p` reset predicate at a settled negative edge after a reset positive edge. | The probe uses the same literal-index diagnostic include and captures the original variable-index `$isunknown({ram_accepted_r_record[p],ram_r_count[p]})` plus the unchanged composite predicate; it observes each phase at a negative edge following the positive-edge owner update. |

The real monitor's address/beat/ID/RLAST acceptance checks and the generated DUT are intentionally absent. The probe tests only the record/count connection and expression boundary, not numerical correctness.

## Finite schedule and expected values

Clock starts low and toggles every 3.333 ns, matching the v3 top. Nonblocking stimulus updates at each negative edge apply before the next positive edge. `p` is the literal top port index 0–6; `s=0` is `dut_mon` and `s=1` is `ram_mon`.

| Negative edge | Phase | Expected owner, wrapper and top values before stimulus update |
| --- | --- | --- |
| 1 (6.666 ns) | `reset_initial` | All records `119'd0`, all counts `32'd0`; top and wrapper seen-reset-posedge flags are 1. Original variable/literal reset predicates should both be 0. |
| 2 (13.332 ns) | `distinct_known` | Each owner record is `{valid=1, ordinal=p+1+16s, address=0x23400000+4096p+256s, beat=p+2, len=p+4, size=p%3, ARID=s, RID=s, last=1}`; its count equals its ordinal. The wrapper RAM output and literal/variable top element equal the `s=1` pair. All seven RAM records/counts differ. Unknown detectors should be 0; original nonzero reset predicates are 1. |
| 3 (19.998 ns) | `reset_again` | All records and counts are zero again; seen-reset-posedge flags are 1. The original reset predicates should be 0. |
| 4 (26.664 ns) | `injected_x_port4_ram` | Known phase values return, except bit 40 of port4 `ram_mon` record is X and propagates through wrapper and top. Record reduction-X, local packed snapshot `$isunknown`, and literal-index `$isunknown` should report 1; the original variable-index result is printed for diagnosis. This expected X is not itself a failure. |
| 5 (33.330 ns) | Assertion/finish | After **all** phase data and expression variants have printed, compare the four captured phases. A mismatch yields `$fatal(1)` and nonzero exit; otherwise `ATT_PROBE_PASS` and `$finish`. |

An independent watchdog fatals on negative edge 8 if the schedule does not finish. The collection emits 4 × (7 × (one header + seven raw pairs + one expression line) + one completion + one phase) = 260 lines. At most 28 per-port and four reset-flag failures plus one final fatal are added, so testbench output is bounded by 293 lines. Each raw pair includes hex and binary record/count with port, time, clock and reset. The original variable-index expression and the literal-index, reduction-X, per-field and packed-snapshot variants are printed before assertions.

## Dormant tool recipe

The following commands are **prepared only**. The source-preparation release forbids executing any compiler, elaborator, simulator or probe. A separate independent execution gate is required. Use a fresh empty build directory when that gate exists.

```bash
XBIN=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
TB=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_attention_preloaded/v5/rtl_static_finite_monitor_v4/tb
DIAG=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_attention_preloaded/v5/rtl_static_finite_monitor_v4/diagnostic
cd FRESH_EMPTY_PROBE_BUILD_DIRECTORY
"$XBIN/xvlog" --sv -work xil_defaultlib -i "$TB" "$DIAG/record_boundary_probe.sv" -log xvlog_probe.log
"$XBIN/xelab" xil_defaultlib.record_boundary_probe -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s record_boundary_probe -log xelab_probe.log
"$XBIN/xsim" record_boundary_probe -runall -log xsim_probe.log
```

No syntax acceptance, actual values, simulator defect, or probe PASS is claimed here.
