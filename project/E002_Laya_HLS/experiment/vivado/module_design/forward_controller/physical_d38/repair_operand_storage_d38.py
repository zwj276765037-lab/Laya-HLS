#!/usr/bin/env python3
"""Apply only the authorized operand representation change; extract actual blocks."""
from pathlib import Path
import difflib,hashlib,json,re
ROOT=Path(__file__).resolve().parents[7]
RUN=ROOT/'project/E022_m007_full_top_physical/experiment_results/runs/R001'
OUT=RUN/'repair'
SRC=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/rtl/laya_m007_matrix_engine_v1.sv'
OLD=RUN/'input/rtl'/SRC.name
OLD_SHA='2147d041620a158cf7f2cddfd172b538e54ba78c5d340507a8c5ce08cfff069f'
def sha(s):return hashlib.sha256(s.encode()).hexdigest()
def freeze(p,s):
 p.parent.mkdir(parents=True,exist_ok=True)
 if p.exists():assert p.read_text()==s,str(p)
 else:p.write_text(s)
def main():
 old=OLD.read_text();assert sha(old)==OLD_SHA
 decl=' logic [63:0][255:0][31:0]  op0,op1;'
 newdecl=' logic [255:0][31:0] op0[0:63],op1[0:63];'
 guards=['state==RUN','format_valid','mul_rsp_valid&&mul_rsp_ready','ps_next<issue_count&&pool_state[ps_next[5:0]]==TERMREADY&&ps_next<32','ps_rd_rsp_valid&&ps_rd_rsp_ready&&ps_rsp_math','add_rsp_valid[0]&&add_rsp_ready[0]&&!add_rsp_tag[0][30]']
 writes=['op0[format_tag[5:0]]<=converted;','op1[format_tag[5:0]]<=products;','op0[mul_rsp_tag[5:0]]<=mul_rsp_data;',"op1[ps_next[5:0]]<='0;",'for(integer a=0;a<16;a++)for(integer c=0;c<16;c++)op1[ps_rd_rsp_tag[18:13]][16*a+c]<=ps_rd_rsp_data[512*ps_rd_rsp_tag[28]+32*a+16*ps_rd_rsp_tag[16]+c];','op0[add_rsp_tag[0][5:0]]<=add_rsp_data;']
 for w in writes:assert old.count(w)==1,w
 # Each source data clause is immediately contained in these actual production ifs.
 expected=[('if('+guards[1]+')begin',writes[0]),('if('+guards[1]+')begin',writes[1]),('if('+guards[2]+')begin',writes[2]),('if('+guards[3]+')begin',writes[3]),('if('+guards[4]+')begin',writes[4]),('if('+guards[5]+')begin',writes[5])]
 control=old[old.index(' always_ff @(posedge clk)begin\n  if(!rst_n)begin'):]
 for g,w in expected:
  prefix=control[:control.index(w)];assert prefix.rfind(g)>prefix.rfind('\n   end\n'),(g,w)
 generated=''' // D38: same asynchronous pools, static slot LHS and unchanged write priority.
 generate for(genvar slot=0;slot<64;slot++)begin:g_operand_slot
  always_ff @(posedge clk)begin
   if(!rst_n)begin
   end else begin
    if(state==RUN)begin
     if(format_valid&&format_tag[5:0]==slot)begin
      op0[slot]<=converted;op1[slot]<=products;
     end
     if(mul_rsp_valid&&mul_rsp_ready&&mul_rsp_tag[5:0]==slot)op0[slot]<=mul_rsp_data;
     if(ps_next<issue_count&&pool_state[ps_next[5:0]]==TERMREADY&&ps_next<32&&ps_next[5:0]==slot)op1[slot]<='0;
    end
    if(ps_rd_rsp_valid&&ps_rd_rsp_ready&&ps_rsp_math&&ps_rd_rsp_tag[18:13]==slot)begin
     for(integer a=0;a<16;a++)for(integer c=0;c<16;c++)op1[slot][16*a+c]<=ps_rd_rsp_data[512*ps_rd_rsp_tag[28]+32*a+16*ps_rd_rsp_tag[16]+c];
    end
    if(add_rsp_valid[0]&&add_rsp_ready[0]&&!add_rsp_tag[0][30]&&add_rsp_tag[0][5:0]==slot)op0[slot]<=add_rsp_data;
   end
  end
 end endgenerate
'''
 anchor=' always_ff @(posedge clk)begin\n  if(!rst_n)begin'
 fixed=old.replace(decl,newdecl)
 operations=[]
 for w in writes:
  at=fixed.index(w);operations.append({'offset_in_sequential_transform':at,'removed':w});fixed=fixed[:at]+fixed[at+len(w):]
 pos=fixed.index(anchor);fixed=fixed[:pos]+generated+fixed[pos:]
 inverse=fixed[:pos]+fixed[pos+len(generated):]
 for o in reversed(operations):i=o['offset_in_sequential_transform'];inverse=inverse[:i]+o['removed']+inverse[i:]
 inverse=inverse.replace(newdecl,decl);assert inverse==old
 current=SRC.read_text();assert current in (old,fixed),'Production changed outside owned transform'
 SRC.write_text(fixed);OUT.mkdir(exist_ok=True)
 freeze(OUT/'original_matrix_engine.sv',old);freeze(OUT/'fixed_matrix_engine.sv',fixed)
 freeze(OUT/'production.diff',''.join(difflib.unified_diff(old.splitlines(True),fixed.splitlines(True),fromfile=str(OLD),tofile=str(SRC))))
 # Guard/assignment source provenance. No manual independent old RAM implementation.
 mapping=[]
 def record(kind,fragment,text,version):
  assert fragment in text
  start=text.index(fragment);mapping.append({'version':version,'kind':kind,'fragment':fragment,'line':text.count('\n',0,start)+1,'offset':start,'bytes':len(fragment)})
 for g in guards:record('guard','if('+g+')',old,'original')
 for w in writes:record('write',w,old,'original')
 record('reset','if(!rst_n)begin',control,'original_control_relative')
 oldblock=' always_ff @(posedge clk)begin\n  if(!rst_n)begin\n  end else begin\n   if('+guards[0]+')begin\n    if('+guards[1]+')begin '+writes[0]+writes[1]+'end\n    if('+guards[2]+')begin '+writes[2]+'end\n    if('+guards[3]+')begin '+writes[3]+'end\n   end\n   if('+guards[4]+')begin '+writes[4]+'end\n   if('+guards[5]+')begin '+writes[5]+'end\n  end\n end\n'
 assert generated in fixed
 # Every production storage read RHS is extracted byte-exactly from BOTH versions.
 reads=['mul_a=op0[mul_next[5:0]];','mul_b=op1[mul_next[5:0]];','add_a=op0[add_next[5:0]];','add_b=op1[add_next[5:0]];','ps_wr_data[bank_index]=op0[write_next[5:0]][16*a+c];','trace_commit_data=op0[ps_wr_rsp_tag[5:0]];']
 for v,t in [('original',old),('fixed',fixed)]:
  for r in reads:record('read',r,t,v)
 # Actual surrounding read selection is preserved, including bias priority.
 bias='ps_rd_rsp_valid&&ps_rsp_bias&&(!ps_rsp_retire||!out_hold_valid||out_ready)'
 addguard='state==RUN&&add_next<issue_count&&pool_state[add_next[5:0]]==ADDREADY'
 wrguard='state==RUN&&write_next<issue_count&&pool_state[write_next[5:0]]==SUMREADY'
 scatter='for(integer a=0;a<16;a++)for(integer c=0;c<16;c++)begin bank_index=512*ctx+32*a+16*write_next[3]+c;ps_wr_mask[bank_index]=1;ps_wr_addr[bank_index]=2*write_next[2:0]+write_next[4];'+reads[4]+'end'
 for v,t in [('original',old),('fixed',fixed)]:
  for fragment in ['if('+bias+')','else if('+addguard+')','else if('+wrguard+')',scatter]:record('read_context',fragment,t,v)
 readblock=' // Storage-related cone: unrelated bias data branch is empty in BOTH extracts.\n always_comb begin\n  '+reads[0]+reads[1]+'\n  add_a=0;add_b=0;ps_wr_mask=0;ps_wr_addr=0;ps_wr_data=0;bank_index=0;\n  if('+bias+')begin end else if('+addguard+')begin '+reads[2]+reads[3]+'end\n  if(add_rsp_valid[0]&&add_rsp_tag[0][30])begin end else if('+wrguard+')begin '+scatter+' end\n  '+reads[5]+'\n end\n'
 ports='''input logic clk,rst_n,
 input logic [2:0] state,input logic [63:0][3:0] pool_state,
 input logic [12:0] issue_count,mul_next,ps_next,add_next,write_next,
 input logic format_valid,mul_rsp_valid,mul_rsp_ready,ps_rd_rsp_valid,ps_rd_rsp_ready,ps_rsp_math,
 input logic [95:0] format_tag,mul_rsp_tag,ps_rd_rsp_tag,ps_wr_rsp_tag,
 input logic [6:0] add_rsp_valid,add_rsp_ready,input logic [6:0][95:0] add_rsp_tag,
 input logic [255:0][31:0] converted,products,mul_rsp_data,add_rsp_data,
 input logic [1023:0][31:0] ps_rd_rsp_data,
 input logic ctx,ps_rsp_bias,ps_rsp_retire,out_hold_valid,out_ready,
 output logic [255:0][31:0] mul_a,mul_b,add_a,add_b,trace_commit_data,
 output logic [1023:0][31:0] ps_wr_data,
 output logic [1023:0] ps_wr_mask,output logic [1023:0][3:0] ps_wr_addr'''
 params='\n'.join(old.splitlines()[112:114])+'\n integer bank_index;\n'
 for name,d,b in [('old_storage',decl,oldblock),('new_storage',newdecl,generated)]:freeze(OUT/(name+'.sv'),'`timescale 1ns/1ps\nmodule '+name+'(\n'+ports+');\n'+params+d+'\n'+b+readblock+'endmodule\n')
 proof={'schema':'m007-d38-operand-representation-v1','original':{'path':str(OLD),'sha256':sha(old)},'fixed':{'path':str(SRC),'sha256':sha(fixed)},'exact_inverse_restores_original_bytes':inverse==old,'unchanged_control_and_reads_proof':'Inverse removes only inserted generated process, restores declaration and six removed assignments at recorded offsets; result equals original bytes.','removed_write_operations':operations,'generated_static_process':generated,'source_fragments':mapping,'read_expressions':reads,'uninitialized_data_preserved':True,'equivalence_scope':'64 known slot addresses; X data/reset/enable planned; known slots only, unknown slot addresses not claimed'}
 freeze(OUT/'source_relation.json',json.dumps(proof,indent=2)+'\n')
 print(json.dumps({'fixed_sha256':sha(fixed),'inverse_exact':True,'extracted_reads':len(reads),'diff':str(OUT/'production.diff')}))
if __name__=='__main__':main()
