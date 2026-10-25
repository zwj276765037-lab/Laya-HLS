from pathlib import Path
m=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine')
p=m/'rtl/laya_attention_check_order_v1.sv';s=p.read_text();s=s.replace('output logic all_accounted,final_ready,coverage_fault','output logic all_accounted,final_ready,coverage_fault,output logic[31:0]first_conflict')
a=s.index(' logic next_valid;')
s=s[:a]+''' // NONE00/COMPLETE01/UNREACHABLE10/DOMINATED11 in two packed planes.
 logic[25:0][15:0]class_lo,class_hi;
 logic[2047:0]av_class_lo,av_class_hi;
 logic[25:0][15:0]stage_conflict;
 logic[2047:0]av_conflict;
 logic next_valid;logic[95:0]next_tuple;
 logic conflict_found;logic[31:0]conflict_record;
 assign completed=class_lo&~class_hi;
 assign unreachable=class_hi&~class_lo;
 assign dominated=class_lo&class_hi;
 assign av_completed=av_class_lo&~av_class_hi;
 assign av_unreachable=av_class_hi&~av_class_lo;
 assign av_dominated=av_class_lo&av_class_hi;
 assign stage_conflict=((completed|complete_set)&(unreachable|unreachable_set))|((completed|complete_set)&(dominated|dominated_set))|((unreachable|unreachable_set)&(dominated|dominated_set));
 assign av_conflict=((av_completed|av_complete_set)&(av_unreachable|av_unreachable_set))|((av_completed|av_complete_set)&(av_dominated|av_dominated_set))|((av_unreachable|av_unreachable_set)&(av_dominated|av_dominated_set));
 always_comb begin
  next_valid=error_valid;next_tuple=error_tuple;
  for(int i=0;i<4;i++)if(candidate_valid[i]&&(!next_valid||candidate_tuple[i]<next_tuple))begin next_valid=1;next_tuple=candidate_tuple[i];end
  all_accounted=(&(class_lo|class_hi))&&(&(av_class_lo|av_class_hi))&&!coverage_fault;
  conflict_found=0;conflict_record=0;
  // Priority only encodes a real conflict; normal operation updates packed planes.
  if(!coverage_fault&&(|stage_conflict))begin
   for(int s=0;s<26;s++)for(int h=0;h<16;h++)if(!conflict_found&&stage_conflict[s][h])begin
    conflict_found=1;conflict_record={14'b0,1'b0,12'(s*16+h),class_hi[s][h],class_lo[s][h],dominated_set[s][h],unreachable_set[s][h],complete_set[s][h]};
   end
  end else if(!coverage_fault&&(|av_conflict))begin
   for(int i=0;i<2048;i++)if(!conflict_found&&av_conflict[i])begin
    conflict_found=1;conflict_record={14'b0,1'b1,12'(i),av_class_hi[i],av_class_lo[i],av_dominated_set[i],av_unreachable_set[i],av_complete_set[i]};
   end
  end
 end
 assign final_ready=rst_n&&all_accounted&&real_debts_clear&&!coverage_fault;
 always_ff@(posedge clk)begin
  if(!rst_n||clear)begin
   error_valid<=0;error_tuple<=0;class_lo<=0;class_hi<=0;av_class_lo<=0;av_class_hi<=0;coverage_fault<=0;first_conflict<=0;
  end else begin
   error_valid<=next_valid;error_tuple<=next_tuple;
   class_lo<=class_lo|complete_set|dominated_set;class_hi<=class_hi|unreachable_set|dominated_set;
   av_class_lo<=av_class_lo|av_complete_set|av_dominated_set;av_class_hi<=av_class_hi|av_unreachable_set|av_dominated_set;
   if(conflict_found)begin coverage_fault<=1;first_conflict<=conflict_record;end
  end
 end
endmodule
'''
p.write_text(s)
# Resident-only production configuration really omits both legacy arrays.
p=m/'rtl/laya_attention_qk_av_engine_v1.sv';s=p.read_text();s=s.replace('module laya_attention_qk_av_engine_v1(','module laya_attention_qk_av_engine_v1 #(parameter bit RESIDENT_ONLY=0)(')
s=s.replace(' logic [767:0] qkv_loaded;logic [2047:0] prob_loaded;',''' wire input_coverage_complete;
 generate if(RESIDENT_ONLY)begin:resident_input
  logic accepted;
  always_ff@(posedge clk)begin
   if(!rst_n||prep_fire)accepted<=0;
   else if(resident_fire)accepted<=1;
  end
  assign input_coverage_complete=accepted&&!mode_av;
 end else begin:independent_input
  logic[767:0]qkv_loaded;logic[2047:0]prob_loaded;
  always_ff@(posedge clk)begin
   if(!rst_n||prep_fire)begin qkv_loaded<=0;prob_loaded<=0;end
   else begin
    if(resident_fire)qkv_loaded<='1;
    if(qkv_wr_valid&&qkv_wr_ready)qkv_loaded[int'(qkv_wr_plane)*256+int'(qkv_wr_token)*2+int'(qkv_wr_half)]<=1;
    if(state==PREP&&g_wr_rsp_valid&&g_wr_rsp_ready)prob_loaded[int'(g_wr_rsp_tag[13:7])*16+int'(g_wr_rsp_tag[6:3])]<=1;
   end
  end
  assign input_coverage_complete=mode_av?((&qkv_loaded[767:512])&&(&prob_loaded)):(&qkv_loaded);
 end endgenerate''')
s=s.replace('wire qwr_domain=state==PREP&&','wire qwr_domain=!RESIDENT_ONLY&&state==PREP&&')
s=s.replace('(mode_av?((&qkv_loaded[767:512])&&(&prob_loaded)):(&qkv_loaded));','input_coverage_complete;')
s=s.replace('if(state==PREP&&mode_av&&prob_wr_generation==generation','if(!RESIDENT_ONLY&&state==PREP&&mode_av&&prob_wr_generation==generation')
s=s.replace('&&prepare_av','&&prepare_av')
s=s.replace('qkv_loaded<=0;prob_loaded<=0;','') if False else s
# Remove only original sequential references, leaving generated implementation above.
s=s.replace('mask<=0;qkv_loaded<=0;prob_loaded<=0;','mask<=0;')
s=s.replace('    qkv_loaded<=0;prob_loaded<=0;aborted<=0;','    aborted<=0;')
s=s.replace("   if(resident_fire)qkv_loaded<='1;\n   if(qkv_wr_valid&&qkv_wr_ready)qkv_loaded[int'(qkv_wr_plane)*256+int'(qkv_wr_token)*2+int'(qkv_wr_half)]<=1;\n   if(state==PREP&&g_wr_rsp_valid&&g_wr_rsp_ready)prob_loaded[int'(g_wr_rsp_tag[13:7])*16+int'(g_wr_rsp_tag[6:3])]<=1;\n",'')
s=s.replace('assign prepare_ready=state==IDLE&&','assign prepare_ready=(!RESIDENT_ONLY||!prepare_av)&&state==IDLE&&')
p.write_text(s)
p=m/'rtl/laya_attention_head_engine_v1.sv';s=p.read_text().replace('module laya_attention_head_engine_v1(','module laya_attention_head_engine_v1 #(parameter bit RESIDENT_ONLY=0)(').replace('laya_attention_qk_av_engine_v1 qkav(','laya_attention_qk_av_engine_v1 #(.RESIDENT_ONLY(RESIDENT_ONLY)) qkav(');p.write_text(s)
print('packed classes, first-conflict32 and true resident-only configuration written')
