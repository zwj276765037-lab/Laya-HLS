# Actual R003 resource boundary for the next controller contract

This is an implementation handoff, not authorization or evidence of a new parent graph. Authority remains SM010 F32-MATRIX-07 and A001's source/m007_single_resource_qkv_attention_wo_20261021.md. No new batch or production parent starts here.

- `laya_m007_quant_a_fill_v1` is already pure with respect to DIV and A storage. It contains one frozen quant_group32, its authorized32 dedicated quant mul leaves, bounded128x16bit accepted-coordinate metadata (256B), global numeric candidate and producer-close control. Its external d_* ports are the real DIV lease/request/return/release interface. Its acfg/awr/fill_cancel ports target the one existing A service. It owns no duplicate A RAM or DIV leaf and does not impose row-major order.
- `laya_m007_matrix_f32_v1` is the current row-major descriptor/input wrapper and independent functional shell. It owns one real DIV8 and one existing matrix_full. It prechecks all descriptor spans and bias identity before any input/A/DIV work. Matrix model64 and tensor32 are internal mapped keys. The future original128bit model/numeric tags must be validated at the enclosing parent before mapping; truncated equality is not full identity validation.
- `matrix_full` still owns the sole A/W services, coefficient store and one `matrix_superblock`; the superblock still contains its FP/PS shell. The Attention layer has a separate resource shell. Instantiating both current shells together would duplicate FP/PS; future A010 matrix-engine and A007 layer-engine extraction is still required under a new explicit contract. Current standalone evidence does not establish production unique-resource integration.
- Current F32 input order is row→group with32F32 per accepted beat. Future QKV output mapping is plane=col//1024,head=(col%1024)//64,half=(col%64)//32,token=row. Future context→WO input can read query→head→half with row=query and group=2*head+half, using bounded response holding and the pure quant/A input, with no context copy. Future G group-major8F32 needs only four beats/128B assembly per quant group; no full G reorder RAM is present or required by this pure interface.
- A publication and producer whole-operation success are distinct. `producer_close_valid/ready/success` exists and current F32 closes success only after every legal input. The pure layer must not submit Down until both quant/A success and whole G success are known. Future G failure must stop input, release the frozen quantizer early, drain only actually accepted quant/DIV and A-ack debt and perform real A cancellation; no missing inputs or padding/reset may be manufactured. This future producer-cancel operation is not current R003 acceptance and has not been claimed tested. Any actually accepted cancellation must retain its real response obligation until consumed.
- Current numeric quant error is different: all required tensor input/checks still retire, global rank is input→scale→inverse→half→product→range and then row/group/element. Frozen local stage4 maps to global phase3,local3 to phase4. Half-overflow skipped inverse is justified only by positive finite d_full>=65520, whose reciprocal is finite; actual operation counts/valid are not fabricated. New quant fields have their own error_domain/phase/coordinates and do not change the matrix stage ABI.
- Phase5 quant and phase6 LN must use one DIV8 via actual exclusive lease handoff. The current pure layer exposes that interface; the standalone shell's divider is for its own functional experiment. Matrix and Attention must similarly hand off the sole shared256mul/add and PS/context resources using actual returns/acknowledgements/credit/owner release. No debt input may be tied to a fake zero for production integration.
- The A service supports matching partial-fill cancellation, retains visible cfg and write acknowledgements until consumed, invalidates only the matching unleased slot and holds its complete cancel identity. A previously consumed successful publication can also be invalidated. Matrix launch waits real A publication consumption, quant/DIV release, producer success and zero actual write debt. Old compatibility tests explicitly disable cancellation.
- The new256B coordinate ledger and other control registers must enter the future joint4KiB control account. Independent module estimates or disjoint lifetimes do not prove combined fit; actual reuse/allocation remains to be shown. Full physical resource, routed300MHz and board throughput remain open.
- QKV's current source has128 original Encoder0 norm rows. Existing WO/Wi/Down/FC fixtures preserve16 original+112 diagnostic rows. Future context→WO all128 real Attention outputs need their own original local reference and cannot inherit diagnostic provenance as real model trajectory. Global original matrix/cross-operator first-error equivalence remains separate from current global quant first-error evidence.

All current functional timing claims remain tied to actual frozen AT builds and their input/oracle identities. Future extraction must preserve these boundaries and add affected actual joint evidence; no new implementation timing is inferred from functional simulation.


## Controller increment26: next-stage producer failure obligation

The existing producer_close_success=0 early-release hook is not verified by R003. The later pure-engine/parent contract must drive actual partial quant/DIV/A activity, close the producer as failed, observe real quant/DIV release and matching A cancellation while every already accepted write acknowledgement drains, then perform no-reset new-generation/source recovery. If input and producer-close are both accepted on the same edge, that actual input is part of the accepted debt and must retire. No fabricated padding, completion, missing response or forced zero-debt is allowed. This is a recorded later acceptance requirement, not a new experiment launch or current PASS.


## Declaration-width nonpayload control account (AT018 source, static only)
Only values assigned in the module sequential process are counted as local persistent control. Connection wires, combinational tag/mask/address buses, loop indices and function temporaries do not create another local state copy. No lifecycle overlap discount is taken. Every module subtotal is rounded up independently; source locations below refer to unchanged current declarations, also frozen in AT018. No synthesis/physical storage result is implied.

### full facade: 1923 persistent bits = 241B; conservative allowance 247B
Declarations: rtl/laya_m007_matrix_full_v1.sv:117; output registers are included from its port declaration.

| fields | bits |
|---|---:|
| latched descriptor (request/model64; generation/epoch/tensor32; k/n/total_blocks16; A/bias1; four base/span64) | 786 |
| active/aborting/core_started/core_finished/load_pending/waiting_next6 + tick32 + issue/load_next2x16 + slot_ready/in_use2x2 + slot_s2x16 | 106 |
| cached real A completion valid2+k2x16+request2x64+generation/epoch2x2x32 | 290 |
| coefficient binding/coverage flags3+coverage128+count8+model/request2x64+tensor/gen/epoch3x32+N16; held coef response1+2+16 | 398 |
| held final done1+status3+request64+generation32+epoch32+error7+16+8+4 | 167 |
| elapsed/firstout/Wwait/ctxwait4x32 + issued/computed/retired3x16 | 176 |

Conservative extra 49bits covers same-cycle blocking scratch declared at module scope: b32, coef_cycle_bad1, coef_cycle_col16. These need no retained value across clocks, but are not deducted from the conservative subtotal.

### superblock controller: 7298 persistent bits = 913B; conservative allowance 933B
Declarations: rtl/laya_m007_matrix_superblock_v1.sv:59; output registers are included from its port declaration.

| fields | bits |
|---|---:|
| FSM/matrix-active/last5 + identity224 + K/N/s48 + A/W/ctx3 + groups8 + tick32 | 320 |
| A/W completion metadata: valid4, four2x16 fields128, three2x64 fields384, four2x32 fields256 | 772 |
| abort1+error-key32 + held done/status/identity/error135 | 168 |
| seven13-bit pipeline pointers/counts | 91 |
| actual math_debt7 + bias_debt7 + retire_debt3 | 17 |
| pool_state64x4 + pool_seq64x13 | 1088 |
| issue_time/ps_time2x64x32 (existing real telemetry registers) | 4096 |
| W hold-valid2/record18 + Wstate2/target1/fetch10/pending-tag64 + A-ret-valid1/tag96 | 194 |
| context flags10/s32/committed26 + bias-active/ctx2/next6 + bias read/add/ack counters42 | 118 |
| retire-active/ctx2/expected16/next9/count9 + output-hold-valid1/beat8/ctx1 | 46 |
| actual A/FP/W release-done flags | 3 |
| held block-done-valid1/ctx1/s16 | 18 |
| seven32-bit latency metrics + four32-bit overlap/hold metrics + peak8+7 | 367 |

Conservative extra 162bits covers same-cycle blocking scratch declared at module scope: cycle_numeric/protocol2, cycle_numeric_key32, four integer cycle coordinates128. These are reinitialized each enabled clock and need no retained prior value; the allowance is kept until implementation mapping is explicit.

### pure quant/A front: 2357 persistent bits = 295B; conservative allowance 295B
Declarations: rtl/laya_m007_quant_a_fill_v1.sv:46; output registers are included from its port declaration.

| fields | bits |
|---|---:|
| state3 + request64 + generation/epoch/total_groups3x32 + K16 + slot1 | 180 |
| eight completion/error/producer/cancel flags | 8 |
| global error key22 + A-write debt9 | 31 |
| accepted_coordinates128x16 | 2048 |
| held done/status/quant phase/row/group/element1+3+3+7+7+5 | 26 |
| real A-write/A-ack counters2x32 | 64 |

The pure front is295B total, including256B coordinates and39B other control after rounding. Persistent module subtotals are facade241B + superblock913B + front295B =1449B. Keeping all sequential scratch allowances yields facade247B + superblock933B + front295B =1475B, with2621B left from4096B before layer/LN/RoPE/parent arbitration/Check and any other new control. This is a matrix-side subtotal, not a joint fit result. The existing512B issue_time/ps_time telemetry is included; it is not silently removed because it is diagnostic.

If the present row-major F32 shell is retained beside a new parent, its declarations at laya_m007_matrix_f32_v1.sv:46 contribute925bits descriptor/order/tick/input count +169bits held done/error +8x32bit milestone registers =1350bits=169B additional control. Removing/reusing it must be an actual code change with an explicit owner; it is not subtracted by lifetime assumptions.

The arithmetic/data account is separate: superblock op0/op1 are2x64x256x32bits=131072B; W holding_data2x4352bits=1088B; ctx_bias_data2x64x32=512B; output holding32x32=128B. The facade coeff_words64x64x32=16384B is the one coefficient payload store, which must join the unique global coefficient allocation later. These payloads are not a second4KiB control grant. Top-level mul/add/PS tags and data are connection buses to existing sole services, not duplicated local state. Actual sharedFP/storage return queues/tags remain owned by A007 and must be counted once under their existing service accounts.

Inherited arithmetic leaf metadata must also remain visible, although it is outside the controller-only subtotal above: the32 integer trees declare6x96bit tag_pipe and6 valid bits each (2304B tags+24B valid);256 half-product leaves declare tag[0:2]x96 plus registered rsp_tag96 and valid3 (12384B raw declarations including unused tag[2]);256 dot-to-F32 leaves hold rsp_tag96 and rsp_valid1 (3104B), and format has sv4 plus aligned_bad4x256 numerical exception bits (129B rounded). Per-lane identical tag values may be optimized by a tool, but no such sharing has been implemented or measured here. They are inherited numerical-pipeline metadata, not sharedFP queue tags and not payload operands. If the parent's4KiB rule includes these raw inherited replicated declarations, it is already exceeded and an explicit ownership/accounting or actual tag-sharing change is required; the1475B subtotal cannot prove that larger scope fits.
