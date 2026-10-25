`timescale 1ns/1ps
// Autonomous S128 single-head QK / explicitly independent AV bring-up service.
// All payload enters/returns through real QKV/PS/G/context production ports.
module laya_attention_qk_av_engine_v1 #(parameter bit RESIDENT_ONLY=0)(
 input logic clk,rst_n,
 input logic resident_valid,output logic resident_ready,input logic[63:0]resident_request_id,input logic[31:0]resident_generation,resident_epoch,input logic[3:0]resident_head,
 input logic prepare_valid,output logic prepare_ready,
 input logic [63:0] prepare_request_id,
 input logic [31:0] prepare_generation,prepare_epoch,
 input logic [3:0] prepare_head,
 input logic prepare_av,prepare_sliding,input logic [127:0] prepare_mask,
 input logic qkv_wr_valid,output logic qkv_wr_ready,
 input logic [31:0] qkv_wr_generation,
 input logic [1:0] qkv_wr_plane,input logic [6:0] qkv_wr_token,
 input logic qkv_wr_half,input logic [31:0][31:0] qkv_wr_data,
 input logic prob_wr_valid,output logic prob_wr_ready,
 input logic [31:0] prob_wr_generation,
 input logic [6:0] prob_wr_query,prob_wr_keybase,
 input logic [7:0][31:0] prob_wr_data,
 input logic start_valid,output logic start_ready,
 input logic [63:0] start_request_id,input logic [31:0] start_generation,
 input logic abort_valid,output logic abort_ready,
 input logic [2:0] qkv_read_grant,input logic ps_grant,g_grant,context_grant,
 output logic done_valid,input logic done_ready,
 output logic [63:0] done_request_id,output logic [31:0] done_generation,
 output logic [3:0] done_head,output logic done_av,
 output logic [7:0] done_status,
 output logic [31:0] done_cycles,first_score_cycle,first_context_cycle,max_feedback_cycles,
 output logic error_valid,output logic [63:0] error_rank,
 output logic [4:0] error_phase,output logic [3:0] error_tile,
 output logic [31:0] error_element,
 output logic [12:0] root_accepted,score_commits,partial_commits,
 output logic [8:0] context_commits,
 output logic [127:0][31:0] maximum,
 input logic score_rd_valid,output logic score_rd_ready,
 input logic [31:0] score_rd_generation,score_rd_tag,
 input logic [6:0] score_rd_query,score_rd_keybase,
 output logic score_rsp_valid,input logic score_rsp_ready,
 output logic [31:0] score_rsp_tag,output logic [7:0][31:0] score_rsp_data,
 input logic result_rd_valid,output logic result_rd_ready,
 input logic [31:0] result_rd_generation,result_rd_tag,
 input logic [6:0] result_rd_query,input logic result_rd_half,
 output logic result_rsp_valid,input logic result_rsp_ready,
 output logic [31:0] result_rsp_tag,output logic [31:0][31:0] result_rsp_data,
 input logic continue_av_valid,output logic continue_av_ready,output logic engine_idle,
 output logic  res_qkv_wr_valid,
 input logic  res_qkv_wr_ready,
 output logic [1:0] res_qkv_wr_plane,
 output logic [3:0] res_qkv_wr_head,
 output logic [6:0] res_qkv_wr_token,
 output logic  res_qkv_wr_half,
 output logic [31:0][31:0] res_qkv_wr_data,
 output logic [2:0] res_qkv_rd_valid,
 input logic [2:0] res_qkv_rd_ready,
 output logic [2:0][3:0] res_qkv_rd_head,
 output logic [2:0][6:0] res_qkv_rd_token,
 output logic [2:0][31:0] res_qkv_rd_tag,
 input logic [2:0] res_qkv_rd_rsp_valid,
 output logic [2:0] res_qkv_rd_rsp_ready,
 input logic [2:0][3:0] res_qkv_rd_rsp_head,
 input logic [2:0][6:0] res_qkv_rd_rsp_token,
 input logic [2:0][31:0] res_qkv_rd_rsp_tag,
 input logic [2:0][63:0][31:0] res_qkv_rd_rsp_data,
 output logic  res_st_bind_valid,
 input logic  res_st_bind_ready,
 output logic [63:0] res_st_bind_request_id,
 output logic [31:0] res_st_bind_generation,
 output logic [31:0] res_st_bind_epoch,
 output logic [3:0] res_st_bind_head,
 output logic [2:0] res_st_bind_phase,
 output logic [63:0] res_st_op_request_id,
 output logic [31:0] res_st_op_generation,
 output logic [31:0] res_st_op_epoch,
 output logic [2:0] res_st_op_phase,
 input logic [63:0] res_st_rsp_request_id,
 input logic [31:0] res_st_rsp_generation,
 input logic [31:0] res_st_rsp_epoch,
 input logic [3:0] res_st_rsp_head,
 input logic [2:0] res_st_rsp_phase,
 output logic  res_st_ps_wr_valid,
 input logic  res_st_ps_wr_ready,
 output logic [1023:0] res_st_ps_wr_mask,
 output logic [1023:0][3:0] res_st_ps_wr_addr,
 output logic [1023:0][31:0] res_st_ps_wr_data,
 output logic [95:0] res_st_ps_wr_tag,
 input logic  res_st_ps_wr_rsp_valid,
 output logic  res_st_ps_wr_rsp_ready,
 input logic [95:0] res_st_ps_wr_rsp_tag,
 output logic  res_st_ps_rd_valid,
 input logic  res_st_ps_rd_ready,
 output logic [1023:0] res_st_ps_rd_mask,
 output logic [1023:0][3:0] res_st_ps_rd_addr,
 output logic [95:0] res_st_ps_rd_tag,
 input logic  res_st_ps_rd_rsp_valid,
 output logic  res_st_ps_rd_rsp_ready,
 input logic [1023:0][31:0] res_st_ps_rd_rsp_data,
 input logic [1023:0] res_st_ps_rd_rsp_mask,
 input logic [95:0] res_st_ps_rd_rsp_tag,
 output logic  res_st_g_wr_valid,
 input logic  res_st_g_wr_ready,
 output logic [255:0] res_st_g_wr_mask,
 output logic [255:0][5:0] res_st_g_wr_addr,
 output logic [255:0][31:0] res_st_g_wr_data,
 output logic [95:0] res_st_g_wr_tag,
 input logic  res_st_g_wr_rsp_valid,
 output logic  res_st_g_wr_rsp_ready,
 input logic [95:0] res_st_g_wr_rsp_tag,
 output logic  res_st_g_rd_valid,
 input logic  res_st_g_rd_ready,
 output logic [255:0] res_st_g_rd_mask,
 output logic [255:0][5:0] res_st_g_rd_addr,
 output logic [95:0] res_st_g_rd_tag,
 input logic  res_st_g_rd_rsp_valid,
 output logic  res_st_g_rd_rsp_ready,
 input logic [255:0][31:0] res_st_g_rd_rsp_data,
 input logic [255:0] res_st_g_rd_rsp_mask,
 input logic [95:0] res_st_g_rd_rsp_tag,
 output logic  res_st_context_wr_valid,
 input logic  res_st_context_wr_ready,
 output logic [63:0] res_st_context_wr_mask,
 output logic [63:0][10:0] res_st_context_wr_addr,
 output logic [63:0][31:0] res_st_context_wr_data,
 output logic [95:0] res_st_context_wr_tag,
 input logic  res_st_context_wr_rsp_valid,
 output logic  res_st_context_wr_rsp_ready,
 input logic [95:0] res_st_context_wr_rsp_tag,
 output logic  res_st_context_rd_valid,
 input logic  res_st_context_rd_ready,
 output logic [63:0] res_st_context_rd_mask,
 output logic [63:0][10:0] res_st_context_rd_addr,
 output logic [95:0] res_st_context_rd_tag,
 input logic  res_st_context_rd_rsp_valid,
 output logic  res_st_context_rd_rsp_ready,
 input logic [63:0][31:0] res_st_context_rd_rsp_data,
 input logic [63:0] res_st_context_rd_rsp_mask,
 input logic [95:0] res_st_context_rd_rsp_tag,
 input logic  res_st_idle,
 output logic  res_fp_lease_valid,
 input logic  res_fp_lease_ready,
 output logic [63:0] res_fp_lease_request_id,
 output logic [31:0] res_fp_lease_generation,
 output logic [31:0] res_fp_lease_epoch,
 output logic [3:0] res_fp_lease_head,
 output logic [2:0] res_fp_lease_phase,
 output logic  res_fp_release_valid,
 input logic  res_fp_release_ready,
 output logic [2:0] res_fp_release_phase,
 output logic [31:0] res_fp_release_epoch,
 output logic  res_fp_phase_debt_clear,
 input logic  res_fp_lease_active,
 input logic  res_fp_draining,
 input logic [63:0] res_fp_rsp_request_id,
 input logic [31:0] res_fp_rsp_generation,
 input logic [31:0] res_fp_rsp_epoch,
 input logic [3:0] res_fp_rsp_head,
 input logic [2:0] res_fp_rsp_phase,
 output logic  res_fp_mul_req_valid,
 input logic  res_fp_mul_req_ready,
 output logic [2:0] res_fp_mul_req_phase,
 output logic [31:0] res_fp_mul_req_epoch,
 output logic [95:0] res_fp_mul_req_tag,
 output logic [256-1:0][31:0] res_fp_mul_a,
 output logic [256-1:0][31:0] res_fp_mul_b,
 input logic  res_fp_mul_rsp_valid,
 output logic  res_fp_mul_rsp_ready,
 input logic [95:0] res_fp_mul_rsp_tag,
 input logic [256-1:0][31:0] res_fp_mul_rsp_data,
 output logic [7-1:0] res_fp_add_req_valid,
 output logic [7-1:0] res_fp_add_req_is_root,
 input logic [7-1:0] res_fp_add_req_ready,
 output logic [7-1:0][2:0] res_fp_add_req_phase,
 output logic [7-1:0][31:0] res_fp_add_req_epoch,
 output logic [7-1:0][95:0] res_fp_add_req_tag,
 output logic [256-1:0][31:0] res_fp_add_a,
 output logic [256-1:0][31:0] res_fp_add_b,
 input logic [7-1:0] res_fp_add_rsp_valid,
 output logic [7-1:0] res_fp_add_rsp_ready,
 input logic [7-1:0][95:0] res_fp_add_rsp_tag,
 input logic [256-1:0][31:0] res_fp_add_rsp_data,
 input logic [6:0] res_fp_mul_pending,
 input logic [7-1:0][6:0] res_fp_add_pending,
 input logic  res_fp_protocol_fault,
 output logic  res_scale_valid,
 input logic  res_scale_ready,
 output logic [95:0] res_scale_tag,
 output logic [3:0][31:0] res_scale_input,
 input logic  res_scale_rsp_valid,
 output logic  res_scale_rsp_ready,
 input logic [95:0] res_scale_rsp_tag,
 input logic [3:0][31:0] res_scale_data,
 input logic [6:0] res_scale_pending,
 input logic  res_scale_fault
);
 localparam IDLE=0,PREP=1,CLAIM=2,QK=3,AV=4,RETIRE=5,DONE=6,RELEASE=7;
 logic [3:0] state;
 logic [63:0] request_id;
 logic [31:0] generation,epoch;
 logic [3:0] head;logic mode_av,sliding;
 logic [127:0] mask;
 wire input_coverage_complete,prep_cancelled;
 logic aborted,protocol_bad,prep_bad,last_success;
 logic [31:0] clock_count,start_stamp;
 logic [2:0] phase;
 wire resident_fire=resident_valid&&resident_ready;
 assign resident_ready=state==PREP&&!mode_av&&resident_request_id==request_id&&resident_generation==generation&&resident_epoch==epoch&&resident_head==head;
 wire prep_fire=prepare_valid&&prepare_ready;
 wire continue_fire=continue_av_valid&&continue_av_ready;
 wire start_fire=(start_valid&&start_ready)||continue_fire;
 assign continue_av_ready=state==IDLE&&last_success&&!mode_av;assign engine_idle=state==IDLE;
 wire abort_fire=abort_valid&&abort_ready;
 wire root_stop=aborted||abort_fire;
 assign phase=mode_av?3'd4:3'd2;
 assign done_request_id=request_id;assign done_generation=generation;
 assign done_head=head;assign done_av=mode_av;
 assign done_valid=state==DONE;
 assign done_status=protocol_bad?8'd3:aborted?8'd2:error_valid?8'd1:8'd0;
 assign abort_ready=(state==CLAIM||state==QK||state==AV||state==RETIRE||(RESIDENT_ONLY&&state==PREP&&!mode_av))&&!aborted;
 function automatic bit finite(input logic [31:0] x);return x[30:23]!=255;endfunction
 function automatic bit greater(input logic [31:0] a,b);
  if(a[30:0]==0&&b[30:0]==0)return 0;
  if(a[31]!=b[31])return !a[31];
  return a[31]?a[30:0]<b[30:0]:a[30:0]>b[30:0];
 endfunction
 function automatic int score_bank(input int q,k);return (k/64)*512+(q%16)*32+k%32;endfunction
 function automatic int score_addr(input int q,k);return (q/16)*2+(k%64)/32;endfunction
 function automatic int prob_bank(input int q,k);return(q%8)*32+k%32;endfunction
 function automatic int prob_addr(input int q,k);return(q/8)*4+k/32;endfunction
 function automatic int av_bank(input int q,c);return(q%8)*64+c;endfunction
 function automatic [63:0] qrank(input int q,k,level,node);
  // Products and each tree phase for an entire8query tile precede next tile.
  if(level==7)return 64'h3000000000000000|(64'(q)<<16)|64'(k);
  return 64'h1000000000000000|(64'(q/8)<<48)|(64'(level)<<40)|(64'(q%8)<<32)|(64'(k)<<16)|64'(node);
 endfunction
 function automatic [63:0] arank(input int q,k,level,c);
  return 64'h2000000000000000|(64'(k)<<48)|(64'(level)<<40)|(64'(q)<<16)|64'(c);
 endfunction
 function automatic int alo(input int g);case(g)0:return 0;1:return 128;2:return 192;3:return 224;4:return 240;5:return 248;default:return 252;endcase endfunction
 function automatic int an(input int g);case(g)0:return 128;1:return 64;2:return 32;3:return 16;4:return 8;default:return 4;endcase endfunction
 logic [2:0] qr_valid,qr_ready,qr_rsp_valid,qr_rsp_ready;
 logic [2:0][3:0] qr_head,qr_rsp_head;
 logic [2:0][6:0] qr_token,qr_rsp_token;
 logic [2:0][31:0] qr_tag,qr_rsp_tag;
 logic [2:0][63:0][31:0] qr_rsp_data;
 logic qwr_ready;
 wire qwr_domain=!RESIDENT_ONLY&&state==PREP&&qkv_wr_generation==generation&&qkv_wr_plane<3;
 assign qkv_wr_ready=qwr_domain&&qwr_ready;

 logic lease_ready;
 logic storage_bind_ready,storage_idle;
 logic [63:0] storage_request_id;logic [31:0] storage_generation,storage_epoch;
 logic [3:0] storage_head;logic [2:0] storage_phase;
 logic ps_wr_valid,ps_wr_ready,ps_wr_rsp_valid,ps_wr_rsp_ready;
 logic [1023:0] ps_wr_mask;logic [1023:0][3:0] ps_wr_addr;logic [1023:0][31:0] ps_wr_data;
 logic [95:0] ps_wr_tag,ps_wr_rsp_tag;
 logic ps_rd_valid,ps_rd_ready,ps_rd_rsp_valid,ps_rd_rsp_ready;
 logic [1023:0] ps_rd_mask,ps_rd_rsp_mask;logic [1023:0][3:0] ps_rd_addr;logic [1023:0][31:0] ps_rd_rsp_data;
 logic [95:0] ps_rd_tag,ps_rd_rsp_tag;
 logic g_wr_valid,g_wr_ready,g_wr_rsp_valid,g_wr_rsp_ready;
 logic [255:0] g_wr_mask;logic [255:0][5:0] g_wr_addr;logic [255:0][31:0] g_wr_data;
 logic [95:0] g_wr_tag,g_wr_rsp_tag;
 logic g_rd_valid,g_rd_ready,g_rd_rsp_valid,g_rd_rsp_ready;
 logic [255:0] g_rd_mask,g_rd_rsp_mask;logic [255:0][5:0] g_rd_addr;logic [255:0][31:0] g_rd_rsp_data;
 logic [95:0] g_rd_tag,g_rd_rsp_tag;
 logic context_wr_valid,context_wr_ready,context_wr_rsp_valid,context_wr_rsp_ready;
 logic [63:0] context_wr_mask;logic [63:0][10:0] context_wr_addr;logic [63:0][31:0] context_wr_data;
 logic [95:0] context_wr_tag,context_wr_rsp_tag;
 logic context_rd_valid,context_rd_ready,context_rd_rsp_valid,context_rd_rsp_ready;
 logic [63:0] context_rd_mask,context_rd_rsp_mask;logic [63:0][10:0] context_rd_addr;logic [63:0][31:0] context_rd_rsp_data;
 logic [95:0] context_rd_tag,context_rd_rsp_tag;


 logic release_ready,fp_owned,fp_draining,fp_fault;
 logic [63:0] fp_request_id;logic [31:0] fp_generation,fp_epoch;
 logic [3:0] fp_head;logic [2:0] fp_phase;
 logic m_valid,m_ready,m_rsp_valid,m_rsp_ready;
 logic [95:0] m_tag,m_rsp_tag;
 logic [255:0][31:0] ma,mb,m_data;
 logic [6:0] a_valid,a_ready,a_root,a_rsp_valid,a_rsp_ready;
 logic [6:0][2:0] a_phase;
 logic [6:0][31:0] a_epoch;
 logic [6:0][95:0] a_tag,a_rsp_tag;
 logic [255:0][31:0] aa,ab,a_data;
 logic [6:0] m_pending;
 logic [6:0][6:0] a_pending;
 logic scale_ready,scale_valid,scale_rsp_valid,scale_rsp_ready,scale_fault;
 logic [95:0] scale_tag,scale_rsp_tag;
 logic [3:0][31:0] scale_input,scale_output,scale_data;

 logic [6:0] scale_pending,scale_inflight;
 logic [1:0][3:0][63:0][31:0] q_hold;
 logic [1:0] q_hold_ready;
 logic [1:0][4:0] q_hold_group;
 logic [5:0] q_load_group,qk_read_group;
 logic [1:0] q_load_row;
 logic [6:0] qk_read_key;
 logic [7:0] v_next_read,av_read_key;
 logic [4:0] av_read_group;
 logic [63:0][31:0] v_hold;
 logic [6:0] v_hold_key;logic v_hold_valid;
 logic product_hold_valid;
 logic [255:0][31:0] product_hold;
 logic [95:0] product_hold_tag;
 logic [31:0] busy;
 logic [31:0][7:0] next_key;
 logic [31:0][31:0] feedback_stamp;
 logic [5:0] retire_group;
 logic [2:0] retire_beat;
 logic [6:0][12:0] tree_returns;
 logic [12:0] scale_returns;
 wire m_fire=m_valid&&m_ready;
 wire a0_fire=a_valid[0]&&a_ready[0];
 wire ps_rfire=ps_rd_valid&&ps_rd_ready;
 wire ps_wfire=ps_wr_valid&&ps_wr_ready;
 wire ctx_wfire=context_wr_valid&&context_wr_ready;
 wire active_compute=state==QK||state==AV||state==RETIRE;
 wire local_idle=storage_idle&&qr_rsp_valid==0&&!product_hold_valid&&scale_pending==0;
 assign prepare_ready=(!RESIDENT_ONLY||!prepare_av)&&state==IDLE&&storage_bind_ready&&lease_ready&&qr_rsp_valid==0;
 assign start_ready=state==PREP&&!(RESIDENT_ONLY&&abort_valid)&&start_request_id==request_id&&start_generation==generation&&
  input_coverage_complete;


 assign res_qkv_wr_valid=qkv_wr_valid&&qwr_domain;
 assign qwr_ready=res_qkv_wr_ready;
 assign res_qkv_wr_plane=qkv_wr_plane;
 assign res_qkv_wr_head=head;
 assign res_qkv_wr_token=qkv_wr_token;
 assign res_qkv_wr_half=qkv_wr_half;
 assign res_qkv_wr_data=qkv_wr_data;
 assign res_qkv_rd_valid=qr_valid;
 assign qr_ready=res_qkv_rd_ready;
 assign res_qkv_rd_head=qr_head;
 assign res_qkv_rd_token=qr_token;
 assign res_qkv_rd_tag=qr_tag;
 assign qr_rsp_valid=res_qkv_rd_rsp_valid;
 assign res_qkv_rd_rsp_ready=qr_rsp_ready;
 assign qr_rsp_head=res_qkv_rd_rsp_head;
 assign qr_rsp_token=res_qkv_rd_rsp_token;
 assign qr_rsp_tag=res_qkv_rd_rsp_tag;
 assign qr_rsp_data=res_qkv_rd_rsp_data;
 assign res_st_bind_valid=prepare_valid&&state==IDLE&&lease_ready&&qr_rsp_valid==0;
 assign storage_bind_ready=res_st_bind_ready;
 assign res_st_bind_request_id=prepare_request_id;
 assign res_st_bind_generation=prepare_generation;
 assign res_st_bind_epoch=prepare_epoch;
 assign res_st_bind_head=prepare_head;
 assign res_st_bind_phase=prepare_av?3'd4:3'd2;
 assign res_st_op_request_id=request_id;
 assign res_st_op_generation=generation;
 assign res_st_op_epoch=epoch;
 assign res_st_op_phase=phase;
 assign storage_request_id=res_st_rsp_request_id;
 assign storage_generation=res_st_rsp_generation;
 assign storage_epoch=res_st_rsp_epoch;
 assign storage_head=res_st_rsp_head;
 assign storage_phase=res_st_rsp_phase;
 assign res_st_ps_wr_valid=ps_wr_valid;
 assign ps_wr_ready=res_st_ps_wr_ready;
 assign res_st_ps_wr_mask=ps_wr_mask;
 assign res_st_ps_wr_addr=ps_wr_addr;
 assign res_st_ps_wr_data=ps_wr_data;
 assign res_st_ps_wr_tag=ps_wr_tag;
 assign ps_wr_rsp_valid=res_st_ps_wr_rsp_valid;
 assign res_st_ps_wr_rsp_ready=ps_wr_rsp_ready;
 assign ps_wr_rsp_tag=res_st_ps_wr_rsp_tag;
 assign res_st_ps_rd_valid=ps_rd_valid;
 assign ps_rd_ready=res_st_ps_rd_ready;
 assign res_st_ps_rd_mask=ps_rd_mask;
 assign res_st_ps_rd_addr=ps_rd_addr;
 assign res_st_ps_rd_tag=ps_rd_tag;
 assign ps_rd_rsp_valid=res_st_ps_rd_rsp_valid;
 assign res_st_ps_rd_rsp_ready=ps_rd_rsp_ready;
 assign ps_rd_rsp_data=res_st_ps_rd_rsp_data;
 assign ps_rd_rsp_mask=res_st_ps_rd_rsp_mask;
 assign ps_rd_rsp_tag=res_st_ps_rd_rsp_tag;
 assign res_st_g_wr_valid=g_wr_valid;
 assign g_wr_ready=res_st_g_wr_ready;
 assign res_st_g_wr_mask=g_wr_mask;
 assign res_st_g_wr_addr=g_wr_addr;
 assign res_st_g_wr_data=g_wr_data;
 assign res_st_g_wr_tag=g_wr_tag;
 assign g_wr_rsp_valid=res_st_g_wr_rsp_valid;
 assign res_st_g_wr_rsp_ready=g_wr_rsp_ready;
 assign g_wr_rsp_tag=res_st_g_wr_rsp_tag;
 assign res_st_g_rd_valid=g_rd_valid;
 assign g_rd_ready=res_st_g_rd_ready;
 assign res_st_g_rd_mask=g_rd_mask;
 assign res_st_g_rd_addr=g_rd_addr;
 assign res_st_g_rd_tag=g_rd_tag;
 assign g_rd_rsp_valid=res_st_g_rd_rsp_valid;
 assign res_st_g_rd_rsp_ready=g_rd_rsp_ready;
 assign g_rd_rsp_data=res_st_g_rd_rsp_data;
 assign g_rd_rsp_mask=res_st_g_rd_rsp_mask;
 assign g_rd_rsp_tag=res_st_g_rd_rsp_tag;
 assign res_st_context_wr_valid=context_wr_valid;
 assign context_wr_ready=res_st_context_wr_ready;
 assign res_st_context_wr_mask=context_wr_mask;
 assign res_st_context_wr_addr=context_wr_addr;
 assign res_st_context_wr_data=context_wr_data;
 assign res_st_context_wr_tag=context_wr_tag;
 assign context_wr_rsp_valid=res_st_context_wr_rsp_valid;
 assign res_st_context_wr_rsp_ready=context_wr_rsp_ready;
 assign context_wr_rsp_tag=res_st_context_wr_rsp_tag;
 assign res_st_context_rd_valid=context_rd_valid;
 assign context_rd_ready=res_st_context_rd_ready;
 assign res_st_context_rd_mask=context_rd_mask;
 assign res_st_context_rd_addr=context_rd_addr;
 assign res_st_context_rd_tag=context_rd_tag;
 assign context_rd_rsp_valid=res_st_context_rd_rsp_valid;
 assign res_st_context_rd_rsp_ready=context_rd_rsp_ready;
 assign context_rd_rsp_data=res_st_context_rd_rsp_data;
 assign context_rd_rsp_mask=res_st_context_rd_rsp_mask;
 assign context_rd_rsp_tag=res_st_context_rd_rsp_tag;
 assign storage_idle=res_st_idle;
 assign res_fp_lease_valid=state==CLAIM;
 assign lease_ready=res_fp_lease_ready;
 assign res_fp_lease_request_id=request_id;
 assign res_fp_lease_generation=generation;
 assign res_fp_lease_epoch=epoch;
 assign res_fp_lease_head=head;
 assign res_fp_lease_phase=phase;
 assign res_fp_release_valid=state==RELEASE&&!prep_cancelled;
 assign release_ready=res_fp_release_ready;
 assign res_fp_release_phase=phase;
 assign res_fp_release_epoch=epoch;
 assign res_fp_phase_debt_clear=local_idle;
 assign fp_owned=res_fp_lease_active;
 assign fp_draining=res_fp_draining;
 assign fp_request_id=res_fp_rsp_request_id;
 assign fp_generation=res_fp_rsp_generation;
 assign fp_epoch=res_fp_rsp_epoch;
 assign fp_head=res_fp_rsp_head;
 assign fp_phase=res_fp_rsp_phase;
 assign res_fp_mul_req_valid=m_valid;
 assign m_ready=res_fp_mul_req_ready;
 assign res_fp_mul_req_phase=phase;
 assign res_fp_mul_req_epoch=epoch;
 assign res_fp_mul_req_tag=m_tag;
 assign res_fp_mul_a=ma;
 assign res_fp_mul_b=mb;
 assign m_rsp_valid=res_fp_mul_rsp_valid;
 assign res_fp_mul_rsp_ready=m_rsp_ready;
 assign m_rsp_tag=res_fp_mul_rsp_tag;
 assign m_data=res_fp_mul_rsp_data;
 assign res_fp_add_req_valid=a_valid;
 assign res_fp_add_req_is_root=a_root;
 assign a_ready=res_fp_add_req_ready;
 assign res_fp_add_req_phase=a_phase;
 assign res_fp_add_req_epoch=a_epoch;
 assign res_fp_add_req_tag=a_tag;
 assign res_fp_add_a=aa;
 assign res_fp_add_b=ab;
 assign a_rsp_valid=res_fp_add_rsp_valid;
 assign res_fp_add_rsp_ready=a_rsp_ready;
 assign a_rsp_tag=res_fp_add_rsp_tag;
 assign a_data=res_fp_add_rsp_data;
 assign m_pending=res_fp_mul_pending;
 assign a_pending=res_fp_add_pending;
 assign fp_fault=res_fp_protocol_fault;
 assign res_scale_valid=scale_valid;
 assign scale_ready=res_scale_ready;
 assign res_scale_tag=scale_tag;
 assign res_scale_input=scale_input;
 assign scale_rsp_valid=res_scale_rsp_valid;
 assign res_scale_rsp_ready=scale_rsp_ready;
 assign scale_rsp_tag=res_scale_rsp_tag;
 assign scale_data=res_scale_data;
 assign scale_pending=res_scale_pending;
 assign scale_fault=res_scale_fault;
 // Pure port selection: every operation still traverses actual bank/FP handshakes.
 always_comb begin
  qr_valid=0;qr_head={3{head}};qr_token=0;qr_tag=0;qr_rsp_ready=0;
  m_valid=0;m_tag=0;ma=0;mb=0;m_rsp_ready=0;
  a_valid=0;a_root=0;a_tag=0;aa=0;ab=0;a_rsp_ready=0;
  for(int g=0;g<7;g++)begin a_phase[g]=phase;a_epoch[g]=epoch;end
  scale_valid=0;scale_tag=0;scale_input=0;scale_rsp_ready=0;
  ps_wr_valid=0;ps_wr_mask=0;ps_wr_addr=0;ps_wr_data=0;ps_wr_tag=0;ps_wr_rsp_ready=1;
  ps_rd_valid=0;ps_rd_mask=0;ps_rd_addr=0;ps_rd_tag=0;ps_rd_rsp_ready=0;
  g_wr_valid=0;g_wr_mask=0;g_wr_addr=0;g_wr_data=0;g_wr_tag=0;g_wr_rsp_ready=1;
  g_rd_valid=0;g_rd_mask=0;g_rd_addr=0;g_rd_tag=0;g_rd_rsp_ready=0;
  context_wr_valid=0;context_wr_mask=0;context_wr_addr=0;context_wr_data=0;context_wr_tag=0;context_wr_rsp_ready=1;
  context_rd_valid=0;context_rd_mask=0;context_rd_addr=0;context_rd_tag=0;context_rd_rsp_ready=0;
  prob_wr_ready=0;score_rd_ready=0;score_rsp_valid=0;score_rsp_tag=ps_rd_rsp_tag[31:0];score_rsp_data=0;
  result_rd_ready=0;result_rsp_valid=0;result_rsp_tag=context_rd_rsp_tag[31:0];result_rsp_data=0;
  if(!RESIDENT_ONLY&&state==PREP&&mode_av&&prob_wr_generation==generation&&prob_wr_keybase[2:0]==0)begin
   g_wr_valid=prob_wr_valid&&g_grant;g_wr_tag={82'b0,prob_wr_query,prob_wr_keybase};
   for(int i=0;i<8;i++)begin
    g_wr_mask[prob_bank(int'(prob_wr_query),int'(prob_wr_keybase)+i)]=1;
    g_wr_addr[prob_bank(int'(prob_wr_query),int'(prob_wr_keybase)+i)]=6'(prob_addr(int'(prob_wr_query),int'(prob_wr_keybase)+i));
    g_wr_data[prob_bank(int'(prob_wr_query),int'(prob_wr_keybase)+i)]=prob_wr_data[i];
   end
   prob_wr_ready=g_wr_ready&&g_grant;
  end
  if(state==QK)begin
   if(!root_stop&&q_load_group<32&&!q_hold_ready[q_load_group[0]])begin
    qr_valid[0]=qkv_read_grant[0];qr_token[0]=7'(q_load_group*4+q_load_row);qr_tag[0]=32'(q_load_group*4+q_load_row);
   end
   qr_rsp_ready[0]=1;
   if(!root_stop&&qk_read_group<32&&q_hold_ready[qk_read_group[0]]&&q_hold_group[qk_read_group[0]]==qk_read_group[4:0])begin
    qr_valid[1]=qkv_read_grant[1];qr_token[1]=qk_read_key;qr_tag[1]={20'b0,qk_read_group[4:0],qk_read_key};
   end
   m_valid=qr_rsp_valid[1]&&!root_stop;m_tag={64'b0,qr_rsp_tag[1]};
   for(int q=0;q<4;q++)for(int c=0;c<64;c++)begin ma[q*64+c]=q_hold[qr_rsp_tag[1][7]][q][c];mb[q*64+c]=qr_rsp_data[1][c];end
   qr_rsp_ready[1]=root_stop||m_ready;
   // Six exact adjacent tree levels share their fixed physical lane ranges.
   a_valid[0]=m_rsp_valid;m_rsp_ready=a_ready[0];a_tag[0]=m_rsp_tag;
   for(int q=0;q<4;q++)for(int n=0;n<32;n++)begin aa[q*32+n]=m_data[q*64+n*2];ab[q*32+n]=m_data[q*64+n*2+1];end
   for(int g=1;g<6;g++)begin
    a_valid[g]=a_rsp_valid[g-1];a_rsp_ready[g-1]=a_ready[g];a_tag[g]=a_rsp_tag[g-1];
    for(int q=0;q<4;q++)for(int n=0;n<(an(g)/4);n++)begin
     aa[alo(g)+q*(an(g)/4)+n]=a_data[alo(g-1)+q*(an(g-1)/4)+n*2];
     ab[alo(g)+q*(an(g)/4)+n]=a_data[alo(g-1)+q*(an(g-1)/4)+n*2+1];
    end
   end
   scale_valid=a_rsp_valid[5];scale_tag=a_rsp_tag[5];a_rsp_ready[5]=scale_ready;
   for(int q=0;q<4;q++)scale_input[q]=a_data[248+q];
   a_valid[6]=scale_rsp_valid;scale_rsp_ready=a_ready[6];a_tag[6]=scale_rsp_tag;
   for(int q=0;q<4;q++)begin
    int query,key,bad;query=int'(scale_rsp_tag[11:7])*4+q;key=int'(scale_rsp_tag[6:0]);
    bad=(!mask[key]?1:0)+((sliding&&((query-key>64)||(key-query>64)))?1:0);
    aa[252+q]=scale_data[q];ab[252+q]=bad==0?32'h00000000:bad==1?32'hc61c4000:32'hc69c4000;
   end
   ps_wr_valid=a_rsp_valid[6]&&ps_grant;ps_wr_tag=a_rsp_tag[6];a_rsp_ready[6]=ps_wr_ready&&ps_grant;
   for(int q=0;q<4;q++)begin
    int query,key,b;query=int'(a_rsp_tag[6][11:7])*4+q;key=int'(a_rsp_tag[6][6:0]);b=score_bank(query,key);
    ps_wr_mask[b]=1;ps_wr_addr[b]=4'(score_addr(query,key));ps_wr_data[b]=a_data[252+q];
   end
  end
  if(state==AV)begin
   if(!root_stop&&v_next_read<128&&(v_next_read==0||(v_hold_valid&&v_next_read=={1'b0,v_hold_key}+1)))begin
    qr_valid[2]=qkv_read_grant[2];qr_token[2]=v_next_read[6:0];qr_tag[2]=32'(v_next_read);
   end
   qr_rsp_ready[2]=root_stop||!v_hold_valid||(m_fire&&m_tag[4:0]==31);
   if(!root_stop&&av_read_key<128&&((v_hold_valid&&av_read_key=={1'b0,v_hold_key})||
      (v_hold_valid&&av_read_key=={1'b0,v_hold_key}+1&&qr_rsp_valid[2]&&qr_rsp_token[2]==av_read_key[6:0])))begin
    g_rd_valid=g_grant;g_rd_tag={84'b0,av_read_key[6:0],av_read_group};
    for(int q=0;q<4;q++)begin
     int row,b;row=int'(av_read_group)*4+q;b=prob_bank(row,int'(av_read_key));g_rd_mask[b]=1;g_rd_addr[b]=6'(prob_addr(row,int'(av_read_key)));
    end
   end
   m_valid=g_rd_rsp_valid&&v_hold_valid&&g_rd_rsp_tag[11:5]==v_hold_key&&!root_stop;m_tag=g_rd_rsp_tag;
   for(int q=0;q<4;q++)for(int c=0;c<64;c++)begin
    ma[q*64+c]=g_rd_rsp_data[prob_bank(int'(g_rd_rsp_tag[4:0])*4+q,int'(g_rd_rsp_tag[11:5]))];mb[q*64+c]=v_hold[c];
   end
   g_rd_rsp_ready=root_stop||(m_valid&&m_ready);
   // One elastic product slot aligns actual PS read response with its product.
   if(m_rsp_valid&&(!product_hold_valid||a0_fire)&&!busy[m_rsp_tag[4:0]]&&ps_grant)begin
    ps_rd_valid=1;ps_rd_tag=m_rsp_tag;
    for(int q=0;q<4;q++)for(int c=0;c<64;c++)begin
     int row,b;row=int'(m_rsp_tag[4:0])*4+q;b=av_bank(row,c);ps_rd_mask[b]=1;ps_rd_addr[b]=4'(row/8);
    end
    m_rsp_ready=ps_rd_ready;
   end
   a_valid[0]=ps_rd_rsp_valid&&product_hold_valid;
   a_tag[0]=product_hold_tag;
   for(int q=0;q<4;q++)for(int c=0;c<64;c++)begin
    int row;row=int'(product_hold_tag[4:0])*4+q;
    aa[q*64+c]=product_hold_tag[11:5]==0?32'b0:ps_rd_rsp_data[av_bank(row,c)];ab[q*64+c]=product_hold[q*64+c];
   end
   ps_rd_rsp_ready=product_hold_valid&&a_ready[0];
   ps_wr_valid=a_rsp_valid[0]&&ps_grant;ps_wr_tag=a_rsp_tag[0];a_rsp_ready[0]=ps_wr_ready&&ps_grant;
   for(int q=0;q<4;q++)for(int c=0;c<64;c++)begin
    int row,b;row=int'(a_rsp_tag[0][4:0])*4+q;b=av_bank(row,c);ps_wr_mask[b]=1;ps_wr_addr[b]=4'(row/8);ps_wr_data[b]=a_data[q*64+c];
   end
  end
  if(state==RETIRE&&!root_stop)begin
   if(retire_group<32&&ps_grant)begin
    ps_rd_valid=1;ps_rd_tag={90'b0,retire_group};
    for(int q=0;q<4;q++)for(int c=0;c<64;c++)begin int row,b;row=int'(retire_group)*4+q;b=av_bank(row,c);ps_rd_mask[b]=1;ps_rd_addr[b]=4'(row/8);end
   end
   context_wr_valid=ps_rd_rsp_valid&&context_grant;
   context_wr_tag={88'b0,ps_rd_rsp_tag[4:0],retire_beat};
   for(int c=0;c<32;c++)begin
    int row,channel;row=int'(ps_rd_rsp_tag[4:0])*4+int'(retire_beat[2:1]);channel=int'(retire_beat[0])*32+c;
    context_wr_mask[channel]=1;context_wr_addr[channel]={head,7'(row)};
    context_wr_data[channel]=ps_rd_rsp_data[av_bank(row,channel)];
   end
   ps_rd_rsp_ready=context_wr_ready&&context_grant&&retire_beat==7;
  end
  // An accepted public read response remains visible across DONE consumption.
  // RELEASE prohibits new reads and waits on the real response debt.
  if((state==IDLE&&last_success)||(state==DONE&&done_status==0)||(state==RELEASE&&last_success))begin
   if(state!=RELEASE&&!mode_av&&score_rd_generation==generation&&score_rd_keybase[2:0]==0)begin
    ps_rd_valid=score_rd_valid&&ps_grant;ps_rd_tag={50'b0,score_rd_query,score_rd_keybase,score_rd_tag};
    for(int i=0;i<8;i++)begin int b;b=score_bank(int'(score_rd_query),int'(score_rd_keybase)+i);ps_rd_mask[b]=1;ps_rd_addr[b]=4'(score_addr(int'(score_rd_query),int'(score_rd_keybase)+i));end
    score_rd_ready=ps_rd_ready&&ps_grant;
   end
   score_rsp_valid=ps_rd_rsp_valid&&!mode_av;ps_rd_rsp_ready=score_rsp_ready&&!mode_av;
   for(int i=0;i<8;i++)score_rsp_data[i]=ps_rd_rsp_data[score_bank(int'(ps_rd_rsp_tag[45:39]),int'(ps_rd_rsp_tag[38:32])+i)];
   if(state!=RELEASE&&mode_av&&result_rd_generation==generation)begin
    context_rd_valid=result_rd_valid;context_rd_tag={56'b0,result_rd_query,result_rd_half,result_rd_tag};
    for(int c=0;c<32;c++)begin int channel;channel=int'(result_rd_half)*32+c;context_rd_mask[channel]=1;context_rd_addr[channel]={head,result_rd_query};end
    result_rd_ready=context_rd_ready;
   end
   result_rsp_valid=context_rd_rsp_valid&&mode_av;context_rd_rsp_ready=result_rsp_ready&&mode_av;
   for(int c=0;c<32;c++)result_rsp_data[c]=context_rd_rsp_data[int'(context_rd_rsp_tag[32])*32+c];
  end
  // Aborting discards only bank reads not accepted into FP. Existing FP debts
  // still traverse dependent tree/add/write paths and never publish success.
  if(root_stop)begin
   qr_valid=0;qr_rsp_ready='1;g_rd_valid=0;g_rd_rsp_ready=1;m_valid=0;
   if(state==RETIRE)begin ps_rd_valid=0;ps_rd_rsp_ready=1;context_wr_valid=0;end
  end
 end
 // Head-local Check candidates reduce logical rank, not physical arrival.
 logic incoming_bad;logic [63:0] incoming_rank;logic [4:0] incoming_phase;logic [3:0] incoming_tile;logic [31:0] incoming_element;
 task automatic candidate(input logic [63:0] rank,input int ph,tile,element);
  if(!incoming_bad||rank<incoming_rank)begin incoming_bad=1;incoming_rank=rank;incoming_phase=5'(ph);incoming_tile=4'(tile);incoming_element=32'(element);end
 endtask
 always_comb begin
  incoming_bad=0;incoming_rank='1;incoming_phase=0;incoming_tile=0;incoming_element=0;
  if(qkv_wr_valid&&qkv_wr_ready)for(int c=0;c<32;c++)if(!finite(qkv_wr_data[c]))
   candidate(64'(int'(qkv_wr_token)*192+int'(qkv_wr_plane)*64+int'(qkv_wr_half)*32+c),31,int'(qkv_wr_token)/8,int'(qkv_wr_token)*192+int'(qkv_wr_plane)*64+int'(qkv_wr_half)*32+c);
  if(prob_wr_valid&&prob_wr_ready)for(int i=0;i<8;i++)if(!finite(prob_wr_data[i]))candidate(64'(int'(prob_wr_query)*128+int'(prob_wr_keybase)+i),30,int'(prob_wr_query)/8,int'(prob_wr_query)*128+int'(prob_wr_keybase)+i);
  if(state==QK)begin
   if(m_rsp_valid&&m_rsp_ready)for(int q=0;q<4;q++)for(int c=0;c<64;c++)if(!finite(m_data[q*64+c]))candidate(qrank(int'(m_rsp_tag[11:7])*4+q,int'(m_rsp_tag[6:0]),0,c),0,int'(m_rsp_tag[11:7])/2,((int'(m_rsp_tag[11:7])%2)*4+q)*128*64+int'(m_rsp_tag[6:0])*64+c);
   for(int g=0;g<7;g++)if(a_rsp_valid[g]&&a_rsp_ready[g])for(int q=0;q<4;q++)for(int n=0;n<an(g)/4;n++)if(!finite(a_data[alo(g)+q*(an(g)/4)+n]))
    candidate(qrank(int'(a_rsp_tag[g][11:7])*4+q,int'(a_rsp_tag[g][6:0]),g==6?7:g+1,n),g==6?7:g+1,int'(a_rsp_tag[g][11:7])/2,((int'(a_rsp_tag[g][11:7])%2)*4+q)*128*(an(g)/4)+int'(a_rsp_tag[g][6:0])*(an(g)/4)+n);
  end
  if(state==AV)begin
   if(m_rsp_valid&&m_rsp_ready)for(int q=0;q<4;q++)for(int c=0;c<64;c++)if(!finite(m_data[q*64+c]))candidate(arank(int'(m_rsp_tag[4:0])*4+q,int'(m_rsp_tag[11:5]),0,c),16,int'(m_rsp_tag[4:0])/2,(int'(m_rsp_tag[4:0])*4+q)*64+c);
   if(a_rsp_valid[0]&&a_rsp_ready[0])for(int q=0;q<4;q++)for(int c=0;c<64;c++)if(!finite(a_data[q*64+c]))candidate(arank(int'(a_rsp_tag[0][4:0])*4+q,int'(a_rsp_tag[0][11:5]),1,c),17,int'(a_rsp_tag[0][4:0])/2,(int'(a_rsp_tag[0][4:0])*4+q)*64+c);
  end
 end
 generate if(RESIDENT_ONLY)begin:resident_input
  logic accepted,cancelled;
  assign prep_cancelled=cancelled;
  always_ff@(posedge clk)begin
   if(!rst_n||prep_fire)begin accepted<=0;cancelled<=0;end
   else begin if(resident_fire)accepted<=1;if(state==PREP&&abort_fire)cancelled<=1;end
  end
  assign input_coverage_complete=accepted&&!mode_av;
 end else begin:independent_input
  assign prep_cancelled=1'b0;
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
 end endgenerate
 always_ff @(posedge clk)begin
  if(!rst_n)begin
   state<=IDLE;request_id<=0;generation<=0;epoch<=0;head<=0;mode_av<=0;sliding<=0;mask<=0;
   aborted<=0;protocol_bad<=0;prep_bad<=0;last_success<=0;clock_count<=0;start_stamp<=0;done_cycles<=0;first_score_cycle<=0;first_context_cycle<=0;max_feedback_cycles<=0;
   error_valid<=0;error_rank<='1;error_phase<=0;error_tile<=0;error_element<=0;root_accepted<=0;score_commits<=0;partial_commits<=0;context_commits<=0;
   q_hold_ready<=0;q_hold_group<=0;q_load_group<=0;q_load_row<=0;qk_read_group<=0;qk_read_key<=0;tree_returns<=0;scale_returns<=0;
   v_next_read<=0;v_hold_key<=0;v_hold_valid<=0;av_read_key<=0;av_read_group<=0;product_hold_valid<=0;busy<=0;next_key<=0;retire_group<=0;retire_beat<=0;
  end else begin
   clock_count<=clock_count+1'b1;
   if(prep_fire)begin
    request_id<=prepare_request_id;generation<=prepare_generation;epoch<=prepare_epoch;head<=prepare_head;mode_av<=prepare_av;sliding<=prepare_sliding;mask<=prepare_mask;state<=PREP;
    aborted<=0;protocol_bad<=0;prep_bad<=0;last_success<=0;
    error_valid<=0;error_rank<='1;error_phase<=0;error_tile<=0;error_element<=0;
   end
   if(incoming_bad&&(!error_valid||incoming_rank<error_rank))begin error_valid<=1;error_rank<=incoming_rank;error_phase<=incoming_phase;error_tile<=incoming_tile;error_element<=incoming_element;if(state==PREP)prep_bad<=1;end
   if(continue_fire)mode_av<=1;
   if(start_fire)begin
    state<=prep_bad?DONE:CLAIM;start_stamp<=clock_count;done_cycles<=prep_bad?1:0;
    first_score_cycle<=0;first_context_cycle<=0;max_feedback_cycles<=0;root_accepted<=0;score_commits<=0;partial_commits<=0;context_commits<=0;
    q_hold_ready<=0;q_load_group<=0;q_load_row<=0;qk_read_group<=0;qk_read_key<=0;tree_returns<=0;scale_returns<=0;
    v_next_read<=0;v_hold_key<=0;v_hold_valid<=0;av_read_key<=0;av_read_group<=0;product_hold_valid<=0;busy<=0;next_key<=0;retire_group<=0;retire_beat<=0;
   end
   if(state==CLAIM&&lease_ready)state<=mode_av?AV:QK;
   if(abort_fire)begin aborted<=1;if(RESIDENT_ONLY&&state==PREP)begin state<=DONE;done_cycles<=0;end end
   if(fp_fault||scale_fault)protocol_bad<=1;
   if(m_fire)root_accepted<=root_accepted+1'b1;
   if(state==QK)begin
    if(qr_valid[0]&&qr_ready[0])begin
     if(q_load_row==3)begin q_load_row<=0;q_load_group<=q_load_group+1'b1;end else q_load_row<=q_load_row+1'b1;
    end
    if(qr_rsp_valid[0]&&qr_rsp_ready[0]&&!root_stop)begin
     q_hold[qr_rsp_tag[0][2]][qr_rsp_tag[0][1:0]]<=qr_rsp_data[0];q_hold_group[qr_rsp_tag[0][2]]<=qr_rsp_tag[0][6:2];
     if(qr_rsp_tag[0][1:0]==3)q_hold_ready[qr_rsp_tag[0][2]]<=1;
    end
    if(qr_valid[1]&&qr_ready[1])begin
     if(qk_read_key==127)begin qk_read_key<=0;qk_read_group<=qk_read_group+1'b1;end else qk_read_key<=qk_read_key+1'b1;
    end
    if(m_fire&&m_tag[6:0]==127)q_hold_ready[m_tag[7]]<=0;
    for(int g=0;g<7;g++)if(a_rsp_valid[g]&&a_rsp_ready[g])tree_returns[g]<=tree_returns[g]+1'b1;
    if(scale_rsp_valid&&scale_rsp_ready)scale_returns<=scale_returns+1'b1;
    if(ps_wfire)for(int q=0;q<4;q++)begin
     int row,key;row=int'(ps_wr_tag[11:7])*4+q;key=int'(ps_wr_tag[6:0]);
     if(finite(a_data[252+q])&&(key==0||greater(a_data[252+q],maximum[row])))maximum[row]<=a_data[252+q];
    end
    if(ps_wr_rsp_valid&&ps_wr_rsp_ready)begin
     score_commits<=score_commits+1'b1;if(score_commits==0)first_score_cycle<=clock_count-start_stamp;
    end
    if(!root_stop&&score_commits==4096&&root_accepted==4096&&tree_returns=={7{13'd4096}}&&scale_returns==4096&&m_pending==0&&a_pending==0&&local_idle)begin state<=DONE;done_cycles<=clock_count-start_stamp+1'b1;end
   end
   if(state==AV)begin
    if(qr_valid[2]&&qr_ready[2])v_next_read<=v_next_read+1'b1;
    if(qr_rsp_valid[2]&&qr_rsp_ready[2]&&!root_stop)begin v_hold<=qr_rsp_data[2];v_hold_key<=qr_rsp_token[2];v_hold_valid<=1;end
    else if(m_fire&&m_tag[4:0]==31)v_hold_valid<=0;
    if(g_rd_valid&&g_rd_ready)begin
     if(av_read_group==31)begin av_read_group<=0;av_read_key<=av_read_key+1'b1;end else av_read_group<=av_read_group+1'b1;
    end
    case({ps_rfire,a0_fire})
     2'b10:product_hold_valid<=1;2'b01:product_hold_valid<=0;default:;
    endcase
    if(ps_rfire)begin
     product_hold<=m_data;product_hold_tag<=m_rsp_tag;busy[m_rsp_tag[4:0]]<=1;feedback_stamp[m_rsp_tag[4:0]]<=clock_count;
     if(m_rsp_tag[11:5]!=next_key[m_rsp_tag[4:0]])protocol_bad<=1;
    end
    if(a0_fire&&ps_rd_rsp_tag!=product_hold_tag)protocol_bad<=1;
    if(ps_wr_rsp_valid&&ps_wr_rsp_ready)begin
     partial_commits<=partial_commits+1'b1;busy[ps_wr_rsp_tag[4:0]]<=0;next_key[ps_wr_rsp_tag[4:0]]<=next_key[ps_wr_rsp_tag[4:0]]+1'b1;
     if(clock_count-feedback_stamp[ps_wr_rsp_tag[4:0]]>max_feedback_cycles)max_feedback_cycles<=clock_count-feedback_stamp[ps_wr_rsp_tag[4:0]];
    end
    if(!root_stop&&partial_commits==4096&&root_accepted==4096&&next_key=={32{8'd128}}&&busy==0&&m_pending==0&&a_pending==0&&local_idle)begin state<=RETIRE;retire_group<=0;retire_beat<=0;end
   end
   if(state==RETIRE)begin
    if(ps_rfire)retire_group<=retire_group+1'b1;
    if(ctx_wfire)begin if(retire_beat==7)retire_beat<=0;else retire_beat<=retire_beat+1'b1;end
    if(context_wr_rsp_valid&&context_wr_rsp_ready)begin context_commits<=context_commits+1'b1;if(context_commits==0)first_context_cycle<=clock_count-start_stamp;end
    if(!root_stop&&context_commits==256&&local_idle&&m_pending==0&&a_pending==0)begin state<=DONE;done_cycles<=clock_count-start_stamp+1'b1;end
   end
   if(aborted&&active_compute&&m_pending==0&&a_pending==0&&local_idle)begin state<=DONE;done_cycles<=clock_count-start_stamp+1'b1;end
   if(state==DONE&&done_ready)begin last_success<=done_status==0;state<=RELEASE;end
   if(state==RELEASE&&(prep_cancelled||!fp_owned||release_ready))state<=IDLE;
  end
 end
endmodule
