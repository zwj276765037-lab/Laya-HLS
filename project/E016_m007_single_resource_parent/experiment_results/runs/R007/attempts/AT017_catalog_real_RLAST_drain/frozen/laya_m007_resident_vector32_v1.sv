`timescale 1ns/1ps
// Fixed128x1024 residual, H+Qscratch -> H. No FP/payload/identity storage.
module laya_m007_resident_vector32_v1(
 input logic clk,rst_n,owner_valid,inputs_ready,
 input logic[63:0]owner_request_id,input logic[31:0]owner_generation,owner_epoch,
 input logic start_valid,output logic start_ready,input logic[1:0]start_op,
 input logic[63:0]start_request_id,input logic[31:0]start_generation,start_epoch,
 output logic start_reject_valid,done_valid,input logic done_ready,
 output logic[31:0]done_status,output logic[6:0]done_error_row,output logic[9:0]done_error_column,
 output logic idle,control_retired,output logic[12:0]issued_vectors,retired_vectors,
 output logic h_rd_valid,input logic h_rd_ready,output logic[11:0]h_rd_addr,
 input logic h_rsp_valid,output logic h_rsp_ready,input logic[11:0]h_rsp_addr,input logic[31:0][31:0]h_rsp_data,
 output logic q_rd_valid,input logic q_rd_ready,output logic[11:0]q_rd_addr,
 input logic q_rsp_valid,output logic q_rsp_ready,input logic[11:0]q_rsp_addr,input logic[31:0][31:0]q_rsp_data,
 output logic h_wr_valid,input logic h_wr_ready,output logic[11:0]h_wr_addr,output logic[31:0][31:0]h_wr_data,input logic h_wr_commit,
 output logic fp_lease_valid,input logic fp_lease_ready,
 output logic[63:0]fp_lease_request_id,output logic[31:0]fp_lease_generation,fp_lease_epoch,
 output logic[3:0]fp_lease_head,output logic[2:0]fp_lease_phase,
 output logic fp_release_valid,input logic fp_release_ready,output logic[2:0]fp_release_phase,output logic[31:0]fp_release_epoch,output logic fp_phase_debt_clear,
 input logic fp_lease_active,input logic[63:0]fp_rsp_request_id,input logic[31:0]fp_rsp_generation,fp_rsp_epoch,input logic[3:0]fp_rsp_head,input logic[2:0]fp_rsp_phase,input logic fp_protocol_fault,
 output logic[6:0]add_req_valid,add_req_is_root,input logic[6:0]add_req_ready,
 output logic[6:0][2:0]add_req_phase,output logic[6:0][31:0]add_req_epoch,output logic[6:0][95:0]add_req_tag,
 output logic[255:0][31:0]add_a,add_b,
 input logic[6:0]add_rsp_valid,output logic[6:0]add_rsp_ready,input logic[6:0][95:0]add_rsp_tag,input logic[255:0][31:0]add_rsp_data
);
 typedef enum logic[2:0]{IDLE,LEASE,RUN,RELEASE,DONE}state_t;
 state_t state;
 logic first_error,protocol_error;logic[11:0]error_addr;logic[4:0]error_lane;
 logic nonfinite;logic[4:0]first_bad_lane;
 wire identity=start_request_id==owner_request_id&&start_generation==owner_generation&&start_epoch==owner_epoch;
 wire fp_identity=fp_lease_active&&fp_rsp_request_id==owner_request_id&&fp_rsp_generation==owner_generation&&fp_rsp_epoch==owner_epoch&&fp_rsp_head==0&&fp_rsp_phase==7;
 wire read_wanted=state==RUN&&issued_vectors<4096&&!first_error&&!protocol_error&&!fp_protocol_fault;
 wire read_fire=h_rd_valid&&h_rd_ready;
 wire pair_valid=h_rsp_valid&&q_rsp_valid;
 wire pair_match=h_rsp_addr==q_rsp_addr;
 wire return_match=add_rsp_tag[0]=={owner_generation,owner_epoch,20'b0,retired_vectors[11:0]}&&fp_identity;
 wire return_fire=add_rsp_valid[0]&&add_rsp_ready[0];
 assign start_ready=rst_n&&state==IDLE&&owner_valid&&inputs_ready&&!fp_lease_active&&identity&&start_op==0;
 assign start_reject_valid=rst_n&&start_valid&&!start_ready;
 assign idle=state==IDLE;assign control_retired=idle&&!fp_lease_active&&!h_rsp_valid&&!q_rsp_valid;
 assign done_valid=state==DONE;assign done_status=protocol_error?32'd8:(first_error?32'd6:32'd0);
 assign done_error_row=error_addr[11:5];assign done_error_column={error_addr[4:0],error_lane};
 assign fp_lease_valid=state==LEASE;assign fp_lease_request_id=owner_request_id;assign fp_lease_generation=owner_generation;assign fp_lease_epoch=owner_epoch;assign fp_lease_head=0;assign fp_lease_phase=7;
 assign fp_release_valid=state==RELEASE;assign fp_release_phase=7;assign fp_release_epoch=owner_epoch;
 assign fp_phase_debt_clear=state==RELEASE&&issued_vectors==retired_vectors&&!h_rsp_valid&&!q_rsp_valid;
 assign h_rd_valid=read_wanted&&q_rd_ready;assign q_rd_valid=read_wanted&&h_rd_ready;
 assign h_rd_addr=issued_vectors[11:0];assign q_rd_addr=issued_vectors[11:0];
 assign h_rsp_ready=state==RUN&&q_rsp_valid&&add_req_ready[0]&&fp_identity;
 assign q_rsp_ready=state==RUN&&h_rsp_valid&&add_req_ready[0]&&fp_identity;
 always_comb begin
  add_req_valid=0;add_req_is_root=0;add_req_phase=0;add_req_epoch=0;add_req_tag=0;add_a=0;add_b=0;add_rsp_ready=0;
  add_req_valid[0]=state==RUN&&pair_valid&&fp_identity;add_req_is_root[0]=1;add_req_phase[0]=7;add_req_epoch[0]=owner_epoch;add_req_tag[0]={owner_generation,owner_epoch,20'b0,h_rsp_addr};
  for(int lane=0;lane<32;lane++)begin add_a[lane]=h_rsp_data[lane];add_b[lane]=q_rsp_data[lane];end
  nonfinite=0;first_bad_lane=0;
  for(int lane=31;lane>=0;lane--)if(add_rsp_data[lane][30:23]==8'hff)begin nonfinite=1;first_bad_lane=5'(lane);end
  add_rsp_ready[0]=state==RUN&&(!return_match||nonfinite||h_wr_ready);
 end
 assign h_wr_valid=state==RUN&&add_rsp_valid[0]&&return_match&&!nonfinite;
 assign h_wr_addr=add_rsp_tag[0][11:0];assign h_wr_data=add_rsp_data[31:0];
 always_ff @(posedge clk)begin
  if(!rst_n)begin state<=IDLE;issued_vectors<=0;retired_vectors<=0;first_error<=0;protocol_error<=0;error_addr<=0;error_lane<=0;end
  else begin
   if(start_valid&&start_ready)begin state<=LEASE;issued_vectors<=0;retired_vectors<=0;first_error<=0;protocol_error<=0;error_addr<=0;error_lane<=0;end
   if(fp_lease_valid&&fp_lease_ready)state<=RUN;
   if(read_fire)issued_vectors<=issued_vectors+1'b1;
   if(state==RUN&&pair_valid&&add_req_ready[0]&&!pair_match)protocol_error<=1;
   if(state==RUN&&fp_protocol_fault)protocol_error<=1;
   if(return_fire)begin
    retired_vectors<=retired_vectors+1'b1;
    if(!return_match||(h_wr_valid&&!h_wr_commit))protocol_error<=1;
    if(nonfinite&&!first_error)begin first_error<=1;error_addr<=add_rsp_tag[0][11:0];error_lane<=first_bad_lane;end
   end
   if(state==RUN&&(issued_vectors==4096||first_error||protocol_error)&&issued_vectors==retired_vectors&&!h_rsp_valid&&!q_rsp_valid)state<=RELEASE;
   if(fp_release_valid&&fp_release_ready)state<=DONE;
   if(done_valid&&done_ready)state<=IDLE;
  end
 end
endmodule
