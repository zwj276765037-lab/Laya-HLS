#!/usr/bin/env python3
"""Public Encoder0 H-load/error/recovery TB preparation; no simulator launch."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[3]
MOD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
old=(MOD/'tb/m007_ffn_parent_tb.sv').read_text()
decl=old[old.index(' logic  clk;'):old.index(' laya_m007_single_parent_v1 dut')]
decl=decl.replace('logic [1:0] cmd_kind;', 'logic [2:0] cmd_kind;').replace('logic [4:0] parent_state;', 'logic [5:0] parent_state;')
extra=''' logic desc_valid,desc_ready;
 logic [63:0] desc_request;
 logic [31:0] desc_generation,desc_source_epoch;
 logic [4:0] desc_global_layer;
 logic desc_pair_kind,desc_slot;
 logic [31:0] desc_tensor;
 logic [3:0][63:0] desc_base,desc_span;
 logic desc_reject_valid;
 logic [3:0] desc_reject_code;
'''
defaults=old[old.rfind(' initial begin')+len(' initial begin'):old.index('  if(!$value$plusargs("FIXTURE=')]
body=r'''
 laya_m007_single_parent_v2 dut(.*);
 always #1 clk=~clk;
 logic [1023:0] original_h[0:4095];
 logic [31:0] cf[0:8191],sf[0:8191];
 integer cycle=0,accepted_h=0,committed_h=0,quant_commands=0,matrix_commands=0,parent_receipts=0;
 integer mode=0,request_h=0,request_writes=0,commands=0,descriptors=0;
 string fixture,attention;
 task automatic step;begin @(posedge clk);#0.1;end endtask
 task automatic send_command;
  begin @(negedge clk);cmd_valid=1;do @(posedge clk);while(!cmd_ready);@(negedge clk);cmd_valid=0;end
 endtask
 task automatic held_result(input logic [7:0] st,src,input logic [2:0] dom,input logic [95:0] tuple);
  logic [242:0] expected;
  begin
   expected={st,src,dom,tuple,cmd_request,cmd_generation,cmd_epoch};
   wait(done_valid);@(negedge clk);
   repeat(5)begin step();if(!done_valid||{done_status,source_status,error_domain,error_tuple,done_request,done_generation,done_epoch}!==expected)$fatal(1,"exact held sourceepoch/error response got status%0d source%0d domain%0d tuple%h expected%h",done_status,source_status,error_domain,error_tuple,tuple);end
   if(!dut.v2_shared_resources_idle||!dut.v2_resident_bank_idle||!dut.v2_scratch_retired||!dut.ws_a_enable)$fatal(1,"failure before actual resources/H/Q retirement");
   @(negedge clk);done_ready=1;step();@(negedge clk);done_ready=0;wait(cmd_ready);
  end
 endtask
 task automatic send_h(input int index,input logic [1023:0] value);
  begin
   @(negedge clk);in_valid=1;in_data=value;in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=index/32;in_group=index%32;
   do @(posedge clk);while(!in_ready);@(negedge clk);in_valid=0;
  end
 endtask
 always_comb begin arready=0;rvalid=0;rid=0;rdata=0;rresp=0;rlast=0;end
 always @(posedge clk)begin
  cycle++;
  if(rst_n)begin
   if(cmd_valid&&cmd_ready)begin commands++;request_h=0;request_writes=0;end
   if(in_valid&&in_ready)begin accepted_h++;request_h++;if(!dut.v2_h_wr_commit||!dut.encoder0_mode||parent_state!=32||dut.operation_epoch!=cmd_epoch)$fatal(1,"public H input without same-edge actual commit/sourceepoch");end
   if(dut.v2_h_wr_commit)begin committed_h++;request_writes++;if(!in_valid||!in_ready||dut.v2_h_wr_addr!=={in_row[6:0],in_group[4:0]}||dut.v2_h_wr_data!==in_data)$fatal(1,"actual ordered H commit bits/coordinate");end
   if(dut.q_cmd_valid&&dut.q_cmd_ready)quant_commands++;
   if(dut.m_cmd_valid&&dut.m_cmd_ready)matrix_commands++;
   if(desc_valid&&desc_ready)descriptors++;
   if(done_valid&&done_ready)parent_receipts++;
   if(arvalid!=0||quant_commands!=0||matrix_commands!=0||descriptors!=0)$fatal(1,"bounded H test unexpectedly started arithmetic/descriptor consumers");
   if(cycle%256==0)begin $display("M007_PARENT_CHECKED checked=%0d phase=H_PUBLIC cycle=%0d",committed_h*32,cycle);$fflush();end
   if(cycle>40000000)$fatal(1,"40Mcycle watchdog");
  end
 end
 initial begin
__DEFAULTS__
  desc_valid=0;desc_request=0;desc_generation=0;desc_source_epoch=0;desc_global_layer=0;desc_pair_kind=0;desc_slot=0;desc_tensor=0;desc_base=0;desc_span=0;
  if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"original fixture required");
  if(!$value$plusargs("ATTENTION=%s",attention))$fatal(1,"original coefficient source required");
  if(!$value$plusargs("MODE=%d",mode))mode=0;
  if(mode<0||mode>3)$fatal(1,"mode0 first nonfinite,1 producer failure,2 last nonfinite,3 wrongepoch then first nonfinite");
  $readmemh({fixture,"/embedding_norm.groups1024.hex"},original_h);
  $readmemh({attention,"/cos_full.mem"},cf);$readmemh({attention,"/sin_full.mem"},sf);
  cmd_request=77;cmd_generation=8;cmd_epoch=9;cmd_kind=4;cmd_layer=0;cmd_mask='1;
  cmd_model_id=128'h6eb6ef58bc4f99bd9db40381604108af;cmd_numeric_id=128'haeb13e7937d29fe6a2c68c407249f294;cmd_table_key=128'hb1fdc9ca482c0210982c7245cc50c965;cmd_graph_id=128'hf33f7848434b73048f957dcd232e1bd4;cmd_layout_id=128'h2d848b5fb78236c795cb1d442f088393;
  cmd_build_id=128'hd92a1f8e927c3051289016db36f20d27;cmd_tensor[0]=4;cmd_tensor[1]=32;
  for(int p=0;p<4;p++)begin cmd_base[0][p]=64'h100000000+64'h10000000*p;cmd_span[0][p]=884736;cmd_base[1][p]=64'h200000000+64'h10000000*p;cmd_span[1][p]=294912;end
  repeat(4)step();@(negedge clk);rst_n=1;
  // Invalid kinds and old/new ABI cross-use must have no actual input/compute.
  wait(cmd_ready);cmd_build_id=128'h7209eb09c3f265363cfb274f7790a733;send_command();held_result(4,0,1,0);
  cmd_kind=3;cmd_tensor[0]=60;cmd_tensor[1]=88;cmd_build_id=128'hd92a1f8e927c3051289016db36f20d27;send_command();held_result(4,0,1,0);
  cmd_kind=5;send_command();held_result(4,0,1,0);
  if(accepted_h!=0||committed_h!=0)$fatal(1,"identity rejection touched H");
  cmd_kind=4;cmd_tensor[0]=4;cmd_tensor[1]=32;
  coeff_bind_model_id=cmd_model_id;coeff_bind_numeric_id=cmd_numeric_id;coeff_bind_table_key=cmd_table_key;coeff_wr_model_id=cmd_model_id;coeff_wr_numeric_id=cmd_numeric_id;coeff_wr_table_key=cmd_table_key;
  @(negedge clk);coeff_bind_valid=1;do @(posedge clk);while(!coeff_bind_ready);@(negedge clk);coeff_bind_valid=0;
  for(int t=0;t<2;t++)for(int r=0;r<128;r++)for(int half=0;half<2;half++)begin
   coeff_wr_valid=1;coeff_wr_table=t;coeff_wr_row=r;coeff_wr_half=half;for(int c=0;c<32;c++)coeff_wr_data[c]=t?sf[r*64+half*32+c]:cf[r*64+half*32+c];#0.1;if(!coeff_wr_ready||coeff_wr_reject_valid)$fatal(1,"real original coeff load");@(posedge clk);@(negedge clk);
  end
  coeff_wr_valid=0;wait(coeff_family_complete[0]);send_command();wait(parent_state==32);
  // A descriptor offered while the first pair is still owned is rejected.
  @(negedge clk);desc_valid=1;desc_request=cmd_request;desc_generation=cmd_generation;desc_source_epoch=cmd_epoch;desc_global_layer=0;desc_pair_kind=1;desc_slot=0;desc_tensor=60;
  repeat(3)begin #0.1;if(desc_ready||!desc_reject_valid||desc_reject_code!=1)$fatal(1,"early refill accepted");step();end
  @(negedge clk);desc_valid=0;
  if(mode==1)begin
   producer_fail_request=cmd_request;producer_fail_generation=cmd_generation;producer_fail_epoch=cmd_epoch;producer_fail_tuple=96'h123456789abcdef012345678;
   @(negedge clk);producer_fail_valid=1;do @(posedge clk);while(!producer_fail_ready);@(negedge clk);producer_fail_valid=0;
   held_result(3,3,2,96'h123456789abcdef012345678);
   if(request_h!=0||request_writes!=0)$fatal(1,"producer failure published H");
  end else begin
   if(mode==3)begin
    @(negedge clk);in_valid=1;in_data=original_h[0];in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch+1;in_row=0;in_group=0;
    repeat(3)begin #0.1;if(in_ready||!input_reject_valid||input_reject_code!=4||dut.v2_h_wr_commit)$fatal(1,"wrong sourceepoch accepted");step();end
    @(negedge clk);in_valid=0;
   end
   if(mode==2)for(int i=0;i<4095;i++)send_h(i,original_h[i]);
   begin
    logic [1023:0] bad;logic [95:0] tuple;int index;
    index=mode==2?4095:0;bad=original_h[index];bad[32*5+:32]=32'h7f800000;bad[32*19+:32]=32'h7fc00001;
    tuple={8'h80,3'(index/512),2'b0,4'((index/32)%16),4'b0,4'b0,10'((index%32)*32+5),4'b0,8'b0,49'b0};
    send_h(index,bad);held_result(1,6,7,tuple);
    if(request_h!=index+1||request_writes!=index+1)$fatal(1,"bad H ordered actual prefix count");
   end
  end
  $display("M007_ENCODER0_PUBLIC_ERROR_PASS mode=%0d request_h=%0d committed=%0d receipts=%0d",mode,request_h,request_writes,parent_receipts);$fflush();
  // No reset: every address must be reloaded through the public H input.
  cmd_request=78;cmd_generation=9;cmd_epoch=10;send_command();wait(parent_state==32);
  for(int i=0;i<4096;i++)send_h(i,original_h[i]);
  if(parent_state!=33||dut.inputs_accepted!=4096||request_h!=4096||request_writes!=4096||done_valid||!dut.v2_h_bank_idle)$fatal(1,"actual complete H/newgen qualification boundary");
  $display("M007_ENCODER0_H_PREFIX_PASS mode=%0d real_H=4096 request=%0d generation=%0d sourceepoch=%0d unfinished=1 cycle=%0d",mode,cmd_request,cmd_generation,cmd_epoch,cycle);$display("HARDWARE_AGENT_SIM_PASS M007_ENCODER0_PUBLIC_H_PREFIX");$fflush();$finish;
 end
endmodule
'''.replace('__DEFAULTS__',defaults)
# AXI slave idle is driven by one comb process, not also by initial values.
body=body.replace("  rvalid='0;\n  rid='0;\n  rdata='0;\n  rresp='0;\n  rlast='0;\n",'')
s='`timescale 1ns/1ps\nmodule m007_encoder0_public_tb;\n'+decl+extra+body
out=MOD/'tb/m007_encoder0_public_tb.sv';out.write_text(s)
r={'scope':'New public H/identity/finite/error/noreset inputprefix only; no math or completeEncoder proof','sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'status':'SOURCE_PREPARED_NOT_COMPILED_NOT_RUN','modes':[0,1,2,3],'source':str(out.relative_to(ROOT))}
(ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R006/reports/public_tb_generation.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r))
