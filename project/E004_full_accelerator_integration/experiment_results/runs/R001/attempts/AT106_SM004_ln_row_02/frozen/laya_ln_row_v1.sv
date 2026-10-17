module laya_ln_row_v1 (
  input  logic        clk, rst_n,
  input  logic        cmd_valid,
  output logic        cmd_ready,
  input  logic [1:0]  gamma_kind,
  input  logic        x_valid,
  output logic        x_ready,
  input  logic [31:0] x_bits,
  input  logic        gamma_valid,
  output logic        gamma_ready,
  input  logic [31:0] gamma_bits,
  output logic        out_valid,
  input  logic        out_ready,
  output logic [31:0] out_bits,
  output logic [9:0]  out_index,
  output logic        out_last,
  output logic        done_valid,
  input  logic        done_ready,
  output logic [3:0]  done_status,
  output logic [31:0] done_bad_element,
  output logic [31:0] mean_bits, variance_bits, inverse_bits
);
  typedef enum logic [4:0] {
    IDLE, LOAD_X, LOAD_G, TREE_MEAN, DIV_MEAN, DELTA1, SQUARE,
    TREE_VAR, DIV_VAR, ADD_EPS, SQRT, DIV_INV, DELTA2, NORMALIZE,
    GAMMA, OUTPUT_ROW, DONE
  } state_t;
  state_t state;
  logic [1:0] kind;
  logic [31:0] x_mem [0:1023], g_mem [0:1023];
  logic [31:0] t0_even [0:511], t0_odd [0:511];
  logic [31:0] t1_even [0:255], t1_odd [0:255];
  logic [10:0] load_count, width, issue_count, commit_count, out_issue;
  logic tree_src_t0;
  logic read_valid;
  logic [9:0] read_tag;
  logic [31:0] read_a,read_b,tree_final,shifted,root_bits;
  logic [31:0] bad_idx,gamma_bad_idx;
  logic [4:0] timer;
  logic scalar_add_sent;
  logic add_in_valid,add_in_ready,add_out_valid,add_out_ready;
  logic [31:0] add_a,add_b,add_out_bits;
  logic [31:0] mul_a,mul_b,mul_out,div_a,div_b,div_out,sqrt_out;
  logic [13:0] mul_valid;
  logic [9:0] mul_tag [0:13];
  logic [31:0] out_reg;
  logic [9:0] out_tag;
  logic out_valid_reg;
  logic mul_phase,add_phase;
  logic [10:0] target_count;

  function automatic logic nonfinite(input logic [31:0] v);
    nonfinite = v[30:23] == 8'hff;
  endfunction
  assign cmd_ready = state==IDLE;
  assign x_ready = state==LOAD_X;
  assign gamma_ready = state==LOAD_G;
  assign out_valid = out_valid_reg;
  assign out_bits = out_reg;
  assign out_index = out_tag;
  assign out_last = out_tag==10'd1023;
  assign done_valid = state==DONE;
  assign mul_phase = state==SQUARE || state==NORMALIZE || state==GAMMA;
  assign add_phase = state==TREE_MEAN || state==TREE_VAR || state==DELTA1 || state==DELTA2;
  assign target_count = (state==TREE_MEAN || state==TREE_VAR) ? (width>>1) : 11'd1024;
  assign add_in_valid = add_phase ? read_valid : (state==ADD_EPS && !scalar_add_sent);
  assign add_a = state==ADD_EPS ? variance_bits : read_a;
  assign add_b = state==ADD_EPS ? 32'h3727c5ac :
                 (state==DELTA1 || state==DELTA2) ? {~mean_bits[31],mean_bits[30:0]} : read_b;
  assign add_out_ready = 1'b1;
  laya_vector_add_stream_v1 add (
    .clk(clk),.rst_n(rst_n),.in_valid(add_in_valid),.in_ready(add_in_ready),
    .a(add_a),.b(add_b),.out_valid(add_out_valid),.out_ready(add_out_ready),.bits(add_out_bits));
  assign mul_a = read_a;
  assign mul_b = state==SQUARE ? read_a :
                 state==NORMALIZE ? inverse_bits : read_b;
  attention_tile_ce_tanh_libm_stream_leaf_stream_mul_node_14_s mul (
    .ap_clk(clk),.ap_rst(!rst_n),.ap_ce(1'b1),.laya_global_ce(1'b1),
    .a(mul_a),.b(mul_b),.ap_return(mul_out));
  assign div_a = state==DIV_INV ? 32'h3f800000 : tree_final;
  assign div_b = state==DIV_INV ? root_bits : 32'h44800000;
  attention_tile_ce_tanh_libm_stream_leaf_stream_div_node_0_s div (
    .ap_clk(clk),.ap_rst(!rst_n),.ap_ce(1'b1),.laya_global_ce(1'b1),
    .a(div_a),.b(div_b),.ap_return(div_out));
  laya_front16_wide_fsqrt_32ns_32ns_32_7_no_dsp_1 sqrt (
    .clk(clk),.reset(!rst_n),.ce(1'b1),.din0(32'd0),.din1(shifted),.dout(sqrt_out));

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      state<=IDLE; kind<=0; load_count<=0; width<=0;
      issue_count<=0; commit_count<=0; out_issue<=0;
      tree_src_t0<=1; read_valid<=0; read_tag<=0; read_a<=0; read_b<=0;
      tree_final<=0; shifted<=0; root_bits<=0;
      bad_idx<=32'hffffffff; gamma_bad_idx<=32'hffffffff;
      timer<=0; scalar_add_sent<=0; mul_valid<=0;
      for(int i=0;i<14;i++) mul_tag[i]<=0;
      out_reg<=0; out_tag<=0; out_valid_reg<=0;
      done_status<=0; done_bad_element<=32'hffffffff;
      mean_bits<=0; variance_bits<=0; inverse_bits<=0;
    end else begin
      mul_valid[0] <= mul_phase && read_valid;
      mul_tag[0] <= read_tag;
      for(int i=1;i<14;i++) begin
        mul_valid[i] <= mul_valid[i-1];
        mul_tag[i] <= mul_tag[i-1];
      end
      case(state)
        IDLE: if(cmd_valid) begin
          kind<=gamma_kind; load_count<=0; width<=0;
          issue_count<=0; commit_count<=0; out_issue<=0;
          read_valid<=0; out_valid_reg<=0; timer<=0;
          bad_idx<=32'hffffffff; gamma_bad_idx<=32'hffffffff;
          done_status<=0; done_bad_element<=32'hffffffff;
          mean_bits<=0; variance_bits<=0; inverse_bits<=0;
          if(gamma_kind>2) begin
            done_status<=4'd3; state<=DONE;
          end else state<=LOAD_X;
        end
        LOAD_X: if(x_valid) begin
          x_mem[load_count[9:0]]<=x_bits;
          if(!load_count[0]) t0_even[load_count[9:1]]<=x_bits;
          else t0_odd[load_count[9:1]]<=x_bits;
          if(nonfinite(x_bits) && bad_idx==32'hffffffff) bad_idx<=load_count;
          if(load_count==11'd1023) begin
            load_count<=0;
            if(bad_idx!=32'hffffffff || nonfinite(x_bits)) begin
              done_status<=4'd6;
              done_bad_element<=bad_idx!=32'hffffffff ? bad_idx : 32'd1023;
              state<=DONE;
            end else if(kind!=0) state<=LOAD_G;
            else begin
              state<=TREE_MEAN; width<=11'd1024; tree_src_t0<=1;
              issue_count<=0; commit_count<=0; read_valid<=0;
            end
          end else load_count<=load_count+1'b1;
        end
        LOAD_G: if(gamma_valid) begin
          g_mem[load_count[9:0]]<=gamma_bits;
          if(nonfinite(gamma_bits) && gamma_bad_idx==32'hffffffff)
            gamma_bad_idx<=load_count;
          if(load_count==11'd1023) begin
            load_count<=0; state<=TREE_MEAN; width<=11'd1024;
            tree_src_t0<=1; issue_count<=0; commit_count<=0; read_valid<=0;
          end else load_count<=load_count+1'b1;
        end
        TREE_MEAN,TREE_VAR,DELTA1,DELTA2: begin
          if(!read_valid || add_in_ready) begin
            read_valid<=issue_count<target_count;
            if(issue_count<target_count) begin
              if(state==TREE_MEAN || state==TREE_VAR) begin
                if(tree_src_t0) begin
                  read_a<=t0_even[issue_count[8:0]];
                  read_b<=t0_odd[issue_count[8:0]];
                end else begin
                  read_a<=t1_even[issue_count[7:0]];
                  read_b<=t1_odd[issue_count[7:0]];
                end
              end else read_a<=x_mem[issue_count[9:0]];
              read_tag<=issue_count[9:0];
              issue_count<=issue_count+1'b1;
            end
          end
          if(add_out_valid) begin
            if(state==TREE_MEAN || state==TREE_VAR) begin
              if(tree_src_t0) begin
                if(!commit_count[0]) t1_even[commit_count[8:1]]<=add_out_bits;
                else t1_odd[commit_count[8:1]]<=add_out_bits;
              end else begin
                if(!commit_count[0]) t0_even[commit_count[9:1]]<=add_out_bits;
                else t0_odd[commit_count[9:1]]<=add_out_bits;
              end
              if(width==2) tree_final<=add_out_bits;
            end else begin
              if(!commit_count[0]) t0_even[commit_count[9:1]]<=add_out_bits;
              else t0_odd[commit_count[9:1]]<=add_out_bits;
            end
            if(nonfinite(add_out_bits) && bad_idx>commit_count)
              bad_idx<=commit_count;
            commit_count<=commit_count+1'b1;
          end
          if(issue_count==target_count && !read_valid && commit_count==target_count) begin
            issue_count<=0; commit_count<=0; read_valid<=0;
            if((state==TREE_MEAN || state==TREE_VAR) && bad_idx!=32'hffffffff) begin
              done_status<=4'd6; done_bad_element<=bad_idx; state<=DONE;
            end else if(state==TREE_MEAN || state==TREE_VAR) begin
              if(width>2) begin width<=width>>1; tree_src_t0<=!tree_src_t0; end
              else if(state==TREE_MEAN) begin state<=DIV_MEAN; timer<=0; end
              else begin state<=DIV_VAR; timer<=0; end
            end else if(state==DELTA1) begin
              if(bad_idx!=32'hffffffff) begin
                done_status<=4'd6; done_bad_element<=bad_idx; state<=DONE;
              end else state<=SQUARE;
            end else if(state==DELTA2) state<=NORMALIZE;
          end
        end
        DIV_MEAN: begin
          if(timer==5'd12) begin
            if(nonfinite(div_out)) begin
              done_status<=4'd6; done_bad_element<=0; state<=DONE;
            end else begin
              mean_bits<=div_out; bad_idx<=32'hffffffff;
              issue_count<=0; commit_count<=0; read_valid<=0; state<=DELTA1;
            end
            timer<=0;
          end else timer<=timer+1'b1;
        end
        SQUARE,NORMALIZE,GAMMA: begin
          read_valid<=issue_count<11'd1024;
          if(issue_count<11'd1024) begin
            if(!issue_count[0]) read_a<=t0_even[issue_count[9:1]];
            else read_a<=t0_odd[issue_count[9:1]];
            if(state==GAMMA) read_b<=g_mem[issue_count[9:0]];
            read_tag<=issue_count[9:0];
            issue_count<=issue_count+1'b1;
          end
          if(mul_valid[13]) begin
            if(!mul_tag[13][0]) t0_even[mul_tag[13][9:1]]<=mul_out;
            else t0_odd[mul_tag[13][9:1]]<=mul_out;
            if(nonfinite(mul_out) && bad_idx>mul_tag[13])
              bad_idx<=mul_tag[13];
            commit_count<=commit_count+1'b1;
          end
          if(issue_count==11'd1024 && !read_valid && commit_count==11'd1024) begin
            issue_count<=0; commit_count<=0; read_valid<=0;
            if(state==SQUARE) begin
              if(bad_idx!=32'hffffffff) begin
                done_status<=4'd6; done_bad_element<=bad_idx; state<=DONE;
              end else begin
                state<=TREE_VAR; width<=11'd1024; tree_src_t0<=1;
              end
            end else if(state==NORMALIZE) begin
              if(kind!=0) state<=GAMMA;
              else if(bad_idx!=32'hffffffff) begin
                done_status<=4'd6; done_bad_element<=bad_idx; state<=DONE;
              end else begin state<=OUTPUT_ROW; out_issue<=0; end
            end else begin
              if(gamma_bad_idx<bad_idx) bad_idx<=gamma_bad_idx;
              if(bad_idx!=32'hffffffff || gamma_bad_idx!=32'hffffffff) begin
                done_status<=4'd6;
                done_bad_element<=gamma_bad_idx<bad_idx ? gamma_bad_idx : bad_idx;
                state<=DONE;
              end else begin state<=OUTPUT_ROW; out_issue<=0; end
            end
          end
        end
        DIV_VAR: begin
          if(timer==5'd12) begin
            if(nonfinite(div_out) || div_out[31]) begin
              done_status<=4'd6; done_bad_element<=0; state<=DONE;
            end else begin
              variance_bits<=div_out; state<=ADD_EPS; scalar_add_sent<=0;
            end
            timer<=0;
          end else timer<=timer+1'b1;
        end
        ADD_EPS: begin
          if(!scalar_add_sent && add_in_ready) scalar_add_sent<=1;
          if(add_out_valid) begin
            if(nonfinite(add_out_bits)) begin
              done_status<=4'd6; done_bad_element<=0; state<=DONE;
            end else begin
              shifted<=add_out_bits; state<=SQRT; timer<=0;
            end
          end
        end
        SQRT: begin
          if(timer==5'd6) begin
            if(nonfinite(sqrt_out) || sqrt_out[31] || sqrt_out[30:0]==0) begin
              done_status<=4'd6; done_bad_element<=0; state<=DONE;
            end else begin root_bits<=sqrt_out; state<=DIV_INV; timer<=0; end
          end else timer<=timer+1'b1;
        end
        DIV_INV: begin
          if(timer==5'd12) begin
            if(nonfinite(div_out)) begin
              done_status<=4'd6; done_bad_element<=0; state<=DONE;
            end else begin
              inverse_bits<=div_out; bad_idx<=32'hffffffff;
              issue_count<=0; commit_count<=0; read_valid<=0; state<=DELTA2;
            end
            timer<=0;
          end else timer<=timer+1'b1;
        end
        OUTPUT_ROW: begin
          if(!out_valid_reg || out_ready) begin
            if(out_issue<11'd1024) begin
              if(!out_issue[0]) out_reg<=t0_even[out_issue[9:1]];
              else out_reg<=t0_odd[out_issue[9:1]];
              out_tag<=out_issue[9:0]; out_valid_reg<=1;
              out_issue<=out_issue+1'b1;
            end else begin
              out_valid_reg<=0; done_status<=0;
              done_bad_element<=32'hffffffff; state<=DONE;
            end
          end
        end
        DONE: if(done_ready) state<=IDLE;
        default: state<=IDLE;
      endcase
    end
  end
endmodule
