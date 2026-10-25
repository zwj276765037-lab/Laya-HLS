# LN-COMPACT-22 pure interface freeze v1 (2026-10-23)

This is an implementation contract, not a measured fit or functional PASS.
Default CANONICAL_TAGS=0, EXTERNAL_CONTROL=0 preserves legacy arbitrary96-bit tags
and numerical/handshake behavior. EXTERNAL_CONTROL requires CANONICAL_TAGS=1.
Canonical inputs use {16'h4c4e,op_epoch32,op_generation32,row7,chunk5,4'b0}.
The original public command/FP/DIV/bank/output ports stay in place.

New ports, ignored or tied benign in legacy mode:

- input control_enable, control_clear; input [12287:0] control_q;
  output [12287:0] control_next; output control_retired.
- input reject_ready; existing reject_valid/reject_code become a held record
  in canonical mode, consumed by reject_valid&&reject_ready. A reject accepts
  no normal data and changes no admitted work; held rejection blocks new input.
- input cancel_valid; output cancel_ready; input cancel_request_id[63:0],
  cancel_generation[31:0], cancel_epoch[31:0]. Matching cancel stops new issue,
  retains already offered holding records, drains actual accepted service work.
- output [1:0] done_kind:0 normal,1 numeric,2 protocol,3 cancelled.
  output cancel_rsp_valid = done_valid && done_kind==3. This is the same held
  terminal record, consumed only by existing done_valid&&done_ready; there is
  no second independently retired cancel response.
- output protocol_fault, protocol_code[3:0], protocol_location[7:0].
- output error_class[1:0], error_check[3:0]; existing error_level/row/node give
  sub/full-row/element. Default error_stage keeps original meaning; canonical
  error_stage is a combinational legacy-stage view of the new CPU-order code.
- input cmd_source_finite_qualified, cmd_source_summary_valid,
  cmd_source_bad_valid, cmd_source_bad_row[6:0], cmd_source_bad_element[9:0].
  Canonical command needs qualified or completed summary. A bad summary must
  be within cmd_rows. Summary is precomputed by an external real scan; the pure
  TB only proves summary arbitration, never a real resident scan or producer
  finite qualification. Gamma load remains pre-command model qualification.

control_next holds control_q when disabled; every production valid/ready is
closed, and control_retired remains0. Inactive is not retirement proof.
A legal control_clear is enabled only after actual control_retired; it clears
operation q, not gamma/numeric payload or services. Illegal active clear is a
protocol fault with actual drain. Retired requires real external pending/bank
idle, no scalar busy/response or held request/output, active0, done0, reject0,
and no gamma loading/held gamma result. Parent must additionally prove its real
FP/DIV lease release before workspace owner switch. No private shadow q FF in
EXTERNAL_CONTROL mode. TB-owned q is PURE_EXTERNAL_CONTROL_UNIT evidence only.

Bit layout is ln_control_layout_v1.json: proposed occupied12116/12288 bits,
172 reserved. Base11959 offsets are retained, bit3 is ctx_failed0, extra3bits
complete ctx_failed4. tree_checked80/protocol13/source summary18/qualified1
bring12074; held reject5/cancel1/donekind2 plus actual read/write expected17+17
bring12116. All additions are charged. Gamma132 and numeric18055 stay private.
Scalar3/2 tags and ADD64x146 metadata preserve all64 credits. ADD item offsets:
stages0..9 at0,8,16,24,32,40,47,53,58,62 within each65-bit tree, second tree+65;
delta130/eps138 each8bit. Every valid item is range-checked before encoding.
Bank per-port one held response is established by actual native_bankset ready
logic; expected descriptors track actual accepts and exact returns, including
same-edge old return/new accept. Source layout will be revised explicitly if
implementation requires any additional long-lived state.
