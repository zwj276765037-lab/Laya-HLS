# A010 current-source map for minimal pure matrix extraction

2026-10-21. Read-only source mapping requested by A001. This does not implement a new interface, modify shared RTL, start a batch or approve a production parent. A001's `source/m007_single_resource_qkv_attention_wo_20261021.md` remains authoritative.

## Present physical containment

| Current module | Actual contained resource | Existing source location |
|---|---|---|
| `laya_m007_matrix_superblock_v1` | One `laya_shared_fp256_v2 fp` and one full `laya_attention_storage_v1 storage`, in addition to the integer dot array, half-product/format pipeline, control and finite operand pool | q8_linear_and_restore/rtl/laya_m007_matrix_superblock_v1.sv:180–195 |
| `laya_m007_matrix_full_v1` | One above superblock, one A cache, one W supply and one coverage-bound bias coefficient store; it does not directly instantiate FP/storage | same rtl/laya_m007_matrix_full_v1.sv, core at~156 and A/W at~223 |
| `laya_m007_matrix_f32_v1` | One pure quant/A front, one DIV8 and one full matrix shell (which contains FP/PS through its child) | same rtl/laya_m007_matrix_f32_v1.sv |
| `laya_m007_quant_a_fill_v1` | One frozen quant_group32 with its authorized dedicated32 quant-mul leaves; no DIV, FP256, A or PS RAM instance | same rtl/laya_m007_quant_a_fill_v1.sv |

The current full/F32 shells must not be connected beside the current Attention resource shell in a production parent: that would instantiate two FP/PS sets.

## Minimal extraction units and single ownership

1. A010 can extract the current superblock compute/control into a pure matrix engine, retaining the exact command/completion/cancel/out interfaces, A/W service ports, current dot/format instances,64-token op0/op1 pool, both context retirement/bias controllers and actual debt accounting. Remove only its direct `fp` and `storage` instantiations and expose their existing nets. The8192INT8/half-product pipeline stays part of the matrix engine; it is not a second shared256F32 array.
2. A010 can extract the current full-N scheduler plus the same A/W/coeff instances into one production matrix facade that instantiates this pure engine and passes its FP/PS service nets to the parent. A/W/coeff remain a single physical facade instance reused by QKV and WO. The public acfg/awr/fill_cancel path already lets the parent's pure quant/A front populate the same A cache; Attention does not need a second A/W instance.
3. Preserve current superblock/full public names as thin standalone compatibility wrappers around those same engines/facade plus one private FP/PS shell for their local experiments. The full compatibility wrapper must instantiate the resource-external full facade, not another privately wrapped superblock beneath an extra resource shell. Production A007 parent instantiates neither standalone private-resource shell.
4. Put the existing pure quant/A instance at the production parent. Connect its d_* ports to A007's one DIV8 and its acfg/awr/cancel ports to the matrix facade. Keep row-major `matrix_f32` as the standalone F32 test shell. Future context/G producers use the pure front directly, with bounded group assembly/order defined by the caller. No pure-quant duplication or new payload reorder RAM.
5. A007 owns the parent and the unique shared FP/storage/DIV implementations. A010 owns only these matrix-side extractions/adapters. Shared interfaces are frozen once by A001/A007/A010 before implementation; this map does not silently change them. Proposed new filenames are not a committed ABI.

If the later parent contract unifies the current bias bank with a broader original coefficient cache, the same actual coverage/identity-bound bank must have one owner and be connected once; this map neither clones it nor silently migrates it. Original128bit identity validation belongs before the existing internal model64/tensor32 mapping.

## Existing real FP port families to expose unchanged

Current internal declarations are superblock lines77–85; its exact connection is lines182–187.

- Ownership request: current `bind_new_lease` drives lease_valid with request64/generation32/epoch32/head0/phase1; actual `fp_lease_ready`, `fp_lease_active`, `fp_draining` return. The current BIND FSM waits real W ready plus real A ready, FP ready and storage bind_ready together. Parent must route this request, not prebind and then fabricate ready.
- Release: valid is `state==FINALRELEASE&&!release_fp_done`; phase1/epoch; real `fp_release_ready` is consumed into `release_fp_done`. `phase_debt_clear` is the current expression `arithmetic_debt==0 && retire_debt==0 && storage_idle && !a_ret_valid && w_state==0 && !out_hold_valid`. Shared FP additionally checks its own actual pending/inflight state. Keep these obligations, not a constant-zero debt surrogate.
- Multiply: scalar valid/ready, phase3bit/epoch32/tag96, two256×F32 operands; actual response valid/ready/tag96/data256×F32. Current nets are `mul_req_*`, `mul_a`, `mul_b`, `mul_rsp_*`.
- Add: seven group request valid/is_root/ready, per-group phase3/epoch32/tag96; one256×F32 operand pair; seven response valid/ready/tag96 plus256×F32 response data. Matrix phase1 uses group0 atomically for all256 lanes, with actual math/bias arbitration retained in the engine. Do not create another bias adder.
- Return accounting: real `mul_pending[6:0]`, `add_pending[6:0][6:0]`, `protocol_fault`. Existing `reserved_vectors = math_debt+bias_debt+retire_debt+mul_pending+add_pending[0]` remains global across both contexts. `arithmetic_debt=math_debt+bias_debt` remains actual accepted-A minus math/bias PS acknowledgements. Expose/route the existing shared response ownership identity (currently left unused at the private shell) under the later parent's agreed identity checks; do not invent it from request pins.

## Existing real PS/bind port families to expose unchanged

Current internal declarations are lines86–90; actual storage wiring is lines188–195.

- Storage has bind_valid/ready and operation identity, not a separate lease/release interface. Current `bind_new_lease`, request64/generation32/epoch32/head0/phase1 bind it; every PS operation uses the matching identity. Preserve returned storage identity and actual whole-bankset `storage_idle` for the parent handoff.
- PS write: valid/ready,1024-bit bank mask,1024×4-bit addresses,1024×F32 data,96-bit tag; real write-response valid/ready/tag. Current consumer is always ready for genuine PS acknowledgements (`ps_wr_rsp_ready=1`); this is a consumer policy, not a fake acknowledgement or debt clear.
- PS read: valid/ready,1024-bit mask,1024×4-bit addresses,96-bit tag; real response valid/ready/data1024×F32/mask1024/tag96. Keep the current atomic merged math/bias/retire transaction and wait-all-destinations response consume. Do not split one accepted physical read into independent fake response handshakes.
- Current private storage ties G/context request valids off because matrix itself uses PS. In the production parent, expose only the matrix PS slice to this engine; the unique A007 storage instance still serves the real G/context consumers and returns its actual overall idle. Do not tie off G/context globally or substitute a PS-only idle for the storage's real idle.

## A/W, complete events and output boundaries

Superblock ports already expose every real A/W service handshake: A lease/read/response/separate-ret/release with slot/request/generation/epoch and96-bit record tag; W lease/read/response/separate-ret/release with slot/request/model/generation/tensor and64-bit accepted tag. The facade owns the two actual caches and routes these as today. `a_complete` and `w_complete` are consumed-publication events with full existing identities/status/shape; retain them and their binding checks rather than making a cache-ready level into a completion.

Full-N control, original coefficient coverage, four AXI ports, W prefetch and real cold service remain in the facade. The pure engine's block_done/ctx release and 32F32 out valid/ready are actual acceptance/retirement boundaries. A W slot may release after copied/returned K issues while its math tail remains; FP/PS/A ownership survives until final actual retirement. Preserve all current accepted-tag/error-drain rules and the final abort-priority cleanup.

For future QKV→Attention, parent output handshake writes the existing QKV bank using plane/head/half/token mapping. For future context→WO, actual context read response consumption feeds the pure quant/A input, and whole producer success/context ownership release must precede matrix start. This map provides no new parent-graph PASS, joint4KiB control fit, global original matrix first-error equivalence or physical timing result.

## A001 readback boundary

A001 accepted this as a later static extraction cut, not a new run. Parent arbitration is per actual resource bundle: while matrix owns FP/PS phase1, QKV output still needs the layer's public32F32 QKV write path, real finite/coverage checks and backpressure into matrix out_ready. A single global owner mux must not suppress this sole-QKV write service. The256B pure coordinate ledger and facade descriptor/scheduler additions enter the joint control account. Overall idle comes from the unique complete storage instance, including real G/context responses, not just matrix PS debt.
