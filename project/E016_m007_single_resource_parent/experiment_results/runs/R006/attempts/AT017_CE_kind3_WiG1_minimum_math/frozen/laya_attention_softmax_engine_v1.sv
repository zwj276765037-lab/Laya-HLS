`timescale 1ns/1ps
// Autonomous S128 softmax engine. Resource instances live in caller's sole
// resource shell. FP tag packs eight semantic groups into86 existing tag bits.
module laya_attention_softmax_engine_v1(
 input logic clk,rst_n,start_valid,output logic start_ready,
 input logic[63:0]start_request_id,input logic[31:0]start_generation,start_epoch,input logic[3:0]start_head,
 input logic[127:0][31:0]maximum,
 input logic abort_valid,output logic abort_ready,
 output logic done_valid,input logic done_ready,output logic[7:0]done_status,
 output logic[31:0]done_cycles,first_row_cycle,max_sum_tail,max_row_launch_gap,
 output logic[7:0]rows_launched,rows_retired,output logic[11:0]probability_commits,
 output logic error_valid,output logic[63:0]error_rank,output logic[4:0]error_phase,output logic[6:0]error_row,error_node,output logic[31:0]error_element,
 output logic[63:0]context_valid,context_row_hi,
 input logic resource_debt_clear,resource_fault,
 output logic score_rd_valid,input logic score_rd_ready,output logic[10:0]score_rd_tag,
 input logic score_rsp_valid,output logic score_rsp_ready,input logic[10:0]score_rsp_tag,input logic[7:0][31:0]score_rsp_data,
 output logic fp_req_valid,input logic fp_req_ready,output logic[95:0]fp_req_tag,output logic[255:0][31:0]fp_a,fp_b,
 input logic fp_rsp_valid,output logic fp_rsp_ready,input logic[95:0]fp_rsp_tag,input logic[255:0][31:0]fp_rsp_data,
 output logic sfu_req_valid,input logic sfu_req_ready,output logic[10:0]sfu_req_tag,output logic[7:0][31:0]sfu_req_x,
 input logic sfu_rsp_valid,output logic sfu_rsp_ready,input logic[10:0]sfu_rsp_tag,input logic[7:0][31:0]sfu_rsp_data,
 output logic exp_wr_valid,input logic exp_wr_ready,output logic[10:0]exp_wr_tag,output logic[7:0][31:0]exp_wr_data,
 input logic exp_wr_ack_valid,output logic exp_wr_ack_ready,input logic[10:0]exp_wr_ack_tag,
 output logic exp_rd_valid,input logic exp_rd_ready,output logic[10:0]exp_rd_tag,
 input logic exp_rsp_valid,output logic exp_rsp_ready,input logic[10:0]exp_rsp_tag,input logic[7:0][31:0]exp_rsp_data,
 output logic div_req_valid,input logic div_req_ready,output logic[95:0]div_req_tag,output logic[7:0][31:0]div_a,div_b,
 input logic div_rsp_valid,output logic div_rsp_ready,input logic[95:0]div_rsp_tag,input logic[7:0][31:0]div_rsp_data,input logic[7:0]div_rsp_error,
 output logic prob_wr_valid,input logic prob_wr_ready,output logic[10:0]prob_wr_tag,output logic[7:0][31:0]prob_wr_data,
 input logic prob_wr_ack_valid,output logic prob_wr_ack_ready,input logic[10:0]prob_wr_ack_tag
);
 localparam IDLE=0,RUN=1,DONE=2;
 logic[1:0]state;logic aborted,protocol_bad;
 logic[63:0]request_id;logic[31:0]generation,epoch;logic[3:0]head;
 logic[31:0]clock_count,start_stamp,previous_row_stamp;
 logic[63:0]active,row_hi,cancelled,total_ready,norm_done;
 logic[63:0][3:0]partial_valid;
 logic[63:0][3:0][3:0]partial_pair;
 logic[63:0][3:0][31:0]partial_value;
 logic[63:0][31:0]total_value,last_exp_stamp;
 logic[63:0][6:0]fp_debt;
 logic[63:0][5:0]sfu_debt,div_debt,score_debt,exp_read_debt,exp_write_debt,prob_debt;
 logic[63:0][4:0]score_chunks,exp_commits,prob_commits;
 logic[7:0]read_row,norm_row;logic[3:0]read_chunk,norm_chunk;
 logic[11:0]score_issued,score_seen;
 logic[6:0]fp_vectors,shift_debt;logic[8:0]sfu_vectors;logic[5:0]div_vectors;
 logic[7:0]bad_group;logic bad_score,bad_shift,bad_exp,bad_div,shift_sink_ready,can_tick,skip_norm;
 logic[63:0]cancel_set,free_row;int free_count;
 int dfp[64],dsfu[64],ddiv[64],dscore[64],der[64],dew[64],dprob[64];
 logic incoming_error;logic[63:0]incoming_rank;logic[4:0]incoming_phase;logic[6:0]incoming_row,incoming_node;logic[31:0]incoming_element;
 wire start_fire=start_valid&&start_ready;
 wire abort_fire=abort_valid&&abort_ready;
 wire drain=aborted||abort_fire||protocol_bad;
 wire fp_fire=fp_req_valid&&fp_req_ready,fp_return=fp_rsp_valid&&fp_rsp_ready;
 wire score_fire=score_rd_valid&&score_rd_ready,score_return=score_rsp_valid&&score_rsp_ready;
 wire sfu_fire=sfu_req_valid&&sfu_req_ready,sfu_return=sfu_rsp_valid&&sfu_rsp_ready;
 wire ew_fire=exp_wr_valid&&exp_wr_ready,ew_ack=exp_wr_ack_valid&&exp_wr_ack_ready;
 wire er_fire=exp_rd_valid&&exp_rd_ready,er_return=exp_rsp_valid&&exp_rsp_ready;
 wire div_fire=div_req_valid&&div_req_ready,div_return=div_rsp_valid&&div_rsp_ready;
 wire pw_fire=prob_wr_valid&&prob_wr_ready,pw_ack=prob_wr_ack_valid&&prob_wr_ack_ready;
 wire debts_zero=fp_vectors==0&&shift_debt==0&&sfu_vectors==0&&div_vectors==0&&resource_debt_clear;
 assign start_ready=state==IDLE&&resource_debt_clear;assign abort_ready=state==RUN&&!aborted;
 assign done_valid=state==DONE;assign done_status=protocol_bad?8'd3:aborted?8'd2:error_valid?8'd1:8'd0;
 assign context_valid=active;assign context_row_hi=row_hi;
 function automatic bit finite(input logic[31:0]v);return v[30:23]!=255;endfunction
 function automatic bit positive(input logic[31:0]v);return !v[31]&&v[30:0]!=0&&finite(v);endfunction
 function automatic bit live(input int row);return active[row%64]&&row_hi[row%64]==1'(row/64);endfunction
 function automatic bit tv(input logic[95:0]t,input int g);case(g)0:return t[11];1:return t[23];2:return t[35];3:return t[47];4:return t[58];5:return t[68];6:return t[77];default:return t[85];endcase endfunction
 function automatic int tr(input logic[95:0]t,input int g);case(g)0:return int'(t[10:4]);1:return int'(t[22:16]);2:return int'(t[34:28]);3:return int'(t[46:40]);4:return int'(t[57:51]);5:return int'(t[67:61]);6:return int'(t[76:70]);default:return int'(t[84:78]);endcase endfunction
 function automatic int ti(input logic[95:0]t,input int g);case(g)0:return int'(t[3:0]);1:return int'(t[15:12]);2:return int'(t[27:24]);3:return int'(t[39:36]);4:return int'(t[50:48]);5:return int'(t[60:59]);6:return int'(t[69]);default:return 0;endcase endfunction
 function automatic int lane0(input int g);case(g)0:return 0;1:return 8;2:return 12;3:return 14;4:return 15;5:return 16;6:return 17;default:return 18;endcase endfunction
 function automatic int nodes(input int g);case(g)0:return 8;1:return 4;2:return 2;default:return 1;endcase endfunction
 task automatic put_tag(input int g,row,node);
  case(g)0:fp_req_tag[11:0]={1'b1,7'(row),4'(node)};1:fp_req_tag[23:12]={1'b1,7'(row),4'(node)};2:fp_req_tag[35:24]={1'b1,7'(row),4'(node)};3:fp_req_tag[47:36]={1'b1,7'(row),4'(node)};4:fp_req_tag[58:48]={1'b1,7'(row),3'(node)};5:fp_req_tag[68:59]={1'b1,7'(row),2'(node)};6:fp_req_tag[77:69]={1'b1,7'(row),1'(node)};7:fp_req_tag[85:78]={1'b1,7'(row)};endcase
 endtask
 // Every group has bounded semantics; no lane metadata table or exp matrix.
 always_comb begin
  bad_score=0;for(int i=0;i<8;i++)if(!finite(score_rsp_data[i]))bad_score=1;
  if(!finite(maximum[score_rsp_tag[10:4]]))bad_score=1;
  bad_group=0;for(int g=0;g<8;g++)if(tv(fp_rsp_tag,g))for(int n=0;n<nodes(g);n++)if(!finite(fp_rsp_data[lane0(g)+n]))bad_group[g]=1;
  bad_shift=bad_group[0];for(int i=0;i<8;i++)if(!fp_rsp_data[i][31]&&fp_rsp_data[i][30:0]!=0)bad_shift=1;
  bad_exp=0;for(int i=0;i<8;i++)if(!finite(sfu_rsp_data[i]))bad_exp=1;
  bad_div=|div_rsp_error;for(int i=0;i<8;i++)if(!finite(div_rsp_data[i]))bad_div=1;
 end
 always_comb begin
  score_rd_valid=0;score_rd_tag={read_row[6:0],read_chunk};score_rsp_ready=0;
  fp_req_valid=0;fp_req_tag=0;fp_a=0;fp_b=0;fp_rsp_ready=0;
  sfu_req_valid=0;sfu_req_tag={7'(tr(fp_rsp_tag,0)),4'(ti(fp_rsp_tag,0))};sfu_req_x=fp_rsp_data[7:0];sfu_rsp_ready=0;
  exp_wr_valid=0;exp_wr_tag=sfu_rsp_tag;exp_wr_data=sfu_rsp_data;exp_wr_ack_ready=state==RUN;
  exp_rd_valid=0;exp_rd_tag={norm_row[6:0],norm_chunk};exp_rsp_ready=0;
  div_req_valid=0;div_req_tag={85'b0,exp_rsp_tag};div_a=exp_rsp_data;div_b=0;div_rsp_ready=0;
  prob_wr_valid=0;prob_wr_tag=div_rsp_tag[10:0];prob_wr_data=div_rsp_data;prob_wr_ack_ready=state==RUN;
  shift_sink_ready=1;can_tick=1;skip_norm=0;
  if(state==RUN)begin
   if(!drain)begin
    if(read_row<128&&(read_chunk!=0||!active[read_row[5:0]]))score_rd_valid=1;
    if(tv(fp_rsp_tag,0)&&!cancelled[tr(fp_rsp_tag,0)%64]&&!bad_shift)shift_sink_ready=sfu_req_ready;
    can_tick=!fp_rsp_valid||shift_sink_ready;
    fp_rsp_ready=fp_req_ready&&shift_sink_ready;
    if(fp_rsp_valid&&tv(fp_rsp_tag,0)&&!cancelled[tr(fp_rsp_tag,0)%64]&&!bad_shift)begin sfu_req_valid=fp_req_ready;sfu_req_x=fp_rsp_data[7:0];end
    // Root shift reserves SFU space before entering FP, avoiding credit rings.
    if(score_rsp_valid&&!bad_score&&can_tick&&int'(sfu_vectors)+int'(shift_debt)<240)begin
     put_tag(0,int'(score_rsp_tag[10:4]),int'(score_rsp_tag[3:0]));
     for(int i=0;i<8;i++)begin fp_a[i]=score_rsp_data[i];fp_b[i]={!maximum[score_rsp_tag[10:4]][31],maximum[score_rsp_tag[10:4]][30:0]};end
     score_rsp_ready=fp_req_ready;
    end
    if(score_rsp_valid&&bad_score)score_rsp_ready=1;
    if(sfu_rsp_valid)begin
     if(cancelled[sfu_rsp_tag[9:4]]||bad_exp)sfu_rsp_ready=1;
     else if(can_tick)begin
      put_tag(1,int'(sfu_rsp_tag[10:4]),int'(sfu_rsp_tag[3:0]));
      for(int n=0;n<4;n++)begin fp_a[8+n]=sfu_rsp_data[n*2];fp_b[8+n]=sfu_rsp_data[n*2+1];end
      // Include this group only when the same real EXP bank write can accept.
      if(!exp_wr_ready)fp_req_tag[23]=0;
      exp_wr_valid=fp_req_ready; sfu_rsp_ready=fp_req_ready&&exp_wr_ready;
     end
    end
    if(fp_rsp_valid&&can_tick)begin
     for(int g=1;g<3;g++)if(tv(fp_rsp_tag,g)&&!cancelled[tr(fp_rsp_tag,g)%64]&&!bad_group[g])begin
      put_tag(g+1,tr(fp_rsp_tag,g),ti(fp_rsp_tag,g));
      for(int n=0;n<nodes(g+1);n++)begin fp_a[lane0(g+1)+n]=fp_rsp_data[lane0(g)+n*2];fp_b[lane0(g+1)+n]=fp_rsp_data[lane0(g)+n*2+1];end
     end
     for(int g=3;g<7;g++)if(tv(fp_rsp_tag,g)&&!cancelled[tr(fp_rsp_tag,g)%64]&&!bad_group[g]&&(ti(fp_rsp_tag,g)%2)==1)begin
      put_tag(g+1,tr(fp_rsp_tag,g),ti(fp_rsp_tag,g)/2);
      fp_a[lane0(g+1)]=partial_value[tr(fp_rsp_tag,g)%64][g-3];fp_b[lane0(g+1)]=fp_rsp_data[lane0(g)];
     end
    end
    for(int g=0;g<8;g++)if(tv(fp_req_tag,g))fp_req_valid=1;
    if(norm_row<128&&live(int'(norm_row)))begin
     if(cancelled[norm_row[5:0]]&&score_chunks[norm_row[5:0]]==16)skip_norm=1;
     else if(total_ready[norm_row[5:0]]&&!norm_done[norm_row[5:0]])exp_rd_valid=1;
    end
    if(exp_rsp_valid)begin
     if(cancelled[exp_rsp_tag[9:4]])exp_rsp_ready=1;
     else begin
      div_req_valid=1;exp_rsp_ready=div_req_ready;
      for(int i=0;i<8;i++)div_b[i]=total_value[exp_rsp_tag[9:4]];
     end
    end
    if(div_rsp_valid)begin
     if(cancelled[div_rsp_tag[9:4]]||bad_div)div_rsp_ready=1;
     else begin prob_wr_valid=1;div_rsp_ready=prob_wr_ready;end
    end
   end else begin score_rsp_ready=1;fp_rsp_ready=1;sfu_rsp_ready=1;exp_rsp_ready=1;div_rsp_ready=1;end
  end
 end
 task automatic candidate(input int ph,row,node,width);
  logic[63:0]rank;rank=64'h4000000000000000|(64'(ph)<<48)|(64'(row)<<16)|64'(node);
  if(!incoming_error||rank<incoming_rank)begin incoming_error=1;incoming_rank=rank;incoming_phase=5'(ph);incoming_row=7'(row);incoming_node=7'(node);incoming_element=32'(row*width+node);end
 endtask
 always_comb begin
  incoming_error=0;incoming_rank='1;incoming_phase=0;incoming_row=0;incoming_node=0;incoming_element=0;cancel_set=0;
  for(int c=0;c<64;c++)begin dfp[c]=0;dsfu[c]=0;ddiv[c]=0;dscore[c]=0;der[c]=0;dew[c]=0;dprob[c]=0;end
  if(fp_fire)for(int g=0;g<8;g++)if(tv(fp_req_tag,g))dfp[tr(fp_req_tag,g)%64]++;
  if(fp_return)for(int g=0;g<8;g++)if(tv(fp_rsp_tag,g))begin
   int row,index;row=tr(fp_rsp_tag,g);index=ti(fp_rsp_tag,g);dfp[row%64]--;
   if(g==0)begin
    for(int n=0;n<8;n++)begin
     if(!finite(fp_rsp_data[n]))begin candidate(8,row,index*8+n,128);cancel_set[row%64]=1;end
     else if(!fp_rsp_data[n][31]&&fp_rsp_data[n][30:0]!=0)begin candidate(9,row,index*8+n,128);cancel_set[row%64]=1;end
    end
   end else begin
    for(int n=0;n<nodes(g);n++)if(!finite(fp_rsp_data[lane0(g)+n]))begin candidate(9+g,row,g<4?index*nodes(g)+n:index,128>>g);cancel_set[row%64]=1;end
    if(g==7&&!positive(fp_rsp_data[18]))begin candidate(17,row,0,1);cancel_set[row%64]=1;end
   end
  end
  if(score_fire)dscore[int'(score_rd_tag[9:4])]++;
  if(score_return)begin
   int row;row=int'(score_rsp_tag[10:4]);dscore[row%64]--;
   for(int n=0;n<8;n++)if(!finite(score_rsp_data[n]))begin candidate(7,row,int'(score_rsp_tag[3:0])*8+n,128);cancel_set[row%64]=1;end
   if(!finite(maximum[row]))begin candidate(7,row,0,128);cancel_set[row%64]=1;end
  end
  if(sfu_fire)dsfu[int'(sfu_req_tag[9:4])]++;
  if(sfu_return)begin
   int row;row=int'(sfu_rsp_tag[10:4]);dsfu[row%64]--;
   for(int n=0;n<8;n++)if(!finite(sfu_rsp_data[n]))begin candidate(9,row,int'(sfu_rsp_tag[3:0])*8+n,128);cancel_set[row%64]=1;end
  end
  if(ew_fire)dew[int'(exp_wr_tag[9:4])]++;
  if(ew_ack)dew[int'(exp_wr_ack_tag[9:4])]--;
  if(er_fire)der[int'(exp_rd_tag[9:4])]++;
  if(er_return)der[int'(exp_rsp_tag[9:4])]--;
  if(div_fire)ddiv[int'(div_req_tag[9:4])]++;
  if(div_return)begin
   int row;row=int'(div_rsp_tag[10:4]);ddiv[row%64]--;
   for(int n=0;n<8;n++)if(div_rsp_error[n]||!finite(div_rsp_data[n]))begin candidate(18,row,int'(div_rsp_tag[3:0])*8+n,128);cancel_set[row%64]=1;end
  end
  if(pw_fire)dprob[int'(prob_wr_tag[9:4])]++;
  if(pw_ack)dprob[int'(prob_wr_ack_tag[9:4])]--;
  free_row=0;free_count=0;
  for(int c=0;c<64;c++)if(active[c]&&norm_done[c]&&score_chunks[c]==16&&fp_debt[c]==0&&sfu_debt[c]==0&&div_debt[c]==0&&score_debt[c]==0&&exp_read_debt[c]==0&&exp_write_debt[c]==0&&prob_debt[c]==0&&
      (cancelled[c]||(prob_commits[c]==16&&partial_valid[c]==0)))begin free_row[c]=1;free_count++;end
 end
 always_ff @(posedge clk)begin
  if(!rst_n)begin
   state<=IDLE;aborted<=0;protocol_bad<=0;request_id<=0;generation<=0;epoch<=0;head<=0;clock_count<=0;start_stamp<=0;previous_row_stamp<=0;
   active<=0;row_hi<=0;cancelled<=0;total_ready<=0;norm_done<=0;partial_valid<=0;fp_debt<=0;sfu_debt<=0;div_debt<=0;score_debt<=0;exp_read_debt<=0;exp_write_debt<=0;prob_debt<=0;score_chunks<=0;exp_commits<=0;prob_commits<=0;
   read_row<=0;read_chunk<=0;norm_row<=0;norm_chunk<=0;fp_vectors<=0;shift_debt<=0;sfu_vectors<=0;div_vectors<=0;score_issued<=0;score_seen<=0;probability_commits<=0;rows_launched<=0;rows_retired<=0;
   done_cycles<=0;first_row_cycle<=0;max_sum_tail<=0;max_row_launch_gap<=0;error_valid<=0;error_rank<='1;error_phase<=0;error_row<=0;error_node<=0;error_element<=0;
  end else begin
   clock_count<=clock_count+1'b1;
   if(start_fire)begin
    state<=RUN;request_id<=start_request_id;generation<=start_generation;epoch<=start_epoch;head<=start_head;start_stamp<=clock_count;aborted<=0;protocol_bad<=0;
    active<=0;row_hi<=0;cancelled<=0;total_ready<=0;norm_done<=0;partial_valid<=0;fp_debt<=0;sfu_debt<=0;div_debt<=0;score_debt<=0;exp_read_debt<=0;exp_write_debt<=0;prob_debt<=0;score_chunks<=0;exp_commits<=0;prob_commits<=0;
    read_row<=0;read_chunk<=0;norm_row<=0;norm_chunk<=0;fp_vectors<=0;shift_debt<=0;sfu_vectors<=0;div_vectors<=0;score_issued<=0;score_seen<=0;probability_commits<=0;rows_launched<=0;rows_retired<=0;
    done_cycles<=0;first_row_cycle<=0;max_sum_tail<=0;max_row_launch_gap<=0;error_valid<=0;error_rank<='1;error_phase<=0;error_row<=0;error_node<=0;error_element<=0;
   end
   if(state==RUN)begin
    if(abort_fire)aborted<=1;
    if(resource_fault||int'(sfu_vectors)+int'(shift_debt)>240||fp_vectors>32)protocol_bad<=1;
    if(incoming_error&&(!error_valid||incoming_rank<error_rank))begin error_valid<=1;error_rank<=incoming_rank;error_phase<=incoming_phase;error_row<=incoming_row;error_node<=incoming_node;error_element<=incoming_element;end
    fp_vectors<=7'(int'(fp_vectors)+int'(fp_fire)-int'(fp_return));
    shift_debt<=7'(int'(shift_debt)+int'(fp_fire&&tv(fp_req_tag,0))-int'(fp_return&&tv(fp_rsp_tag,0)));
    sfu_vectors<=9'(int'(sfu_vectors)+int'(sfu_fire)-int'(sfu_return));div_vectors<=6'(int'(div_vectors)+int'(div_fire)-int'(div_return));
    rows_retired<=8'(int'(rows_retired)+free_count);
    for(int c=0;c<64;c++)begin
     if(score_fire&&score_rd_tag[3:0]==0&&int'(score_rd_tag[9:4])==c)begin
      active[c]<=1;row_hi[c]<=score_rd_tag[10];cancelled[c]<=0;total_ready[c]<=0;norm_done[c]<=0;partial_valid[c]<=0;
      fp_debt[c]<=0;sfu_debt[c]<=0;div_debt[c]<=0;score_debt[c]<=1;exp_read_debt[c]<=0;exp_write_debt[c]<=0;prob_debt[c]<=0;score_chunks[c]<=0;exp_commits[c]<=0;prob_commits[c]<=0;
     end else begin
      fp_debt[c]<=7'(int'(fp_debt[c])+dfp[c]);sfu_debt[c]<=6'(int'(sfu_debt[c])+dsfu[c]);div_debt[c]<=6'(int'(div_debt[c])+ddiv[c]);score_debt[c]<=6'(int'(score_debt[c])+dscore[c]);
      exp_read_debt[c]<=6'(int'(exp_read_debt[c])+der[c]);exp_write_debt[c]<=6'(int'(exp_write_debt[c])+dew[c]);prob_debt[c]<=6'(int'(prob_debt[c])+dprob[c]);
      if(cancel_set[c])cancelled[c]<=1;
      if(free_row[c])begin active[c]<=0;partial_valid[c]<=0;end
     end
     if(int'(fp_debt[c])+dfp[c]<0||int'(sfu_debt[c])+dsfu[c]<0||int'(div_debt[c])+ddiv[c]<0||int'(score_debt[c])+dscore[c]<0||int'(exp_read_debt[c])+der[c]<0||int'(exp_write_debt[c])+dew[c]<0||int'(prob_debt[c])+dprob[c]<0)protocol_bad<=1;
    end
    if(score_fire)begin
     score_issued<=score_issued+1'b1;
     if(read_chunk==0)begin
      rows_launched<=rows_launched+1'b1;if(rows_launched!=0&&clock_count-previous_row_stamp>max_row_launch_gap)max_row_launch_gap<=clock_count-previous_row_stamp;previous_row_stamp<=clock_count;
     end
     if(read_chunk==15)begin read_chunk<=0;read_row<=read_row+1'b1;end else read_chunk<=read_chunk+1'b1;
    end
    if(score_return)begin score_seen<=score_seen+1'b1;score_chunks[score_rsp_tag[9:4]]<=score_chunks[score_rsp_tag[9:4]]+1'b1;if(!live(int'(score_rsp_tag[10:4])))protocol_bad<=1;end
    if(sfu_fire&&!live(int'(sfu_req_tag[10:4])))protocol_bad<=1;
    if(sfu_return)begin if(!live(int'(sfu_rsp_tag[10:4])))protocol_bad<=1;if(sfu_rsp_tag[3:0]==15)last_exp_stamp[sfu_rsp_tag[9:4]]<=clock_count;end
    if(ew_ack)begin exp_commits[exp_wr_ack_tag[9:4]]<=exp_commits[exp_wr_ack_tag[9:4]]+1'b1;if(!live(int'(exp_wr_ack_tag[10:4])))protocol_bad<=1;end
    if(fp_return)for(int g=0;g<8;g++)if(tv(fp_rsp_tag,g))begin
     int row,node,c;row=tr(fp_rsp_tag,g);node=ti(fp_rsp_tag,g);c=row%64;
     if(!live(row))protocol_bad<=1;
     if(!drain&&!cancelled[c]&&!bad_group[g])begin
      if(g>=3&&g<7)begin
       if(node%2==0)begin partial_value[c][g-3]<=fp_rsp_data[lane0(g)];partial_pair[c][g-3]<=4'(node/2);partial_valid[c][g-3]<=1;end
       else begin if(!partial_valid[c][g-3]||partial_pair[c][g-3]!=4'(node/2))protocol_bad<=1;partial_valid[c][g-3]<=0;end
      end
      if(g==7&&positive(fp_rsp_data[18]))begin total_value[c]<=fp_rsp_data[18];total_ready[c]<=1;if(clock_count-last_exp_stamp[c]>max_sum_tail)max_sum_tail<=clock_count-last_exp_stamp[c];end
     end
    end
    if(skip_norm)begin norm_done[norm_row[5:0]]<=1;norm_chunk<=0;norm_row<=norm_row+1'b1;end
    else if(er_fire)begin if(norm_chunk==15)begin norm_done[norm_row[5:0]]<=1;norm_chunk<=0;norm_row<=norm_row+1'b1;end else norm_chunk<=norm_chunk+1'b1;end
    if(er_return&&!live(int'(exp_rsp_tag[10:4])))protocol_bad<=1;
    if(div_return&&!live(int'(div_rsp_tag[10:4])))protocol_bad<=1;
    if(pw_ack)begin
     probability_commits<=probability_commits+1'b1;prob_commits[prob_wr_ack_tag[9:4]]<=prob_commits[prob_wr_ack_tag[9:4]]+1'b1;
     if(prob_wr_ack_tag[10:4]==0&&prob_commits[0]==15)first_row_cycle<=clock_count-start_stamp;
     if(!live(int'(prob_wr_ack_tag[10:4])))protocol_bad<=1;
    end
    if((drain&&debts_zero)||(!drain&&read_row==128&&norm_row==128&&rows_retired==128&&active==0&&score_seen==2048&&debts_zero))begin state<=DONE;done_cycles<=clock_count-start_stamp+1'b1;end
   end
   if(state==DONE&&done_ready)state<=IDLE;
  end
 end
endmodule
