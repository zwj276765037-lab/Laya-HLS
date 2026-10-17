// Internal complete admission A; no HOLD/S/H is manufactured here.
package laya_admission_owner_layout_v1;
  localparam int BYTES=1024,BEATS=16,VERSION=1;
  localparam logic [31:0] MAGIC=32'h3144414c;
  localparam int FLAGS=8,KNOWN_ROLES=12,SESSION=16,ACCEPTED_REQUEST=24;
  localparam int IDENTITY=64,MODEL=160,MAPPINGS=576,ROLE_BYTES=24,ROLES=13;
  localparam int RESERVED=888;
  function automatic logic record_ok(input logic [8191:0] p);
    return laya_generated_provenance_layout_v1::admission_record_ok(p);
  endfunction
endpackage
