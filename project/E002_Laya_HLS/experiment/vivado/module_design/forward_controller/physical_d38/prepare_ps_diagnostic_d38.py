#!/usr/bin/env python3
"""One bounded PS representation diagnostic, with actual source extraction."""
from pathlib import Path
import hashlib,json,difflib
ROOT=Path(__file__).resolve().parents[7]
RUN=ROOT/'project/E022_m007_full_top_physical/experiment_results/runs/R001'
OUT=RUN/'ps_diagnostic'
SRC=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/rtl/laya_m007_matrix_engine_v1.sv'
def sha(s):return hashlib.sha256(s.encode()).hexdigest()
def freeze(p,s):
 p.parent.mkdir(parents=True,exist_ok=True)
 if p.exists():assert p.read_text()==s,str(p)
 else:p.write_text(s)
def main():
 old=SRC.read_text();assert sha(old)=='f8493b130354123a57115f85bc1d6cdeab776a64697234962063604594b9c1cd'
 readloops=[line for line in old.splitlines(True)if line.startswith(('  if(math_read_part)for','  if(bias_read_part)for','  if(retire_read_part)for'))];assert len(readloops)==3
 writeloops=[line for line in old.splitlines(True)if line.startswith('   for(integer a=0;a<16;a++)for(integer c=0;c<16;c++)begin bank_index=512*')and'ps_wr_mask[bank_index]'in line];assert len(writeloops)==2
 removals=['ps_rd_mask=0;ps_rd_addr=0;','ps_wr_mask=0;ps_wr_addr=0;ps_wr_data=0;',*readloops,*writeloops]
 generated=''' // PS representation diagnostic: fixed bank b={context,row,half,column}.
 generate for(genvar bank=0;bank<1024;bank++)begin:g_ps_static_bank
  localparam int C=bank/512,A=(bank%512)/32,H=(bank%32)/16,J=bank%16;
  always_comb begin
   ps_rd_mask[bank]=0;ps_rd_addr[bank]=0;
   if(math_read_part&&ctx==C&&ps_next[3]==H)begin ps_rd_mask[bank]=1;ps_rd_addr[bank]=2*ps_next[2:0]+ps_next[4];end
   if(bias_read_part&&bias_ctx==C&&bias_next[3]==H)begin ps_rd_mask[bank]=1;ps_rd_addr[bank]=2*bias_next[2:0]+bias_next[4];end
   if(retire_read_part&&retire_ctx==C&&retire_next[4:1]==A)begin ps_rd_mask[bank]=1;ps_rd_addr[bank]=2*retire_next[7:5]+retire_next[0];end
   ps_wr_mask[bank]=0;ps_wr_addr[bank]=0;ps_wr_data[bank]=0;
   if(add_rsp_valid[0]&&add_rsp_tag[0][30])begin
    if(add_rsp_tag[0][31]==C&&add_rsp_tag[0][3]==H)begin ps_wr_mask[bank]=1;ps_wr_addr[bank]=2*add_rsp_tag[0][2:0]+add_rsp_tag[0][4];ps_wr_data[bank]=add_rsp_data[16*A+J];end
   end else if(state==RUN&&write_next<issue_count&&pool_state[write_next[5:0]]==SUMREADY)begin
    if(ctx==C&&write_next[3]==H)begin ps_wr_mask[bank]=1;ps_wr_addr[bank]=2*write_next[2:0]+write_next[4];ps_wr_data[bank]=op0[write_next[5:0]][32*(16*A+J)+:32];end
   end
  end
 end endgenerate
'''
 candidate=old;operations=[]
 for fragment in removals:
  assert candidate.count(fragment)==1,fragment
  at=candidate.index(fragment);operations.append({'offset':at,'removed':fragment});candidate=candidate[:at]+candidate[at+len(fragment):]
 anchor=' always_comb begin\n  descriptor_ok='
 at=candidate.index(anchor);candidate=candidate[:at]+generated+candidate[at:]
 inverse=candidate[:at]+candidate[at+len(generated):]
 for op in reversed(operations):i=op['offset'];inverse=inverse[:i]+op['removed']+inverse[i:]
 assert inverse==old
 # Mechanical projection of the complete PS combinational fan-in.
 def span(first,last):
  i=old.index(first);j=old.index(last,i)+len(last);return old[i:j]
 fragments=[span(' function automatic [95:0] tag('," endfunction"),
  ' assign arithmetic_debt=math_debt+bias_debt;',
  span('  normal_write_ack=','  room=64-arithmetic_debt+normal_write_ack+bias_write_ack;'),
  span('  math_read_part=','retire_read_fire=ps_rd_valid&&ps_rd_ready&&retire_read_part;'),
  '  ps_rsp_math=ps_rd_rsp_tag[31];ps_rsp_bias=ps_rd_rsp_tag[30];ps_rsp_retire=ps_rd_rsp_tag[29];',
  '  ps_rd_rsp_ready=(!ps_rsp_retire||!out_hold_valid||out_ready)&&(!ps_rsp_bias||add_req_ready[0]);',
  span('  ps_wr_valid=0;','  add_rsp_ready=7\'b0000001;if(add_rsp_tag[0][30])add_rsp_ready[0]=ps_wr_ready;'),
  " assign ps_wr_rsp_ready=1'b1;"]
 ports=''' input logic clk,
 input logic [2:0] state,input logic [63:0][3:0] pool_state,
 input logic [12:0] ps_next,issue_count,commit_count,write_next,
 input logic [15:0] k,input logic ctx,bias_ctx,retire_ctx,bias_active,retire_active,aborting,
 input logic [5:0] bias_next,input logic [8:0] retire_next,
 input logic [1:0][12:0] ctx_committed,input logic [6:0] math_debt,bias_debt,
 input logic out_hold_valid,out_ready,ps_rd_ready,ps_wr_ready,ps_wr_rsp_valid,
 input logic [95:0] ps_wr_rsp_tag,ps_rd_rsp_tag,
 input logic [31:0] epoch,generation,
 input logic [6:0] add_rsp_valid,add_req_ready,input logic [6:0][95:0] add_rsp_tag,
 input logic [255:0][31:0] add_rsp_data,input logic [8191:0] op0[0:63],
 output logic [1023:0] ps_rd_mask,ps_wr_mask,
 output logic [1023:0][3:0] ps_rd_addr,ps_wr_addr,
 output logic [1023:0][31:0] ps_wr_data,
 output logic ps_rd_valid,ps_wr_valid,ps_rd_rsp_ready,ps_wr_rsp_ready,
 output logic [95:0] ps_rd_tag,ps_wr_tag,output logic [6:0] add_rsp_ready,
 output logic math_read_part,bias_read_part,retire_read_part,math_read_fire,bias_read_fire,retire_read_fire,
 output logic normal_write_ack,bias_write_ack,output logic [6:0] arithmetic_debt,output integer room'''
 params='\n'.join(old.splitlines()[112:114]);definitions='\n'+params+'\n integer bank_index;logic ps_rsp_math,ps_rsp_bias,ps_rsp_retire;\n'+fragments[0]+'\n'+fragments[1]+'\n'+fragments[-1]+'\n'
 body=' always_comb begin\n'+'\n'.join(fragments[2:-1])+'\n end\n'
 oldcone='`timescale 1ns/1ps\nmodule old_ps_cone(\n'+ports+');'+definitions+body+'endmodule\n'
 newbody=body
 for fragment in removals:assert newbody.count(fragment)==1;newbody=newbody.replace(fragment,'',1)
 newcone='`timescale 1ns/1ps\nmodule new_ps_cone(\n'+ports+');'+definitions+newbody+generated+'endmodule\n'
 freeze(OUT/'original_f849_matrix_engine.sv',old);freeze(OUT/'candidate_matrix_engine.sv',candidate);freeze(OUT/'candidate_production.diff',''.join(difflib.unified_diff(old.splitlines(True),candidate.splitlines(True),fromfile=str(SRC),tofile=str(OUT/'candidate_matrix_engine.sv'))));freeze(OUT/'old_ps_cone.sv',oldcone);freeze(OUT/'new_ps_cone.sv',newcone)
 mapping=[{'fragment':f,'line':old.count('\n',0,old.index(f))+1,'offset':old.index(f),'bytes':len(f)}for f in fragments]
 relation={'original_production_SHA256':sha(old),'candidate_SHA256':sha(candidate),'production_untouched':SRC.read_text()==old,'inverse_exact_f849':inverse==old,'removed_operations':operations,'generated_static_bank_process':generated,'source_fragments':mapping,'ports':ports,'full_fanin':'64 unpacked8192bit op0, dynamic64pool_state, actual room/debt/acks, actual grants/priority, state q and original main inputs; no preselected payload or prederived grant inputs','outputs':'all5 PS vectors including unselected banks plus actual PS valid/tag/readies, add_rsp_ready, grants/fires/acks/arithmetic_debt/room','outside_fanin_excluded':'sequential q updates, dot/format arithmetic, add-request data/bias payloads that do not feed these PS outputs; same on both sides','bank_bijection':'b=512*C+32*A+16*H+J; C=b/512,A=(b%512)/32,H=(b%32)/16,J=b%16; lane=16*A+J','X_Z_policy':'procedural if/== retained; no ternary X merge; new four-state differential planned including unknown selectors/branch controls','OOC_gate':'both complete original>=4GiB,new<=half and decrease>=2GiB; OR original actual24GiB guard,new complete<=12GiB; new mapped DCP/0BB required; no other result admits core retry'}
 freeze(OUT/'source_relation.json',json.dumps(relation,indent=2)+'\n')
 print(json.dumps({'directory':str(OUT),'candidate_SHA256':sha(candidate),'production_untouched':True,'inverse_exact':True}))
if __name__=='__main__':main()
