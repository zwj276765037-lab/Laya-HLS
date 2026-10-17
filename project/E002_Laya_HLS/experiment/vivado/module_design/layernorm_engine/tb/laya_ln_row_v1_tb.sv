`timescale 1ns/1ps
module laya_ln_row_v1_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,cmd_valid=0,cmd_ready;
  logic [1:0] gamma_kind=0;
  logic x_valid=0,x_ready,gamma_valid=0,gamma_ready;
  logic [31:0] x_bits=0,gamma_bits=0;
  logic out_valid,out_ready=0,out_last,done_valid,done_ready=0;
  logic [31:0] out_bits,done_bad_element,mean_bits,variance_bits,inverse_bits;
  logic [9:0] out_index;
  logic [3:0] done_status;
  logic [31:0] x0[0:1023],x1[0:1023],g1[0:1023];
  logic [31:0] y0[0:1023],y1[0:1023],st0[0:2],st1[0:2];
  laya_ln_row_v1 dut(.*);
  task automatic run_case(input integer id,input integer kind,
                          input bit throttle,input integer error);
    integer c,xi,gi,oi,dc,hold_count,blocked,peak_add,peak_mul,layer_done;
    bit accepted,consumed,prev_block,injected,force_active;
    logic [31:0] held_bits;
    logic [9:0] held_index;
    logic held_last;
    logic [31:0] expect_bad;
    logic [3:0] expect_status;
    begin
      accepted=0;consumed=0;xi=0;gi=0;oi=0;dc=-1;hold_count=0;
      blocked=0;prev_block=0;
      peak_add=0; peak_mul=0; layer_done=0; injected=0; force_active=0;
      expect_status=error==3 ? 4'd3 : error!=0 ? 4'd6 : 4'd0;
      expect_bad=error==1 ? 32'd7 : (error==2 || error==5) ? 32'd3 :
                 error==4 ? 32'd0 : 32'hffffffff;
      for(c=0;c<200000 && !consumed;c++) begin
        @(negedge clk);
        if(force_active) begin release dut.mul_out; force_active=0; end
        cmd_valid=!accepted;
        gamma_kind=kind[1:0];
        x_valid=accepted && xi<1024 && (!throttle || c%5!=0);
        x_bits=id==0 || id==3 || id==8 ? x0[xi<1024?xi:0] : x1[xi<1024?xi:0];
        if(error==1 && xi==7) x_bits=32'h7fc00000;
        if(error==4 && xi<2) x_bits=32'h7f7fffff;
        gamma_valid=accepted && kind!=0 && gi<1024 && (!throttle || c%7!=1);
        gamma_bits=g1[gi<1024?gi:0];
        if((error==2 || error==5) && gi==3) gamma_bits=32'h7fc00000;
        if(error==5 && !injected && dut.state==5'd13 &&
           dut.mul_valid[13] && dut.mul_tag[13]==10'd9) begin
          force dut.mul_out=32'h7f800000;
          force_active=1; injected=1;
        end
        out_ready=!throttle || c%9>=4;
        done_ready=dc>=0 && c-dc>=5;
        @(posedge clk);
        if(dut.add.occupancy>peak_add) peak_add=dut.add.occupancy;
        if((dut.state==5'd6 || dut.state==5'd13 || dut.state==5'd14) &&
           dut.issue_count-dut.commit_count>peak_mul)
          peak_mul=dut.issue_count-dut.commit_count;
        if((dut.state==5'd3 || dut.state==5'd7) &&
           dut.issue_count==(dut.width>>1) &&
           dut.commit_count==(dut.width>>1) && !dut.read_valid) begin
          layer_done++;
          $display("LN_TREE_LAYER_DONE id=%0d phase=%0d width=%0d nodes=%0d c=%0d",
            id,dut.state,dut.width,dut.commit_count,c);
        end
        if(cmd_valid && cmd_ready) accepted=1;
        if(x_valid && x_ready) xi++;
        if(gamma_valid && gamma_ready) gi++;
        if(prev_block &&
           (!out_valid || out_bits !== held_bits ||
            out_index !== held_index || out_last !== held_last))
          $fatal(1,"LN_OUT_HOLD id=%0d index=%0d",id,oi);
        prev_block=out_valid && !out_ready;
        if(prev_block) begin
          blocked++; held_bits=out_bits; held_index=out_index; held_last=out_last;
        end
        if(out_valid && out_ready) begin
          if(error!=0) $fatal(1,"LN_ERROR_OUTPUT id=%0d",id);
          if(out_index !== oi || out_last !== (oi==1023) ||
             out_bits !== (id==0 || id==3 || id==8 ? y0[oi] : y1[oi]))
            $fatal(1,"LN_GOLD id=%0d i=%0d got=%08x expected=%08x",
              id,oi,out_bits,(id==0 || id==3 || id==8 ? y0[oi] : y1[oi]));
          oi++;
        end
        if(done_valid) begin
          if(done_status !== expect_status || done_bad_element !== expect_bad ||
             (error==0 && (oi!=1024 ||
              mean_bits !== (id==0 || id==3 || id==8 ? st0[0] : st1[0]) ||
              variance_bits !== (id==0 || id==3 || id==8 ? st0[1] : st1[1]) ||
              inverse_bits !== (id==0 || id==3 || id==8 ? st0[2] : st1[2]))))
            $fatal(1,"LN_DONE id=%0d status=%0d bad=%0d out=%0d mean=%08x var=%08x inv=%08x",
              id,done_status,done_bad_element,oi,mean_bits,variance_bits,inverse_bits);
          if(dc<0) dc=c;
          if(!done_ready) hold_count++;
          else consumed=1;
        end
      end
      @(negedge clk);if(force_active) release dut.mul_out;
      cmd_valid=0;x_valid=0;gamma_valid=0;done_ready=0;
      if(!consumed || done_valid || !cmd_ready || hold_count<5 ||
         (error==0 && (xi!=1024 || (kind!=0 && gi!=1024) || oi!=1024)) ||
         (error!=0 && oi!=0) || (error==5 && !injected) ||
         (error==0 && layer_done!=20))
        $fatal(1,"LN_DEBT id=%0d consumed=%0d x=%0d gamma=%0d out=%0d hold=%0d",
          id,consumed,xi,gi,oi,hold_count);
      $display("LN_ROW_CASE_PASS id=%0d kind=%0d error=%0d cycles=%0d x=%0d gamma=%0d out=%0d blocked=%0d layers=%0d peak_add=%0d peak_mul=%0d",
        id,kind,error,c,xi,gi,oi,blocked,layer_done,peak_add,peak_mul);
    end
  endtask

  task automatic reset_during_mul;
    integer n;
    integer pre_reset_mul_issued;
    begin
      @(negedge clk);cmd_valid=1;gamma_kind=0;
      @(posedge clk);if(!cmd_ready) $fatal(1,"RESET_CMD_NOT_READY");
      @(negedge clk);cmd_valid=0;
      for(integer i=0;i<1024;i++) begin
        x_valid=1;x_bits=x0[i];
        @(posedge clk);if(!x_ready) $fatal(1,"RESET_X_NOT_READY i=%0d",i);
        @(negedge clk);
      end
      x_valid=0;
      n=0;
      while(!(dut.state==5'd6 && dut.issue_count>=8) && n<30000) begin
        @(posedge clk);n++;
      end
      if(n>=30000) $fatal(1,"RESET_MUL_NOT_REACHED");
      pre_reset_mul_issued=dut.issue_count;
      @(negedge clk);rst_n=0;
      repeat(2) @(negedge clk);
      rst_n=1;
      if(!cmd_ready || done_valid || out_valid) $fatal(1,"RESET_GHOST");
      $display("LN_INFLIGHT_RESET_PASS pre_reset_mul_issued=%0d",pre_reset_mul_issued);
    end
  endtask
  initial begin
    string p;
    if(!$value$plusargs("FIXTURE=%s",p)) $fatal(1,"LN_FIXTURE_MISSING");
    $readmemh({p,"/x0.mem"},x0); $readmemh({p,"/x1.mem"},x1);
    $readmemh({p,"/g1.mem"},g1); $readmemh({p,"/y0.mem"},y0);
    $readmemh({p,"/y1.mem"},y1); $readmemh({p,"/st0.mem"},st0);
    $readmemh({p,"/st1.mem"},st1);
    for(integer i=0;i<1024;i++)
      if($isunknown(x0[i]) || $isunknown(x1[i]) || $isunknown(g1[i]) ||
         $isunknown(y0[i]) || $isunknown(y1[i])) $fatal(1,"LN_FIXTURE_UNKNOWN %0d",i);
    repeat(4) @(negedge clk);rst_n=1;
    run_case(0,0,0,0);
    run_case(1,1,1,0);
    run_case(2,2,0,0);
    run_case(3,0,1,1);
    run_case(4,1,1,2);
    run_case(5,3,0,3);
    run_case(6,0,0,4);
    run_case(7,1,1,5);
    reset_during_mul();
    run_case(8,0,0,0);
    $display("LN_ROW_PASS cases=9 reset_during_mul=1");
    $finish;
  end
  initial begin repeat(1000000) @(posedge clk);$fatal(1,"LN_ROW_TIMEOUT");end
endmodule
