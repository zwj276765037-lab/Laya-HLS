`timescale 1ns/1ps
// Fixed128x1024 op0 H+Q and op1 Q+type -> H. External48 control, no payload/identity FF.
module laya_m007_resident_vector32_v3 #(parameter bit EXTERNAL_CONTROL=0)(
 input logic external_control_enable,input logic[47:0]external_control_q,output logic[47:0]external_control_next,output logic control_private_idle,
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
 output logic type_rd_valid,input logic type_rd_ready,output logic[11:0]type_rd_addr,
 input logic type_rsp_valid,output logic type_rsp_ready,input logic[11:0]type_rsp_addr,input logic[31:0][31:0]type_rsp_data,
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
 typedef enum logic[2:0]{IDLE,LEASE,RUN,RELEASE,DONE,TYPE_LEASE,TYPE_RUN,TYPE_RELEASE}state_t;
 state_t state;
 logic first_error,protocol_error;logic[11:0]error_addr;logic[4:0]error_lane;
 logic nonfinite;logic[4:0]first_bad_lane;
 logic[47:0]q_view,q_next;
 wire control_enabled=!EXTERNAL_CONTROL||external_control_enable;
 generate if(EXTERNAL_CONTROL)begin:external_control
  assign q_view=external_control_q;
 end else begin:local_control
  logic[47:0]control_q;
  assign q_view=control_q;
  always_ff@(posedge clk)begin if(!rst_n)control_q<=0;else control_q<=q_next;end
 end endgenerate
 assign external_control_next=q_next;
 assign state=state_t'(q_view[0+:3]);
 assign issued_vectors=q_view[3+:13];
 assign retired_vectors=q_view[16+:13];
 assign first_error=q_view[29+:1];
 assign protocol_error=q_view[30+:1];
 assign error_addr=q_view[31+:12];
 assign error_lane=q_view[43+:5];

 wire identity=start_request_id==owner_request_id&&start_generation==owner_generation&&start_epoch==owner_epoch;
 wire fp_identity=fp_lease_active&&fp_rsp_request_id==owner_request_id&&fp_rsp_generation==owner_generation&&fp_rsp_epoch==owner_epoch&&fp_rsp_head==0&&fp_rsp_phase==7;
 wire type_mode=state==TYPE_LEASE||state==TYPE_RUN||state==TYPE_RELEASE;
 wire run_state=state==RUN||state==TYPE_RUN;
 wire release_state=state==RELEASE||state==TYPE_RELEASE;
 wire[11:0]pair_addr=type_mode?q_rsp_addr:h_rsp_addr;
 wire read_wanted=control_enabled&&run_state&&issued_vectors<4096&&!first_error&&!protocol_error&&!fp_protocol_fault;
 wire read_fire=type_mode?(type_rd_valid&&type_rd_ready):(h_rd_valid&&h_rd_ready);
 wire pair_valid=type_mode?(q_rsp_valid&&type_rsp_valid):(h_rsp_valid&&q_rsp_valid);
 wire pair_match=type_mode?(q_rsp_addr==type_rsp_addr):(h_rsp_addr==q_rsp_addr);
 wire type_drain_pair=type_mode&&pair_valid&&(protocol_error||!pair_match);
 wire type_drain_fire=type_drain_pair&&q_rsp_ready&&type_rsp_ready;
 wire return_match=add_rsp_tag[0]=={owner_generation,owner_epoch,20'b0,retired_vectors[11:0]}&&fp_identity;
 wire return_fire=add_rsp_valid[0]&&add_rsp_ready[0];
 assign start_ready=control_enabled&&rst_n&&state==IDLE&&owner_valid&&inputs_ready&&!fp_lease_active&&identity&&(start_op==0||(start_op==1&&!h_rsp_valid&&!q_rsp_valid&&!type_rsp_valid));
 assign start_reject_valid=control_enabled&&rst_n&&start_valid&&!start_ready;
 assign idle=control_enabled&&state==IDLE;
 assign control_private_idle=!fp_lease_active&&!h_rsp_valid&&!q_rsp_valid&&!type_rsp_valid&&!h_wr_valid;
 assign control_retired=idle&&control_private_idle&&!(start_valid&&start_ready);
 assign done_valid=control_enabled&&state==DONE;assign done_status=protocol_error?32'd8:(first_error?32'd6:32'd0);
 assign done_error_row=error_addr[11:5];assign done_error_column={error_addr[4:0],error_lane};
 assign fp_lease_valid=control_enabled&&(state==LEASE||state==TYPE_LEASE);assign fp_lease_request_id=owner_request_id;assign fp_lease_generation=owner_generation;assign fp_lease_epoch=owner_epoch;assign fp_lease_head=0;assign fp_lease_phase=7;
 assign fp_release_valid=control_enabled&&release_state;assign fp_release_phase=7;assign fp_release_epoch=owner_epoch;
 assign fp_phase_debt_clear=control_enabled&&release_state&&issued_vectors==retired_vectors&&!h_rsp_valid&&!q_rsp_valid&&!type_rsp_valid;
 assign h_rd_valid=read_wanted&&!type_mode&&q_rd_ready;assign q_rd_valid=read_wanted&&(type_mode?type_rd_ready:h_rd_ready);
 assign type_rd_valid=read_wanted&&type_mode&&q_rd_ready;assign type_rd_addr=issued_vectors[11:0];
 assign h_rd_addr=issued_vectors[11:0];assign q_rd_addr=issued_vectors[11:0];
 assign h_rsp_ready=control_enabled&&state==RUN&&q_rsp_valid&&add_req_ready[0]&&fp_identity;
 assign type_rsp_ready=control_enabled&&state==TYPE_RUN&&q_rsp_valid&&(type_drain_pair||add_req_ready[0])&&fp_identity;
 assign q_rsp_ready=control_enabled&&run_state&&(type_mode?type_rsp_valid:h_rsp_valid)&&(type_drain_pair||add_req_ready[0])&&fp_identity;
 always_comb begin
  add_req_valid=0;add_req_is_root=0;add_req_phase=0;add_req_epoch=0;add_req_tag=0;add_a=0;add_b=0;add_rsp_ready=0;
  add_req_valid[0]=control_enabled&&run_state&&pair_valid&&fp_identity&&(!type_mode||(pair_match&&!protocol_error));add_req_is_root[0]=1;add_req_phase[0]=7;add_req_epoch[0]=owner_epoch;add_req_tag[0]={owner_generation,owner_epoch,20'b0,pair_addr};
  for(int lane=0;lane<32;lane++)begin add_a[lane]=type_mode?q_rsp_data[lane]:h_rsp_data[lane];add_b[lane]=type_mode?type_rsp_data[lane]:q_rsp_data[lane];end
  nonfinite=0;first_bad_lane=0;
  for(int lane=31;lane>=0;lane--)if(add_rsp_data[lane][30:23]==8'hff)begin nonfinite=1;first_bad_lane=5'(lane);end
  add_rsp_ready[0]=control_enabled&&run_state&&(!return_match||nonfinite||(type_mode&&protocol_error)||h_wr_ready);
 end
 assign h_wr_valid=control_enabled&&run_state&&add_rsp_valid[0]&&return_match&&!nonfinite&&!(type_mode&&protocol_error);
 assign h_wr_addr=add_rsp_tag[0][11:0];assign h_wr_data=add_rsp_data[31:0];
 always_comb begin
  q_next=q_view;
  if(control_enabled)begin
  if(!rst_n)begin q_next[0+:3]=IDLE;q_next[3+:13]=0;q_next[16+:13]=0;q_next[29+:1]=0;q_next[30+:1]=0;q_next[31+:12]=0;q_next[43+:5]=0;end
  else begin
   if(start_valid&&start_ready)begin q_next[0+:3]=start_op==1?TYPE_LEASE:LEASE;q_next[3+:13]=0;q_next[16+:13]=0;q_next[29+:1]=0;q_next[30+:1]=0;q_next[31+:12]=0;q_next[43+:5]=0;end
   if(fp_lease_valid&&fp_lease_ready)q_next[0+:3]=state==TYPE_LEASE?TYPE_RUN:RUN;
   if(read_fire)q_next[3+:13]=issued_vectors+1'b1;
   if(run_state&&pair_valid&&add_req_ready[0]&&!pair_match)q_next[30+:1]=1;
   if(run_state&&fp_protocol_fault)q_next[30+:1]=1;
   if(type_drain_fire)begin q_next[30+:1]=1;q_next[16+:13]=retired_vectors+1'b1;end
   if(return_fire)begin
    q_next[16+:13]=retired_vectors+1'b1+13'(type_drain_fire);
    if(!return_match||(h_wr_valid&&!h_wr_commit))q_next[30+:1]=1;
    if(nonfinite&&!first_error)begin q_next[29+:1]=1;q_next[31+:12]=add_rsp_tag[0][11:0];q_next[43+:5]=first_bad_lane;end
   end
   if(run_state&&(issued_vectors==4096||first_error||protocol_error)&&issued_vectors==retired_vectors&&!h_rsp_valid&&!q_rsp_valid&&!type_rsp_valid)q_next[0+:3]=state==TYPE_RUN?TYPE_RELEASE:RELEASE;
   if(fp_release_valid&&fp_release_ready)q_next[0+:3]=DONE;
   if(done_valid&&done_ready)q_next[0+:3]=IDLE;
  end
 end
 end
endmodule
