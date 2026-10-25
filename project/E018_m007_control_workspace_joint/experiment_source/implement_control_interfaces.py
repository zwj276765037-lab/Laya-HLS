from pathlib import Path
import re,json
ROOT=Path(__file__).resolve().parents[3]
MOD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design'
BASE=Path(__file__).parent/'input_baseline'
# The AT133 census order is the stable low-to-high layout order. Packed ascending
# array indices preserve the original unpacked index ordering within each field.
F=[('tag_mem_hi',2048,'[0:255][7:0]'),('numeric_bad',2048,'[0:255][7:0]'),('peer_bad',2048,'[0:255][7:0]'),('z_good_mem',2048,'[0:255][7:0]'),('live',256,'[255:0]'),('available',256,'[255:0]'),('sent',256,'[255:0]'),('received',256,'[255:0]'),('reserve_ptr',8,'[7:0]'),('head_ptr',8,'[7:0]'),('expected_valid',36,'[8:0][3:0]'),('expected_tag',576,'[0:8][0:3][15:0]'),('pre_tag',240,'[0:14][15:0]'),('x_good_pipe',120,'[0:14][7:0]'),('t_tag',112,'[0:6][15:0]'),('t_valid',7,'[6:0]'),('ugood_delay',32,'[0:3][7:0]'),('vgood_delay',24,'[0:2][7:0]'),('tgood_delay',56,'[0:6][7:0]'),('zeligible_delay',32,'[0:3][7:0]'),('post_tag',208,'[0:12][15:0]'),('r_tag',16,'[15:0]'),('post_valid',13,'[12:0]'),('r_valid',1,''),('post_good',104,'[0:12][7:0]'),('yeligible_delay',32,'[0:3][7:0]'),('geligible_delay',32,'[0:3][7:0]'),('pending',9,'[8:0]'),('slot_pending',18,'[1:0][8:0]'),('slot_sfu_debt',18,'[1:0][8:0]'),('slot_fp_debt',16,'[1:0][7:0]'),('covered',152,'[7:0][18:0]'),('evaluated',152,'[7:0][18:0]'),('first_error_valid',1,''),('first_error_rank',3,'[2:0]'),('first_error_row',7,'[6:0]'),('first_error_column',12,'[11:0]'),('protocol_fault',1,''),('tag_context',64,'[63:0]'),('context_valid',1,''),('next_input_seq',16,'[15:0]')]
assert sum(w for n,w,d in F)==11343
layout=[];off=0
for n,w,d in F:layout.append(dict(name=n,width=w,lsb=off,msb=off+w-1,packed_shape=d));off+=w
(Path(__file__).parent/'g_control_layout_v1.json').write_text(json.dumps({'schema':'m007-control-arena-layout-v1','bits':off,'order':'AT133 census entry order, low to high; each original array uses ascending packed indices','fields':layout},indent=2)+'\n')
s=(BASE/'laya_m007_g_math_v1.sv').read_text()
s=s.replace('module laya_m007_g_math_v1(', 'module laya_m007_g_math_v1 #(parameter bit EXTERNAL_CONTROL=0)(\n input logic external_control_enable,input logic [11342:0] external_control_q,\n output logic [11342:0] external_control_next,output logic control_retired,')
anchor=' wire accept='
struct=''' // Version1: exact AT133 control layout. Aliases below are wires, not shadows.\n wire control_enabled=!EXTERNAL_CONTROL||external_control_enable;\n typedef struct packed {\n'''+''.join('  logic '+d+' '+n+';\n' for n,w,d in reversed(F))+''' } control_state_t;\n control_state_t control_q,control_d;\n assign external_control_next=control_d;\n generate if(EXTERNAL_CONTROL)begin:external_state\n  assign control_q=external_control_q;\n end else begin:local_state\n  logic [11342:0] state_q;\n  always_ff @(posedge clk)state_q<=control_d;\n  assign control_q=state_q;\n end endgenerate\n'''
# Alias existing declared outputs and arrays to packed view, with no always_ff driver.
arrays={'tag_mem_hi':(256,),'numeric_bad':(256,),'peer_bad':(256,),'z_good_mem':(256,),'expected_tag':(9,4),'pre_tag':(15,),'x_good_pipe':(15,),'t_tag':(7,),'ugood_delay':(4,),'vgood_delay':(3,),'tgood_delay':(7,),'zeligible_delay':(4,),'post_tag':(13,),'post_good':(13,),'yeligible_delay':(4,),'geligible_delay':(4,)}
for n,w,d in F:
 if n in arrays:
  shape=arrays[n];idx=''.join(f'[a{i}]'for i in range(len(shape)))
  struct+=' '+''.join(f'for(genvar a{i}=0;a{i}<{v};a{i}++)'for i,v in enumerate(shape))+f'assign {n}{idx}=control_q.{n}{idx};\n'
 else:struct+=f' assign {n}=control_q.{n};\n'
s=s.replace(anchor,struct+anchor,1)
s=s.replace('assign pool_reset_n=rst_n&&!clear;', 'assign pool_reset_n=rst_n&&!clear&&control_enabled;')
s=s.replace(' assign sfu_req_mask=', ' assign control_retired=control_enabled&&idle&&pre_flight==0&&slot_pending==0&&slot_sfu_debt==0&&slot_fp_debt==0&&!sfu_req_valid;\n assign sfu_req_mask=',1)
s=s.replace('  event_valid={matched[8]', '  if(!control_enabled)fp_req_valid=0;\n\n  event_valid={matched[8]',1)
start=s.index(' always_ff @(posedge clk)begin\n  if(!pool_reset_n)')
old=s[start:s.rindex('endmodule')]
names={n for n,w,d in F};writes=[]
bracket=r'\[(?:[^\[\]\n]|\[(?:[^\[\]\n]|\[[^\[\]\n]*\])*\])*\]'
pat=re.compile(r'\b([A-Za-z_]\w*)((?:'+bracket+r')*)\s*<=\s*([^;]+);')
def cv(m):
 n,ix,rhs=m.groups()
 if n in names:writes.append((n,ix,rhs));return 'control_d.'+n+ix+'='+rhs+';'
 return ' begin end '
d=pat.sub(cv,old)
assert '<=' not in d
assert set(n for n,ix,rhs in writes)==names,(names-set(n for n,ix,rhs in writes))
d=d.replace(' always_ff @(posedge clk)begin',' always_comb begin\n  control_d=control_q;',1)
# Numeric payload/alignment remains in its original FF class and cycle.
payload=''' always_ff @(posedge clk)begin\n  if(pool_reset_n)begin\n   if(accept)begin x_mem[reserve_ptr]<=in_x;gate_mem[reserve_ptr]<=in_gate;end\n   x_delay[0]<=in_x;for(int i=1;i<4;i++)x_delay[i]<=x_delay[i-1];\n   t_delay[0]<=fp_rsp_data[3];for(int i=1;i<7;i++)t_delay[i]<=t_delay[i-1];\n   if(sfu_return)begin h0<=sfu_rsp_data;x0<=x_mem[sfu_rsp_tag[7:0]];gate_delay[0]<=gate_mem[sfu_rsp_tag[7:0]];end\n   for(int i=1;i<9;i++)gate_delay[i]<=gate_delay[i-1];\n   r_aligned<=fp_rsp_data[5];\n   if(matched[8])for(int l=0;l<8;l++)result_mem[fp_rsp_tag[8][7:0]][l]<=geligible_delay[3][l]&&finite(fp_rsp_data[8][l])?fp_rsp_data[8][l]:0;\n  end\n end\n'''
s=s[:start]+d+payload+'endmodule\n'
(MOD/'vector_and_ffn/rtl/laya_m007_g_math_v1.sv').write_text(s)
# Layer: only coverage leaves the original FF. Both modes use exactly this next.
s=(BASE/'laya_attention_layer_engine_v1.sv').read_text()
s=s.replace('module laya_attention_layer_engine_v1(', 'module laya_attention_layer_engine_v1 #(parameter bit EXTERNAL_CONTROL=0)(\n input logic external_control_enable,input logic [12287:0] external_control_q,\n output logic [12287:0] external_control_next,output logic control_private_idle,control_retired,')
s=s.replace(' logic qkv_complete;', ''' logic [12287:0]qkv_coverage;
 wire control_enabled=!EXTERNAL_CONTROL||external_control_enable;\n logic [12287:0]coverage_next;\n assign external_control_next=coverage_next;\n generate if(EXTERNAL_CONTROL)begin:external_state\n  assign qkv_coverage=external_control_q;\n end else begin:local_state\n  logic [12287:0]state_q;\n  always_ff @(posedge clk)state_q<=coverage_next;\n  assign qkv_coverage=state_q;\n end endgenerate\n // Private-idle never inspects the inactive coverage view.\n logic qkv_complete;''',1)
s=s.replace(' logic [12287:0]qkv_coverage;logic aborted,',' logic aborted,')
s=s.replace(' wire cancel_fire=', ' assign control_private_idle=state==L_IDLE&&h_prepare_ready&&!h_done_valid&&!r_owner_valid&&!r_done_valid&&!public_read_owned;\n assign control_retired=control_enabled&&control_private_idle&&real_idle&&r_resource_debt_clear&&!prepare_valid&&!done_valid&&!prepare_cancel_rsp_valid&&!result_rsp_valid;\n wire cancel_fire=',1)
# Gate public admission and rejection; private controllers are idle before disable.
for n in ['prepare_cancel_ready','prepare_ready','start_ready','abort_ready','qkv_wr_ready','reject_valid','result_discard_ready','result_rd_ready']:
 s=s.replace('assign '+n+'=rst_n&&','assign '+n+'=rst_n&&control_enabled&&')
# remove only coverage NBA assignments and reuse their original textual order.
start=s.index(' always_ff@(posedge clk)begin')
prefix=s[:start];seq=s[start:]
coverage=[]
def lc(m):
 n,ix,rhs=m.groups()
 if n=='qkv_coverage':coverage.append((ix,rhs));return ' begin end '
 return m.group(0)
seq=pat.sub(lc,seq)
assert len(coverage)==6,len(coverage)
nextlogic=''' always_comb begin\n  coverage_next=qkv_coverage;\n  if(!rst_n)coverage_next=0;\n  else if(control_enabled)begin\n   if(prepare_valid&&prepare_ready&&prepare_kind!=3)coverage_next=0;\n   if(qkv_wr_valid&&qkv_wr_ready)coverage_next[((int'(qkv_wr_head)*3+int'(qkv_wr_plane))*128+int'(qkv_wr_token))*2+int'(qkv_wr_half)]=1;\n   if(layer_start)coverage_next[4095:0]=0;\n   if(cancel_fire)coverage_next=0;\n   if(result_rsp_valid&&result_rsp_ready)coverage_next[res_st_context_rd_rsp_tag[43:32]]=1;\n  end\n end\n'''
(MOD/'attention_and_fp_engine/rtl/laya_attention_layer_engine_v1.sv').write_text(prefix+nextlogic+seq)
# Engine optional mode only passes q/next/enable, and blocks admission while inactive.
s=(BASE/'laya_m007_g_engine_v1.sv').read_text()
s=s.replace('module laya_m007_g_engine_v1(', 'module laya_m007_g_engine_v1 #(parameter bit EXTERNAL_CONTROL=0)(\n input logic external_control_enable,input logic [11342:0] external_control_q,\n output logic [11342:0] external_control_next,output logic control_private_idle,control_retired,')
s=s.replace(' logic bind_ready,', ' wire control_enabled=!EXTERNAL_CONTROL||external_control_enable;\n logic math_control_retired;\n logic bind_ready,',1)
s=s.replace(' logic all_covered;', ' logic all_covered;\n assign control_private_idle=!active&&!done_valid&&!needs_discard&&slot_active==0&&!write_pending&&bank_issued==bank_returned;\n assign control_retired=control_enabled&&control_private_idle&&engine_idle&&math_control_retired&&!cmd_valid&&!out_valid;',1)
s=s.replace('assign fill_reject_valid=fill_valid&&','assign fill_reject_valid=control_enabled&&fill_valid&&')
s=s.replace('bind_valid=cmd_valid&&','bind_valid=control_enabled&&cmd_valid&&')
s=s.replace('cmd_ready=!active&&','cmd_ready=control_enabled&&!active&&')
s=s.replace('discard_reject_valid=discard_valid&&','discard_reject_valid=control_enabled&&discard_valid&&')
s=s.replace(' laya_m007_g_math_v1 math(.clk,.rst_n,', ' laya_m007_g_math_v1 #(.EXTERNAL_CONTROL(EXTERNAL_CONTROL)) math(.external_control_enable(control_enabled),.external_control_q,.external_control_next,.control_retired(math_control_retired),.clk,.rst_n,')
(MOD/'vector_and_ffn/rtl/laya_m007_g_engine_v1.sv').write_text(s)
print('EXTRACTED',len(F),'fields',len(writes),'control NBA statements; layer',len(coverage))
