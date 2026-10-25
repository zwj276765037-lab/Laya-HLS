`timescale 1ns/1ps
// Production s-major control. No storage/SFU/FP resource instances inside.
// A slot retires independently while the other slot remains in arithmetic.
module laya_m007_g_engine_v1 #(parameter bit EXTERNAL_CONTROL=0)(
 input logic external_control_enable,input logic [11342:0] external_control_q,
 output logic [11342:0] external_control_next,output logic control_private_idle,control_retired,
 input logic clk,rst_n,
 input logic producer_cancel_valid,output logic producer_cancel_ready,
 input logic [63:0] producer_cancel_request_id,input logic [31:0] producer_cancel_generation,producer_cancel_epoch,
 output logic producer_cancel_reject_valid,
 input logic cmd_valid,output logic cmd_ready,input logic [63:0] cmd_request_id,
 input logic [31:0] cmd_generation,cmd_epoch,
 input logic storage_owner_valid,input logic [63:0] storage_owner_request_id,
 input logic [31:0] storage_owner_generation,storage_owner_epoch,input logic [2:0] storage_owner_phase,
 input logic sfu_owner_valid,input logic [63:0] sfu_owner_request_id,
 input logic [31:0] sfu_owner_generation,sfu_owner_epoch,input logic [2:0] sfu_owner_phase,
 input logic fill_valid,output logic fill_ready,input logic [63:0] fill_request_id,
 input logic [31:0] fill_generation,fill_epoch,input logic fill_slot,fill_half,
 input logic [6:0] fill_s,fill_row,input logic [31:0][31:0] fill_data,
 output logic fill_reject_valid,output logic [1:0] fill_reject_code,
 output logic out_valid,input logic out_ready,output logic [7:0][31:0] out_data,out_status,
 output logic [95:0] out_tag,output logic [6:0] out_s,out_row,output logic [1:0] out_chunk,
 output logic done_valid,input logic done_ready,output logic done_cancelled,output logic [31:0] done_status,
 output logic [2:0] done_error_rank,output logic [6:0] done_error_row,output logic [11:0] done_error_column,
 output logic [63:0] rsp_request_id,output logic [31:0] rsp_generation,rsp_epoch,
 input logic discard_valid,output logic discard_ready,input logic [63:0] discard_request_id,
 input logic [31:0] discard_generation,discard_epoch,output logic discard_reject_valid,
 output logic engine_idle,active,needs_discard,protocol_fault,
 output logic [1:0] slot_active,slot_ready,output logic [1:0][6:0] slot_s,
 output logic [1:0][9:0] slot_consumed_vectors,
 output logic [1:0][8:0] slot_math_pending,slot_sfu_debt,output logic [1:0][7:0] slot_fp_debt,
 output logic [7:0][18:0] covered,evaluated,output logic pool_reset_n,
 output logic [8:0] fp_req_valid,input logic [8:0] fp_req_ready,
 output logic [8:0][95:0] fp_req_tag,output logic [8:0][7:0][31:0] fp_req_a,fp_req_b,
 input logic [8:0] fp_rsp_valid,input logic [8:0][95:0] fp_rsp_tag,
 input logic [8:0][7:0][31:0] fp_rsp_data,fp_rsp_status,input logic fp_pool_fault,
 output logic sfu_req_valid,input logic sfu_req_ready,output logic [95:0] sfu_req_tag,
 output logic [7:0] sfu_req_mask,output logic [7:0][31:0] sfu_req_x,
 input logic sfu_rsp_valid,output logic sfu_rsp_ready,input logic [95:0] sfu_rsp_tag,
 input logic [7:0][31:0] sfu_rsp_data,sfu_rsp_status,input logic sfu_protocol_fault,sfu_reject_valid,
 output logic g_wr_valid,input logic g_wr_ready,output logic [255:0] g_wr_mask,
 output logic [255:0][5:0] g_wr_addr,output logic [255:0][31:0] g_wr_data,output logic [95:0] g_wr_tag,
 input logic g_wr_rsp_valid,output logic g_wr_rsp_ready,input logic [95:0] g_wr_rsp_tag,
 output logic g_rd_valid,input logic g_rd_ready,output logic [255:0] g_rd_mask,
 output logic [255:0][5:0] g_rd_addr,output logic [95:0] g_rd_tag,
 input logic g_rd_rsp_valid,output logic g_rd_rsp_ready,input logic [255:0][31:0] g_rd_rsp_data,
 input logic [255:0] g_rd_rsp_mask,input logic [95:0] g_rd_rsp_tag
);
 wire control_enabled=!EXTERNAL_CONTROL||external_control_enable;
 logic math_control_retired;
 logic bind_ready,bound,owner_match,bind_valid,write_pending,pair_fault,math_fault,math_idle,math_clear,math_in_ready;
 logic pair_fill_ready,pair_fill_reject;logic [1:0] pair_fill_code;
 logic bank_req_valid,bank_req_ready,bank_rsp_valid,bank_rsp_ready,bank_rsp_slot,bank_reject;
 logic [6:0] bank_rsp_s,bank_rsp_row;logic [1:0] bank_rsp_chunk;
 logic [7:0][31:0] bank_x,bank_gate;logic [95:0] bank_tag,math_tag;
 logic [1:0][9:0] bank_issued,bank_returned;
 logic [15:0] read_index;logic [6:0] completed_groups;
 logic pair_release_valid,pair_release_ready,pair_release_slot,pair_release_reject;
 logic [6:0] pair_release_s;logic [9:0] pair_release_consumed;logic pair_release_clear;
 logic pair_discard_valid,pair_discard_ready,pair_discard_reject;
 logic [8:0] math_pending;logic first_error;logic [2:0] first_rank;logic [6:0] first_row;logic [11:0] first_column;
 logic all_covered;
 logic cancel_read_held,cancel_fill_held;
 wire producer_cancel_identity=producer_cancel_request_id==rsp_request_id&&producer_cancel_generation==rsp_generation&&producer_cancel_epoch==rsp_epoch;
 wire producer_cancel_fire=(producer_cancel_valid===1'b1)&&producer_cancel_ready;
 wire fill_admit=active&&((!done_cancelled&&!protocol_fault)||cancel_fill_held);
 assign producer_cancel_ready=control_enabled&&active&&!done_cancelled&&!done_valid&&producer_cancel_identity;
 assign producer_cancel_reject_valid=control_enabled&&(producer_cancel_valid===1'b1)&&!producer_cancel_ready;
 assign control_private_idle=!active&&!done_valid&&!needs_discard&&slot_active==0&&!write_pending&&bank_issued==bank_returned;
 assign control_retired=control_enabled&&control_private_idle&&engine_idle&&math_control_retired&&!cmd_valid&&!out_valid;
 wire cmd_fire=cmd_valid&&cmd_ready;
 wire consume=out_valid&&out_ready;
 wire pair_release_fire=pair_release_valid&&pair_release_ready;
 wire discard_fire=discard_valid&&discard_ready;
 assign protocol_fault=pair_fault||math_fault;
 assign fill_ready=fill_admit&&pair_fill_ready;
 assign fill_reject_valid=control_enabled&&fill_valid&&(!active||(done_cancelled&&!cancel_fill_held)||pair_fill_reject);
 assign fill_reject_code=(!active||(done_cancelled&&!cancel_fill_held))?2'd1:pair_fill_code;
 assign engine_idle=!active&&!done_valid&&!needs_discard&&math_idle&&slot_active==0&&!write_pending&&bank_issued==bank_returned;
 assign out_s=out_tag[15:9];assign out_row=out_tag[8:2];assign out_chunk=out_tag[1:0];
 assign math_tag={rsp_generation,rsp_epoch,16'b0,bank_rsp_s,bank_rsp_row,bank_rsp_chunk};
 always_comb begin
  owner_match=storage_owner_valid&&sfu_owner_valid&&storage_owner_request_id==cmd_request_id&&sfu_owner_request_id==cmd_request_id&&
   storage_owner_generation==cmd_generation&&sfu_owner_generation==cmd_generation&&storage_owner_epoch==cmd_epoch&&sfu_owner_epoch==cmd_epoch&&storage_owner_phase==1&&sfu_owner_phase==1;
  bind_valid=control_enabled&&cmd_valid&&!active&&!done_valid&&!needs_discard&&math_idle&&owner_match;
  cmd_ready=control_enabled&&!active&&!done_valid&&!needs_discard&&math_idle&&owner_match&&bind_ready;
  bank_req_valid=active&&read_index<41984&&((!done_cancelled&&!protocol_fault)||cancel_read_held);
  bank_rsp_ready=math_fault?1'b1:math_in_ready;
  pair_release_valid=0;pair_release_slot=0;pair_release_s=0;pair_release_consumed=0;pair_release_clear=0;
  for(int slot=1;slot>=0;slot--)if(active&&slot_active[slot]&&slot_consumed_vectors[slot]==512&&
    slot_math_pending[slot]==0&&slot_sfu_debt[slot]==0&&slot_fp_debt[slot]==0)begin
   pair_release_valid=1;pair_release_slot=1'(slot);pair_release_s=slot_s[slot];pair_release_consumed=slot_consumed_vectors[slot];pair_release_clear=1;
  end
  pair_discard_valid=discard_valid&&needs_discard&&!active&&!done_valid&&math_idle;
  discard_ready=needs_discard&&!active&&!done_valid&&math_idle&&pair_discard_ready;
  discard_reject_valid=control_enabled&&discard_valid&&(!needs_discard||pair_discard_reject);
  math_clear=cmd_fire||discard_fire;
  all_covered=1;for(int rank=0;rank<8;rank++)if(covered[rank]!=335872)all_covered=0;
 end
 laya_m007_g_pairs_v1 pairs(.clk,.rst_n,.bind_valid,.bind_ready,.bind_request_id(cmd_request_id),.bind_generation(cmd_generation),.bind_epoch(cmd_epoch),
  .bound,.request_id(rsp_request_id),.generation(rsp_generation),.epoch(rsp_epoch),
  .fill_valid(fill_valid&&fill_admit),.fill_ready(pair_fill_ready),.fill_request_id,.fill_generation,.fill_epoch,.fill_slot,.fill_half,.fill_s,.fill_row,.fill_data,.fill_reject_valid(pair_fill_reject),.fill_reject_code(pair_fill_code),
  .rd_valid(bank_req_valid),.rd_ready(bank_req_ready),.rd_request_id(rsp_request_id),.rd_generation(rsp_generation),.rd_epoch(rsp_epoch),.rd_slot(read_index[9]),.rd_s(read_index[15:9]),.rd_row(read_index[8:2]),.rd_chunk(read_index[1:0]),.rd_reject_valid(bank_reject),
  .rd_rsp_valid(bank_rsp_valid),.rd_rsp_ready(bank_rsp_ready),.rd_rsp_slot(bank_rsp_slot),.rd_rsp_s(bank_rsp_s),.rd_rsp_row(bank_rsp_row),.rd_rsp_chunk(bank_rsp_chunk),.rd_rsp_x(bank_x),.rd_rsp_gate(bank_gate),.rd_rsp_tag(bank_tag),
  .release_valid(pair_release_valid),.release_ready(pair_release_ready),.release_request_id(rsp_request_id),.release_generation(rsp_generation),.release_epoch(rsp_epoch),.release_slot(pair_release_slot),.release_s(pair_release_s),.release_consumed_vectors(pair_release_consumed),.release_client_debt_clear(pair_release_clear),.release_reject_valid(pair_release_reject),
  .discard_valid(pair_discard_valid),.discard_ready(pair_discard_ready),.discard_request_id,.discard_generation,.discard_epoch,.discard_client_debt_clear(math_idle),.discard_reject_valid(pair_discard_reject),
  .slot_active,.slot_ready,.slot_s,.issued_vectors(bank_issued),.returned_vectors(bank_returned),.write_pending,.protocol_fault(pair_fault),
  .g_wr_valid,.g_wr_ready,.g_wr_mask,.g_wr_addr,.g_wr_data,.g_wr_tag,.g_wr_rsp_valid,.g_wr_rsp_ready,.g_wr_rsp_tag,
  .g_rd_valid,.g_rd_ready,.g_rd_mask,.g_rd_addr,.g_rd_tag,.g_rd_rsp_valid,.g_rd_rsp_ready,.g_rd_rsp_data,.g_rd_rsp_mask,.g_rd_rsp_tag);
 laya_m007_g_math_v1 #(.EXTERNAL_CONTROL(EXTERNAL_CONTROL)) math(.external_control_enable(control_enabled),.external_control_q,.external_control_next,.control_retired(math_control_retired),.clk,.rst_n,.clear(math_clear),.idle(math_idle),.pool_reset_n,
  .in_valid(bank_rsp_valid&&!math_fault),.in_ready(math_in_ready),.in_tag(math_tag),.in_x(bank_x),.in_gate(bank_gate),
  .out_valid,.out_ready,.out_tag,.out_data,.out_status,
  .fp_req_valid,.fp_req_ready,.fp_req_tag,.fp_req_a,.fp_req_b,.fp_rsp_valid,.fp_rsp_tag,.fp_rsp_data,.fp_rsp_status,
  .fp_pool_fault(fp_pool_fault||sfu_protocol_fault||sfu_reject_valid||bank_reject||pair_release_reject),
  .sfu_req_valid,.sfu_req_ready,.sfu_req_tag,.sfu_req_mask,.sfu_req_x,.sfu_rsp_valid,.sfu_rsp_ready,.sfu_rsp_tag,.sfu_rsp_data,.sfu_rsp_status,
  .pending(math_pending),.slot_pending(slot_math_pending),.slot_sfu_debt,.slot_fp_debt,.covered,.evaluated,
  .first_error_valid(first_error),.first_error_rank(first_rank),.first_error_row(first_row),.first_error_column(first_column),.protocol_fault(math_fault));
 always_ff @(posedge clk)begin
  if(!rst_n)begin
   active<=0;needs_discard<=0;done_valid<=0;done_cancelled<=0;cancel_read_held<=0;cancel_fill_held<=0;done_status<=0;done_error_rank<=0;done_error_row<=0;done_error_column<=0;
   read_index<=0;completed_groups<=0;slot_consumed_vectors<=0;
  end else begin
   if(done_valid&&done_ready)begin done_valid<=0;done_cancelled<=0;end
   if(cmd_fire)begin done_cancelled<=0;cancel_read_held<=0;cancel_fill_held<=0;active<=1;read_index<=0;completed_groups<=0;slot_consumed_vectors<=0;done_status<=0;done_error_rank<=0;done_error_row<=0;done_error_column<=0;end
   // Preserve only external bank requests already published before cancel.
   // Their payload remains supplied by the original stable upstream signals.
   if(cancel_read_held&&g_rd_valid&&g_rd_ready)cancel_read_held<=0;
   if(cancel_fill_held&&g_wr_valid&&g_wr_ready)cancel_fill_held<=0;
   if(producer_cancel_fire)begin
    done_cancelled<=1;
    cancel_read_held<=g_rd_valid&&!g_rd_ready;
    cancel_fill_held<=g_wr_valid&&!g_wr_ready;
   end
   if(bank_req_valid&&bank_req_ready)read_index<=read_index+1'b1;
   if(consume)slot_consumed_vectors[out_tag[9]]<=slot_consumed_vectors[out_tag[9]]+1'b1;
   if(pair_release_fire)begin slot_consumed_vectors[pair_release_slot]<=0;completed_groups<=completed_groups+1'b1;end
   if(active&&math_idle&&math_control_retired&&!write_pending&&bank_issued==bank_returned&&
      !out_valid&&!g_wr_valid&&!g_rd_valid&&!g_wr_rsp_valid&&!g_rd_rsp_valid&&!cancel_read_held&&!cancel_fill_held&&!producer_cancel_fire&&
      (done_cancelled||(read_index==41984&&completed_groups==82&&slot_active==0&&all_covered)||protocol_fault))begin
    active<=0;done_valid<=1;done_status<=protocol_fault?32'd8:(first_error?32'd6:32'd0);needs_discard<=done_cancelled||protocol_fault||first_error;
    done_error_rank<=first_rank;done_error_row<=first_row;done_error_column<=first_column;
   end
   if(discard_fire)begin done_cancelled<=0;cancel_read_held<=0;cancel_fill_held<=0;needs_discard<=0;slot_consumed_vectors<=0;read_index<=0;completed_groups<=0;end
  end
 end
endmodule
