# QAR0: fixed-priority shared quant admission

AT035 static, short pilot, and full four-row RTL all passed. This closes the specific AT034 idle dual-valid deadlock: with both commands held valid, G alone is ready and accepts; the waiting external LN_FFN quant command accepts after a safe zero-work G rejection. The unchanged quantizer then completes the original LN_FFN F32→Wi→GATE→Down chain in one runtime, including independent gold, real DDR transfers, final B/leases/responses, and full byte readback. This is a scoped simulation result, not a production arbitration, recovery, physical timing, or full-request sign-off.

## Repair and observed admission

AT034 had `ext_quant_ready` gated by `!cfg_valid` and `cfg_ready` gated by `!ext_quant_valid`. When both valid inputs were held at idle, neither could be accepted. AT035 introduces one combinational `select_ext_quant = EXT_QUANT && !ext_quant_active && phase==IDLE && !cfg_valid && !done_valid && ext_quant_valid`. External ready and the quantizer's input route both use that selection. G ready now excludes only an *accepted, active* external task. The existing one-bit `ext_quant_active` continues to hold external response ownership through rejection or actual response consumption and zero debt. There is no added persistent state, queue, quantizer, A/W cache, or matrix engine. `EXT_QUANT=0` keeps the original G-only equations by static inspection. AT036 also compiled and elaborated the AT035 frozen bridge as the default-parameter top; it did not run a new G-only dynamic replay.

The frozen TB directly exercises three orderings in the one full replay. At cycle23, both valid signals were held; G ready was high, external ready low, and G was rejected for `owner_admitted=0` with no G AXI/A-cache work. The external request remained asserted and accepted at cycle24. During its real computation and seven held response cycles, a new G valid remained waiting without ready or reject; only after the external response was consumed did G obtain its own zero-work rejection, then release without a duplicate rejection. Later the real G task accepted at cycle102160. A second external valid with `owner_admitted=0` remained waiting through G activity and seven held response cycles; after G response consumption, that request rejected without changing the published epoch2 A or GATE transaction counts. These latter checks are executable assertions in the frozen TB: the raw log advances past them to Down and the final chain marker, but it does not print their individual ready/reject cycle numbers. The fixed priority makes no fairness guarantee against an unbounded stream of G commands, and these probes do not cover cancellation or reset during activity.

The diagnostic Context opcodes now match `include/laya_tasks.h` (SHA256 `20a8a3a0a94e997c05d0f81657498f16f8d08e406a202eb8b08dde5b2ccd55bf`): external producer LN_FFN `0x12`, both quant tasks QUANT `0x20`, Wi consumer `0x32`, G producer GEGLU `0x60`, and Down consumer `0x33`. Their original task IDs, B1/S128, batch0/row0, source/ref/slot/epoch fields and independent gold remain. The RTL treats these Context fields as complete opaque keys; this replay does not add or validate production opcode permission decoding.

## Four-row chain result

| Actual AT035 endpoint | Result |
| --- | ---: |
| Source Q accept→A publish | cycle24→1103, 1079 cycles |
| Source AXI AR / requested beats / actual R | 4 bursts / 256 beats / 256 beats |
| Source first/last AR; first/last R | 27/712; 31/938 |
| Wi cfg→first done→actual consume | 55239→102148→102155 |
| G cfg→GATE-Q A publish | 102160→162865 |
| Down cfg→first done→actual consume | 189944→206128→206135 |
| Full cold TB | 206136 cycles |

The source task generated all original 4096 INT8 values and 128 FP16 scales from 16384B original LN_FFN F32 through real AXI reads, with 256 half commits and epoch1 A publication. Wi produced 20992 F32 and 1312 AW/W/B; its stored output fed 1312 real reader R into G. G produced 10496 F32 and 656 AW/W/B; the same quantizer reread 656 GATE beats and published 328 scale groups to epoch2 A. Down completed 335872 PS lane-groups, 4096 F32 and 256 AW/W/B. The original independent intermediate and final gold, physical A/W supply, last B, seven-cycle done holds, once-only actual response consumption, leases and debt checks passed. Source quant counters are per task; the final `total_quant_groups=328` is the second task only. The final 393216B DDR scan checked the 16384B read-only source, 142336B Wi/GATE/Down written outputs against gold, and 234496B untouched sentinel bytes.

AT034's cold TB was 206133 cycles. AT035 is three cycles longer because it includes admission probes and different absolute response alignment; this is not an arithmetic or deployment performance comparison.

## Provenance, cost, and limits

AT035 has 106 manifest rows and 104 distinct frozen paths. Every frozen SHA256/byte count matched. Compared with AT034, only the bridge RTL, observation/diagnostic TB, and runner differ; all 103 other manifest rows retain their prior content hashes, including original fixture/gold and tool inputs. The new bridge diff changes the shared selection/ready logic only. The full source and raw log are in the frozen attempt; historical AT034 and AT033 receipts remain unchanged.

Static/pilot/full guards ran serially and passed with child exit 0 and no protection trigger: 83.022106s / 29.197961s / 1782.005508s. Full peak owned RSS was 1505004KiB, minimum MemAvailable 447149816KiB. All 27/9/9 actual policy samples matched CPU0–3, nice19, idle I/O. The conservative full admission estimate was 2726.021088s under the unchanged 3600s cap. Pilot reached source Q publication and Wi W prefix only; all G/Down/full-storage claims rely on full. No HLS, OOC, P&R, or board run occurred.

AT036 is a separate affected static configuration check using the identical frozen bridge RTL from AT035, with only its new Tcl selecting `geglu_gate_quant_bridge_v1` as simulation top. Its actual compile/elaboration passed in 53.105357s, child exit 0, no guard trigger, peak owned RSS 2212056KiB and 31 matching policy samples. The default parameter is `EXT_QUANT=0`. AT036 does not add G-only runtime or numerical coverage.

The scope is one normal B1/S128 four-row profile plus three directed admission situations. LN_FFN producer input, FFN residual, full 28+2-layer/122-matrix request, production 13BO control, error recovery, all arbitration interleavings, joint resources, and physical timing remain unverified. M003/M004 stay open.

Evidence: [AT035 receipt](../attempts/AT035_QAR0_shared_admission_01/receipt.json), [full raw log](../attempts/AT035_QAR0_shared_admission_01/raw_full.log), [pilot raw log](../attempts/AT035_QAR0_shared_admission_01/raw_pilot.log), [manifest](../attempts/AT035_QAR0_shared_admission_01/input_manifest.json), [independent identity/guard check](../attempts/AT035_QAR0_shared_admission_01/verification.json), [AT036 default static receipt](../attempts/AT036_QAR0_default_static_01/receipt.json), [AT034 predecessor](../attempts/AT034_QWIGQD0_chain_02/receipt.json).
