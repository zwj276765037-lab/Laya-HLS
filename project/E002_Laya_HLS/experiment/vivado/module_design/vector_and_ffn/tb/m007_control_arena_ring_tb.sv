`timescale 1ns/1ps
module m007_control_arena_ring_tb;
 logic clk=0;always #1.6665 clk=~clk;logic rst_n=0,clear=0,idle,pool_reset_n;
 logic iv=0,ir,ov,ready=1;logic [95:0] tag=0,ot;logic [7:0][31:0] x=0,gate=0,y,status;
 logic [8:0] fqv,fqr,fpv;logic [8:0][95:0] fqt,fpt;logic [8:0][7:0][31:0] fa,fb,fy,fs;
 logic pool_fault,sv,sr,sov,sor;logic [95:0] st,sot;logic [7:0] sm,som;logic [7:0][31:0] sx,sy,ss;
 logic [8:0] pending;logic [1:0][8:0] slot_pending,sfu_debt;logic [1:0][7:0] fp_debt;
 logic [7:0][18:0] covered,evaluated;logic err;logic [2:0] erank;logic [6:0] erow;logic [11:0] ecol;logic fault;
 logic lv=0,lr,active,draining,release_valid=0,release_ready,reject,sfu_fault;logic [1:0] reject_code;
 logic [63:0] rid=64'h123456789abcdef0;logic [31:0] gen=7,epoch=9;logic [8:0] sfu_pending,sfu_flight;
 logic [383:0] vectors[0:335871];string vf,pf;integer progress_fd;
 int groups,count,issued=0,consumed=0,cycles=0,first_latency=-1,last=-1,first_accept=-1,node_checks=0,held_cycles=0,peak=0,full_swaps=0,held_records=0,output_hold_gaps=0,boundary255=0,boundary511=0;
 logic [11342:0]external_q,external_next;
 always_ff @(posedge clk)external_q<=external_next;
 laya_m007_g_math_v1 #(.EXTERNAL_CONTROL(1)) dut(.external_control_enable(1'b1),.external_control_q(external_q),.external_control_next(external_next),.control_retired(),.clk,.rst_n,.clear,.idle,.pool_reset_n,.in_valid(iv),.in_ready(ir),.in_tag(tag),.in_x(x),.in_gate(gate),
  .out_valid(ov),.out_ready(ready),.out_tag(ot),.out_data(y),.out_status(status),
  .fp_req_valid(fqv),.fp_req_ready(fqr),.fp_req_tag(fqt),.fp_req_a(fa),.fp_req_b(fb),.fp_rsp_valid(fpv),.fp_rsp_tag(fpt),.fp_rsp_data(fy),.fp_rsp_status(fs),.fp_pool_fault(pool_fault),
  .sfu_req_valid(sv),.sfu_req_ready(sr),.sfu_req_tag(st),.sfu_req_mask(sm),.sfu_req_x(sx),.sfu_rsp_valid(sov),.sfu_rsp_ready(sor),.sfu_rsp_tag(sot),.sfu_rsp_data(sy),.sfu_rsp_status(ss),
  .pending,.slot_pending,.slot_sfu_debt(sfu_debt),.slot_fp_debt(fp_debt),.covered,.evaluated,.first_error_valid(err),.first_error_rank(erank),.first_error_row(erow),.first_error_column(ecol),.protocol_fault(fault));
 laya_m007_g_vector_pool_v1 pool(.clk,.rst_n(pool_reset_n),.req_valid(fqv),.req_ready(fqr),.req_tag(fqt),.req_a(fa),.req_b(fb),.rsp_valid(fpv),.rsp_tag(fpt),.rsp_data(fy),.rsp_status(fs),.protocol_fault(pool_fault));
 laya_m007_tanh8_v1 tanh(.clk,.rst_n,.lease_valid(lv),.lease_ready(lr),.lease_request_id(rid),.lease_generation(gen),.lease_epoch(epoch),.lease_phase(3'd1),
  .release_valid,.release_ready,.release_phase(3'd1),.release_epoch(epoch),.phase_debt_clear(idle),.lease_active(active),.draining,
  .rsp_request_id(),.rsp_generation(),.rsp_epoch(),.rsp_phase(),.req_valid(sv),.req_ready(sr),.req_mode(2'd1),.req_request_id(rid),.req_generation(gen),.req_epoch(epoch),.req_phase(3'd1),.req_tag(st),.req_mask(sm),.req_x(sx),
  .reject_valid(reject),.reject_code,.rsp_valid(sov),.rsp_ready(sor),.rsp_tag(sot),.rsp_mask(som),.rsp_data(sy),.rsp_status(ss),.pending_vectors(sfu_pending),.in_flight_vectors(sfu_flight),.protocol_fault(sfu_fault));
 function automatic int scalar_index(input int vector_index,lane);
  return ((vector_index%512)/4)*2624+(vector_index/512)*32+(vector_index%4)*8+lane;
 endfunction
 function automatic [31:0] field(input int index,word_index);return vectors[index][383-word_index*32-:32];endfunction
 task automatic drive(input int index);
  tag={gen,epoch,16'b0,16'(index)};
  for(int l=0;l<8;l++)begin x[l]=field(scalar_index(index,l),0);gate[l]=field(scalar_index(index,l),1);end
  iv=1;
 endtask
 initial begin
  if(!$value$plusargs("VECTORS=%s",vf)||!$value$plusargs("PROGRESS_FILE=%s",pf)||!$value$plusargs("GROUPS=%d",groups)||groups<1||groups>82)$fatal(1,"ARGS");
  if(groups!=3)$fatal(1,"RING_TEST_THREE_ORIGINAL_BLOCKS");count=groups*512;ready=0;$readmemh(vf,vectors);progress_fd=$fopen(pf,"w");if(!progress_fd)$fatal(1,"PROGRESS_OPEN");
  repeat(5)@(negedge clk);rst_n=1;lv=1;#0.001;while(!lr)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);lv=0;
  for(int i=0;i<count;i++)begin
   @(negedge clk);drive(i);
   if(i==256||i==512||i==768)begin
    logic [607:0] record;
    ready=0;#0.001;while(!ov)begin @(negedge clk);#0.001;end
    if(pending!=256||ir||dut.head_ptr!=dut.reserve_ptr||ot[15:0]!=16'(i-256))$fatal(1,"FULL_HELD_PRECONDITION");
    record={y,status,ot};
    repeat(17)begin
     @(negedge clk);#0.001;
     if(!ov||{y,status,ot}!==record||pending!=256||ir||dut.head_ptr!=dut.reserve_ptr)$fatal(1,"FULL_HELD_RECORD_OVERWRITTEN");
     held_cycles=held_cycles+1;
    end
    held_records=held_records+1;ready=1;
   end
   #0.001;while(!ir)begin @(negedge clk);#0.001;end
  end
  @(negedge clk);iv=0;wait(consumed==count);repeat(3)@(negedge clk);
  if(issued!=count||pending||!idle||err||fault||sfu_pending||sfu_flight||slot_pending||sfu_debt||fp_debt)$fatal(1,"FINAL_DEBT issued=%0d consumed=%0d pending=%0d fault=%0d",issued,consumed,pending,fault);
  for(int rank=0;rank<8;rank++)if(covered[rank]!=count*8||evaluated[rank]!=count*8)$fatal(1,"COVERAGE rank=%0d covered=%0d evaluated=%0d",rank,covered[rank],evaluated[rank]);
  if(peak!=256||full_swaps!=count-256||held_cycles!=51||held_records!=3||output_hold_gaps!=2||boundary255!=1||boundary511!=1)$fatal(1,"EXACT_RING_COUNTS peak=%0d swaps=%0d held=%0d records=%0d gaps=%0d boundary255=%0d boundary511=%0d",peak,full_swaps,held_cycles,held_records,output_hold_gaps,boundary255,boundary511);
  release_valid=1;wait(!active);@(negedge clk);release_valid=0;$fclose(progress_fd);
  $display("HARDWARE_AGENT_SIM_PASS G_RING_TAG groups=%0d checked=%0d node_checks=%0d first_actual_consume=%0d pending_peak=%0d full_same_address_swaps=%0d held_cycles=%0d held_records=%0d output_hold_gaps=%0d boundary255=%0d boundary511=%0d fp56mul16add=1 real_tanh8=1 all_debt_zero=1",groups,consumed*8,node_checks,first_latency,peak,full_swaps,held_cycles,held_records,output_hold_gaps,boundary255,boundary511);$finish;
 end
 always @(posedge clk)begin
  cycles=cycles+1;if(cycles>100000)$fatal(1,"TIMEOUT");
  if(rst_n)begin
   if(fault||pool_fault||sfu_fault||reject)$fatal(1,"PEER_FAULT math=%0d pool=%0d sfu=%0d",fault,pool_fault,sfu_fault);
   if(iv&&ir)begin
    if(pending==256)begin
     if(!ov||!ready||dut.head_ptr!=dut.reserve_ptr||tag[15:0]!=ot[15:0]+16'd256||dut.tag_mem_hi[dut.head_ptr]!=ot[15:8])$fatal(1,"FULL_SAME_ADDRESS_OLD_RECORD");
     full_swaps=full_swaps+1;
    end
    if(tag[15:0]!=issued)$fatal(1,"INPUT_ORDER");if(first_accept<0)first_accept=cycles;issued=issued+1;end
   for(int n=0;n<9;n++)if(fpv[n])begin
    int gold_word;gold_word=n==0?2:n==1?3:n==2?4:n==3?5:n==4?6:n==5?8:n==6?9:n==7?10:11;
    for(int l=0;l<8;l++)begin
     if(fy[n][l]!==field(scalar_index(int'(fpt[n][15:0]),l),gold_word))$fatal(1,"FP_NODE node=%0d vector=%0d lane=%0d got=%h expected=%h",n,fpt[n][15:0],l,fy[n][l],field(scalar_index(int'(fpt[n][15:0]),l),gold_word));node_checks=node_checks+1;
    end
   end
   if(sov&&sor)for(int l=0;l<8;l++)begin if(sy[l]!==field(scalar_index(int'(sot[15:0]),l),7)||ss[l]!==0||som!==8'hff)$fatal(1,"TANH_H");node_checks=node_checks+1;end
   if(ov&&ready)begin
    logic [7:0][31:0] expected_vector,observed_vector,observed_status;
    observed_vector=y;observed_status=status;
    if(ot[15:0]!=consumed||ot[31:16]!=0||ot[95:64]!=gen||ot[63:32]!=epoch)$fatal(1,"OUTPUT_TAG");
    // Read the frozen final-product word directly. Nested automatic function
    // calls inside this loop produced a repeated lane0 expected vector in
    // AT062, although the underlying frozen fixture contains distinct lanes.
    for(int l=0;l<8;l++)begin
     integer golden_index;
     golden_index=((consumed%512)/4)*2624+(consumed/512)*32+(consumed%4)*8+l;
     expected_vector[l]=vectors[golden_index][31:0];
    end
    if(observed_vector!==expected_vector||observed_status!==256'b0)$fatal(1,"OUTPUT vector=%0d got=%h expected=%h status=%h data_diff=%0d status_diff=%0d",consumed,observed_vector,expected_vector,observed_status,observed_vector!==expected_vector,observed_status!==256'b0);
    if(first_latency<0)first_latency=cycles-first_accept;
    if(last>=0&&cycles!=last+1)begin
     if(cycles-last!=18)$fatal(1,"UNPLANNED_OUTPUT_GAP old=%0d new=%0d",last,cycles);output_hold_gaps=output_hold_gaps+1;
    end
    if(consumed==256)boundary255=boundary255+1;
    if(consumed==512)boundary511=boundary511+1;
    last=cycles;consumed=consumed+1;
    if(consumed%512==0||consumed==count)begin
     $fdisplay(progress_fd,"{\"schema\":\"m007-tanh-consumed-v1\",\"checked\":%0d,\"node_checks\":%0d,\"cycle\":%0d,\"phase\":1,\"returned\":%0d}",consumed*8,node_checks,cycles,consumed);$fflush(progress_fd);
    end
   end
   if(pending>peak)peak=pending;
  end
 end
endmodule
