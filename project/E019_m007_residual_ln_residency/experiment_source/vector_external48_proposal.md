# D21 successor: minimal external VECTOR control proposal

Status: proposal only, requested by A001 after increment69. No production RTL, workspace v1/joint or A010 parent change; no new-stage EDA. Current D21 provider retains all48 private FF. A008 candidate LN interface/layout has now been read; its actual implementation/validation remains A008 scope.

A later canonical `laya_m007_resident_vector32_v2 #(EXTERNAL_CONTROL=0)` can expose `external_control_enable`, `external_control_q[47:0]`, `external_control_next[47:0]`, `control_private_idle`, `control_retired`. Default local mode has exactly48 FF; external mode has no local control mirror. Both use the same combinational next-state logic preserving old-value RHS and existing assignment priority. Only one provider instance exists in a final composition. A v1 compatibility wrapper may instantiate this canonical local mode for old entrypoints; such source changes require fresh affected default-mode evidence and never relabel D21's frozen build.

Proposed layout v1, low-to-high (not yet an approved shared contract):

| Field | Offset | Bits |
|---|---:|---:|
| state, IDLE=0 | 0 | 3 |
| issued_vectors | 3 | 13 |
| retired_vectors | 16 | 13 |
| first_error | 29 | 1 |
| protocol_error | 30 | 1 |
| error_addr | 31 | 12 |
| error_lane | 43 | 5 |

The existing one-copy12288-bit workspace can then receive A full12288, G low11343, VECTOR low48, and the later frozen LN view. A separate successor `control_workspace_v2`/production composition keeps current v1/joint interfaces unchanged for A010's FFN closure. The successor contains one state_q store, not a v1 store plus a new store. Four owners require2 owner bits plus1 REARM bit:1 incremental private bit over current v1's owner+REARM2-bit state, subject to full actual glue census. Clearing the single arena on accepted safe ownership change seeds VECTOR IDLE/zero debt; one cycle REARM keeps all consumers disabled. Same-owner requests preserve state.

Inactive VECTOR must not interpret another view's random state bits to determine private idle. Its48 control bits all live in the arena, and it has no private payload/identity FF; proposed `control_private_idle` derives from actual shared-FP lease absence plus actual H/Q read-response absence, independently of arena state. Active retirement additionally requires VECTOR IDLE after held DONE consumption and no accepted same-edge bank/ADD/lease work. All published req/result/DONE/ready qualification is inactive-zero, while no live response is withdrawn on an ownership request. Shared-resource routing and source retirement must guarantee no VECTOR obligations before disable; no math reset clears debts.

The hidden read valid/address13 bits and scratch owner_active1 bit remain real outside the arena. They are shared bank/qualification state and not included in the proposed48-bit overlay savings. Scratch lease may span VECTOR and LN while parent identity remains held; read/write debts must still drain at each view transition. Parent keeps existing request/generation/epoch context; no new128-bit copy.

After implementation and default/external equivalence, the48 bits may save6B relative to current D21 standalone declaration; no saving is booked now. Final combined sum must include the extra workspace owner bit, actual parent FSM/glue, A008 LN private state, banks14 bits and every other real FF. Current D2162-bit increment/4044.125B projection remains unmodified.

Bounded successor verification should cover actual A/G retirement to VECTOR, VECTOR4096 H/Q reads and real phase7 ADD/commits, held-DONE/FP/bank barriers, VECTOR-to-LN only after A008's real service/bank debts retire, one-cycle REARM and return to A/new epoch. Original numeric leaf tests are reused by identity; full mixed parent/Encoder evidence remains a later explicit scope. No LN output is substituted by saved norm/residual gold.

## Frozen LN input received after D21

Read A008's `project/E014_m007_layernorm32/experiment_source/ln_compact_interface_v1.md` and parsed `ln_control_layout_v1.json`. Candidate external LN has12288-bit q/next with12116 occupied bits and172 reserved; this is a view-layout candidate, not actual FF fit or residual-plus-LN headroom. `CANONICAL_TAGS=1` is required for external mode. LN `control_enable/control_clear/q/next/control_retired` can map directly at the successor composition; clear is legal only after actual active retirement and must never reset gamma/numeric/services. Disabled LN retired is0, so target-private-idle must come from independently verified actual resource/private readiness, never inactive q interpretation or disabled retired.

Gamma132 and numeric18055 remain private and fully charged. LN held reject/cancel/done_kind are part of its frozen view; cancelled terminal is the same DONE record/unique done_ready consumption. Parent actual FP/DIV release and real native-bank expected-response obligations remain barriers. Current D21 residual finite-result observation qualifies only its actual covered output stage; it must not be silently treated as full original LN Source scan or as a proof of `cmd_source_finite_qualified`. Source qualification/summary needs the later fixed real producer/scan interface and CPU ordering. No cross-write to LN or current workspace/v1/A010 interface occurs here.
