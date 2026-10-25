#!/usr/bin/env python3
"""Mechanical legacy NBA split plus explicit canonical q representation.
The preserved implementation baseline is source, never numerical gold.
"""
from pathlib import Path
import re,json
MODULE=Path(__file__).resolve().parents[1];ROOT=MODULE.parents[5]
RUN=ROOT/'project/E014_m007_layernorm32/experiment_results/runs/R002'
BASE=RUN/'implementation_baseline/laya_m007_layernorm32_v1.sv'
def main():
 old=BASE.read_text();ports=(RUN/'ln_compact_ports_v1.txt').read_text()
 fields=json.loads((ROOT/'project/E014_m007_layernorm32/experiment_source/ln_control_layout_v3.json').read_text())['fields']
 shapes={'ctx_active':'[3:0]','ctx_row':'[3:0][6:0]','raw_coverage':'[3:0][31:0]','delta_coverage':'[3:0][31:0]',
 'raw_read_count':'[3:0][5:0]','delta_read_count':'[3:0][5:0]','output_count':'[3:0][5:0]',
 'sum_wait':'[3:0]','square_sum_wait':'[3:0]','sqrt_wait':'[3:0]','mean_valid':'[3:0]','inverse_valid':'[3:0]',
 'left_valid':'[1:0][3:0][4:0]','add_debt':'[3:0][8:0]','mul_debt':'[3:0][8:0]',
 'read_debt':'[3:0][6:0]','write_debt':'[3:0][6:0]','scalar_debt':'[3:0][3:0]',
 'add_metadata':'[63:0][145:0]','mul_metadata':'[63:0][23:0]','tree_checked':'[1:0][3:0][9:0]'}
 engine={}
 for f in fields:
  if not f['field'].startswith('engine.') or f['field'].startswith('engine.ctx_failed') or f['field']=='engine.div_expected':continue
  name=f['field'][7:].split('[')[0];engine[name]=f
 engine['ctx_failed']={'bits':4}
 current={name:'c_'+name for name in engine};current['error_stage']='c_error_order_code'
 outputs=['active','done_valid','done_error','out_valid','ctx_active','ctx_row','raw_coverage','delta_coverage','cycle_count','peak_add_pending','peak_mul_pending','error_level','error_row','error_node','out_request_id','out_generation','out_epoch','out_row','out_chunk','done_kind','protocol_fault','protocol_code','protocol_location']
 def rename(t):
  for name in sorted(current,key=len,reverse=True):t=re.sub(r'\b'+re.escape(name)+r'\b',current[name],t)
  t=re.sub(r'\bgamma_done_valid\b','gamma_done_valid_i',t)
  return t
 declarations=''' typedef logic[7:0] item_t;
 logic[12287:0]q_view,q_next;wire enabled=control_enable;
 generate if(EXTERNAL_CONTROL)begin:external_q
  assign q_view=control_q;
 end else begin:internal_q
  logic[12127:0]local_control;
  assign q_view={160'b0,local_control};
  always_ff@(posedge clk)begin if(!rst_n)local_control<=0;else if(enabled)local_control<=q_next[12127:0];end
 end endgenerate
 assign control_next=q_next;
 logic[31:0][31:0]gamma_mem[0:31];logic[31:0]gamma_coverage;
 logic gamma_loading,gamma_done_valid_i;logic[63:0]held_model;logic[31:0]held_key;
 logic[3:0][31:0]sum_value,mean_value,square_sum_value,shift_value,inverse_value;
 logic[1:0][3:0][4:0][31:0]left_value;
 logic[104:0][31:0]add_hold_a,add_hold_b,add_build_a,add_build_b;
 logic[95:0][31:0]mul_hold_a,mul_hold_b,mul_build_a,mul_build_b;
 logic[31:0][31:0]wr_hold_raw,wr_hold_delta,wr_build_raw,wr_build_delta;
 logic[175:0]am,add_build_meta;logic[23:0]mm,mul_build_meta;
 logic add_build_valid,mul_build_valid;logic[15:0]wr_build_desc,rd_build_desc;
 logic can_add,can_mul,can_write,root_capacity,take_input,take_add,take_mul,take_read;
 logic input_finite,gamma_finite,bad_now,work_debt_clear,physical_debt_clear,aborting;
 logic[4:0]bad_stage;logic[1:0]bad_ctx;logic[9:0]bad_node;logic[3:0]bad_level;logic[6:0]bad_row;
 logic scale_req_valid,scale_req_ready,scale_rsp_valid,scale_rsp_ready,scale_rsp_error;
 logic[31:0]scale_req_data,scale_rsp_data;logic[95:0]scale_req_tag,scale_rsp_tag;
 logic sqrt_req_valid,sqrt_req_ready,sqrt_rsp_valid,sqrt_rsp_ready,sqrt_rsp_error,sqrt_busy;
 logic[31:0]sqrt_req_data,sqrt_rsp_data;logic[95:0]sqrt_req_tag,sqrt_rsp_tag;
 logic[2:0]scale_local_tag;logic[1:0]sqrt_local_tag;logic[4:0]scale_control_next;logic[12:0]sqrt_control_next;
 integer scale_select,sqrt_select,raw_select,delta_select;
 integer add_change[0:3],mul_change[0:3],read_change[0:3],write_change[0:3],scalar_change[0:3];
 logic add_match,mul_match,read_match,write_match,div_match,proto_now,cancel_fire;
 logic[3:0]proto_code_now,raw_reject;logic[7:0]proto_location_now;
 logic[3:0]c_div_expected,n_div_expected;
 assign c_div_expected=q_view[12116+:4];
'''
 for name,f in engine.items():
  shape=shapes.get(name,''if f['bits']==1 else f"[{f['bits']-1}:0]")
  declarations+=f' logic {shape} c_{name},n_{name};\n'
  if name=='ctx_failed':declarations+=' assign c_ctx_failed={q_view[11959+:3],q_view[3]};\n'
  else:declarations+=f" assign c_{name}=q_view[{f['lsb']}+:{f['bits']}];\n"
 for name in outputs:
  gate='enabled&&'if name in ['active','done_valid','out_valid','protocol_fault'] else "enabled?c_ctx_active:4'b0" if name=='ctx_active' else ''
  declarations+=f' assign {name}='+ (gate+'c_'+name if name!='ctx_active'else gate)+';\n'
 declarations+=''' assign gamma_done_valid=enabled&&gamma_done_valid_i;
 assign op_request_id=c_out_request_id;assign op_generation=c_out_generation;assign op_epoch=c_out_epoch;
 assign out_tag={16'h4c4e,c_out_epoch,c_out_generation,c_out_row,c_out_chunk,4'b0};
 assign cancel_rsp_valid=done_valid&&c_done_kind==3;
 assign error_class=c_error_order_code[4:3];assign error_check={1'b0,c_error_order_code[2:0]};
 assign error_stage=c_error_order_code[4:3]==0?0:c_error_order_code[4:3]==1?12:
  c_error_order_code[2:0]==0?1:c_error_order_code[2:0]==1?3:c_error_order_code[2:0]==2?4:
  c_error_order_code[2:0]==3?5:c_error_order_code[2:0]==4?6:c_error_order_code[2:0]==6?(c_mode_gamma?11:10):
  c_error_level==0?2:c_error_level==1?6:c_error_level==2?7:c_error_level==3?8:9;
'''
 funcs=old[old.index(' function automatic item_t item'):old.index(' assign op_request_id=')]
 funcs+=''' function automatic integer item_width(input integer s);
  return s<5?8:s<10?12-s:8;
 endfunction
 function automatic logic[145:0]encode_add(input logic[175:0]full);
  logic[145:0]packed_meta;integer off,w;packed_meta=0;off=0;
  for(int k=0;k<22;k++)begin
   w=k<20?item_width(k%10):8;
   packed_meta[off+w-1]=full[k*8+7];packed_meta[off+w-3+:2]=full[k*8+5+:2];
   for(int b=0;b<5;b++)if(b<w-3)packed_meta[off+b]=full[k*8+b];off+=w;
  end
  return packed_meta;
 endfunction
 function automatic logic[175:0]decode_add(input logic[145:0]compact);
  logic[175:0]full;integer off,w;full=0;off=0;
  for(int k=0;k<22;k++)begin
   w=k<20?item_width(k%10):8;full[k*8+7]=compact[off+w-1];full[k*8+5+:2]=compact[off+w-3+:2];
   for(int b=0;b<5;b++)if(b<w-3)full[k*8+b]=compact[off+b];off+=w;
  end
  return full;
 endfunction
 function automatic logic add_encoding_ok(input logic[175:0]full);
  logic ok;integer w;ok=1;
  for(int k=0;k<20;k++)begin w=item_width(k%10);if(full[k*8+7])for(int b=0;b<5;b++)if(b>=w-3&&full[k*8+b])ok=0;end
  return ok;
 endfunction
 function automatic logic[4:0]order_code(input logic[4:0]stage);
  case(stage)0:return 0;1:return 16;3:return 17;4:return 18;5:return 19;6:return 20;10,11:return 22;default:return 21;endcase
 endfunction
'''
 # Keep the original combinational dataflow and old-RHS semantics. Protocol
 # and CPU-order refinement are separate explicit additions, not implicit muxes.
 logicpart=old[old.index(' assign am='):old.index(' laya_m007_ln_div1024_v1 scale')]
 logicpart=logicpart.replace('assign am=add_metadata[add_rsp_tag[5:0]];assign mm=mul_metadata[mul_rsp_tag[5:0]];',
  "assign am=add_match?decode_add(add_metadata[add_rsp_tag[5:0]]):176'b0;assign mm=mul_match?mul_metadata[mul_rsp_tag[5:0]]:24'b0;")
 logicpart=logicpart.replace('add_hold_valid?add_hold_meta:add_build_meta','add_hold_valid?decode_add(add_hold_meta):add_build_meta')
 logicpart=logicpart.replace('  reject_code=0;','  raw_reject=0;').replace('reject_code=','raw_reject=')
 logicpart=logicpart.replace('  reject_valid=rst_n&&reject_code!=0;','')
 logicpart=logicpart.replace('  reject_valid=rst_n&&raw_reject!=0;','')
 logicpart=logicpart.replace('assign gamma_begin_ready=rst_n','assign gamma_begin_ready=enabled&&rst_n').replace('assign gamma_ready=rst_n','assign gamma_ready=enabled&&rst_n')
 logicpart=logicpart.replace('cmd_ready=rst_n','cmd_ready=enabled&&rst_n&&!reject_pending&&!cancel_valid').replace('in_ready=rst_n','in_ready=enabled&&rst_n&&!reject_pending&&!cancel_valid')
 logicpart=logicpart.replace('in_row==input_row&&in_chunk==input_chunk&&','in_row==input_row&&in_chunk==input_chunk&&in_tag=={16\'h4c4e,op_epoch,op_generation,in_row,in_chunk,4\'b0}&&')
 logicpart=logicpart.replace('take_add=add_rsp_valid&&add_rsp_ready;take_mul=mul_rsp_valid&&mul_rsp_ready;take_read=rd_rsp_valid&&rd_rsp_ready;',
 'take_add=add_rsp_valid&&add_rsp_ready&&add_match&&!protocol_fault;take_mul=mul_rsp_valid&&mul_rsp_ready&&mul_match&&!protocol_fault;take_read=rd_rsp_valid&&rd_rsp_ready&&read_match&&!protocol_fault;')
 logicpart=logicpart.replace('wr_rsp_ready=active;','wr_rsp_ready=enabled&&active;')
 logicpart=logicpart.replace('cmd_rows<=128&&','cmd_rows<=128&&(cmd_source_finite_qualified||cmd_source_summary_valid)&&(!cmd_source_bad_valid||cmd_source_bad_row<cmd_rows)&&')
 # Gate every production request/response path while inactive.
 logicpart=logicpart.replace('=active&&','=enabled&&active&&').replace('div_rsp_ready=active;','div_rsp_ready=enabled&&active;')
 # Existing opaque-tag detection remains a temporary local error domain until
 # the separate CPU-order candidate/closure block replaces it below.
 def replace_once(before,after):
  nonlocal logicpart
  assert logicpart.count(before)==1,(before,logicpart.count(before))
  logicpart=logicpart.replace(before,after)
 replace_once('scale_req_valid=enabled&&active&&!aborting&&scale_select>=0;', 'scale_req_valid=enabled&&active&&((!aborting&&scale_select>=0)||scale_offer_valid);')
 replace_once('  sqrt_req_valid=enabled&&active&&!aborting&&sqrt_select>=0;', "  if(scale_offer_valid)begin scale_req_data=scale_offer_tag[2]?square_sum_value[scale_offer_tag[1:0]]:sum_value[scale_offer_tag[1:0]];scale_req_tag={32'h4c4e5343,op_generation,29'b0,scale_offer_tag};end\n  sqrt_req_valid=enabled&&active&&((!aborting&&sqrt_select>=0)||sqrt_offer_valid);")
 replace_once('  // The sqrt result slot itself holds', "  if(sqrt_offer_valid)begin sqrt_req_data=shift_value[sqrt_offer_ctx];sqrt_req_tag={32'h4c4e5351,op_generation,30'b0,sqrt_offer_ctx};end\n  // The sqrt result slot itself holds")
 replace_once('div_req_valid=enabled&&active&&!aborting&&sqrt_rsp_valid&&!sqrt_rsp_error;', 'div_req_valid=enabled&&active&&(!aborting||div_offer_valid)&&sqrt_rsp_valid&&!sqrt_rsp_error;')
 replace_once('sqrt_rsp_ready=enabled&&active&&(aborting||sqrt_rsp_error||div_req_ready);', 'sqrt_rsp_ready=enabled&&active&&((aborting&&!div_offer_valid)||sqrt_rsp_error||div_req_ready);')
 logicpart=rename(logicpart)
 logicpart=logicpart.replace('!c_reject_pending','!c_reject_pending')
 leaf=''' laya_m007_ln_div1024_external_v2 scale(.clk,.rst_n,.control_enable(enabled),.control_q(q_view[11941+:5]),.control_next(scale_control_next),
  .req_valid(scale_req_valid),.req_ready(scale_req_ready),.req_data(scale_req_data),.req_tag(scale_req_tag[2:0]),
  .rsp_valid(scale_rsp_valid),.rsp_ready(scale_rsp_ready),.rsp_data(scale_rsp_data),.rsp_error(scale_rsp_error),.rsp_tag(scale_local_tag));
 assign scale_rsp_tag={32'h4c4e5343,c_out_generation,29'b0,scale_local_tag};
 laya_m007_ln_sqrt_external_v2 square_root(.clk,.rst_n,.control_enable(enabled),.control_q(q_view[11946+:13]),.control_next(sqrt_control_next),
  .req_valid(sqrt_req_valid),.req_ready(sqrt_req_ready),.req_data(sqrt_req_data),.req_tag(sqrt_req_tag[1:0]),
  .rsp_valid(sqrt_rsp_valid),.rsp_ready(sqrt_rsp_ready),.rsp_data(sqrt_rsp_data),.rsp_error(sqrt_rsp_error),.rsp_tag(sqrt_local_tag),.busy(sqrt_busy));
 assign sqrt_rsp_tag={32'h4c4e5351,c_out_generation,30'b0,sqrt_local_tag};
'''
 debts=old[old.index(' // Count actual issued'):old.index(' always_ff@(posedge clk)begin')]
 debts=debts.replace('add_hold_valid?add_hold_meta:add_build_meta','add_hold_valid?decode_add(add_hold_meta):add_build_meta')
 debts=debts.replace('wr_rsp_valid&&wr_rsp_ready&&','wr_rsp_valid&&wr_rsp_ready&&write_match&&!protocol_fault&&')
 debts=debts.replace('if(div_rsp_valid&&div_rsp_ready&&','if(div_rsp_valid&&div_rsp_ready&&div_match&&!protocol_fault&&')
 debts=rename(debts)
 assert debts.count('!sqrt_busy&&!sqrt_rsp_valid&&!scale_rsp_valid&&!(|c_sum_wait)')==1
 debts=debts.replace('!sqrt_busy&&!sqrt_rsp_valid&&!scale_rsp_valid&&!(|c_sum_wait)', '!sqrt_busy&&!sqrt_rsp_valid&&!scale_rsp_valid&&!c_scale_offer_valid&&!c_sqrt_offer_valid&&!c_div_offer_valid&&!(|c_sum_wait)')
 debts=debts.replace('  work_debt_clear=', '  physical_debt_clear=mul_pending==0&&add_pending==0&&div_pending==0&&bank_idle&&\n   !c_add_hold_valid&&!c_mul_hold_valid&&!c_rd_hold_valid&&!c_wr_hold_valid&&!c_out_valid&&\n   !sqrt_busy&&!sqrt_rsp_valid&&!scale_rsp_valid&&!c_scale_offer_valid&&!c_sqrt_offer_valid&&!c_div_offer_valid;\n  work_debt_clear=')
 debts=debts.replace('  debt_clear=work_debt_clear&&!c_active&&!c_done_valid;',
 '  if(c_protocol_fault)work_debt_clear=physical_debt_clear;\n  debt_clear=enabled&&work_debt_clear&&!c_active&&!c_done_valid&&!c_reject_pending&&!gamma_loading&&!gamma_done_valid_i;\n  control_retired=debt_clear&&!cancel_rsp_valid;')
 seq=old[old.index(' always_ff@(posedge clk)begin'):old.rindex('\nendmodule')]
 seq=seq.replace('     input_tags[in_row[1:0]][in_chunk]<=in_tag;','')
 seq=seq.replace('input_tags[in_row[1:0]][in_chunk]<=in_tag;',';')
 seq=seq.replace('out_tag<=input_tags[mm[21+:2]][mm[16+:5]];','').replace('out_tag<=input_tags[mm[13+:2]][mm[8+:5]];','')
 seq=seq.replace('add_metadata[add_tail]<=add_hold_valid?add_hold_meta:add_build_meta;', 'add_metadata[add_tail]<=add_hold_valid?add_hold_meta:encode_add(add_build_meta);')
 seq=seq.replace('add_hold_meta<=add_build_meta;', 'add_hold_meta<=encode_add(add_build_meta);')
 seq=seq.replace('wr_rsp_valid&&wr_rsp_ready)begin','wr_rsp_valid&&wr_rsp_ready&&write_match&&!protocol_fault)begin')
 seq=seq.replace('div_rsp_valid&&div_rsp_ready&&!aborting','div_rsp_valid&&div_rsp_ready&&div_match&&!aborting')
 bad_old='''    if(bad_now&&!aborting)begin
     aborting<=1;done_error<=1;error_stage<=bad_stage;error_level<=bad_level;error_row<=bad_row;error_node<=bad_node;
     sum_wait<=0;square_sum_wait<=0;sqrt_wait<=0;
    end'''
 assert bad_old in seq;seq=seq.replace(bad_old,'')
 seq=seq.replace('aborting<=0;','ctx_failed<=0;')
 # Split each nonblocking assignment. Every RHS still names the original q,
 # preserving old RHS and last-NBA-wins even for multiple same-edge updates.
 bracket=r'\[(?:[^\[\]\n]|\[(?:[^\[\]\n]|\[[^\[\]\n]*\])*\])*\]'
 rx=re.compile(r'([A-Za-z_]\w*(?:'+bracket+r')*)\s*<=\s*([^;]*);')
 numeric={'gamma_loading','gamma_loaded','gamma_coverage','gamma_done_valid','gamma_done_error','held_model','held_key','gamma_mem','out_data','sum_value','mean_value','square_sum_value','shift_value','inverse_value','left_value','add_hold_a','add_hold_b','mul_hold_a','mul_hold_b','wr_hold_raw','wr_hold_delta'}
 def split(kind):
  def convert(m):
   lhs,rhs=m.groups();base=lhs.split('[')[0]
   if base in numeric:return m.group(0) if kind=='numeric' else ';'
   if base in engine or base=='error_stage':
    if kind=='numeric':return ';'
    dest=('error_order_code' if base=='error_stage'else base)
    return 'n_'+dest+lhs[len(base):]+' = '+rhs+';'
   raise RuntimeError('Unclassified NBA '+base)
  t=rx.sub(convert,seq)
  t=rename(t)
  if kind=='numeric':t=t.replace('always_ff@(posedge clk)begin','always_ff@(posedge clk)if(!rst_n||enabled)begin',1)
  else:
   t=t.replace('always_ff@(posedge clk)begin','always_comb begin\n'+''.join(f'  n_{name}=c_{name};\n'for name in engine)+'  n_div_expected=c_div_expected;\n',1)
  return t
 control=split('control');numeric_seq=split('numeric')
 # q scalar fields have their own pure-next arithmetic controllers; no FF copy.
 assemble=''' always_comb begin
  q_next=q_view;
  if(enabled)begin
'''
 for name,f in engine.items():
  if name=='ctx_failed':assemble+="   q_next[3]=n_ctx_failed[0];q_next[11959+:3]=n_ctx_failed[3:1];\n"
  else:assemble+=f"   q_next[{f['lsb']}+:{f['bits']}]=n_{name};\n"
 assemble+='''   q_next[11941+:5]=scale_control_next;q_next[11946+:13]=sqrt_control_next;
   q_next[12116+:4]=n_div_expected;
   if(!rst_n)q_next=0;
   else if(control_clear&&control_retired)q_next=0;
  end
 end
'''
 protocol=''' assign add_match=add_pending!=0&&add_rsp_tag=={32'h4c4e4144,c_out_generation,26'b0,6'(c_add_tail-add_pending)};
 assign mul_match=mul_pending!=0&&mul_rsp_tag=={32'h4c4e4d55,c_out_generation,26'b0,6'(c_mul_tail-mul_pending)};
 assign read_match=c_read_expected_valid&&rd_rsp_tag=={32'h4c4e5244,c_out_generation,16'b0,c_read_expected_desc};
 assign write_match=c_write_expected_valid&&wr_rsp_tag=={32'h4c4e5752,c_out_generation,16'b0,c_write_expected_desc};
 assign div_match=div_pending!=0&&div_rsp_tag=={32'h4c4e5351,c_out_generation,30'b0,div_rsp_tag[1:0]}&&c_div_expected[div_rsp_tag[1:0]];
 assign reject_valid=enabled&&rst_n&&c_reject_pending;assign reject_code=c_reject_held_code;
 assign cancel_ready=enabled&&rst_n&&c_active&&!c_done_valid&&!c_cancel_active&&cancel_request_id==c_out_request_id&&cancel_generation==c_out_generation&&cancel_epoch==c_out_epoch;
 assign cancel_fire=cancel_valid&&cancel_ready;
 assign aborting=(|c_ctx_failed)||c_protocol_fault||c_cancel_active;
 always_comb begin
  proto_now=0;proto_code_now=0;proto_location_now=0;
  if(enabled&&c_active&&!c_protocol_fault)begin
   if(add_rsp_valid&&!add_match)begin proto_now=1;proto_code_now=1;end
   else if(mul_rsp_valid&&!mul_match)begin proto_now=1;proto_code_now=2;end
   else if(rd_rsp_valid&&!read_match)begin proto_now=1;proto_code_now=3;end
   else if(wr_rsp_valid&&!write_match)begin proto_now=1;proto_code_now=4;end
   else if(div_rsp_valid&&!div_match)begin proto_now=1;proto_code_now=5;end
   else if(add_build_valid&&!add_encoding_ok(add_build_meta))begin proto_now=1;proto_code_now=6;end
   else if(control_clear&&!control_retired)begin proto_now=1;proto_code_now=7;end
  end
 end
'''
 # Append explicit protocol/cancel state updates within the same next block.
 pos=control.rfind('\n end')
 extra='''
  if(enabled&&rst_n)begin
   if(c_reject_pending&&reject_ready)n_reject_pending=0;
   if(!c_reject_pending)begin
    if(raw_reject!=0)begin n_reject_pending=1;n_reject_held_code=raw_reject;end
    else if(in_valid&&c_active&&in_tag!={16'h4c4e,c_out_epoch,c_out_generation,in_row,in_chunk,4'b0})begin n_reject_pending=1;n_reject_held_code=8;end
    else if(cmd_valid&&((!cmd_source_finite_qualified&&!cmd_source_summary_valid)||(cmd_source_bad_valid&&cmd_source_bad_row>=cmd_rows)))begin n_reject_pending=1;n_reject_held_code=10;end
    else if(cancel_valid&&!cancel_ready)begin n_reject_pending=1;n_reject_held_code=11;end
   end
   if(cmd_valid&&cmd_ready)begin
    n_ctx_failed=0;n_protocol_fault=0;n_protocol_code=0;n_protocol_location=0;
    n_cancel_active=0;n_done_kind=0;n_tree_checked=0;n_div_expected=0;n_scale_offer_valid=0;n_scale_offer_tag=0;n_sqrt_offer_valid=0;n_sqrt_offer_ctx=0;n_div_offer_valid=0;
    n_read_expected_valid=0;n_write_expected_valid=0;
    n_source_finite_qualified=cmd_source_finite_qualified;n_source_bad_valid=cmd_source_bad_valid;
    n_source_bad_row=cmd_source_bad_row;n_source_bad_element=cmd_source_bad_element;
   end
   if(scale_req_valid&&scale_req_ready)n_scale_offer_valid=0;
   else if(scale_req_valid&&!c_scale_offer_valid)begin n_scale_offer_valid=1;n_scale_offer_tag=scale_req_tag[2:0];end
   if(sqrt_req_valid&&sqrt_req_ready)n_sqrt_offer_valid=0;
   else if(sqrt_req_valid&&!c_sqrt_offer_valid)begin n_sqrt_offer_valid=1;n_sqrt_offer_ctx=sqrt_req_tag[1:0];end
   if(div_req_valid&&div_req_ready)n_div_offer_valid=0;
   else if(div_req_valid&&!c_div_offer_valid)n_div_offer_valid=1;
   if(rd_rsp_valid&&rd_rsp_ready&&read_match)n_read_expected_valid=0;
   if(wr_rsp_valid&&wr_rsp_ready&&write_match)n_write_expected_valid=0;
   if(rd_valid&&rd_ready)begin n_read_expected_valid=1;n_read_expected_desc=rd_tag[15:0];end
   if(wr_valid&&wr_ready)begin n_write_expected_valid=1;n_write_expected_desc=wr_tag[15:0];end
   if(div_rsp_valid&&div_rsp_ready&&div_match)n_div_expected[div_rsp_tag[1:0]]=0;
   if(div_req_valid&&div_req_ready)n_div_expected[div_req_tag[1:0]]=1;
   if(cancel_fire)begin n_cancel_active=1;n_done_error=1;n_done_kind=c_protocol_fault?2:3;end
   if(bad_now&&!aborting)begin
    n_ctx_failed[bad_ctx]=1;n_done_error=1;n_done_kind=1;
    n_error_order_code=order_code(bad_stage);n_error_level=bad_level;n_error_row=bad_row;n_error_node=bad_node;
    n_sum_wait=0;n_square_sum_wait=0;n_sqrt_wait=0;
   end
   if(proto_now)begin
    n_protocol_fault=1;n_protocol_code=proto_code_now;n_protocol_location=proto_location_now;n_done_error=1;n_done_kind=2;
   end
   if(c_protocol_fault&&physical_debt_clear)begin
    n_add_debt=0;n_mul_debt=0;n_read_debt=0;n_write_debt=0;n_scalar_debt=0;
    n_read_expected_valid=0;n_write_expected_valid=0;n_div_expected=0;
   end
  end
'''
 control=control[:pos]+extra+control[pos:]
 # Ensure reset covers every newly added q field, without touching payload.
 reset='''  if(!rst_n)begin
   n_ctx_failed=0;n_tree_checked=0;n_protocol_fault=0;n_protocol_code=0;n_protocol_location=0;
   n_source_bad_valid=0;n_source_bad_row=0;n_source_bad_element=0;n_source_finite_qualified=0;
   n_reject_pending=0;n_reject_held_code=0;n_cancel_active=0;n_done_kind=0;n_scale_offer_valid=0;n_scale_offer_tag=0;n_sqrt_offer_valid=0;n_sqrt_offer_ctx=0;n_div_offer_valid=0;
   n_read_expected_valid=0;n_read_expected_desc=0;n_write_expected_valid=0;n_write_expected_desc=0;n_div_expected=0;
  end
'''
 pos=control.rfind('\n end');control=control[:pos]+reset+control[pos:]
 codec_functions=funcs[funcs.index(' function automatic integer item_width'):funcs.index(' function automatic logic[4:0]order_code')]
 codec_wrapper='''
// Public local codec verification wrapper. These are the exact production
// functions above; this wrapper adds no engine state and cannot inject faults.
module laya_m007_ln_compact_codec_v1(
 input logic[175:0]full,output logic[145:0]encoded,
 output logic[175:0]decoded,output logic encoding_ok
);
'''+codec_functions+'''
 always_comb begin encoded=encode_add(full);decoded=decode_add(encoded);encoding_ok=add_encoding_ok(full);end
endmodule
'''
 text='`timescale 1ns/1ps\n// Canonical pure q/next LN; legacy implementation is a separate generate branch.\nmodule laya_m007_layernorm32_compact_v2 #(parameter bit EXTERNAL_CONTROL=0)(\n'+ports+');\n'+declarations+funcs+protocol+logicpart+leaf+debts+control+numeric_seq+assemble+'\nendmodule\n'+codec_wrapper
 # Stop accidental references to deleted opaque state or full local scalar tags.
 assert 'input_tags'not in text and not re.search(r'\bn_aborting\b',text)
 (MODULE/'rtl/laya_m007_layernorm32_compact_v2.sv').write_text(text)
 print('Generated canonical q/next implementation; numerical CPU-order refinement remains explicitly local until updated')
if __name__=='__main__':main()
