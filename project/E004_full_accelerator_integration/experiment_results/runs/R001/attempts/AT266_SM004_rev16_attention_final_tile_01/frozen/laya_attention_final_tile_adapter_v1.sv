`timescale 1ns/1ps

// One borrowed-reader / borrowed-writer FINAL -> Attention tile transaction.
// The caller owns the published tensor and the physical QKV/ATT_OUT routing.
module laya_attention_final_tile_adapter_v1 (
  input  logic clk, rst_n,
  input  logic cmd_valid,
  output logic cmd_ready,
  input  logic [31:0] cmd_id,
  input  logic [63:0] cmd_request, cmd_generation,
  input  logic [671:0] cmd_numeric_identity,
  input  logic [1759:0] cmd_binding_words,
  input  logic [1023:0] cmd_mask_bytes,
  input  logic [63:0] cmd_mask_request, cmd_mask_generation,
  input  logic [7:0] cmd_mask_length,
  input  logic [3:0] cmd_head,
  input  logic [6:0] cmd_row0,
  input  logic [31:0] cmd_service_epoch,
  input  logic [1:0][63:0] cmd_qkv_base, cmd_qkv_span,
  input  logic [1:0][31:0] cmd_qkv_final_epoch,
  input  logic [63:0] cmd_att_base, cmd_att_span,
  input  logic [31:0] cmd_att_epoch,
  input  logic cmd_tensor_final_valid, cmd_tensor_failed,
  input  logic [127:0] cmd_row_final,
  input  logic cmd_source_debt_zero,
  output logic done_valid,
  input  logic done_ready,
  output logic [3:0] done_status, done_phase,
  output logic [31:0] done_id,
  output logic [3:0] done_head,
  output logic [6:0] done_row0,
  output logic [31:0] done_service_command, done_service_status,
  output logic [31:0] done_service_result,
  output logic tile_success,
  // Borrowed t4_w_reader_port_v1, SCALE_MODE=0.
  output logic read_load_valid,
  input  logic read_load_ready,
  output logic [63:0] read_load_base,
  output logic [31:0] read_load_bytes, read_load_epoch,
  input  logic read_load_done, read_load_error,
  input  logic [31:0] read_committed_bytes,
  input  logic [511:0] read_out_data,
  input  logic [31:0] read_out_offset, read_out_epoch,
  input  logic [6:0] read_out_bytes,
  input  logic read_out_last, read_out_valid,
  output logic read_out_ready,
  output logic read_route,
  // Original attention_tile_service_v1 control interface.
  input  logic service_idle, service_done,
  input  logic service_result_valid, service_status_valid,
  input  logic [31:0] service_result, service_status,
  output logic service_start, service_continue,
  output logic [31:0] service_command, service_index,
  output logic [31:0] service_payload, service_epoch,
  // Borrowed tm1tn8_axi512_writer, linear mode.
  output logic writer_tile_valid,
  input  logic writer_tile_ready,
  output logic [255:0] writer_tile_f32,
  output logic [11:0] writer_tile_n0,
  output logic [63:0] writer_output_base, writer_output_span,
  output logic writer_flush_req,
  input  logic writer_flush_done, writer_debt_zero, writer_fault,
  output logic writer_rearm_valid,
  input  logic writer_rearm_ready
);
  typedef enum logic [5:0] {
    S_IDLE, S_RESET, S_BIND, S_BIND_READ, S_CONFIG, S_K_START,
    S_K_DATA, S_K_DONE, S_V_START, S_V_DATA, S_V_DONE,
    S_K_SEND, S_V_SEND, S_KV_ADVANCE, S_MASK, S_Q_START,
    S_Q_DATA, S_Q_SEND, S_Q_ADVANCE, S_Q_DONE,
    S_QK, S_SM, S_AV, S_OUT_CONFIG, S_OUT_READ, S_OUT_ADVANCE,
    S_WRITE_TILE, S_FLUSH, S_FLUSH_DOWN, S_REARM,
    S_CALL_START, S_CALL_WAIT, S_CALL_RETIRE, S_ERROR_DRAIN, S_DONE
  } state_t;
  state_t state, return_state;
  logic [31:0] q_id, q_epoch, q_att_epoch;
  logic [63:0] q_request, q_generation;
  logic [671:0] q_numeric;
  logic [1759:0] q_binding;
  logic [1023:0] q_mask;
  logic [1:0][63:0] q_src_base, q_src_span;
  logic [1:0][31:0] q_src_epoch;
  logic [63:0] q_att_base, q_att_span;
  logic [3:0] q_head;
  logic [6:0] q_row0;
  logic [6:0] key;
  logic [1:0] stripe;
  logic [3:0] word_in_stripe;
  logic [6:0] mask_index;
  logic [5:0] bind_index;
  logic [5:0] q_beat;
  logic [3:0] query_local;
  logic [5:0] output_d;
  logic [511:0] k_stripe, v_stripe;
  logic [255:0] output_pack;
  logic [31:0] call_command, call_index, call_payload, call_result;
  logic call_bad;
  logic [3:0] error_status;
  logic read_done_seen, read_error_seen;
  logic read_active;
  logic [63:0] load_address;
  logic [31:0] load_size;
  logic [64:0] q_limit0, q_limit1, att_limit;
  logic [64:0] q_last0, q_last1;
  logic [64:0] att_last;
  logic admission_ok;
  logic [63:0] active_row_base;
  logic read_is_q, read_is_k, read_is_v;
  logic [63:0] read_offset;
  integer i;

  function automatic [63:0] qkv_offset(input logic [1:0] plane,
      input logic [3:0] head, input logic [6:0] row,
      input logic [5:0] d);
    logic [63:0] section;
    begin
      section = (64'(plane)*16 + 64'(head>>1))*1024 + 64'(row);
      qkv_offset = (section*64 + 64'(d))*4;
    end
  endfunction
  always_comb begin
    q_limit0={1'b0,cmd_qkv_base[0]}+{1'b0,cmd_qkv_span[0]};
    q_limit1={1'b0,cmd_qkv_base[1]}+{1'b0,cmd_qkv_span[1]};
    att_limit={1'b0,cmd_att_base}+{1'b0,cmd_att_span};
    q_last0={1'b0,cmd_qkv_base[0]}+{1'b0,qkv_offset(2,cmd_head,7'd127,6'd63)}+65'd4;
    q_last1={1'b0,cmd_qkv_base[1]}+{1'b0,qkv_offset(2,cmd_head,7'd127,6'd63)}+65'd4;
    att_last={1'b0,cmd_att_base}+65'(7'd127)*65'd4096+65'(cmd_head)*65'd256+65'd256;
    admission_ok=cmd_id!=0 && cmd_request!=0 && cmd_generation!=0 &&
      cmd_service_epoch!=0 && cmd_att_epoch!=0 &&
      cmd_head<=15 && cmd_row0<=112 && cmd_row0[3:0]==0 &&
      cmd_mask_request==cmd_request && cmd_mask_generation==cmd_generation &&
      cmd_mask_length==8'd128 && cmd_tensor_final_valid && !cmd_tensor_failed &&
      (&cmd_row_final) && cmd_source_debt_zero && writer_debt_zero &&
      cmd_qkv_final_epoch[0]!=0 &&
      cmd_qkv_final_epoch[0]==cmd_qkv_final_epoch[1] &&
      cmd_qkv_base[0][5:0]==0 && cmd_qkv_base[1][5:0]==0 &&
      cmd_qkv_span[0]>=64'd12582912 && cmd_qkv_span[1]>=64'd12582912 &&
      !q_limit0[64] && !q_limit1[64] &&
      !q_last0[64] && !q_last1[64] &&
      q_last0<=q_limit0 && q_last1<=q_limit1 &&
      cmd_att_base[5:0]==0 && cmd_att_span>=64'd8388608 &&
      !att_limit[64] && !att_last[64] && att_last<=att_limit &&
      cmd_binding_words[4*32 +: 32]==32'h00800001 &&
      cmd_binding_words[23*32 +: 32]=={8'd0,8'd16,9'd0,cmd_row0} &&
      cmd_binding_words[27*32 +: 32]==cmd_binding_words[23*32 +: 32] &&
      cmd_binding_words[31*32 +: 32]==cmd_binding_words[23*32 +: 32] &&
      cmd_binding_words[49*32 +: 32]==cmd_qkv_final_epoch[0] &&
      cmd_binding_words[52*32 +: 32]==cmd_qkv_final_epoch[1] &&
      cmd_binding_words[54*32 +: 8]=={4'b0,cmd_head};
    for(integer n=0;n<21;n=n+1)
      if(cmd_binding_words[n*32 +: 32]!==cmd_numeric_identity[n*32 +: 32])
        admission_ok=0;
  end
  assign cmd_ready=state==S_IDLE && !done_valid;
  assign service_start=state==S_CALL_START && service_idle;
  assign service_continue=state==S_CALL_RETIRE && service_done;
  assign service_command=call_command;
  assign service_index=call_index;
  assign service_payload=call_payload;
  assign service_epoch=q_epoch;
  assign read_is_q=state==S_Q_START || state==S_Q_DATA ||
                   state==S_Q_SEND || state==S_Q_ADVANCE || state==S_Q_DONE;
  assign read_is_k=state==S_K_START || state==S_K_DATA || state==S_K_DONE;
  assign read_is_v=state==S_V_START || state==S_V_DATA || state==S_V_DONE;
  assign read_load_valid=state==S_K_START || state==S_V_START || state==S_Q_START;
  assign read_load_bytes=state==S_Q_START ? 32'd4096 : 32'd64;
  assign read_load_epoch=q_epoch;
  assign read_route=q_head[0];
  assign read_offset=read_is_q ? qkv_offset(0,q_head,q_row0,0) :
      read_is_k ? qkv_offset(1,q_head,key,{stripe,4'b0}) :
      qkv_offset(2,q_head,key,{stripe,4'b0});
  assign read_load_base=q_src_base[q_head[0]]+read_offset;
  assign read_out_ready=state==S_K_DATA || state==S_V_DATA ||
                        state==S_Q_DATA || state==S_ERROR_DRAIN;
  assign active_row_base=q_att_base+64'({q_row0+query_local})*64'd4096+
                         64'(q_head)*64'd256;
  assign writer_output_base=active_row_base;
  assign writer_output_span=64'd256;
  assign writer_tile_valid=state==S_WRITE_TILE;
  assign writer_tile_f32=output_pack;
  assign writer_tile_n0={3'b0,output_d[5:3],3'b0};
  assign writer_flush_req=state==S_FLUSH || state==S_ERROR_DRAIN;
  assign writer_rearm_valid=state==S_REARM;

  always_ff @(posedge clk) begin
    if(!rst_n)begin
      state<=S_IDLE;return_state<=S_IDLE;done_valid<=0;done_status<=0;
      done_phase<=4'd15;done_id<=0;done_head<=0;done_row0<=0;
      done_service_command<=0;done_service_status<=0;done_service_result<=0;
      tile_success<=0;error_status<=0;read_active<=0;
      read_done_seen<=0;read_error_seen<=0;
      q_id<=0;q_epoch<=0;q_att_epoch<=0;q_request<=0;q_generation<=0;
      q_numeric<=0;q_binding<=0;q_mask<=0;q_src_base<=0;q_src_span<=0;
      q_src_epoch<=0;q_att_base<=0;q_att_span<=0;q_head<=0;q_row0<=0;
      key<=0;stripe<=0;word_in_stripe<=0;mask_index<=0;bind_index<=0;
      q_beat<=0;query_local<=0;output_d<=0;k_stripe<=0;v_stripe<=0;
      output_pack<=0;call_command<=0;call_index<=0;call_payload<=0;
      call_result<=0;call_bad<=0;
    end else begin
      if(read_load_done)begin
        read_done_seen<=1;
        if(read_load_error)read_error_seen<=1;
      end
      if(writer_fault && state!=S_IDLE && state!=S_DONE)begin
        error_status<=4'd7;
        if(state!=S_CALL_WAIT && state!=S_CALL_RETIRE)state<=S_ERROR_DRAIN;
      end
      case(state)
        S_IDLE:if(cmd_valid && cmd_ready)begin
          done_id<=cmd_id;done_head<=cmd_head;done_row0<=cmd_row0;
          done_phase<=4'd15;done_status<=0;tile_success<=0;
          done_service_command<=0;done_service_status<=0;done_service_result<=0;
          if(!admission_ok)begin done_status<=4'd7;state<=S_DONE;end
          else begin
            q_id<=cmd_id;q_request<=cmd_request;q_generation<=cmd_generation;
            q_epoch<=cmd_service_epoch;q_att_epoch<=cmd_att_epoch;
            q_numeric<=cmd_numeric_identity;q_binding<=cmd_binding_words;
            q_mask<=cmd_mask_bytes;q_src_base<=cmd_qkv_base;
            q_src_span<=cmd_qkv_span;q_src_epoch<=cmd_qkv_final_epoch;
            q_att_base<=cmd_att_base;q_att_span<=cmd_att_span;
            q_head<=cmd_head;q_row0<=cmd_row0;
            key<=0;stripe<=0;word_in_stripe<=0;mask_index<=0;
            bind_index<=0;q_beat<=0;query_local<=0;output_d<=0;
            error_status<=0;read_active<=0;state<=S_RESET;
          end
        end
        S_RESET:begin call_command<=0;call_index<=0;call_payload<=0;
          return_state<=S_BIND;state<=S_CALL_START;end
        S_BIND:if(bind_index<55)begin
          call_command<=1;call_index<=bind_index;
          call_payload<=q_binding[bind_index*32 +: 32];
          return_state<=S_BIND;state<=S_CALL_START;
        end else begin bind_index<=0;state<=S_BIND_READ;end
        S_BIND_READ:if(bind_index<55)begin
          call_command<=17;call_index<=bind_index;call_payload<=0;
          return_state<=S_BIND_READ;state<=S_CALL_START;
        end else state<=S_CONFIG;
        S_CONFIG:begin
          call_command<=2;call_index<=128;
          call_payload<={7'd0,1'b0,4'b0,q_head,9'd0,q_row0};
          return_state<=S_K_START;state<=S_CALL_START;
        end
        S_K_START:if(read_load_ready)begin
          read_active<=1;read_done_seen<=0;read_error_seen<=0;
          state<=S_K_DATA;
        end
        S_K_DATA:if(read_out_valid)begin
          if(read_out_offset!=0 || read_out_epoch!=q_epoch ||
             read_out_bytes!=64 || !read_out_last)begin
            error_status<=7;state<=S_ERROR_DRAIN;
          end else begin k_stripe<=read_out_data;state<=S_K_DONE;end
        end
        S_K_DONE:if(read_done_seen || read_load_done)begin
          read_active<=0;
          if(read_error_seen || read_load_error || read_committed_bytes!=64)
            begin error_status<=7;state<=S_ERROR_DRAIN;end
          else state<=S_V_START;
        end
        S_V_START:if(read_load_ready)begin
          read_active<=1;read_done_seen<=0;read_error_seen<=0;
          state<=S_V_DATA;
        end
        S_V_DATA:if(read_out_valid)begin
          if(read_out_offset!=0 || read_out_epoch!=q_epoch ||
             read_out_bytes!=64 || !read_out_last)begin
            error_status<=7;state<=S_ERROR_DRAIN;
          end else begin v_stripe<=read_out_data;word_in_stripe<=0;state<=S_V_DONE;end
        end
        S_V_DONE:if(read_done_seen || read_load_done)begin
          read_active<=0;
          if(read_error_seen || read_load_error || read_committed_bytes!=64)
            begin error_status<=7;state<=S_ERROR_DRAIN;end
          else state<=S_K_SEND;
        end
        S_K_SEND:begin
          call_command<=4;call_index<=32'(key)*32'd64+32'(stripe)*16+word_in_stripe;
          call_payload<=k_stripe[word_in_stripe*32 +: 32];
          return_state<=S_V_SEND;state<=S_CALL_START;
        end
        S_V_SEND:begin
          call_command<=5;call_index<=32'(key)*32'd64+32'(stripe)*16+word_in_stripe;
          call_payload<=v_stripe[word_in_stripe*32 +: 32];
          return_state<=S_KV_ADVANCE;state<=S_CALL_START;
        end
        S_KV_ADVANCE:if(word_in_stripe<15)begin
          word_in_stripe<=word_in_stripe+1;state<=S_K_SEND;
        end else if(stripe<3)begin
          stripe<=stripe+1;state<=S_K_START;
        end else if(key<127)begin
          key<=key+1;stripe<=0;state<=S_K_START;
        end else begin mask_index<=0;state<=S_MASK;end
        S_MASK:begin
          call_command<=6;call_index<=mask_index;
          call_payload<={24'd0,q_mask[mask_index*8 +: 8]};
          return_state<=mask_index==127 ? S_Q_START : S_MASK;
          if(mask_index<127)mask_index<=mask_index+1;
          state<=S_CALL_START;
        end
        S_Q_START:if(read_load_ready)begin
          read_active<=1;read_done_seen<=0;read_error_seen<=0;q_beat<=0;
          state<=S_Q_DATA;
        end
        S_Q_DATA:if(read_out_valid)begin
          if(read_out_offset!={q_beat,6'b0} || read_out_epoch!=q_epoch ||
             read_out_bytes!=64 || read_out_last!=(q_beat==63))begin
            error_status<=7;state<=S_ERROR_DRAIN;
          end else begin k_stripe<=read_out_data;word_in_stripe<=0;state<=S_Q_SEND;end
        end
        S_Q_SEND:begin
          call_command<=18;call_index<=32'(q_beat)*16+word_in_stripe;
          call_payload<=k_stripe[word_in_stripe*32 +: 32];
          return_state<=S_Q_ADVANCE;state<=S_CALL_START;
        end
        S_Q_ADVANCE:if(word_in_stripe<15)begin
          word_in_stripe<=word_in_stripe+1;state<=S_Q_SEND;
        end else if(q_beat<63)begin
          q_beat<=q_beat+1;state<=S_Q_DATA;
        end else state<=S_Q_DONE;
        S_Q_DONE:if(read_done_seen || read_load_done)begin
          read_active<=0;
          if(read_error_seen || read_load_error || read_committed_bytes!=4096)
            begin error_status<=7;state<=S_ERROR_DRAIN;end
          else state<=S_QK;
        end
        S_QK:begin call_command<=19;call_index<=0;call_payload<=0;
          return_state<=S_SM;state<=S_CALL_START;end
        S_SM:begin call_command<=20;call_index<=0;call_payload<=0;
          return_state<=S_AV;state<=S_CALL_START;end
        S_AV:begin call_command<=21;call_index<=0;call_payload<=0;
          return_state<=S_OUT_CONFIG;state<=S_CALL_START;end
        S_OUT_CONFIG:begin
          call_command<=2;call_index<=128;
          call_payload<={7'd0,1'b0,4'b0,q_head,9'd0,(q_row0+query_local)};
          return_state<=S_OUT_READ;output_d<=0;state<=S_CALL_START;
        end
        S_OUT_READ:begin
          call_command<=12;call_index<=output_d;call_payload<=0;
          return_state<=S_OUT_ADVANCE;state<=S_CALL_START;
        end
        S_OUT_ADVANCE:if(output_d[2:0]==7)state<=S_WRITE_TILE;
          else begin output_d<=output_d+1;state<=S_OUT_READ;end
        S_WRITE_TILE:if(writer_tile_ready)begin
          if(output_d==63)state<=S_FLUSH;
          else begin output_d<=output_d+1;state<=S_OUT_READ;end
        end
        S_FLUSH:if(writer_flush_done && writer_debt_zero)state<=S_FLUSH_DOWN;
        S_FLUSH_DOWN:state<=S_REARM;
        S_REARM:if(writer_rearm_ready)begin
          if(query_local==15)begin tile_success<=1;done_status<=0;state<=S_DONE;end
          else begin query_local<=query_local+1;state<=S_OUT_CONFIG;end
        end
        S_CALL_START:if(service_idle)state<=S_CALL_WAIT;
        S_CALL_WAIT:if(service_done && service_result_valid && service_status_valid)begin
          call_result<=service_result;
          done_service_command<=call_command;
          done_service_status<=service_status;
          done_service_result<=service_result;
          call_bad<=service_status!=0;
          if(call_command==17 && service_result!==q_binding[call_index*32 +: 32])call_bad<=1;
          if(call_command==12 && service_status==0)
            output_pack[output_d[2:0]*32 +: 32]<=service_result;
          state<=S_CALL_RETIRE;
        end
        S_CALL_RETIRE:if(service_done)begin
          if(call_bad || writer_fault)begin
            error_status<=service_status==1 ? 4'd6 : 4'd7;
            state<=S_ERROR_DRAIN;
          end else begin
            if(call_command==1 || call_command==17)bind_index<=bind_index+1;
            state<=return_state;
          end
        end
        S_ERROR_DRAIN:if(!read_active && writer_debt_zero && service_idle)begin
          done_status<=error_status;tile_success<=0;state<=S_DONE;
        end else if(read_active && read_load_done)read_active<=0;
        S_DONE:begin
          done_valid<=1;
          if(done_valid && done_ready)begin done_valid<=0;state<=S_IDLE;end
        end
        default:state<=S_IDLE;
      endcase
    end
  end
endmodule
