`timescale 1ns/1ps
// Real synchronous H -> canonical LN -> Qscratch adapter. No payload or
// request-identity storage; parent context remains held through terminal consume.
// source_success_valid is wired by production composition to an actually
// completed finite producer, never a command constant or saved checker tensor.
module laya_m007_resident_ln32_v1(
 input logic clk,rst_n,control_enable,source_success_valid,source_invalidate,
 input logic[63:0]owner_request_id,input logic[31:0]owner_generation,owner_epoch,
 input logic start_valid,output logic start_ready,input logic[7:0]rows,
 input logic use_gamma,input logic[63:0]model,input logic[31:0]key,
 output logic done_valid,input logic done_ready,output logic[31:0]done_status,
 output logic[1:0]done_kind,output logic idle,control_retired,source_qualified,
 output logic[12:0]issued_vectors,written_vectors,
 output logic h_rd_valid,input logic h_rd_ready,output logic[11:0]h_rd_addr,
 input logic h_rsp_valid,output logic h_rsp_ready,input logic[11:0]h_rsp_addr,input logic[31:0][31:0]h_rsp_data,
 output logic q_wr_valid,input logic q_wr_ready,output logic[11:0]q_wr_addr,
 output logic[31:0][31:0]q_wr_data,input logic q_wr_commit,
 output logic ln_cmd_valid,input logic ln_cmd_ready,output logic[63:0]ln_cmd_request_id,
 output logic[31:0]ln_cmd_generation,ln_cmd_epoch,output logic[7:0]ln_cmd_rows,
 output logic ln_cmd_gamma,output logic[63:0]ln_cmd_model,output logic[31:0]ln_cmd_key,
 output logic ln_source_finite_qualified,
 output logic ln_in_valid,input logic ln_in_ready,output logic[63:0]ln_in_request_id,
 output logic[31:0]ln_in_generation,ln_in_epoch,output logic[6:0]ln_in_row,
 output logic[4:0]ln_in_chunk,output logic[95:0]ln_in_tag,output logic[31:0][31:0]ln_in_data,
 input logic ln_out_valid,output logic ln_out_ready,input logic[63:0]ln_out_request_id,
 input logic[31:0]ln_out_generation,ln_out_epoch,input logic[6:0]ln_out_row,
 input logic[4:0]ln_out_chunk,input logic[95:0]ln_out_tag,input logic[31:0][31:0]ln_out_data,
 input logic ln_done_valid,output logic ln_done_ready,input logic[1:0]ln_done_kind,
 input logic ln_debt_clear,ln_cancel_accepted,ln_reject_accepted,
 output logic protocol_cancel_valid,input logic protocol_cancel_ready,
 output logic fp_lease_valid,input logic fp_lease_ready,
 output logic div_lease_valid,input logic div_lease_ready,
 output logic bank_bind_valid,input logic bank_bind_ready,
 output logic[63:0]lease_request_id,output logic[31:0]lease_generation,lease_epoch,
 output logic[3:0]lease_head,output logic[2:0]lease_phase,
 output logic fp_release_valid,input logic fp_release_ready,
 output logic div_release_valid,input logic div_release_ready,
 output logic phase_debt_clear,input logic fp_active,div_active,bank_idle
);
 typedef enum logic[2:0]{IDLE,LEASE,CMD,RUN,RELEASE,DONE}state_t;
 state_t state;
 logic source_witness,provider_protocol_error;logic[1:0]terminal_kind;
 wire enabled=rst_n&&control_enable;
 wire cancelled=terminal_kind==3;
 wire valid_rows=rows!=0&&rows<=128;
 wire[12:0]target_vectors={rows,5'b0};
 wire in_location_valid=h_rsp_addr[11:5]<rows;
 wire out_identity=ln_out_request_id==owner_request_id&&ln_out_generation==owner_generation&&ln_out_epoch==owner_epoch&&ln_out_row<rows&&ln_out_tag=={16'h4c4e,owner_epoch,owner_generation,ln_out_row,ln_out_chunk,4'b0};
 wire drain_input=provider_protocol_error||cancelled||ln_done_valid;
 wire actual_h_read=h_rd_valid&&h_rd_ready;
 wire actual_q_write=q_wr_valid&&q_wr_ready;
 wire terminal_fire=ln_done_valid&&ln_done_ready;
 wire actual_idle=!fp_active&&!div_active&&bank_idle&&!h_rsp_valid&&!q_wr_valid;
 assign source_qualified=source_witness;
 assign idle=state==IDLE;
 assign control_retired=enabled&&idle&&actual_idle&&!(start_valid&&start_ready);
 assign start_ready=enabled&&state==IDLE&&source_witness&&valid_rows&&actual_idle;
 assign done_valid=enabled&&state==DONE;
 assign done_kind=provider_protocol_error?2'd2:terminal_kind;
 assign done_status=provider_protocol_error||terminal_kind==2?32'd8:terminal_kind==1?32'd6:32'd0;
 assign lease_request_id=owner_request_id;assign lease_generation=owner_generation;assign lease_epoch=owner_epoch;assign lease_head=0;assign lease_phase=6;
 // One atomic ownership event; no service may acquire one side alone.
 assign fp_lease_valid=enabled&&state==LEASE&&div_lease_ready&&bank_bind_ready;
 assign div_lease_valid=enabled&&state==LEASE&&fp_lease_ready&&bank_bind_ready;
 assign bank_bind_valid=enabled&&state==LEASE&&fp_lease_ready&&div_lease_ready;
 assign phase_debt_clear=state==RELEASE&&ln_debt_clear&&bank_idle&&!h_rsp_valid&&!ln_out_valid&&!q_wr_valid;
 assign fp_release_valid=enabled&&state==RELEASE&&div_release_ready&&phase_debt_clear;
 assign div_release_valid=enabled&&state==RELEASE&&fp_release_ready&&phase_debt_clear;
 assign ln_cmd_valid=enabled&&state==CMD;
 assign ln_cmd_request_id=owner_request_id;assign ln_cmd_generation=owner_generation;assign ln_cmd_epoch=owner_epoch;assign ln_cmd_rows=rows;assign ln_cmd_gamma=use_gamma;assign ln_cmd_model=model;assign ln_cmd_key=key;assign ln_source_finite_qualified=source_witness;
 assign h_rd_valid=enabled&&state==RUN&&!drain_input&&issued_vectors<target_vectors;
 assign h_rd_addr=issued_vectors[11:0];
 assign ln_in_valid=enabled&&state==RUN&&h_rsp_valid&&!drain_input&&in_location_valid;
 assign ln_in_request_id=owner_request_id;assign ln_in_generation=owner_generation;assign ln_in_epoch=owner_epoch;
 assign ln_in_row=h_rsp_addr[11:5];assign ln_in_chunk=h_rsp_addr[4:0];assign ln_in_tag={16'h4c4e,owner_epoch,owner_generation,h_rsp_addr,4'b0};assign ln_in_data=h_rsp_data;
 assign h_rsp_ready=enabled&&state==RUN&&(drain_input||!in_location_valid||ln_in_ready);
 assign q_wr_valid=enabled&&state==RUN&&ln_out_valid&&out_identity;
 assign q_wr_addr={ln_out_row,ln_out_chunk};assign q_wr_data=ln_out_data;
 assign ln_out_ready=enabled&&state==RUN&&(!out_identity||q_wr_ready);
 assign ln_done_ready=enabled&&state==RUN&&!h_rsp_valid&&!ln_out_valid&&bank_idle;
 assign protocol_cancel_valid=enabled&&state==RUN&&provider_protocol_error&&!ln_done_valid;
 always_ff@(posedge clk)begin
  if(!rst_n)begin state<=IDLE;source_witness<=0;provider_protocol_error<=0;terminal_kind<=0;issued_vectors<=0;written_vectors<=0;end
  else begin
   // This witness deliberately survives arena rearm; no identity copy is made.
   // Parent invalidation is legal only before a new operation in true IDLE.
   if(source_invalidate&&state==IDLE)source_witness<=0;
   if(source_success_valid&&state==IDLE)source_witness<=1;
   if(start_valid&&start_ready)begin state<=LEASE;issued_vectors<=0;written_vectors<=0;provider_protocol_error<=0;terminal_kind<=0;end
   if(enabled&&state==LEASE&&fp_lease_ready&&div_lease_ready&&bank_bind_ready)state<=CMD;
   if(ln_cmd_valid&&ln_cmd_ready)state<=RUN;
   if(actual_h_read)issued_vectors<=issued_vectors+1'b1;
   if(actual_q_write)begin written_vectors<=written_vectors+1'b1;if(!q_wr_commit)provider_protocol_error<=1;end
   if(enabled&&state==CMD&&ln_reject_accepted)begin provider_protocol_error<=1;terminal_kind<=2;state<=RELEASE;end
   if(enabled&&state==RUN)begin
    if(ln_reject_accepted)provider_protocol_error<=1;
    if((h_rsp_valid&&!in_location_valid)||(ln_out_valid&&!out_identity))provider_protocol_error<=1;
    if(ln_cancel_accepted)terminal_kind<=3;
   end
   if(terminal_fire)begin
    terminal_kind<=ln_done_kind;
    if(ln_done_kind==0&&(issued_vectors!=target_vectors||written_vectors!=target_vectors))provider_protocol_error<=1;
    state<=RELEASE;
   end
   if(enabled&&state==RELEASE&&fp_release_ready&&div_release_ready&&phase_debt_clear)state<=DONE;
   if(done_valid&&done_ready)begin state<=IDLE;source_witness<=0;end
  end
 end
endmodule
