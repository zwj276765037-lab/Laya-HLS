`timescale 1ns/1ps
// A real resource shell: exactly one full256 FP, one DIV8, one32KiB LN-exp.
module m007_ln_compact_engine_tb;
 logic clk=0,rst_n=0;always#5 clk=~clk;
 logic cmd_valid=0,cmd_ready,cmd_gamma=0;logic[63:0]cmd_request_id=64'h14000001,cmd_model=64'h6eb6ef58bc4f99bd;
 logic[31:0]cmd_generation=61,cmd_epoch=81,cmd_key=32'h4c4e0001;logic[7:0]cmd_rows=4;
 logic gamma_begin_valid=0,gamma_begin_ready,gamma_valid=0,gamma_ready,gamma_done_valid,gamma_done_ready=1,gamma_done_error,gamma_loaded;
 logic[63:0]gamma_model=64'h6eb6ef58bc4f99bd;logic[31:0]gamma_key=32'h4c4e0001;logic[4:0]gamma_chunk=0;logic[31:0][31:0]gamma_data=0;
 logic in_valid=0,in_ready;logic[63:0]in_request_id;logic[31:0]in_generation,in_epoch;
 logic[6:0]in_row;logic[4:0]in_chunk;logic[95:0]in_tag;logic[31:0][31:0]in_data;
 logic out_valid,out_ready=1;logic[63:0]out_request_id;logic[31:0]out_generation,out_epoch;
 logic[6:0]out_row;logic[4:0]out_chunk;logic[95:0]out_tag;logic[31:0][31:0]out_data;
 logic done_valid,done_ready=0,done_error;logic[4:0]error_stage;logic[3:0]error_level;logic[6:0]error_row;logic[9:0]error_node;
 logic reject_valid;logic[3:0]reject_code;logic active,debt_clear;
 logic[63:0]op_request_id;logic[31:0]op_generation,op_epoch;
 logic mul_req_valid,mul_req_ready,mul_rsp_valid,mul_rsp_ready;logic[95:0]mul_req_tag,mul_rsp_tag;
 logic[255:0][31:0]mul_a,mul_b,mul_rsp_data;logic[6:0]mul_pending;
 logic add_req_valid,add_req_ready,add_rsp_valid,add_rsp_ready;logic[95:0]add_req_tag,add_rsp_tag;
 logic[255:0][31:0]add_a,add_b,add_rsp_data;logic[6:0]add_pending;
 logic div_req_valid,div_req_ready,div_rsp_valid,div_rsp_ready,div_rsp_error;logic[95:0]div_req_tag,div_rsp_tag;
 logic[31:0]div_a,div_b,div_rsp_data;logic[5:0]div_pending;
 logic wr_valid,wr_ready,wr_rsp_valid,wr_rsp_ready;logic[255:0]wr_mask;logic[255:0][4:0]wr_addr;
 logic[255:0][31:0]wr_data;logic[95:0]wr_tag,wr_rsp_tag;
 logic rd_valid,rd_ready,rd_rsp_valid,rd_rsp_ready;logic[255:0]rd_mask;logic[255:0][4:0]rd_addr;
 logic[255:0][31:0]rd_rsp_data;logic[95:0]rd_tag,rd_rsp_tag;logic bank_idle;
 logic trace_add_valid,trace_mul_valid;logic[175:0]trace_add_meta;logic[23:0]trace_mul_meta;
 logic[6:0]trace_scalar_valid;logic[6:0][1:0]trace_scalar_ctx;logic[6:0][31:0]trace_scalar_data;
 logic trace_row_start;logic[6:0]trace_row;logic[3:0]ctx_active;logic[3:0][6:0]ctx_row;
 logic[3:0][31:0]raw_coverage,delta_coverage;logic[31:0]cycle_count;logic[6:0]peak_add_pending,peak_mul_pending;
 logic control_enable=1,control_clear=0,control_retired;
 logic[12287:0]control_q=0,control_next;
 logic reject_ready=1,cancel_valid=0,cancel_ready,cancel_rsp_valid;
 logic[63:0]cancel_request_id=0;logic[31:0]cancel_generation=0,cancel_epoch=0;
 logic[1:0]done_kind,error_class;logic[3:0]error_check,protocol_code;logic[7:0]protocol_location;logic protocol_fault;
 logic cmd_source_finite_qualified=1,cmd_source_summary_valid=0,cmd_source_bad_valid=0;
 logic[6:0]cmd_source_bad_row=0;logic[9:0]cmd_source_bad_element=0;
 logic test_q_write=0;logic[12287:0]test_q_value=0;
 always_ff@(posedge clk)begin if(!rst_n)control_q<=0;else if(test_q_write&&!control_enable)control_q<=test_q_value;else if(control_enable)control_q<=control_next;end
 laya_m007_layernorm32_v1 #(.CANONICAL_TAGS(1),.EXTERNAL_CONTROL(1))engine(.*);
 logic lease_valid=0,fp_lease_ready,div_lease_ready,bank_bind_ready,release_valid=0,fp_release_ready,div_release_ready;
 logic fp_active,div_active,fp_draining,div_draining,fp_fault,div_fault,div_reject;
 logic[3:0]div_reject_code;
 logic[6:0]fp_add_req_valid,fp_add_req_ready,fp_add_rsp_valid,fp_add_rsp_ready;
 logic[6:0][2:0]fp_add_phase;logic[6:0][31:0]fp_add_epoch;logic[6:0][95:0]fp_add_req_tag,fp_add_rsp_tag;
 logic[6:0][6:0]fp_add_pending;logic[7:0][31:0]div_req_as,div_req_bs,div_rsps;
 logic[7:0]div_mask,div_errors;logic[5:0]div_inflight;logic[8:0]div_scalar_inflight;
 logic allow_add=1,allow_mul=1,allow_read=1,allow_write=1,allow_div=1;
 logic service_add_ready,service_mul_ready,service_read_ready,service_write_ready,service_div_ready;
 logic service_div_rsp_valid,service_div_rsp_ready;logic[95:0]service_div_rsp_tag;
 logic inject_bad_add=0,block_add_requests=0;logic[255:0][31:0]service_add_rsp_data;
 always_comb begin
  fp_add_req_valid=0;fp_add_req_valid[0]=add_req_valid&&allow_add&&!block_add_requests;
  fp_add_rsp_ready=0;fp_add_rsp_ready[0]=add_rsp_ready&&!inject_bad_add;
  fp_add_req_tag=0;fp_add_req_tag[0]=add_req_tag;
  for(int g=0;g<7;g++)begin fp_add_phase[g]=6;fp_add_epoch[g]=cmd_epoch;end
  add_req_ready=fp_add_req_ready[0]&&allow_add&&!block_add_requests;add_rsp_valid=inject_bad_add||fp_add_rsp_valid[0];
  add_rsp_tag=inject_bad_add?(fp_add_rsp_tag[0]^96'h000000000000000100000000):fp_add_rsp_tag[0];add_rsp_data=service_add_rsp_data;add_pending=fp_add_pending[0];
  mul_req_ready=service_mul_ready&&allow_mul;rd_ready=service_read_ready&&allow_read;wr_ready=service_write_ready&&allow_write;
  div_req_ready=service_div_ready&&allow_div;div_rsp_valid=service_div_rsp_valid;div_rsp_tag=service_div_rsp_tag;service_div_rsp_ready=div_rsp_ready;
  div_req_as=0;div_req_bs=0;div_req_as[0]=div_a;div_req_bs[0]=div_b;div_rsp_data=div_rsps[0];div_rsp_error=div_errors[0];
 end
 laya_shared_fp256_v2#(.LANES(256),.ADD_GROUPS(7))shared_fp(
  .clk,.rst_n,.lease_valid,.lease_ready(fp_lease_ready),.lease_request_id(cmd_request_id),.lease_generation(cmd_generation),.lease_epoch(cmd_epoch),.lease_head(4'b0),.lease_phase(3'd6),
  .release_valid,.release_ready(fp_release_ready),.release_phase(3'd6),.release_epoch(cmd_epoch),.phase_debt_clear(debt_clear),.lease_active(fp_active),.draining(fp_draining),
  .rsp_request_id(),.rsp_generation(),.rsp_epoch(),.rsp_head(),.rsp_phase(),
  .mul_req_valid(mul_req_valid&&allow_mul),.mul_req_ready(service_mul_ready),.mul_req_phase(3'd6),.mul_req_epoch(cmd_epoch),.mul_req_tag,.mul_a,.mul_b,.mul_rsp_valid,.mul_rsp_ready,.mul_rsp_tag,.mul_rsp_data,
  .add_req_valid(fp_add_req_valid),.add_req_is_root(7'b0),.add_req_ready(fp_add_req_ready),.add_req_phase(fp_add_phase),.add_req_epoch(fp_add_epoch),.add_req_tag(fp_add_req_tag),.add_a,.add_b,
  .add_rsp_valid(fp_add_rsp_valid),.add_rsp_ready(fp_add_rsp_ready),.add_rsp_tag(fp_add_rsp_tag),.add_rsp_data(service_add_rsp_data),.mul_pending,.add_pending(fp_add_pending),.protocol_fault(fp_fault));
 laya_shared_div8_v1 shared_div(
  .clk,.rst_n,.lease_valid,.lease_ready(div_lease_ready),.lease_request_id(cmd_request_id),.lease_generation(cmd_generation),.lease_epoch(cmd_epoch),.lease_head(4'b0),.lease_phase(3'd6),
  .release_valid,.release_ready(div_release_ready),.release_phase(3'd6),.release_epoch(cmd_epoch),.phase_debt_clear(debt_clear),.lease_active(div_active),.draining(div_draining),
  .rsp_request_id(),.rsp_generation(),.rsp_epoch(),.rsp_head(),.rsp_phase(),
  .req_valid(div_req_valid&&allow_div),.req_ready(service_div_ready),.req_generation(cmd_generation),.req_epoch(cmd_epoch),.req_phase(3'd6),.req_lane_mask(8'b1),.req_tag(div_req_tag),.req_a(div_req_as),.req_b(div_req_bs),
  .protocol_reject_valid(div_reject),.protocol_reject_code(div_reject_code),.rsp_valid(service_div_rsp_valid),.rsp_ready(service_div_rsp_ready),.rsp_tag(service_div_rsp_tag),.rsp_lane_mask(div_mask),.rsp_numeric_error(div_errors),.rsp_data(div_rsps),
  .pending_vectors(div_pending),.in_flight_vectors(div_inflight),.in_flight_scalars(div_scalar_inflight),.protocol_fault(div_fault));
 laya_ln_exp_storage_v1 ln_payload(
  .clk,.rst_n,.bind_valid(lease_valid),.bind_ready(bank_bind_ready),.bind_request_id(cmd_request_id),.bind_generation(cmd_generation),.bind_epoch(cmd_epoch),.bind_head(4'b0),.bind_phase(3'd6),
  .op_request_id,.op_generation,.op_epoch,.op_phase(3'd6),.rsp_request_id(),.rsp_generation(),.rsp_epoch(),.rsp_head(),.rsp_phase(),
  .wr_valid(wr_valid&&allow_write),.wr_ready(service_write_ready),.wr_mask,.wr_addr,.wr_data,.wr_tag,.wr_rsp_valid,.wr_rsp_ready,.wr_rsp_tag,
  .rd_valid(rd_valid&&allow_read),.rd_ready(service_read_ready),.rd_mask,.rd_addr,.rd_tag,.rd_rsp_valid,.rd_rsp_ready,.rd_rsp_data,.rd_rsp_mask(),.rd_rsp_tag,.idle(bank_idle));
 logic[1023:0]gold_raw[0:4095],gold_delta[0:4095],gold_square[0:4095],gold_norm[0:4095],gold_output[0:4095],gold_gamma[0:31];
 logic[31:0]gold_tree1[0:130943],gold_tree2[0:130943];logic[223:0]gold_stats[0:127];
 string progress_file;integer progress_fd=0,progress_outputs=0;
 string fixture,case_name;integer rows_arg=4,gamma_arg=0,stall_arg=0,mode_arg=0;
 integer cycle=0,command_cycle=0,input_sent=0,output_seen=0,tree_nodes=0,delta_words=0,square_words=0,norm_words=0,gamma_words=0,scalar_count=0,bank_words=0;
 integer row_start[0:127],first_output[0:127],last_output[0:127],stat_at[0:127][0:6],last_input[0:127],last_square[0:127];
 integer observed_ctx_row[0:3],consumed_by_ctx[0:3];logic[3:0]previous_contexts=0;
 integer held_outputs=0,hold_until=0,max_contexts=0,done_cycle=0,done_retired_cycle=0,observed_numeric_failure_cycle=0;
 bit checking=0,input_enable=0,input_waiting=0,numeric_case=0,held_out=0,held_add_req=0,held_mul_req=0,held_wr=0,held_rd=0;
 logic[1131:0]held_out_record;logic[16479:0]held_add_record,held_mul_record;
 logic[9823:0]held_wr_record;logic[1631:0]held_rd_record;
 bit held_scale=0,held_sqrt=0,held_div=0;
 logic[127:0]held_scale_record,held_sqrt_record;logic[159:0]held_div_record;
 integer checked_cancel_cases=0,checked_protocol_cases=0,checked_disabled_cases=0,checked_reject_cycles=0,checked_offer_cycles=0;
 integer checked_scale_offer_cycles=0,checked_sqrt_offer_cycles=0,checked_div_offer_cycles=0;
 wire scale_offer_valid=engine.canonical_mode.compact_unit.scale_req_valid;
 wire scale_offer_ready=engine.canonical_mode.compact_unit.scale_req_ready;
 wire[127:0]scale_offer_record={engine.canonical_mode.compact_unit.scale_req_tag,engine.canonical_mode.compact_unit.scale_req_data};
 wire sqrt_offer_valid=engine.canonical_mode.compact_unit.sqrt_req_valid;
 wire sqrt_offer_ready=engine.canonical_mode.compact_unit.sqrt_req_ready;
 wire[127:0]sqrt_offer_record={engine.canonical_mode.compact_unit.sqrt_req_tag,engine.canonical_mode.compact_unit.sqrt_req_data};
 logic[175:0]codec_full=0,codec_decoded;logic[145:0]codec_encoded;logic codec_ok;
 integer codec_checks=0,codec_invalid_checks=0;
 laya_m007_ln_compact_codec_v1 codec(.full(codec_full),.encoded(codec_encoded),.decoded(codec_decoded),.encoding_ok(codec_ok));
 function automatic integer offset(input integer level);return 1024-(1024>>(level-1));endfunction
 function automatic integer lane_start(input integer s);
  case(s)0:return 0;1:return 16;2:return 24;3:return 28;4:return 30;5:return 31;6:return 32;7:return 33;8:return 34;default:return 35;endcase
 endfunction
 function automatic logic[95:0]tag_for(input integer row,chunk,input logic[31:0]epoch,generation);return {16'h4c4e,epoch,generation,7'(row),5'(chunk),4'b0};endfunction
 always@(negedge clk)begin
  if(stall_arg&&active)begin
   allow_add=cycle%53<43;allow_mul=cycle%47<39;allow_read=cycle%61<49;allow_write=cycle%59<51;
   if(out_valid&&hold_until==0)hold_until=cycle+1800;
   out_ready=(hold_until==0||cycle>=hold_until)&&(cycle%41<33);
  end else begin allow_add=1;allow_mul=1;allow_read=1;allow_write=1;out_ready=1;end
  if(input_enable&&input_waiting)in_valid=1;
  else begin
  in_valid=0;
  if(input_enable&&input_sent<rows_arg*32&&(!stall_arg||cycle%37<29))begin
   in_valid=1;in_request_id=cmd_request_id;in_generation=cmd_generation;in_epoch=cmd_epoch;
   in_row=7'(input_sent/32);in_chunk=5'(input_sent%32);in_tag=tag_for(input_sent/32,input_sent%32,cmd_epoch,cmd_generation);in_data=gold_raw[input_sent];
   if(numeric_case&&mode_arg==1&&input_sent==0)in_data[3]=32'h7f800000;
   if(numeric_case&&mode_arg==3)for(int l=0;l<32;l++)in_data[l]=l%2?32'hff7fffff:32'h7f7fffff;
   if(numeric_case&&mode_arg==4)for(int l=0;l<32;l++)in_data[l]=32'h7f7fffff;
  end
  end
 end
 always@(posedge clk)begin:monitor
  integer c,row,chunk,lev,n,node,base,count_contexts;
  logic[31:0]want;logic[7:0]m;
  cycle++;if(cycle>400000)$fatal(1,"LN real shell cycle limit");
  if(!rst_n)begin input_waiting=0;held_out=0;held_add_req=0;held_mul_req=0;held_wr=0;held_rd=0;held_scale=0;held_sqrt=0;held_div=0;previous_contexts=0;for(int x=0;x<4;x++)consumed_by_ctx[x]=0;end
  else begin
   input_waiting=in_valid&&!in_ready&&input_enable;
   if(fp_fault||div_fault||div_reject)$fatal(1,"shared service fault/reject %0d",div_reject_code);
   if(held_out&&(!out_valid||{out_row,out_chunk,out_tag,out_data}!==held_out_record))$fatal(1,"held output changed");
   if(held_add_req&&(!add_req_valid||{add_req_tag,add_a,add_b}!==held_add_record))$fatal(1,"held add request changed");
   if(held_mul_req&&(!mul_req_valid||{mul_req_tag,mul_a,mul_b}!==held_mul_record))$fatal(1,"held mul request changed");
   if(held_wr&&(!wr_valid||{wr_mask,wr_addr,wr_data,wr_tag}!==held_wr_record))$fatal(1,"held bank write changed");
   if(held_rd&&(!rd_valid||{rd_mask,rd_addr,rd_tag}!==held_rd_record))$fatal(1,"held bank read changed");
   if(held_scale&&(!scale_offer_valid||scale_offer_record!==held_scale_record))$fatal(1,"held scale request changed across cancel/drain");
   if(held_sqrt&&(!sqrt_offer_valid||sqrt_offer_record!==held_sqrt_record))$fatal(1,"held sqrt request changed across cancel/drain");
   if(held_div&&(!div_req_valid||{div_req_tag,div_a,div_b}!==held_div_record))$fatal(1,"held DIV request changed across cancel/drain");
   held_out=out_valid&&!out_ready;held_out_record={out_row,out_chunk,out_tag,out_data};if(held_out)held_outputs++;
   held_add_req=add_req_valid&&!add_req_ready;held_add_record={add_req_tag,add_a,add_b};
   held_mul_req=mul_req_valid&&!mul_req_ready;held_mul_record={mul_req_tag,mul_a,mul_b};
   held_wr=wr_valid&&!wr_ready;held_wr_record={wr_mask,wr_addr,wr_data,wr_tag};
   held_rd=rd_valid&&!rd_ready;held_rd_record={rd_mask,rd_addr,rd_tag};
   held_scale=scale_offer_valid&&!scale_offer_ready;held_scale_record=scale_offer_record;
   held_sqrt=sqrt_offer_valid&&!sqrt_offer_ready;held_sqrt_record=sqrt_offer_record;
   held_div=div_req_valid&&!div_req_ready;held_div_record={div_req_tag,div_a,div_b};
   if(held_scale||held_sqrt||held_div)checked_offer_cycles++;
   if(held_scale)checked_scale_offer_cycles++;if(held_sqrt)checked_sqrt_offer_cycles++;if(held_div)checked_div_offer_cycles++;
   count_contexts=0;for(int x=0;x<4;x++)count_contexts+=int'(ctx_active[x]);if(count_contexts>max_contexts)max_contexts=count_contexts;
   if(checking)begin
    if(numeric_case&&observed_numeric_failure_cycle==0&&
      ((mode_arg==1&&in_valid&&in_ready&&in_data[3][30:23]==255)||
       (mode_arg==3&&trace_mul_valid&&trace_mul_meta[7]&&mul_rsp_data[0][30:23]==255)||
       (mode_arg==4&&trace_add_valid&&trace_add_meta[7]&&add_rsp_data[0][30:23]==255)))observed_numeric_failure_cycle=cycle;
    if(!numeric_case)begin
     for(int x=0;x<4;x++)if(previous_contexts[x]&&!ctx_active[x]&&consumed_by_ctx[x]!=32)$fatal(1,"context reused before1024 real output consumption");
     previous_contexts=ctx_active;
    end
    if(cmd_valid&&cmd_ready)command_cycle=cycle;
    if(in_valid&&in_ready)begin last_input[in_row]=cycle;input_sent++;end
    if(trace_row_start)begin
     row_start[trace_row]=cycle;
     observed_ctx_row[trace_row%4]=int'(trace_row);consumed_by_ctx[trace_row%4]=0;
     if(!stall_arg&&trace_row>0&&cycle-row_start[trace_row-1]!=128)$fatal(1,"input row II %0d",cycle-row_start[trace_row-1]);
    end
    if(!numeric_case)begin
     if(trace_add_valid)for(int s=0;s<22;s++)begin
      m=trace_add_meta[s*8+:8];if(m[7])begin
       c=int'(m[6:5]);row=int'(ctx_row[c]);chunk=int'(m[4:0]);
       if(s<20)begin
        lev=s%10+1;n=lev<=5?(16>>(lev-1)):1;node=lev<=5?chunk*n:chunk;
        for(int l=0;l<n;l++)begin
         base=row*1023+offset(lev)+node+l;want=s<10?gold_tree1[base]:gold_tree2[base];
         if(add_rsp_data[(s<10?0:36)+lane_start(s%10)+l]!==want)$fatal(1,"LN tree row=%0d tree=%0d lev=%0d node=%0d got=%h want=%h",row,s/10,lev,node+l,add_rsp_data[(s<10?0:36)+lane_start(s%10)+l],want);
         tree_nodes++;
        end
       end else if(s==20)begin
        if(add_rsp_data[72+:32]!==gold_delta[row*32+chunk])$fatal(1,"delta row=%0d chunk=%0d",row,chunk);delta_words+=32;
       end else if(add_rsp_data[104]!==gold_stats[row][4*32+:32])$fatal(1,"epsilon stage");
      end
     end
     if(trace_mul_valid)for(int s=0;s<3;s++)begin
      m=trace_mul_meta[s*8+:8];if(m[7])begin
       row=int'(ctx_row[m[6:5]]);chunk=int'(m[4:0]);
       if(s==0)begin if(mul_rsp_data[0+:32]!==gold_square[row*32+chunk])$fatal(1,"square row=%0d chunk=%0d",row,chunk);square_words+=32;last_square[row]=cycle;end
       if(s==1)begin if(mul_rsp_data[32+:32]!==gold_norm[row*32+chunk])$fatal(1,"norm row=%0d chunk=%0d",row,chunk);norm_words+=32;end
       if(s==2)begin if(mul_rsp_data[64+:32]!==gold_output[row*32+chunk])$fatal(1,"gamma row=%0d chunk=%0d",row,chunk);gamma_words+=32;end
      end
     end
     for(int s=0;s<7;s++)if(trace_scalar_valid[s])begin
      row=int'(ctx_row[trace_scalar_ctx[s]]);stat_at[row][s]=cycle;
      if(trace_scalar_data[s]!==gold_stats[row][s*32+:32])$fatal(1,"scalar row=%0d stage=%0d got=%h want=%h",row,s,trace_scalar_data[s],gold_stats[row][s*32+:32]);scalar_count++;
      if(!stall_arg)begin
       if((s==1||s==3)&&cycle-stat_at[row][s-1]>16)$fatal(1,"div1024 cycle gate");
       if(s==5&&cycle-stat_at[row][4]>32)$fatal(1,"sqrt cycle gate");
       if(s==6&&cycle-stat_at[row][5]>32)$fatal(1,"inverse cycle gate");
       if(s==0&&cycle-last_input[row]>80)$fatal(1,"tree tail %0d",cycle-last_input[row]);
       if(s==2&&cycle-last_square[row]>80)$fatal(1,"square tree tail %0d",cycle-last_square[row]);
       if(s==1&&cycle-row_start[row]>128)$fatal(1,"pass1 %0d",cycle-row_start[row]);
       if(s==6&&cycle-stat_at[row][1]>256)$fatal(1,"pass2 %0d",cycle-stat_at[row][1]);
      end
     end
     if(rd_rsp_valid&&rd_rsp_ready)for(int k=0;k<2;k++)begin
      m=rd_rsp_tag[k*8+:8];if(m[7])begin
       row=int'(ctx_row[m[6:5]]);chunk=int'(m[4:0]);
       if(rd_rsp_data[int'(m[6:5])*64+k*32+:32] !== (k==0?gold_raw[row*32+chunk]:gold_delta[row*32+chunk]))$fatal(1,"real bank payload read k=%0d row=%0d chunk=%0d",k,row,chunk);bank_words+=32;
      end
     end
     if(wr_valid&&wr_ready)for(int k=0;k<2;k++)begin
      m=wr_tag[k*8+:8];if(m[7])begin
       row=observed_ctx_row[m[6:5]];chunk=int'(m[4:0]);
       if(wr_data[int'(m[6:5])*64+k*32+:32] !== (k==0?gold_raw[row*32+chunk]:gold_delta[row*32+chunk]))$fatal(1,"real bank payload write");
      end
     end
     if(out_valid&&out_ready)begin
      if(out_row!=output_seen/32||out_chunk!=output_seen%32||out_tag!==tag_for(output_seen/32,output_seen%32,cmd_epoch,cmd_generation)||out_request_id!=cmd_request_id||out_generation!=cmd_generation||out_epoch!=cmd_epoch)$fatal(1,"output identity/order seen=%0d row=%0d chunk=%0d",output_seen,out_row,out_chunk);
      if(out_data!==gold_output[output_seen])$fatal(1,"output mismatch row=%0d chunk=%0d",out_row,out_chunk);
      if(out_chunk==0)begin
       first_output[out_row]=cycle;
       if(!stall_arg&&out_row==0&&cycle-command_cycle>448)$fatal(1,"first output cycle gate %0d",cycle-command_cycle);
       if(!stall_arg&&out_row>0&&cycle-first_output[out_row-1]>128)$fatal(1,"output row II %0d",cycle-first_output[out_row-1]);
      end
      if(out_chunk==31)begin last_output[out_row]=cycle;if(!stall_arg&&cycle-stat_at[out_row][6]>64)$fatal(1,"pass3 %0d",cycle-stat_at[out_row][6]);end
      output_seen++;progress_outputs++;
      if(progress_fd&&out_chunk==31)begin
       $fdisplay(progress_fd,"{\"schema\":\"m007-tanh-consumed-v1\",\"checked\":%0d,\"node_checks\":%0d,\"cycle\":%0d,\"phase\":1,\"returned\":%0d}",progress_outputs*32,progress_outputs*32,cycle,progress_outputs);$fflush(progress_fd);
      end
      consumed_by_ctx[out_row%4]++;
     end
    end
    if(done_valid&&done_cycle==0)begin done_cycle=cycle;$display("M007_LN_DONE_AVAILABLE cycle=%0d command_to_done=%0d error=%0d peak_add=%0d peak_mul=%0d",cycle,cycle-command_cycle,done_error,peak_add_pending,peak_mul_pending);end
    if(done_valid&&done_ready)done_retired_cycle=cycle;
   end
  end
 end
 task automatic acquire;
  @(negedge clk);lease_valid=1;
  do @(posedge clk);while(!(fp_lease_ready&&div_lease_ready&&bank_bind_ready));
  @(negedge clk);lease_valid=0;
 endtask
 task automatic release_resources;
  @(negedge clk);release_valid=1;
  do @(posedge clk);while(!(fp_release_ready&&div_release_ready));
  @(negedge clk);release_valid=0;
  if(fp_active||div_active||!bank_idle||!debt_clear)$fatal(1,"release before actual debt clear");
 endtask
 task automatic load_gamma;
  if(mode_arg==2)begin
   @(negedge clk);gamma_begin_valid=1;do @(posedge clk);while(!gamma_begin_ready);
   @(negedge clk);gamma_begin_valid=0;gamma_valid=1;gamma_chunk=0;gamma_data=gold_gamma[0];gamma_data[0]=32'h7fc00000;
   do @(posedge clk);while(!gamma_ready);
   @(negedge clk);gamma_valid=0;
   if(!gamma_done_valid||!gamma_done_error||gamma_loaded)$fatal(1,"nonfinite coefficient did not produce bounded error ack");
   repeat(2)@(negedge clk);
  end
  @(negedge clk);gamma_begin_valid=1;do @(posedge clk);while(!gamma_begin_ready);
  @(negedge clk);gamma_begin_valid=0;
  for(int k=0;k<32;k++)begin
   gamma_chunk=5'(k);gamma_data=gold_gamma[k];gamma_valid=1;do @(posedge clk);while(!gamma_ready);@(negedge clk);
   if(mode_arg==2&&k==15)begin
    gamma_valid=0;cmd_valid=1;#1;if(cmd_ready||!reject_valid||reject_code!=3)$fatal(1,"partial gamma coverage not rejected");
    @(negedge clk);cmd_valid=0;
   end
  end
  gamma_valid=0;if(!gamma_loaded||gamma_done_error)$fatal(1,"real gamma load failed");
 endtask
 task automatic begin_command;
  @(negedge clk);checking=1;cmd_valid=1;do @(posedge clk);while(!cmd_ready);
  @(negedge clk);cmd_valid=0;input_enable=1;
 endtask
 task automatic reset_counts;
  input_sent=0;output_seen=0;tree_nodes=0;delta_words=0;square_words=0;norm_words=0;gamma_words=0;scalar_count=0;bank_words=0;done_cycle=0;done_retired_cycle=0;
  previous_contexts=0;for(int c=0;c<4;c++)consumed_by_ctx[c]=0;
 endtask
 task automatic inactive_probe(input bit expected_gamma);
  @(negedge clk);control_enable=0;test_q_write=1;test_q_value='1;
  @(negedge clk);test_q_write=0;
  repeat(17)begin
   #1;
   if(control_next!==control_q||control_retired||cmd_ready||in_ready||out_valid||done_valid||reject_valid||cancel_ready||cancel_rsp_valid||
      gamma_begin_ready||gamma_ready||gamma_done_valid||add_req_valid||mul_req_valid||div_req_valid||rd_valid||wr_valid||
      add_rsp_ready||mul_rsp_ready||div_rsp_ready||rd_rsp_ready||wr_rsp_ready||trace_add_valid||trace_mul_valid||(|trace_scalar_valid)||trace_row_start||active||(|ctx_active))
    $fatal(1,"disabled owner decoded another union view or accepted production work");
   if(gamma_loaded!==expected_gamma)$fatal(1,"disabled gamma reset/persistence mismatch");
   checked_disabled_cases++;@(negedge clk);
  end
  test_q_write=1;test_q_value=0;@(negedge clk);test_q_write=0;control_enable=1;
  #1;if(!control_retired)$fatal(1,"restored empty enabled view did not retire");
 endtask
 task automatic check_public_codec;
  integer max_index,stage;
  for(int k=0;k<22;k++)begin
   stage=k%10;
   if(k>=20||stage<5)max_index=31;
   else case(stage)5:max_index=15;6:max_index=7;7:max_index=3;8:max_index=1;default:max_index=0;endcase
   for(int c=0;c<4;c++)for(int index=0;index<32;index++)begin
    codec_full=0;codec_full[k*8+:8]={1'b1,2'(c),5'(index)};#1;
    if(codec_ok!==(index<=max_index))$fatal(1,"public compact range k=%0d ctx=%0d index=%0d",k,c,index);
    if(index<=max_index&&codec_decoded!==codec_full)$fatal(1,"public compact roundtrip k=%0d ctx=%0d index=%0d",k,c,index);
    codec_checks++;if(index>max_index)codec_invalid_checks++;
   end
  end
  codec_full=0;
  $display("M007_LN_PUBLIC_CODEC checks=%0d invalid_range_checks=%0d production_fault_injection=0",codec_checks,codec_invalid_checks);
 endtask
 task automatic accept_matching_cancel;
  cancel_request_id=cmd_request_id;cancel_generation=cmd_generation-1;cancel_epoch=cmd_epoch;
  #1;if(cancel_ready)$fatal(1,"old generation cancel ready");
  cancel_generation=cmd_generation;cancel_valid=1;
  #1;if(!cancel_ready)$fatal(1,"matching cancel blocked");
  @(posedge clk);@(negedge clk);cancel_valid=0;
 endtask
 task automatic wait_terminal(input logic[1:0]kind);
  integer timeout_cycles;
  logic[169:0]terminal_record;
  timeout_cycles=0;
  while(!done_valid&&timeout_cycles<2048)begin @(negedge clk);timeout_cycles++;end
  if(!done_valid||!done_error||done_kind!=kind||active||add_pending||mul_pending||div_pending||!bank_idle||out_valid)
   $fatal(1,"directed terminal failed to drain actual service work kind=%0d actual=%0d",kind,done_kind);
  terminal_record={op_request_id,op_generation,op_epoch,done_kind,done_error,error_stage,error_level,error_row,error_node,protocol_fault,protocol_code,protocol_location};
  repeat(17)begin
   #1;if(!done_valid||done_kind!=kind||!done_error||control_retired||debt_clear||cmd_ready||fp_release_ready||div_release_ready||cancel_rsp_valid!=(kind==3))
    $fatal(1,"directed held terminal/release barrier");
   if({op_request_id,op_generation,op_epoch,done_kind,done_error,error_stage,error_level,error_row,error_node,protocol_fault,protocol_code,protocol_location}!==terminal_record)
    $fatal(1,"directed held terminal record changed");
   @(negedge clk);
  end
  done_ready=1;@(negedge clk);done_ready=0;
  if(kind==3)checked_cancel_cases++;else checked_protocol_cases++;
  release_resources();
 endtask
 task automatic run_protocol_prelude;
  logic[3:0]expected_code;
  logic[6:0]saved_add_pending;
  logic[95:0]saved_return_tag;
  acquire();
  if(mode_arg==16||mode_arg==17)allow_div=0;
  begin_command();
  if(mode_arg==16||mode_arg==17)begin
   if(mode_arg==16)wait(div_req_valid&&!div_req_ready);
   else wait(sqrt_offer_valid&&!sqrt_offer_ready&&div_req_valid&&!div_req_ready);
   @(negedge clk);input_enable=0;checking=0;
   accept_matching_cancel();
   repeat(17)begin
    #1;if(!div_req_valid||div_req_ready||done_valid||control_retired)$fatal(1,"cancel retracted blocked DIV offer");
    if(mode_arg==17&&(!sqrt_offer_valid||sqrt_offer_ready))$fatal(1,"cancel retracted blocked sqrt offer");
    @(negedge clk);
   end
   allow_div=1;wait_terminal(3);
   $display("M007_LN_DIRECTED_OFFER_CANCEL mode=%0d checked_offer_cycles=%0d actual_debt_drained=1",mode_arg,checked_offer_cycles);
  end else if(mode_arg==14)begin
   wait(fp_add_rsp_valid[0]);@(negedge clk);input_enable=0;checking=0;inject_bad_add=1;block_add_requests=1;
   saved_add_pending=add_pending;saved_return_tag=fp_add_rsp_tag[0];
   if(saved_add_pending==0)$fatal(1,"bad-return test lacked genuine pending work");
   @(posedge clk);@(negedge clk);
   if(!protocol_fault||protocol_code!=1||fp_add_pending[0]!=saved_add_pending||!fp_add_rsp_valid[0]||fp_add_rsp_tag[0]!==saved_return_tag)
    $fatal(1,"extra bad return consumed or replaced genuine return");
   inject_bad_add=0;block_add_requests=0;wait_terminal(2);
   $display("M007_LN_DIRECTED_BAD_RETURN genuine_return_preserved=1 actual_debt_drained=1");
  end else begin
   wait(input_sent>=4&&add_pending!=0);
   @(negedge clk);input_enable=0;checking=0;#1;in_valid=0;input_waiting=0;
   if(mode_arg==13)begin
    control_clear=1;@(negedge clk);control_clear=0;
    #1;if(!protocol_fault||protocol_code!=7)$fatal(1,"active clear not classified as protocol");
    wait_terminal(2);
    $display("M007_LN_DIRECTED_ACTIVE_CLEAR actual_debt_drained=1");
   end else begin
    reject_ready=0;in_valid=1;in_request_id=cmd_request_id;in_generation=cmd_generation;in_epoch=cmd_epoch;
    in_row=7'(input_sent/32);in_chunk=5'(input_sent%32);in_tag=tag_for(input_sent/32,input_sent%32,cmd_epoch,cmd_generation);in_data=gold_raw[input_sent];
    case(mode_arg)
     10:begin in_generation=cmd_generation-1;expected_code=5;end
     11:begin in_tag[0]=1;expected_code=8;end
     12:begin in_chunk=in_chunk+1'b1;in_tag=tag_for(int'(in_row),int'(in_chunk),cmd_epoch,cmd_generation);expected_code=6;end
     default:$fatal(1,"unknown directed mode");
    endcase
    #1;if(in_ready)$fatal(1,"malformed canonical input admitted");
    @(posedge clk);@(negedge clk);#1;in_valid=0;
    repeat(17)begin
     #1;if(!reject_valid||reject_code!=expected_code||in_ready||control_retired||!active)$fatal(1,"held canonical reject lost or retired");
     checked_reject_cycles++;@(negedge clk);
    end
    accept_matching_cancel();
    #1;if(!reject_valid||reject_code!=expected_code)$fatal(1,"cancel consumed independent held reject");
    reject_ready=1;@(negedge clk);#1;if(reject_valid)$fatal(1,"held reject did not consume");
    wait_terminal(3);
    $display("M007_LN_DIRECTED_REJECT_CANCEL mode=%0d reject=%0d held_cycles=%0d actual_debt_drained=1",mode_arg,expected_code,checked_reject_cycles);
   end
  end
  checking=0;input_enable=0;input_waiting=0;reset_counts();cmd_generation++;cmd_epoch++;
  $display("M007_LN_DIRECTED_NEWGEN no_reset=1 mode=%0d cancel_cases=%0d protocol_cases=%0d",mode_arg,checked_cancel_cases,checked_protocol_cases);
 endtask
 task automatic retire_command;
  repeat(5)begin @(negedge clk);if(!done_valid||debt_clear||active||cmd_ready||fp_release_ready||div_release_ready)$fatal(1,"held done/debt barrier");end
  done_ready=1;@(negedge clk);done_ready=0;release_resources();
 endtask
 task automatic print_stages;
  integer p1,p2,p3,tail,scale_cycles,sqrt_cycles,inverse_cycles;
  p1=0;p2=0;p3=0;tail=0;scale_cycles=0;sqrt_cycles=0;inverse_cycles=0;
  for(int r=0;r<rows_arg;r++)begin
   if(stat_at[r][1]-row_start[r]>p1)p1=stat_at[r][1]-row_start[r];
   if(stat_at[r][6]-stat_at[r][1]>p2)p2=stat_at[r][6]-stat_at[r][1];
   if(last_output[r]-stat_at[r][6]>p3)p3=last_output[r]-stat_at[r][6];
   if(stat_at[r][0]-last_input[r]>tail)tail=stat_at[r][0]-last_input[r];
   if(stat_at[r][2]-last_square[r]>tail)tail=stat_at[r][2]-last_square[r];
   for(int s=1;s<4;s+=2)if(stat_at[r][s]-stat_at[r][s-1]>scale_cycles)scale_cycles=stat_at[r][s]-stat_at[r][s-1];
   if(stat_at[r][5]-stat_at[r][4]>sqrt_cycles)sqrt_cycles=stat_at[r][5]-stat_at[r][4];
   if(stat_at[r][6]-stat_at[r][5]>inverse_cycles)inverse_cycles=stat_at[r][6]-stat_at[r][5];
  end
  $display("M007_LN_STAGE_MAX pass1=%0d pass2=%0d pass3=%0d tree_tail=%0d div1024=%0d sqrt=%0d inverse=%0d",p1,p2,p3,tail,scale_cycles,sqrt_cycles,inverse_cycles);
 endtask
 initial begin
  if($value$plusargs("PROGRESS_FILE=%s",progress_file))begin progress_fd=$fopen(progress_file,"w");if(!progress_fd)$fatal(1,"PROGRESS_FILE");end
  if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
  if($value$plusargs("ROWS=%d",rows_arg))begin end
  if($value$plusargs("GAMMA=%d",gamma_arg))begin end
  if($value$plusargs("STALL=%d",stall_arg))begin end
  if($value$plusargs("MODE=%d",mode_arg))begin end
  check_public_codec();
  case_name=gamma_arg?"gamma_encoder27":"plain_encoder00";cmd_rows=8'(rows_arg);cmd_gamma=gamma_arg!=0;
  $readmemh({fixture,"/",case_name,"/raw.hex"},gold_raw);$readmemh({fixture,"/",case_name,"/delta.hex"},gold_delta);
  $readmemh({fixture,"/",case_name,"/square.hex"},gold_square);$readmemh({fixture,"/",case_name,"/normalized.hex"},gold_norm);
  $readmemh({fixture,"/",case_name,"/output.hex"},gold_output);$readmemh({fixture,"/",case_name,"/tree1.hex"},gold_tree1);
  $readmemh({fixture,"/",case_name,"/tree2.hex"},gold_tree2);$readmemh({fixture,"/",case_name,"/stats.hex"},gold_stats);
  $readmemh({fixture,"/gamma.hex"},gold_gamma);
  if(mode_arg==15)control_enable=0;
  repeat(4)@(negedge clk);rst_n=1;
  numeric_case=mode_arg==1||mode_arg==3||mode_arg==4;
  if(mode_arg==15)begin
   if(!cmd_gamma)$fatal(1,"disabled gamma test requires GAMMA=1");
   inactive_probe(0);
  end
  if(mode_arg==2&&cmd_gamma)begin
   @(negedge clk);cmd_valid=1;#1;if(cmd_ready||!reject_valid||reject_code!=3)$fatal(1,"missing gamma not rejected");
   @(negedge clk);cmd_valid=0;
  end
  if(cmd_gamma)load_gamma();
  if(mode_arg==15)begin
   repeat(2)@(negedge clk);inactive_probe(1);
   @(negedge clk);control_clear=1;
   #1;if(!control_retired)$fatal(1,"legal idle clear was not retired");
   @(negedge clk);control_clear=0;
   #1;if(!gamma_loaded||protocol_fault||control_q!==0)$fatal(1,"legal retired clear changed gamma or retained q");
   $display("M007_LN_DIRECTED_DISABLED_GAMMA checks=%0d common_reset_qualification=1 persistent_across_disable_clear=1",checked_disabled_cases);
  end
  if(mode_arg==2&&cmd_gamma)begin
   @(negedge clk);cmd_model=cmd_model^1;cmd_valid=1;#1;if(cmd_ready||!reject_valid||reject_code!=3)$fatal(1,"wrong gamma model not rejected");
   @(negedge clk);cmd_model=cmd_model^1;cmd_valid=0;
   // A new coefficient transaction wins an otherwise simultaneous valid LN
   // command. Old loaded coverage must not permit command acceptance here.
   while(!gamma_begin_ready)@(negedge clk);
   gamma_begin_valid=1;cmd_valid=1;#1;
   if(!gamma_begin_ready||cmd_ready)$fatal(1,"simultaneous coefficient begin and LN command both accepted");
   @(posedge clk);@(negedge clk);gamma_begin_valid=0;cmd_valid=0;
   if(gamma_loaded)$fatal(1,"coefficient reload retained old coverage");
   for(int k=0;k<32;k++)begin
    gamma_valid=1;gamma_chunk=5'(k);gamma_data=gold_gamma[k];do @(posedge clk);while(!gamma_ready);@(negedge clk);
   end
   gamma_valid=0;if(!gamma_loaded||gamma_done_error)$fatal(1,"arbitrated coefficient reload failed");
   $display("M007_LN_GAMMA_BEGIN_CMD_ARBITRATION loader_priority=1 coverage_reloaded=32");
  end
  if(mode_arg>=10&&mode_arg!=15)run_protocol_prelude();
  acquire();
  begin_command();
  if(mode_arg==2)begin
   input_enable=0;
   @(negedge clk);#1;in_valid=1;in_request_id=cmd_request_id;in_generation=cmd_generation-1;in_epoch=cmd_epoch;in_row=0;in_chunk=0;in_tag=0;in_data=gold_raw[0];
   #1;if(in_ready||!reject_valid||reject_code!=5)$fatal(1,"old generation not rejected");
   @(negedge clk);#1;in_valid=0;input_waiting=0;input_enable=1;
   wait(trace_scalar_valid[4]);@(negedge clk);input_enable=0;checking=0;
   if(!active||add_pending==0||!ctx_active)$fatal(1,"active reset did not contain real LN work");
   rst_n=0;repeat(3)@(negedge clk);rst_n=1;cmd_generation++;cmd_epoch++;
   repeat(40)begin @(negedge clk);if(add_rsp_valid||mul_rsp_valid||div_rsp_valid||out_valid||done_valid||add_pending||mul_pending||div_pending)$fatal(1,"old LN return after common reset");end
   reset_counts();if(cmd_gamma)load_gamma();acquire();begin_command();
  end
  wait(done_cycle!=0);
  @(negedge clk);input_enable=0;
  if(numeric_case)begin
   if(!done_error||error_stage!=(mode_arg==1?0:mode_arg==3?4:1)||error_row!=0||output_seen!=0||add_pending||mul_pending||div_pending||!bank_idle||out_valid||active)$fatal(1,"numeric error did not drain correct observed stage");
   if(mode_arg==4&&(error_level!=1||error_node!=0))$fatal(1,"actual tree error level/node lost");
   if(observed_numeric_failure_cycle==0||done_cycle-observed_numeric_failure_cycle>128)$fatal(1,"numeric drain not bounded by actual observed failure");
   $display("M007_LN_NUMERIC_DRAIN stage=%0d level=%0d row=%0d node=%0d actual_error_to_done=%0d",error_stage,error_level,error_row,error_node,done_cycle-observed_numeric_failure_cycle);
   retire_command();checking=0;numeric_case=0;reset_counts();cmd_generation++;cmd_epoch++;
   acquire();begin_command();wait(done_cycle!=0);@(negedge clk);input_enable=0;
   $display("M007_LN_NUMERIC_NEWGEN_RECOVERY no_reset=1 rows=%0d",rows_arg);
  end
  begin
   if(done_error)$fatal(1,"unexpected LN numeric error stage=%0d row=%0d node=%0d",error_stage,error_row,error_node);
   if(output_seen!=rows_arg*32||tree_nodes!=rows_arg*2046||delta_words!=rows_arg*1024||square_words!=rows_arg*1024||norm_words!=rows_arg*1024||gamma_words!=(cmd_gamma?rows_arg*1024:0)||scalar_count!=rows_arg*7||bank_words!=rows_arg*2048)$fatal(1,"coverage input=%0d output=%0d tree=%0d delta=%0d square=%0d norm=%0d gamma=%0d scalar=%0d bank=%0d",input_sent,output_seen,tree_nodes,delta_words,square_words,norm_words,gamma_words,scalar_count,bank_words);
   print_stages();
  end
  if(stall_arg&&(max_contexts!=4||held_outputs<1800||row_start[4]<hold_until))$fatal(1,"finite stall did not really fill4 contexts and block fifth row");
  retire_command();
  if(!stall_arg&&rows_arg==128&&done_retired_cycle-command_cycle>16704)$fatal(1,"full128 command through actual done retirement cycle gate %0d",done_retired_cycle-command_cycle);
  $display("M007_LN_DONE_RETIRED command_to_retirement=%0d held_done_release_barrier=1 mode=%0d",done_retired_cycle-command_cycle,mode_arg);
  $display("M007_LN_OFFER_COUNTS scale=%0d sqrt=%0d div=%0d",checked_scale_offer_cycles,checked_sqrt_offer_cycles,checked_div_offer_cycles);
  $display("HARDWARE_AGENT_SIM_PASS M007_LN_ENGINE rows=%0d gamma=%0d stall=%0d first=%0d done=%0d tree_nodes=%0d outputs=%0d max_contexts=%0d held_outputs=%0d peak_add=%0d peak_mul=%0d",rows_arg,gamma_arg,stall_arg,numeric_case?0:first_output[0]-command_cycle,done_cycle-command_cycle,tree_nodes,output_seen,max_contexts,held_outputs,peak_add_pending,peak_mul_pending);$finish;
 end
endmodule
