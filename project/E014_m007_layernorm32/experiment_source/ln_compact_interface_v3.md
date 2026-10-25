# LN-COMPACT-22 pure interface freeze v3 (2026-10-23)

This freezes the production interface and proposed control representation for
integration preparation. It does not transfer the v2 normal PASS to v3.
The ports and all v2 offsets are unchanged from
[interface v2](ln_compact_interface_v2.md). The authoritative complete layout is
[ln_control_layout_v3.json](ln_control_layout_v3.json).

Default `CANONICAL_TAGS=0, EXTERNAL_CONTROL=0` preserves arbitrary 96-bit tags.
External mode requires canonical mode. Canonical public tags remain
`{16'h4c4e, op_epoch32, op_generation32, row7, chunk5, 4'b0}`.
`control_q/control_next` remain exactly 12288 bits, with no private shadow q in
external mode. A TB-owned q establishes only PURE_EXTERNAL_CONTROL_UNIT scope.

The v3 layout occupies 12128 bits and leaves 160 reserved bits. It appends only
the following offered-request state after the v2 DIV flags at bits 12116..12119:

| State | Bit positions | Purpose |
| --- | --- | --- |
| scale_offer_valid | 12120 | Preserve a blocked scale request |
| scale_offer_tag[2:0] | 12121..12123 | Preserve scale kind and context |
| sqrt_offer_valid | 12124 | Preserve a blocked sqrt request |
| sqrt_offer_ctx[1:0] | 12125..12126 | Preserve sqrt context |
| div_offer_valid | 12127 | Keep the sqrt response until real DIV acceptance |

No numerical FF is added. Operands remain in the original immutable context
sum/square-sum/shift storage or the held sqrt response. Already offered requests
survive matching cancellation and protocol drain until actual acceptance;
their flags participate in physical retirement. Gamma control remains 132
private persistent bits and original private numeric state remains 18055 bits.
Scalar control (5+13 bits), ADD64x146 metadata and all 64 credits remain in q.

The public held reject, matching cancel, `done_kind`, `cancel_rsp_valid`,
protocol diagnostic, source qualification and summary ports retain interface
v2 semantics. Cancelled DONE is one terminal record consumed by `done_ready`;
there is no independent cancel-response retirement. Inactive holds next=q,
closes production valid/ready and reports retired=0. Legal clear follows actual
retirement and does not clear gamma or numerical payload. Parent integration
must additionally observe actual FP/DIV release and real bank/provider debt.

Version boundary: normal AT001..008 use core SHA
`c612633a78644b4474a49ee34ab032241f32f5795637c67492d18ef1b24d1265`
with layout v2. Their complete normal results are frozen in
`../experiment_results/runs/R002/normal_checkpoint_v1.json` and are not v3 results.
The prepared v3 core SHA is
`2a97609c9245f53c699b77e5c8110fc9ea7f2029547e32d593366da0e2e22eac`;
it has not yet been compiled or tested. Shared arena, finite producer proof,
v3 protocol recovery, full CPU exception ordering and source-summary
arbitration remain open. The current numeric path still uses legacy physical
observation order; the allocated ordering fields do not establish equivalence.

The earlier prepared ab7769 revision had unmatched generator replacement text;
e47eeb16 corrected the exact offer mux/valid replacements. The current revision
also includes all offer flags in both normal and physical retirement and adds
a stateless public wrapper around the exact production codec functions for
local range/roundtrip checks. These are preparation revisions, with no runtime
PASS on any of them. Runtime validation will freeze a separate actual build.
