`timescale 1ns/1ps
module m007_ln_scalars_tb;
 logic clk=0,rst_n=0;always#5 clk=~clk;
 logic d_req_valid=0,d_req_ready,d_rsp_valid,d_rsp_ready=0,d_rsp_error;
 logic s_req_valid=0,s_req_ready,s_rsp_valid,s_rsp_ready=0,s_rsp_error,s_busy;
 logic[31:0]d_req_data=0,s_req_data=0,d_rsp_data,s_rsp_data;
 logic[15:0]d_req_tag=0,s_req_tag=0,d_rsp_tag,s_rsp_tag;
 logic[103:0]vectors[0:32767];integer count,initial_count,cycle=0,d_sent=0,s_sent=0,d_got=0,s_got=0;
 integer d_at[0:32767],s_at[0:32767];bit d_seen[0:32767],s_seen[0:32767];
 integer d_checked=0,s_checked=0,held_div=0,held_sqrt=0;bit checking=1,d_held=0,s_held=0;
 logic[48:0]d_held_record,s_held_record;string vector_file;
 laya_m007_ln_div1024_v1#(.TAG_WIDTH(16))divider(.clk,.rst_n,.req_valid(d_req_valid),.req_ready(d_req_ready),.req_data(d_req_data),.req_tag(d_req_tag),.rsp_valid(d_rsp_valid),.rsp_ready(d_rsp_ready),.rsp_data(d_rsp_data),.rsp_error(d_rsp_error),.rsp_tag(d_rsp_tag));
 laya_m007_ln_sqrt_v1#(.TAG_WIDTH(16))square_root(.clk,.rst_n,.req_valid(s_req_valid),.req_ready(s_req_ready),.req_data(s_req_data),.req_tag(s_req_tag),.rsp_valid(s_rsp_valid),.rsp_ready(s_rsp_ready),.rsp_data(s_rsp_data),.rsp_error(s_rsp_error),.rsp_tag(s_rsp_tag),.busy(s_busy));
 always@(posedge clk)begin
  cycle=cycle+1;if(cycle>600000)$fatal(1,"scalar cycle limit");
  if(!rst_n)begin d_held=0;s_held=0;end
  else begin
   if(d_held&&(!d_rsp_valid||{d_rsp_tag,d_rsp_error,d_rsp_data}!==d_held_record))$fatal(1,"held div result changed");
   if(s_held&&(!s_rsp_valid||{s_rsp_tag,s_rsp_error,s_rsp_data}!==s_held_record))$fatal(1,"held sqrt result changed");
   d_held=d_rsp_valid&&!d_rsp_ready;s_held=s_rsp_valid&&!s_rsp_ready;
   d_held_record={d_rsp_tag,d_rsp_error,d_rsp_data};s_held_record={s_rsp_tag,s_rsp_error,s_rsp_data};
   if(d_held)held_div++;if(s_held)held_sqrt++;
   if(checking)begin
    if(d_req_valid&&d_req_ready)begin d_at[d_req_tag]=cycle;d_sent++;end
    if(s_req_valid&&s_req_ready)begin s_at[s_req_tag]=cycle;s_sent++;end
    if(d_rsp_valid)begin
     if(d_rsp_tag>=count)$fatal(1,"stale div tag=%h",d_rsp_tag);
     if(!d_seen[d_rsp_tag])begin
      if(cycle-d_at[d_rsp_tag]!=1)$fatal(1,"div availability latency=%0d",cycle-d_at[d_rsp_tag]);d_seen[d_rsp_tag]=1;
     end
     if(d_rsp_error!==vectors[d_rsp_tag][96]||(!d_rsp_error&&d_rsp_data!==vectors[d_rsp_tag][63:32]))$fatal(1,"div exact mismatch tag=%0d input=%h actual=%h expected=%h",d_rsp_tag,vectors[d_rsp_tag][31:0],d_rsp_data,vectors[d_rsp_tag][63:32]);
     if(d_rsp_ready)begin if(d_rsp_tag!=d_got)$fatal(1,"div order");d_got++;d_checked++;end
    end
    if(s_rsp_valid)begin
     if(s_rsp_tag>=count)$fatal(1,"stale sqrt tag=%h",s_rsp_tag);
     if(!s_seen[s_rsp_tag])begin
      if(cycle-s_at[s_rsp_tag]!=25)$fatal(1,"sqrt availability latency=%0d",cycle-s_at[s_rsp_tag]);s_seen[s_rsp_tag]=1;
     end
     if(s_rsp_error!==vectors[s_rsp_tag][100]||(!s_rsp_error&&s_rsp_data!==vectors[s_rsp_tag][95:64]))$fatal(1,"sqrt exact mismatch tag=%0d input=%h actual=%h expected=%h err=%0d",s_rsp_tag,vectors[s_rsp_tag][31:0],s_rsp_data,vectors[s_rsp_tag][95:64],s_rsp_error);
     if(s_rsp_ready)begin if(s_rsp_tag!=s_got)$fatal(1,"sqrt order");s_got++;s_checked++;end
    end
   end else if(d_rsp_valid&&d_rsp_ready||s_rsp_valid&&s_rsp_ready)$fatal(1,"unexpected discarded-work consumption");
  end
 end
 task automatic stream;
  for(int i=0;i<count;i++)begin d_seen[i]=0;s_seen[i]=0;end
  while(d_got<count||s_got<count)begin
   @(negedge clk);d_rsp_ready=cycle%29>=6;s_rsp_ready=cycle%41>=7;
   d_req_valid=d_sent<count;s_req_valid=s_sent<count;
   if(d_sent<count)begin d_req_tag=16'(d_sent);d_req_data=vectors[d_sent][31:0];end
   if(s_sent<count)begin s_req_tag=16'(s_sent);s_req_data=vectors[s_sent][31:0];end
  end
  @(negedge clk);d_req_valid=0;s_req_valid=0;d_rsp_ready=0;s_rsp_ready=0;
  if(d_sent!=count||s_sent!=count||s_busy||d_rsp_valid||s_rsp_valid)$fatal(1,"scalar final count/debt mismatch");
 endtask
 initial begin
  if(!$value$plusargs("VECTORS=%s",vector_file)||!$value$plusargs("COUNT=%d",count))$fatal(1,"scalar fixture args required");
  initial_count=count;$readmemh(vector_file,vectors);
  repeat(4)@(negedge clk);rst_n=1;stream;
  if(held_div==0||held_sqrt==0)$fatal(1,"no actual held scalar result");
  $display("M007_LN_SCALARS_PROGRESS vectors=%0d div_latency=1 sqrt_latency=25 held_div=%0d held_sqrt=%0d",count,held_div,held_sqrt);
  // Reset a real pending div result and a real active iterative root together.
  checking=0;@(negedge clk);d_req_valid=1;s_req_valid=1;d_req_data=32'h3f800000;s_req_data=32'h3f800000;d_req_tag=16'hf100;s_req_tag=16'hf101;
  @(posedge clk);if(!d_req_ready||!s_req_ready)$fatal(1,"reset pilot input not accepted");
  @(negedge clk);d_req_valid=0;s_req_valid=0;
  repeat(4)@(negedge clk);if(!s_busy||!d_rsp_valid)$fatal(1,"reset missing actual pending work");rst_n=0;
  repeat(3)@(negedge clk);rst_n=1;checking=1;d_sent=0;s_sent=0;d_got=0;s_got=0;count=4;
  repeat(30)@(negedge clk);if(s_busy||d_rsp_valid||s_rsp_valid)$fatal(1,"stale scalar result after reset");
  stream;repeat(8)@(negedge clk);
  $display("HARDWARE_AGENT_SIM_PASS M007_LN_SCALARS initial_vectors=%0d div_checked=%0d sqrt_checked=%0d div_latency=1 sqrt_latency=25 hold=1 active_reset=1",initial_count,d_checked,s_checked);$finish;
 end
endmodule
