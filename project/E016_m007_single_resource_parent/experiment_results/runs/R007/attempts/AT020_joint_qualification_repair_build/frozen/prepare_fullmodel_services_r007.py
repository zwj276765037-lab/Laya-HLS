#!/usr/bin/env python3
"""Create compatible successors only; frozen v1 sources are read-only."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[3]
M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design'
R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007'
def sub(s,a,b):
 assert a in s,a[:100]
 return s.replace(a,b)
def save(rel,s):
 p=M/rel;p.write_text(s);return {'path':str(p.relative_to(ROOT)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
versions=[]
s=(M/'hbm_loader_and_cache/rtl/laya_m007_w_reader_v1.sv').read_text()
s=sub(s,'module laya_m007_w_reader_v1(','module laya_m007_w_reader_v2(')
s=sub(s,'output logic [31:0] accepted_ar,accepted_r','output logic [31:0] accepted_ar,accepted_r,\n output logic transport_idle')
s=sub(s,' integer i;integer live;',' integer i;integer live;\n assign transport_idle=!rst&&!active&&busy==0&&complete==0&&!out_valid&&!arvalid&&inflight==0;')
s=sub(s,'if(received[rid]+1==wanted[rid])complete[rid]<=1;', 'if(rlast)begin complete[rid]<=1;if(received[rid]+1<wanted[rid])wanted[rid]<=received[rid]+1;end')
s=sub(s,'if(!busy[rid]||complete[rid]||received[rid]>=wanted[rid])errors[1]<=1;', 'if(!busy[rid]||complete[rid]||received[rid]>=wanted[rid])begin errors[1]<=1;if(busy[rid]&&!complete[rid]&&rlast)complete[rid]<=1;end')
versions.append(save('hbm_loader_and_cache/rtl/laya_m007_w_reader_v2.sv',s))
s=(M/'hbm_loader_and_cache/rtl/laya_m007_w_supply_v1.sv').read_text()
s=sub(s,'module laya_m007_w_supply_v1(','module laya_m007_w_supply_v2(')
s=sub(s,'output logic release_ready,output logic [1:0] slot_valid,slot_leased','output logic release_ready,output logic [1:0] slot_valid,slot_leased,\n output logic transport_idle')
s=sub(s,' logic loading,start_readers;',' logic [3:0] reader_idle;\n logic loading,start_readers;')
s=sub(s,' always_comb begin',' assign transport_idle=!rst&&!loading&&!start_readers&&!load_rsp_valid&&(&reader_idle)&&!read_pending&&!rd_rsp_valid&&!borrowed&&slot_leased==0&&stream_valid==0&&arvalid==0;\n always_comb begin')
s=sub(s,'laya_m007_w_reader_v1 reader(','laya_m007_w_reader_v2 reader(.transport_idle(reader_idle[p]),')
versions.append(save('hbm_loader_and_cache/rtl/laya_m007_w_supply_v2.sv',s))
s=(M/'q8_linear_and_restore/rtl/laya_m007_matrix_facade_v1.sv').read_text()
s=sub(s,'module laya_m007_matrix_facade_v1 #(parameter bit PROFILE_ENABLE=0)(','module laya_m007_matrix_facade_v2 #(parameter bit PROFILE_ENABLE=0,parameter bit CANONICAL_MODEL=0,parameter logic[63:0] CANONICAL_MODEL_ID=0)(')
s=sub(s,' input logic run_enable,',' input logic model_committed,\n input logic bias_word_valid,output logic bias_word_ready,input logic[9:0] bias_word_index,input logic[31:0][31:0] bias_word_data,\n output logic transport_idle,\n input logic run_enable,')
a=s.index(' logic [63:0][31:0] coeff_words');b=s.index(' assign out_request',a)
s=s[:a]+''' logic descriptor_ok;logic [64:0] needed,last_byte;
 logic coef_binding_ok,coef_idle,bias_available;
 logic[63:0][31:0] core_bias_data;
 logic w_transport_idle;
 assign transport_idle=rst_n&&!active&&!done_valid&&!load_pending&&!wl_rsp_valid&&w_transport_idle&&a_read_debt==0&&a_slot_leased==0&&slot_in_use==0&&arvalid==0&&coef_idle;
 generate if(CANONICAL_MODEL)begin:canonical
  // Exactly288x64F32 persistent bias words. No legacy coefficients elaborate.
  (* ram_style="block" *) logic[63:0][31:0] words[0:287];
  logic response_valid;
  logic[63:0][31:0] response_data;
  function automatic logic[8:0] row_base(input logic[31:0] t);
   case(t)117:return 0;121:return 48;125:return 64;129:return 128;
    119:return 144;123:return 192;127:return 208;131:return 272;
    default:return 9'd511;endcase
  endfunction
  function automatic logic legal_shape(input logic[31:0] t,input logic[15:0] ck,cn);
   case(t)117,119:return ck==1024&&cn==3072;121,123:return ck==1024&&cn==1024;
    125,127:return ck==1024&&cn==4096;129,131:return ck==4096&&cn==1024;
    default:return 0;endcase
  endfunction
  assign coef_binding_ok=model_committed&&cmd_model==CANONICAL_MODEL_ID&&legal_shape(cmd_tensor,cmd_k,cmd_n);
  assign coef_idle=!response_valid;
  assign bias_available=!bias||response_valid;
  assign core_bias_data=response_data;
  assign bias_word_ready=rst_n&&!model_committed&&!active&&!done_valid&&!response_valid&&bias_word_index<576;
  assign coef_cfg_ready=0;assign coef_wr_ready=0;assign coef_rsp_valid=0;assign coef_status=0;assign coef_error_col=0;
  always_ff@(posedge clk)begin
   if(!rst_n)response_valid<=0;
   else begin
    if(bias_word_valid&&bias_word_ready)for(int lane=0;lane<32;lane++)words[bias_word_index[9:1]][32*bias_word_index[0]+lane]<=bias_word_data[lane];
    if(response_valid&&(aborting||!active||core_cmd_valid&&core_cmd_ready))response_valid<=0;
    // issue_next remains fixed until the actual core command handshake.
    if(active&&!aborting&&bias&&!response_valid&&issue_next<total_blocks&&slot_ready[issue_next[0]]&&slot_s[issue_next[0]]==issue_next)begin
     response_data<=words[row_base(tensor)+9'(issue_next)];response_valid<=1;
    end
   end
  end
 end else begin:legacy
  logic[63:0][31:0] coeff_words[0:63];logic coeff_busy,coeff_valid,coeff_bad;
  logic[127:0] coeff_coverage;logic[7:0] coeff_count;
  logic[63:0] coeff_model,coeff_request;logic[31:0] coeff_tensor,coeff_generation,coeff_epoch;logic[15:0] coeff_n;
  logic coef_cycle_bad;logic[15:0] coef_cycle_col;
  assign coef_binding_ok=coeff_valid&&coeff_model==cmd_model&&coeff_tensor==cmd_tensor&&coeff_request==cmd_request&&coeff_generation==cmd_generation&&coeff_epoch==cmd_epoch&&coeff_n==cmd_n;
  assign coef_idle=!coeff_busy&&!coef_rsp_valid;
  assign bias_available=1;assign core_bias_data=coeff_words[issue_next[5:0]];
  assign bias_word_ready=0;
  assign coef_cfg_ready=rst_n&&!active&&!coeff_busy&&!coef_rsp_valid;
  assign coef_wr_ready=rst_n&&coeff_busy&&coef_wr_addr<(coeff_n>>5);
  always_ff@(posedge clk)begin
   if(!rst_n)begin
    coeff_busy<=0;coeff_valid<=0;coeff_bad<=0;coeff_coverage<=0;coeff_count<=0;coeff_model<=0;coeff_request<=0;coeff_tensor<=0;coeff_generation<=0;coeff_epoch<=0;coeff_n<=0;coef_rsp_valid<=0;coef_status<=0;coef_error_col<=0;
   end else begin
    coef_cycle_bad=0;coef_cycle_col=65535;
    if(coef_rsp_valid&&coef_rsp_ready)coef_rsp_valid<=0;
    if(coef_cfg_valid&&coef_cfg_ready)begin
     coeff_valid<=0;coeff_bad<=0;coeff_coverage<=0;coeff_count<=0;coeff_model<=coef_model;coeff_request<=coef_request;coeff_tensor<=coef_tensor;coeff_generation<=coef_generation;coeff_epoch<=coef_epoch;coeff_n<=coef_n;coef_status<=0;coef_error_col<=0;
     if(coef_n==1024||coef_n==3072||coef_n==4096)coeff_busy<=1;else begin coef_rsp_valid<=1;coef_status<=1;end
    end
    if(coef_wr_valid&&coef_wr_ready)begin
     for(int lane=0;lane<32;lane++)begin
      coeff_words[coef_wr_addr[6:1]][32*coef_wr_addr[0]+lane]<=coef_wr_data[lane];
      if(coef_wr_data[lane][30:23]==255)begin coef_cycle_bad=1;if(32*coef_wr_addr+lane<coef_cycle_col)coef_cycle_col=32*coef_wr_addr+lane;end
     end
     if(coef_cycle_bad)begin coeff_bad<=1;coef_status<=2;if(!coeff_bad||coef_cycle_col<coef_error_col)coef_error_col<=coef_cycle_col;end
     if(coeff_coverage[coef_wr_addr])begin coeff_bad<=1;coef_status<=1;end
     else begin coeff_coverage[coef_wr_addr]<=1;coeff_count<=coeff_count+1;end
     if(!coeff_coverage[coef_wr_addr]&&coeff_count+1==(coeff_n>>5))begin coeff_busy<=0;coef_rsp_valid<=1;coeff_valid<=!coeff_bad&&!coef_cycle_bad;end
    end
   end
  end
 end endgenerate
''' +s[b:]
s=sub(s,'if(cmd_bias)descriptor_ok=descriptor_ok&&coeff_valid&&coeff_model==cmd_model&&coeff_tensor==cmd_tensor&&coeff_request==cmd_request&&coeff_generation==cmd_generation&&coeff_epoch==cmd_epoch&&coeff_n==cmd_n;','if(cmd_bias)descriptor_ok=descriptor_ok&&coef_binding_ok;')
s=sub(s,'cmd_ready=rst_n&&!active&&!done_valid&&!coeff_busy&&!coef_rsp_valid;','cmd_ready=rst_n&&!active&&!done_valid&&coef_idle;')
s=sub(s,'  coef_cfg_ready=rst_n&&!active&&!coeff_busy&&!coef_rsp_valid;coef_wr_ready=rst_n&&coeff_busy&&coef_wr_addr<(coeff_n>>5);\n','')
s=sub(s,'core_cmd_valid=active&&!aborting&&issue_next','core_cmd_valid=active&&!aborting&&bias_available&&issue_next')
s=sub(s,'.cmd_bias_data(coeff_words[issue_next[5:0]])','.cmd_bias_data(core_bias_data)')
# Delete legacy FF assignments from the original main process, leaving generate branch sole owner.
a=s.index('   coeff_busy<=0;',s.index(' laya_m007_matrix_engine_v1'));b=s.index('\n',a);s=s[:a]+s[b+1:]
s=sub(s,'   coef_cycle_bad=0;coef_cycle_col=65535;\n','')
s=sub(s,'   if(coef_rsp_valid&&coef_rsp_ready)coef_rsp_valid<=0;\n','')
a=s.index('   if(coef_cfg_valid&&coef_cfg_ready)begin',s.index(' laya_m007_matrix_engine_v1'));b=s.index('   if(cmd_valid&&cmd_ready)begin',a);s=s[:a]+s[b:]
s=sub(s,'laya_m007_w_supply_v1 w_cache(','laya_m007_w_supply_v2 w_cache(.transport_idle(w_transport_idle),')
s=sub(s,'   end else begin\n      if(coef_cfg_valid&&coef_cfg_ready)begin', '   end else begin\n    coef_cycle_bad=0;coef_cycle_col=65535;\n    if(coef_rsp_valid&&coef_rsp_ready)coef_rsp_valid<=0;\n    if(coef_cfg_valid&&coef_cfg_ready)begin')
versions.append(save('q8_linear_and_restore/rtl/laya_m007_matrix_facade_v2.sv',s))
(R/'service_source_preparation.json').write_text(json.dumps({'stage':'SOURCE_WRITTEN_NOT_COMPILED','versions':versions,'legacy_v1_files_modified':False,'removed_legacy_canonical_control_bits':398,'new_bias_response_valid_bits':1,'new_bias_response_payload_bytes':256,'census_status':'NOT_RUN','eda_launched':False},indent=2)+'\n')
print(json.dumps(versions,indent=2))
