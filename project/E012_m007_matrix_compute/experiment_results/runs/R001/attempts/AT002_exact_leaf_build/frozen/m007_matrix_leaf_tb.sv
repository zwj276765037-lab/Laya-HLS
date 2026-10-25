`timescale 1ns/1ps
module m007_matrix_leaf_tb;
 localparam int COUNT=1142784,PAIRS=274688;
 logic clk=0;always #1 clk=~clk;
 logic rst_n=0,req_valid=0;logic [31:0] req_tag=0;logic [15:0] a,b;logic signed [20:0] din;
 logic half_valid,dot_valid,bad,domain;logic [31:0] half_tag,dot_tag,half_result,dot_result;
 laya_m007_half_product_v1 halfprod(.clk,.rst_n,.req_valid,.req_tag,.a,.b,.rsp_valid(half_valid),.rsp_tag(half_tag),.result(half_result),.nonfinite(bad));
 laya_m007_dot_to_f32_v1 dotcast(.clk,.rst_n,.req_valid,.req_tag,.dot(din),.rsp_valid(dot_valid),.rsp_tag(dot_tag),.result(dot_result),.domain_error(domain));
 logic signed [7:0] pa,pw0,pw1;logic signed [15:0] pp0,pp1;
 tm1tn8_signed_pack_pair pair(.a(pa),.w0(pw0),.w1(pw1),.p0(pp0),.p1(pp1));
 logic [119:0] vectors[0:COUNT-1];logic [55:0] pairs[0:PAIRS-1];
 string fixture;integer half_checks=0,dot_checks=0,pair_checks=0,cycle=0;logic pairs_done=0,half_bad_seen=0,dot_bad_seen=0;
 always @(posedge clk)begin
  cycle=cycle+1;#0.001;
  if(rst_n)begin
   if(half_valid)begin
    if(half_tag<COUNT)begin
     if(bad||half_result!==vectors[half_tag][63:32])$fatal(1,"exact half product mismatch tag=%0d A=%h B=%h got=%h gold=%h",half_tag,vectors[half_tag][15:0],vectors[half_tag][31:16],half_result,vectors[half_tag][63:32]);
     half_checks=half_checks+1;
    end else begin if(!bad)$fatal(1,"nonfinite half domain lost");half_bad_seen=1;end
   end
   if(dot_valid)begin
    if(dot_tag<COUNT)begin
     if(domain||dot_result!==vectors[dot_tag][119:88])$fatal(1,"exact dot F32 mismatch tag=%0d got=%h gold=%h",dot_tag,dot_result,vectors[dot_tag][119:88]);
     dot_checks=dot_checks+1;
    end else begin if(!domain)$fatal(1,"dot domain bound lost");dot_bad_seen=1;end
   end
  end
  if(cycle>2000000)$fatal(1,"leaf cycle watchdog");
 end
 initial begin
  if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
  $readmemh({fixture,"/scale.hex"},vectors);$readmemh({fixture,"/pair.hex"},pairs);
  repeat(5)@(negedge clk);rst_n=1;
  fork
   begin
    for(integer i=0;i<PAIRS;i=i+1)begin
     @(negedge clk);pa=pairs[i][7:0];pw0=pairs[i][15:8];pw1=pairs[i][23:16];#0.001;
     if(pp0!==pairs[i][39:24]||pp1!==pairs[i][55:40])$fatal(1,"signed pair mismatch i=%0d a=%0d w0=%0d w1=%0d p0=%0d p1=%0d",i,pa,pw0,pw1,pp0,pp1);
     pair_checks=pair_checks+1;
    end
    pairs_done=1;
   end
   begin
    for(integer i=0;i<COUNT;i=i+1)begin
     @(negedge clk);req_valid=1;req_tag=i;a=vectors[i][15:0];b=vectors[i][31:16];din=vectors[i][84:64];
     if(i%997==0)begin req_valid=0;repeat(3)@(negedge clk);req_valid=1;end
    end
    @(negedge clk);req_tag=COUNT;a=16'h7c00;b=16'h3c00;din=21'd524289;
    @(negedge clk);req_valid=0;
   end
  join
  wait(half_checks==COUNT&&dot_checks==COUNT&&half_bad_seen&&dot_bad_seen&&pairs_done);
  $display("HARDWARE_AGENT_SIM_PASS M007_MATRIX_LEAF pair_checks=%0d half_product_checks=%0d dot_F32_checks=%0d nonfinite_and_domain=checked cycles=%0d",pair_checks,half_checks,dot_checks,cycle);$finish;
 end
endmodule
