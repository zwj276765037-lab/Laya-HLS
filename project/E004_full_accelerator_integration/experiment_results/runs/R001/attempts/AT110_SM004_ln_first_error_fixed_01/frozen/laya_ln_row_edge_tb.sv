`timescale 1ns/1ps
module laya_ln_row_edge_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,cmd_valid=0,cmd_ready;
  logic [1:0] gamma_kind=0;
  logic x_valid=0,x_ready,gamma_valid=0,gamma_ready;
  logic [31:0] x_bits=0,gamma_bits=0;
  logic out_valid,out_ready=1,out_last,done_valid,done_ready=0;
  logic [31:0] out_bits,done_bad_element,mean_bits,variance_bits,inverse_bits;
  logic [9:0] out_index;
  logic [3:0] done_status;
  logic [31:0] x[0:1023],y[0:1023],meta[0:29];
  laya_ln_row_v1 dut(.*);

  task automatic one_case(input integer id,input string fixture);
    integer xi,oi,t,hold;
    bit accepted,consumed;
    begin
      $readmemh($sformatf("%s/x%0d.mem",fixture,id),x);
      $readmemh($sformatf("%s/y%0d.mem",fixture,id),y);
      xi=0;oi=0;hold=0;accepted=0;consumed=0;
      for(t=0;t<30000 && !consumed;t++) begin
        @(negedge clk);
        cmd_valid=!accepted; gamma_kind=0;
        x_valid=accepted && xi<1024;
        x_bits=x[xi<1024?xi:0];
        done_ready=hold>=5;
        @(posedge clk);
        if(cmd_valid && cmd_ready) accepted=1;
        if(x_valid && x_ready) xi++;
        if(out_valid && out_ready) begin
          if(meta[id*5]!=0 || out_index !== oi ||
             out_last !== (oi==1023) || out_bits !== y[oi])
            $fatal(1,"LN_EDGE_OUTPUT id=%0d i=%0d got=%08x expected=%08x",id,oi,out_bits,y[oi]);
          oi++;
        end
        if(done_valid) begin
          if(done_status !== meta[id*5][3:0] ||
             done_bad_element !== meta[id*5+1] ||
             (meta[id*5]==0 && (mean_bits !== meta[id*5+2] ||
                                  variance_bits !== meta[id*5+3] ||
                                  inverse_bits !== meta[id*5+4]))) begin
            $display("LN_EDGE_OBSERVED id=%0d status=%0d bad=%0d out=%0d expected_status=%0d expected_bad=%0d",
              id,done_status,done_bad_element,oi,meta[id*5],meta[id*5+1]);
            $fatal(1,"LN_EDGE_FIRST_ERROR id=%0d",id);
          end
          if(!done_ready) hold++;
          else consumed=1;
        end
      end
      @(negedge clk);cmd_valid=0;x_valid=0;done_ready=0;
      if(!consumed || !cmd_ready || done_valid || xi!=1024 || hold<5 ||
         (meta[id*5]==0 ? oi!=1024 : oi!=0))
        $fatal(1,"LN_EDGE_DEBT id=%0d consumed=%0d x=%0d out=%0d hold=%0d",id,consumed,xi,oi,hold);
      $display("LN_EDGE_CASE_PASS id=%0d status=%0d bad=%0d cycles=%0d out=%0d",id,meta[id*5],meta[id*5+1],t,oi);
    end
  endtask
  initial begin
    string fixture;
    if(!$value$plusargs("FIXTURE=%s",fixture)) $fatal(1,"LN_EDGE_FIXTURE_MISSING");
    $readmemh({fixture,"/meta.mem"},meta);
    repeat(4) @(negedge clk);rst_n=1;
    for(integer i=0;i<6;i++) one_case(i,fixture);
    $display("LN_EDGE_PASS cases=6");
    $finish;
  end
  initial begin repeat(200000) @(posedge clk);$fatal(1,"LN_EDGE_TIMEOUT");end
endmodule
