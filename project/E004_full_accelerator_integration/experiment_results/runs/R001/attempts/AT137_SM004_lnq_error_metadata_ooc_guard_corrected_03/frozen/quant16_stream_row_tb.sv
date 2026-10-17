`timescale 1ns/1ps

// Frozen external producer rows and independent NumPy Q8/half/scalar oracle.
// Handshakes, actual bank reads, divider, sixteen FMULs and output commit all
// execute in one clocked service; no testbench queue substitutes for an IP.
module quant16_stream_row_tb;
  logic clk=0, rst=1, start_valid=0, in_valid=0, out_ready=0, done_ready=0;
  wire start_ready, in_ready, out_valid, done_valid;
  logic [31:0] cfg_task_id=0, cfg_source_epoch=0;
  logic [15:0] cfg_row=0;
  logic [7:0] cfg_groups=0;
  logic [511:0] in_lanes=0;
  logic [31:0] in_task_id=0, in_source_epoch=0;
  logic [15:0] in_row=0, in_mask=16'hffff;
  logic [6:0] in_group=0;
  logic in_half=0;
  wire [6:0] out_group;
  wire out_half;
  wire [127:0] out_q;
  wire [15:0] out_scale;
  wire [31:0] out_d_full, out_reciprocal;
  wire [1:0] done_status;
  wire [15:0] first_bad_col;
  wire [31:0] accepted_groups, covered_groups;
  wire [31:0] scale_issues, scale_returns, recip_issues, recip_returns;
  wire [31:0] amax_read_beats, replay_read_beats;
  wire [31:0] mul_halves_issued, mul_halves_returned;
  wire input_read_debt_zero,slot_debt_zero,divider_helper_debt_zero;
  wire mul_return_debt_zero,physical_debt_zero;
  wire [31:0] retired_d_full,retired_reciprocal;
  wire [15:0] retired_scale;
  logic [31:0] wi_source [0:1023], down_source [0:2623];
  logic [7:0] wi_q [0:1023], down_q [0:2623];
  logic [31:0] wi_product [0:1023];
  logic wi_active_fp [0:1023];
  bit check_products=0;
  logic [15:0] wi_scale [0:31], down_scale [0:81];
  logic [31:0] wi_amax [0:31], wi_d [0:31], wi_recip [0:31];
  logic [31:0] down_amax [0:81], down_d [0:81], down_recip [0:81];
  logic [7:0] adapter_status [0:26], adapter_recip_count [0:26];
  logic [15:0] adapter_bad_col [0:26];
  string fixture, adapter_fixture;

  always #3.333 clk=~clk;
  int total_clocks=0;
  always @(posedge clk) begin
    total_clocks++;
    if (total_clocks>40000000) $fatal(1,"quant16 total 40M clock watchdog");
  end
  quant16_stream_row dut (.*);

  // Independent issue-order scoreboard and clock observations. These queues
  // are testbench evidence only; they never supply a DUT arithmetic result.
  logic [101:0] expected_div_tags [0:511];
  int tag_issue_count=0, tag_retire_count=0, event_cycle=0;
  int first_scale_issue=-1,last_scale_issue=-1;
  int first_scale_return=-1,last_scale_return=-1;
  int first_recip_issue=-1,last_recip_issue=-1;
  int first_recip_return=-1,last_recip_return=-1;
  int scale_gap_min=1000000,scale_gap_max=0;
  int slot_highwater=0,input_stalls=0,div_stalls=0,output_stalls=0;
  int scan_starts=0,scan_reservations=0,both_ready_cycles=0;
  int late_ready_cycles=0,bank_tree_checks=0,scan_quad_checks=0;
  bit observed_done=0;
  always @(posedge clk) begin
    if (rst || dut.start_fire) begin
      tag_issue_count=0; tag_retire_count=0; event_cycle=0;
      first_scale_issue=-1; last_scale_issue=-1;
      first_scale_return=-1; last_scale_return=-1;
      first_recip_issue=-1; last_recip_issue=-1;
      first_recip_return=-1; last_recip_return=-1;
      scale_gap_min=1000000; scale_gap_max=0;
      slot_highwater=0; input_stalls=0; div_stalls=0; output_stalls=0;
      scan_starts=0;scan_reservations=0;both_ready_cycles=0;
      late_ready_cycles=0;bank_tree_checks=0;scan_quad_checks=0;
      observed_done=0;
    end else begin
      int used_slots, gap, best_amax, best_replay, best_div;
      used_slots=0;
      for (int i=0;i<32;i++) if (dut.state[i]!=0) used_slots++;
      if (used_slots>slot_highwater) slot_highwater=used_slots;
      best_amax=-1;best_replay=-1;
      for(int i=0;i<32;i++) begin
        if(dut.state[i]==2 && (best_amax<0 ||
           dut.ordinal[i]<dut.ordinal[best_amax] ||
           (dut.ordinal[i]==dut.ordinal[best_amax] && i<best_amax)))
          best_amax=i;
        if(dut.state[i]==8 && (best_replay<0 ||
           dut.ordinal[i]<dut.ordinal[best_replay] ||
           (dut.ordinal[i]==dut.ordinal[best_replay] && i<best_replay)))
          best_replay=i;
      end
      if(dut.have_amax !== (best_amax>=0) ||
         dut.have_replay !== (best_replay>=0) ||
         (best_amax>=0 && dut.amax_choice !== 5'(best_amax)) ||
         (best_replay>=0 && dut.replay_choice !== 5'(best_replay)))
        $fatal(1,"bank balanced selector differs from scalar oracle");
      bank_tree_checks++;
      if(dut.scan_state==0 &&
         (dut.scale_eligible!=0 || dut.recip_eligible!=0)) scan_starts++;
      if(dut.scale_eligible!=0 && dut.recip_eligible!=0) both_ready_cycles++;
      if(dut.scan_state==1) begin
        best_div=-1;
        for(int i=0;i<4;i++) begin
          int slot;
          slot=int'(dut.scan_index)*4+i;
          if(dut.scan_mask[slot] && (best_div<0 ||
             dut.ordinal[slot]<dut.ordinal[best_div] ||
             (dut.ordinal[slot]==dut.ordinal[best_div] && slot<best_div)))
            best_div=slot;
        end
        if(dut.scan_best.valid) begin
          if(best_div<0 || dut.scan_best.ord<dut.ordinal[best_div] ||
             (dut.scan_best.ord==dut.ordinal[best_div] &&
              dut.scan_best.slot<5'(best_div)))
            best_div=int'(dut.scan_best.slot);
        end
        if(dut.scan_next_best.valid !== (best_div>=0) ||
           (best_div>=0 &&
            (dut.scan_next_best.slot !== 5'(best_div) ||
             dut.scan_next_best.ord !== dut.ordinal[best_div] ||
             dut.scan_next_best.epoch !== dut.slot_epoch[best_div])))
          $fatal(1,"four-slot selector differs from scalar oracle index=%0d",dut.scan_index);
        scan_quad_checks++;
        if(((dut.scan_phase ? dut.recip_eligible : dut.scale_eligible) &
            ~dut.scan_mask)!=0)
          late_ready_cycles++;
      end
      if(dut.scan_state==2 && dut.scan_best.valid &&
         dut.scan_task_epoch==dut.task_epoch &&
         dut.state[dut.scan_best.slot]==(dut.scan_phase ? 6 : 4))
        scan_reservations++;
      if (in_valid && !in_ready) input_stalls++;
      if (dut.div_req_valid && !dut.div_req_ready) div_stalls++;
      if (out_valid && !out_ready) output_stalls++;
      if (dut.div_fire) begin
        if (tag_issue_count>=512) $fatal(1,"divider scoreboard capacity");
        expected_div_tags[tag_issue_count]=dut.div_tag;
        tag_issue_count++;
        if (dut.div_phase) begin
          if (first_recip_issue<0) first_recip_issue=event_cycle;
          last_recip_issue=event_cycle;
        end else begin
          if (first_scale_issue<0) first_scale_issue=event_cycle;
          if (last_scale_issue>=0) begin
            gap=event_cycle-last_scale_issue;
            if (gap<scale_gap_min) scale_gap_min=gap;
            if (gap>scale_gap_max) scale_gap_max=gap;
          end
          last_scale_issue=event_cycle;
        end
      end
      if (dut.div_resp_valid) begin
        if (tag_retire_count>=tag_issue_count ||
            dut.div_resp_tag!==expected_div_tags[tag_retire_count])
          $fatal(1,"divider semantic retirement order expected_index=%0d",
                 tag_retire_count);
        tag_retire_count++;
        if (dut.div_resp_tag[0]) begin
          if (first_recip_return<0) first_recip_return=event_cycle;
          last_recip_return=event_cycle;
        end else begin
          if (first_scale_return<0) first_scale_return=event_cycle;
          last_scale_return=event_cycle;
        end
      end
      if (done_valid && !observed_done) begin
        observed_done=1;
        if (tag_issue_count!=tag_retire_count)
          $fatal(1,"divider scoreboard debt at done");
        if(scan_reservations!=tag_issue_count)
          $fatal(1,"reserved/issued mismatch reserved=%0d issued=%0d",
                 scan_reservations,tag_issue_count);
        $display("QUANT16_SELECTOR_OBS task=%0d scans=%0d reserved=%0d issued=%0d both_ready_cycles=%0d late_ready_cycles=%0d bank_checks=%0d quad_checks=%0d",
                 cfg_task_id,scan_starts,scan_reservations,tag_issue_count,
                 both_ready_cycles,late_ready_cycles,bank_tree_checks,scan_quad_checks);
        $display("QUANT16_SERVICE_OBS task=%0d cycles=%0d scale_issue_first_last=%0d/%0d scale_return_first_last=%0d/%0d recip_issue_first_last=%0d/%0d recip_return_first_last=%0d/%0d scale_gap_min_max=%0d/%0d slots_peak=%0d div_pending_peak=%0d stalls_input_div_output=%0d/%0d/%0d fp=%0d/%0d dummy=%0d helper=%0d/%0d semantic=%0d",
                 cfg_task_id,event_cycle,first_scale_issue,last_scale_issue,
                 first_scale_return,last_scale_return,
                 first_recip_issue,last_recip_issue,
                 first_recip_return,last_recip_return,
                 scale_gap_min==1000000 ? 0 : scale_gap_min,scale_gap_max,
                 slot_highwater,dut.divider.pending_peak,
                 input_stalls,div_stalls,output_stalls,
                 dut.divider.fp_issues,dut.divider.fp_returns,
                 dut.divider.fp_dummy_issues,dut.divider.helper_issues,
                 dut.divider.helper_returns,dut.divider.semantic_returns);
      end
      event_cycle++;
    end
  end

  task automatic run_case(input bit use_down, input int groups);
    int sent, got, cycles, group, half, expected_recip_count;
    logic [31:0] expected_d, expected_recip;
    logic [15:0] expected_scale;
    logic [7:0] expected_q;
    bit finished;
    begin
      @(negedge clk);
      rst=1; start_valid=0; in_valid=0; out_ready=0;
      done_ready=0;
      repeat (3) @(negedge clk);
      rst=0; start_valid=1;
      cfg_task_id=use_down ? 32'd202 : 32'd101;
      cfg_source_epoch=use_down ? 32'd22 : 32'd11;
      cfg_row=use_down ? 16'd7 : 16'd3;
      cfg_groups=8'(groups);
      expected_recip_count=0;
      for (int i=0;i<groups;i++)
        if ((use_down ? down_d[i] : wi_d[i])!=0)
          expected_recip_count++;
      #1ps;
      if (!start_ready) $fatal(1,"stream start not ready case=%0d",use_down);
      @(posedge clk);
      @(negedge clk);
      start_valid=0;
      sent=0; got=0; cycles=0; finished=0;
      while (!finished) begin
        in_valid=(sent<groups*2);
        out_ready=(cycles%5!=2);
        if (in_valid) begin
          in_task_id=cfg_task_id;
          in_source_epoch=cfg_source_epoch;
          in_row=cfg_row;
          in_group=7'(sent/2);
          in_half=1'(sent%2);
          in_mask=16'hffff;
          for (int lane=0;lane<16;lane++)
            in_lanes[lane*32 +: 32]=use_down ?
                down_source[sent*16+lane] : wi_source[sent*16+lane];
        end
        @(posedge clk);
        if (in_valid && in_ready) sent++;
        if (dut.div_fire) begin
          int ordinal;
          logic [31:0] expected_operand;
          ordinal=int'(dut.div_tag[32:1]);
          if (ordinal<0 || ordinal>=groups)
            $fatal(1,"stream divider ordinal case=%0d ordinal=%0d",
                   use_down,ordinal);
          expected_operand=dut.div_phase ?
              (use_down ? down_d[ordinal] : wi_d[ordinal]) :
              (use_down ? down_amax[ordinal] : wi_amax[ordinal]);
          if (!dut.div_phase && expected_operand<=32'h03fe0000) begin
            if (dut.div_route!==2'd1 || dut.div_numerator!==0 ||
                dut.div_denominator!==32'h42fe0000 ||
                dut.divider.req_tiny_amax!==expected_operand)
              $fatal(1,"stream tiny SCALE route case=%0d ordinal=%0d",
                     use_down,ordinal);
          end else if (dut.div_phase && expected_operand[30:23]==0 &&
                       expected_operand[22:0]!=0) begin
            if (dut.div_route!==2'd2 ||
                dut.div_numerator!==32'h3f800000 ||
                dut.div_denominator[30:23]==0)
              $fatal(1,"stream subnormal RECIP route case=%0d ordinal=%0d",
                     use_down,ordinal);
          end else if (dut.div_route!==2'd0 ||
                       (dut.div_phase ? dut.div_denominator :
                                        dut.div_numerator)!==expected_operand)
            $fatal(1,"stream divider operand case=%0d ordinal=%0d phase=%0d",
                   use_down,ordinal,dut.div_phase);
        end
        if (check_products && dut.mul_pop) begin
          int product_base;
          product_base=int'(dut.mul_ret_tag[32:1])*32+
                       int'(dut.mul_ret_tag[0])*16;
          for (int lane=0;lane<16;lane++) begin
            if (dut.mul_bypass[dut.mul_head][lane]!==
                !wi_active_fp[product_base+lane])
              $fatal(1,"adapter multiply route col=%0d",product_base+lane);
            if (wi_active_fp[product_base+lane] &&
                dut.mul_result[lane]!==wi_product[product_base+lane])
              $fatal(1,"adapter true multiply product col=%0d got=%08x expected=%08x",
                     product_base+lane,dut.mul_result[lane],
                     wi_product[product_base+lane]);
          end
        end
        if (out_valid && out_ready) begin
          group=got/2; half=got%2;
          if (out_group!==7'(group) || out_half!==1'(half))
            $fatal(1,"stream output order case=%0d got=%0d group=%0d half=%0d",
                   use_down,got,out_group,out_half);
          expected_d=use_down ? down_d[group] : wi_d[group];
          expected_recip=use_down ? down_recip[group] : wi_recip[group];
          expected_scale=half ? (use_down ? down_scale[group] : wi_scale[group]) : 0;
          if (out_d_full!==expected_d || out_reciprocal!==expected_recip ||
              out_scale!==expected_scale)
            $fatal(1,"stream scalar mismatch case=%0d group=%0d half=%0d d=%08x/%08x r=%08x/%08x h=%04x/%04x",
                   use_down,group,half,out_d_full,expected_d,
                   out_reciprocal,expected_recip,out_scale,expected_scale);
          for (int lane=0;lane<16;lane++) begin
            expected_q=use_down ? down_q[group*32+half*16+lane] :
                                  wi_q[group*32+half*16+lane];
            if (out_q[lane*8 +: 8]!==expected_q)
              $fatal(1,"stream q mismatch case=%0d col=%0d got=%02x expected=%02x",
                     use_down,group*32+half*16+lane,
                     out_q[lane*8 +: 8],expected_q);
          end
          got++;
        end
        if (done_valid) begin
          if (done_status!==0 || first_bad_col!==16'hffff ||
              sent!=groups*2 || got!=groups*2 ||
              accepted_groups!=groups || covered_groups!=groups ||
              scale_issues!=groups || scale_returns!=groups ||
              recip_issues!=expected_recip_count ||
              recip_returns!=expected_recip_count ||
              amax_read_beats!=groups*2 || replay_read_beats!=groups*2 ||
              mul_halves_issued!=groups*2 || mul_halves_returned!=groups*2)
            $fatal(1,"stream debt/READY case=%0d status=%0d sent=%0d got=%0d accepted=%0d covered=%0d scale=%0d/%0d recip=%0d/%0d read=%0d/%0d mul=%0d/%0d",
                   use_down,done_status,sent,got,accepted_groups,covered_groups,
                   scale_issues,scale_returns,recip_issues,recip_returns,
                   amax_read_beats,replay_read_beats,
                   mul_halves_issued,mul_halves_returned);
          if (dut.divider.pending!=0 || dut.divider.fp_pending!=0 ||
              dut.divider.helper_pending!=0 ||
              dut.divider.fp_issues!=scale_issues+recip_issues ||
              dut.divider.fp_returns!=dut.divider.fp_issues ||
              dut.divider.semantic_returns!=dut.divider.fp_issues ||
              dut.divider.helper_issues!=dut.divider.helper_returns ||
              dut.divider.helper_issues!=dut.divider.fp_dummy_issues)
            $fatal(1,"stream divider physical/semantic debt case=%0d",use_down);
          finished=1;
          $display("QUANT16_STREAM_ROW_PASS case=%0d groups=%0d cycles=%0d q_bytes=%0d",
                   use_down,groups,cycles,groups*32);
        end
        cycles++;
        if (cycles>10000)
          $fatal(1,"stream watchdog case=%0d sent=%0d got=%0d cap=%0d write=%0d pending bank=%0d amax=%0d div=%0d mul=%0d",
                 use_down,sent,got,dut.capture_group,dut.write_group,
                 dut.bank_reads_pending,dut.amax_pending,dut.div_pending,
                 dut.mul_pending);
        @(negedge clk);
      end
    end
  endtask

  task automatic run_adapter_cases;
    string case_path;
    begin
      $readmemh({adapter_fixture,"/status.mem"},adapter_status);
      $readmemh({adapter_fixture,"/bad_col.mem"},adapter_bad_col);
      $readmemh({adapter_fixture,"/recip_count.mem"},adapter_recip_count);
      for (int i=0;i<27;i++) begin
        case_path=$sformatf("%s/case_%02d",adapter_fixture,i);
        $readmemh({case_path,"/source.mem"},wi_source,0,31);
        $readmemh({case_path,"/q.mem"},wi_q,0,31);
        $readmemh({case_path,"/amax.mem"},wi_amax,0,0);
        $readmemh({case_path,"/d_full.mem"},wi_d,0,0);
        $readmemh({case_path,"/reciprocal.mem"},wi_recip,0,0);
        $readmemh({case_path,"/scale.mem"},wi_scale,0,0);
        $readmemh({case_path,"/product.mem"},wi_product,0,31);
        $readmemh({case_path,"/active_fp.mem"},wi_active_fp,0,31);
        check_products=1;
        if (adapter_status[i]==0)
          run_case(0,1);
        else begin
          run_numeric_error(100+i,1,int'(adapter_bad_col[i]),1,
                            int'(adapter_recip_count[i]));
          if (dut.amax[0]!==wi_amax[0] || dut.d_full[0]!==wi_d[0] ||
              dut.reciprocal[0]!==wi_recip[0] || dut.scale[0]!==wi_scale[0])
            $fatal(1,"adapter scalar mismatch slot=%0d amax=%08x/%08x d=%08x/%08x recip=%08x/%08x scale=%04x/%04x",
                   i,dut.amax[0],wi_amax[0],dut.d_full[0],wi_d[0],
                   dut.reciprocal[0],wi_recip[0],dut.scale[0],wi_scale[0]);
        end
        $display("QUANT16_ADAPTER_CASE_PASS slot=%0d status=%0d amax=%08x d=%08x reciprocal=%08x",
                 i,adapter_status[i],wi_amax[0],wi_d[0],wi_recip[0]);
      end
      $display("QUANT16_ADAPTER_CASES_PASS count=27 independent_reference=R0_finite_v2");
      case_path={adapter_fixture,"/mixed"};
      $readmemh({case_path,"/source.mem"},wi_source,0,191);
      $readmemh({case_path,"/q.mem"},wi_q,0,191);
      $readmemh({case_path,"/amax.mem"},wi_amax,0,5);
      $readmemh({case_path,"/d_full.mem"},wi_d,0,5);
      $readmemh({case_path,"/reciprocal.mem"},wi_recip,0,5);
      $readmemh({case_path,"/scale.mem"},wi_scale,0,5);
      $readmemh({case_path,"/product.mem"},wi_product,0,191);
      $readmemh({case_path,"/active_fp.mem"},wi_active_fp,0,191);
      run_case(0,6);
      $display("QUANT16_ADAPTER_MIXED_PASS groups=6 normal_tiny_zero=1 finite_backpressure=1");
      case_path={adapter_fixture,"/case_16"}; // Signed subnormal half-integer trio.
      $readmemh({case_path,"/source.mem"},wi_source,0,31);
      $readmemh({case_path,"/q.mem"},wi_q,0,31);
      $readmemh({case_path,"/amax.mem"},wi_amax,0,0);
      $readmemh({case_path,"/d_full.mem"},wi_d,0,0);
      $readmemh({case_path,"/reciprocal.mem"},wi_recip,0,0);
      $readmemh({case_path,"/scale.mem"},wi_scale,0,0);
      $readmemh({case_path,"/product.mem"},wi_product,0,31);
      $readmemh({case_path,"/active_fp.mem"},wi_active_fp,0,31);
      for (int kind=2;kind<=4;kind++) begin
        run_reset_inflight(kind);
        run_case(0,1);
      end
      check_products=0;
      $display("QUANT16_ADAPTER_RESET_PASS helper=1 normalized_recip=1 fmul_bypass=1 recovery=3");
    end
  endtask

  task automatic run_numeric_error(input int case_id, input int groups,
                                    input int expected_col,
                                    input int expected_scale,
                                    input int expected_recip);
    int sent, got, cycles;
    bit finished;
    begin
      @(negedge clk);
      rst=1; start_valid=0; in_valid=0; out_ready=1;
      done_ready=0;
      repeat (3) @(negedge clk);
      rst=0; start_valid=1;
      cfg_task_id=32'(400+case_id);
      cfg_source_epoch=32'(40+case_id);
      cfg_row=16'(case_id);
      cfg_groups=8'(groups);
      @(posedge clk);
      @(negedge clk);
      start_valid=0; sent=0; got=0; cycles=0; finished=0;
      while (!finished) begin
        in_valid=(sent<groups*2);
        if (in_valid) begin
          in_task_id=cfg_task_id; in_source_epoch=cfg_source_epoch;
          in_row=cfg_row; in_group=7'(sent/2);
          in_half=1'(sent%2); in_mask=16'hffff;
          for (int lane=0;lane<16;lane++)
            in_lanes[lane*32 +: 32]=wi_source[sent*16+lane];
        end
        @(posedge clk);
        if (in_valid && in_ready) sent++;
        if (out_valid && out_ready) got++;
        if (done_valid) begin
          if (done_status!==1 || first_bad_col!==16'(expected_col) ||
              sent!=groups*2 || got!=0 || accepted_groups!=groups ||
              covered_groups!=0 || scale_issues!=expected_scale ||
              scale_returns!=expected_scale ||
              recip_issues!=expected_recip ||
              recip_returns!=expected_recip ||
              amax_read_beats!=groups*2 || replay_read_beats!=0 ||
              mul_halves_issued!=0 || mul_halves_returned!=0)
            $fatal(1,"stream numerical case=%0d status=%0d col=%0d sent=%0d got=%0d amax_bits=%08x d_bits=%08x reciprocal_bits=%08x scale=%0d/%0d recip=%0d/%0d amax=%0d replay=%0d mul=%0d/%0d",
                   case_id,done_status,first_bad_col,sent,got,
                   dut.amax[0],dut.d_full[0],dut.reciprocal[0],
                   scale_issues,scale_returns,recip_issues,recip_returns,
                   amax_read_beats,replay_read_beats,
                   mul_halves_issued,mul_halves_returned);
          if (dut.divider.pending!=0 || dut.divider.fp_pending!=0 ||
              dut.divider.helper_pending!=0 ||
              dut.divider.fp_issues!=scale_issues+recip_issues ||
              dut.divider.fp_returns!=dut.divider.fp_issues ||
              dut.divider.semantic_returns!=dut.divider.fp_issues ||
              dut.divider.helper_issues!=dut.divider.helper_returns ||
              dut.divider.helper_issues!=dut.divider.fp_dummy_issues)
            $fatal(1,"stream numerical divider physical/semantic debt case=%0d",
                   case_id);
          finished=1;
          $display("QUANT16_STREAM_NUMERIC_PASS case=%0d groups=%0d first_col=%0d scale=%0d recip=%0d",
                   case_id,groups,expected_col,expected_scale,expected_recip);
        end
        cycles++;
        if (cycles>2000)
          $fatal(1,"stream numerical watchdog case=%0d sent=%0d got=%0d",
                 case_id,sent,got);
        @(negedge clk);
      end
    end
  endtask

  task automatic run_reset_inflight(input int kind);
    int sent, cycles;
    begin
      @(negedge clk);
      rst=1; start_valid=0; in_valid=0; out_ready=1;
      repeat (3) @(negedge clk);
      rst=0; start_valid=1;
      cfg_task_id=32'(601+kind);
      cfg_source_epoch=32'(61+kind);
      cfg_row=16'd6; cfg_groups=8'd1;
      @(posedge clk);
      @(negedge clk);
      start_valid=0; sent=0; cycles=0;
      while (sent<2) begin
        in_valid=1;
        in_task_id=cfg_task_id; in_source_epoch=cfg_source_epoch;
        in_row=cfg_row; in_group=0; in_half=1'(sent);
        in_mask=16'hffff;
        for (int lane=0;lane<16;lane++)
          in_lanes[lane*32 +: 32]=wi_source[sent*16+lane];
        @(posedge clk);
        if (in_ready) sent++;
        @(negedge clk);
        cycles++;
        if (cycles>50) $fatal(1,"reset injection capture watchdog");
      end
      in_valid=0;
      cycles=0;
      while (kind==0 ? dut.div_pending==0 :
             kind==1 ? dut.mul_pending==0 :
             kind==2 ? dut.divider.helper_pending==0 :
             kind==3 ? !(dut.state[0]==7 && dut.divider.fp_pending!=0) :
                       !(dut.mul_pending!=0 &&
                         dut.mul_bypass[dut.mul_head]!=0)) begin
        @(negedge clk);
        cycles++;
        if (cycles>200) $fatal(1,"reset injection pending watchdog kind=%0d",kind);
      end
      rst=1;
      repeat (2) @(negedge clk);
      if (done_valid || out_valid || dut.div_pending!=0 ||
          dut.mul_pending!=0 || dut.protocol_error)
        $fatal(1,"reset did not cancel in-flight service kind=%0d",kind);
      $display("QUANT16_STREAM_RESET_INFLIGHT_PASS kind=%0d",kind);
    end
  endtask

  task automatic run_bad_second_mask;
    int cycles;
    begin
      @(negedge clk);
      rst=1; start_valid=0; in_valid=0; out_ready=1;
      repeat (3) @(negedge clk);
      rst=0; start_valid=1;
      cfg_task_id=32'd303; cfg_source_epoch=32'd33;
      cfg_row=16'd9; cfg_groups=8'd8;
      @(posedge clk);
      @(negedge clk);
      start_valid=0; in_valid=1;
      in_task_id=cfg_task_id; in_source_epoch=cfg_source_epoch;
      in_row=cfg_row; in_group=0; in_half=0;
      in_mask=16'hffff; in_lanes=0;
      @(posedge clk);
      if (!in_ready) $fatal(1,"protocol first half not accepted");
      @(negedge clk);
      in_half=1; in_mask=16'hfffe;
      @(posedge clk);
      if (!in_ready) $fatal(1,"protocol malformed half not consumed");
      @(negedge clk);
      in_valid=0; cycles=0;
      while (!done_valid) begin
        @(posedge clk);
        if (out_valid) $fatal(1,"protocol partial output published");
        cycles++;
        if (cycles>100) $fatal(1,"protocol drain watchdog");
        @(negedge clk);
      end
      if (done_status!==2 || accepted_groups!==1 || covered_groups!==0 ||
          dut.drain_groups!==1 || dut.bank_reads_pending!==0 ||
          dut.amax_pending!==0 || dut.div_pending!==0 ||
          dut.mul_pending!==0)
        $fatal(1,"protocol malformed half retirement");
      $display("QUANT16_STREAM_PROTOCOL_PASS bad_second_mask=1");
    end
  endtask

  // A new task after the local reset, without a second reset, checks that
  // neither an abandoned selector nor a stale FP return entered this row.
  task automatic run_partition_recovery(input int phase);
    int sent,got,cycles;
    begin
      @(negedge clk);
      start_valid=1;cfg_task_id=32'(800+phase);cfg_source_epoch=32'(80+phase);
      cfg_row=16'(phase);cfg_groups=1;in_valid=0;out_ready=1;done_ready=0;
      #1ps;
      if(!start_ready) $fatal(1,"partition recovery not ready phase=%0d",phase);
      @(posedge clk);if(!start_ready) $fatal(1,"partition recovery start lost");
      @(negedge clk);start_valid=0;
      sent=0;got=0;cycles=0;
      while(!done_valid && cycles<500) begin
        in_valid=sent<2;
        if(in_valid) begin
          in_task_id=cfg_task_id;in_source_epoch=cfg_source_epoch;
          in_row=cfg_row;in_group=0;in_half=1'(sent);in_mask=16'hffff;
          for(int lane=0;lane<16;lane++)
            in_lanes[32*lane+:32]=wi_source[16*sent+lane];
        end
        @(posedge clk);
        if(in_valid && in_ready) sent++;
        if(out_valid && out_ready) begin
          if(out_group!==0 || out_half!==1'(got) ||
             out_d_full!==wi_d[0] || out_reciprocal!==wi_recip[0] ||
             out_scale!==(got==0 ? 16'd0 : wi_scale[0]))
            $fatal(1,"partition recovery scalar phase=%0d half=%0d",phase,got);
          for(int lane=0;lane<16;lane++)
            if(out_q[8*lane+:8]!==wi_q[16*got+lane])
              $fatal(1,"partition recovery q phase=%0d col=%0d",phase,16*got+lane);
          got++;
        end
        cycles++;
        @(negedge clk);
      end
      in_valid=0;
      if(!done_valid || done_status!==0 || sent!=2 || got!=2 ||
         accepted_groups!==1 || covered_groups!==1 ||
         scale_issues!==1 || scale_returns!==1 ||
         !physical_debt_zero || dut.divider.protocol_fault)
        $fatal(1,"partition recovery done phase=%0d sent=%0d got=%0d status=%0d debt=%b",
               phase,sent,got,done_status,physical_debt_zero);
      done_ready=1;
      @(posedge clk);if(!done_valid) $fatal(1,"partition recovery done lost");
      @(negedge clk);done_ready=0;
      $display("QUANT16_PARTITION_RECOVERY_PASS phase=%0d cycles=%0d",phase,cycles);
    end
  endtask

  // Phase 0=scan, 1=reserved, 2=classified, 3=FIRE blocked on the shared
  // ready wire. Each reset happens before a divider issue from this task.
  task automatic run_partition_phase_reset(input int phase);
    int sent,cycles,observed;
    logic [101:0] held_tag;
    logic [31:0] held_num,held_den;
    logic [1:0] held_route;
    bit target;
    begin
      $readmemh({fixture,"/wi_source_f32.mem"},wi_source);
      $readmemh({fixture,"/wi_q.mem"},wi_q);
      $readmemh({fixture,"/wi_scale.mem"},wi_scale);
      $readmemh({fixture,"/wi_d_full.mem"},wi_d);
      $readmemh({fixture,"/wi_reciprocal.mem"},wi_recip);
      @(negedge clk);rst=1;start_valid=0;in_valid=0;out_ready=0;done_ready=0;
      repeat(3) @(negedge clk);
      rst=0;start_valid=1;cfg_task_id=32'(700+phase);
      cfg_source_epoch=32'(70+phase);cfg_row=16'(phase);cfg_groups=1;
      @(posedge clk);if(!start_ready) $fatal(1,"partition phase start phase=%0d",phase);
      @(negedge clk);start_valid=0;
      sent=0;cycles=0;
      while(sent<2 && cycles<100) begin
        in_valid=1;in_task_id=cfg_task_id;in_source_epoch=cfg_source_epoch;
        in_row=cfg_row;in_group=0;in_half=1'(sent);in_mask=16'hffff;
        for(int lane=0;lane<16;lane++)
          in_lanes[32*lane+:32]=wi_source[16*sent+lane];
        @(posedge clk);if(in_valid && in_ready) sent++;
        @(negedge clk);cycles++;
      end
      in_valid=0;
      if(sent!=2) $fatal(1,"partition phase input phase=%0d",phase);
      target=0;
      while(!target && cycles<150) begin
        target=(phase==0 && dut.scan_state==3'd1 && dut.scan_index==3'd3) ||
               (phase==1 && dut.scan_state==3'd3 && dut.state[0]==4'd13) ||
               (phase==2 && dut.scan_state==3'd4 && dut.state[0]==4'd13) ||
               (phase==3 && dut.scan_state==3'd5 && dut.state[0]==4'd13);
        if(!target) begin @(negedge clk);cycles++; end
      end
      if(!target || dut.task_id!==cfg_task_id || !dut.active ||
         dut.accepted_groups!==1 || dut.covered_groups!==0 ||
         dut.scale_issues!==0 || dut.div_pending!==0 ||
         divider_helper_debt_zero || physical_debt_zero)
        $fatal(1,"partition phase missing phase=%0d state=%0d scan=%0d pending=%0d",
               phase,dut.state[0],dut.scan_state,dut.div_pending);
      if(phase==3) begin
        held_tag=dut.div_tag;held_num=dut.div_numerator;
        held_den=dut.div_denominator;held_route=dut.div_route;
        force dut.div_req_ready=1'b0;
        force dut.divider.req_ready=1'b0;
        repeat(3) begin
          @(posedge clk);
          if(!dut.div_req_valid || dut.div_fire || dut.divider.req_fire ||
             dut.div_tag!==held_tag || dut.div_numerator!==held_num ||
             dut.div_denominator!==held_den || dut.div_route!==held_route)
            $fatal(1,"partition FIRE hold phase=%0d",phase);
          @(negedge clk);
        end
      end
      $display("QUANT16_PARTITION_PHASE_CAPTURE phase=%0d scan=%0d index=%0d slot_state=%0d accepted=%0d issue=%0d debt_zero=%b",
               phase,dut.scan_state,dut.scan_index,dut.state[0],
               dut.accepted_groups,dut.scale_issues,physical_debt_zero);
      rst=1;
      if(phase==3) begin
        release dut.div_req_ready;
        release dut.divider.req_ready;
      end
      repeat(3) @(negedge clk);
      rst=0;observed=0;
      repeat(16) begin
        @(negedge clk);observed++;
        if(out_valid || done_valid || dut.div_resp_valid ||
           dut.divider.fp_return || dut.divider.protocol_fault ||
           dut.protocol_error || !physical_debt_zero)
          $fatal(1,"partition reset ghost phase=%0d cycle=%0d",phase,observed);
      end
      if(dut.scan_state!==3'd0 || dut.divider.quarantine!==4'd0 ||
         !start_ready || !slot_debt_zero || !divider_helper_debt_zero)
        $fatal(1,"partition reset debt phase=%0d",phase);
      run_partition_recovery(phase);
      $display("QUANT16_PARTITION_PHASE_RESET_PASS phase=%0d post_cycles=%0d",
               phase,observed);
    end
  endtask

  // Controlled return-data injection only at an actual FMUL return handshake.
  // The FP valid, physical pending, original tag and independent row source
  // remain real. Infinity has rounded_q8.bad=1 for the selected lane.
  // mode 0: final half/lane31; 1: consecutive halves/lane12 then lane17;
  // mode 2: reset while final-half error metadata is pending;
  // mode 3: group0 MUL error competes with group1 AMAX and group2 DIV errors.
  task automatic run_metadata_case(input int mode);
    int groups_local,sent,cycles,captures,commits,simultaneous;
    int amax_errors,div_errors,releases,inject_lane;
    bit pre_capture,pre_commit,pre_release,finished;
    logic [63:0] expected_key;
    begin
      $readmemh({fixture,"/wi_source_f32.mem"},wi_source);
      $readmemh({fixture,"/wi_q.mem"},wi_q);
      $readmemh({fixture,"/wi_scale.mem"},wi_scale);
      $readmemh({fixture,"/wi_d_full.mem"},wi_d);
      $readmemh({fixture,"/wi_reciprocal.mem"},wi_recip);
      groups_local=mode==3 ? 3 : 1;
      if(mode==3) begin
        for(int i=32;i<96;i++) wi_source[i]=0;
        wi_source[32+5]=32'h7f800000; // independent first bad: group1, col37
        wi_source[64]=32'h501502f9;   // original finite scale overflow boundary
      end
      @(negedge clk);rst=1;start_valid=0;in_valid=0;
      out_ready=1;done_ready=0;
      repeat(3) @(negedge clk);
      rst=0;start_valid=1;cfg_task_id=32'(930+mode);
      cfg_source_epoch=32'(93+mode);cfg_row=16'(mode);
      cfg_groups=8'(groups_local);
      @(posedge clk);if(!start_ready) $fatal(1,"metadata start mode=%0d",mode);
      @(negedge clk);start_valid=0;
      sent=0;cycles=0;
      while(sent<groups_local*2 && cycles<100) begin
        in_valid=1;in_task_id=cfg_task_id;
        in_source_epoch=cfg_source_epoch;in_row=cfg_row;
        in_group=7'(sent/2);in_half=1'(sent%2);in_mask=16'hffff;
        for(int lane=0;lane<16;lane++)
          in_lanes[32*lane+:32]=wi_source[16*sent+lane];
        @(posedge clk);if(in_valid && in_ready) sent++;
        @(negedge clk);cycles++;
      end
      in_valid=0;
      if(sent!=groups_local*2) $fatal(1,"metadata capture mode=%0d",mode);
      captures=0;commits=0;simultaneous=0;
      amax_errors=0;div_errors=0;releases=0;finished=0;
      while(!finished && cycles<700) begin
        inject_lane=-1;
        if(dut.mul_pop && dut.mul_ret_tag[32:1]==0) begin
          if(mode==1 && !dut.mul_ret_tag[0]) begin
            inject_lane=12;
            force dut.mul_result[12]=32'h7f800000;
          end else if(dut.mul_ret_tag[0]) begin
            inject_lane=mode==1 ? 1 : 15;
            if(mode==1) force dut.mul_result[1]=32'h7f800000;
            else force dut.mul_result[15]=32'h7f800000;
          end
        end
        #1ps;
        pre_capture=dut.mul_bad_event;
        pre_commit=dut.err_valid;
        pre_release=pre_commit && dut.write_group==0 &&
                    dut.state[0]==4'd12 && dut.q_received[0]==2'b11;
        if(pre_capture && inject_lane<0)
          $fatal(1,"metadata unexpected natural MUL bad mode=%0d",mode);
        if(inject_lane>=0 && !pre_capture)
          $fatal(1,"metadata injected return not accepted mode=%0d",mode);
        if(pre_commit && (mul_return_debt_zero || physical_debt_zero ||
                          start_ready || done_valid ||
                          dut.err_bad_mask==0 ||
                          dut.bad_tree[4][0].lane!==4'(mode==1 ?
                               (captures==1 ? 12 : 1) : 15)))
          $fatal(1,"metadata candidate debt/priority mode=%0d captured=%0d mask=%h",
                 mode,captures,dut.err_bad_mask);
        if(out_valid) $fatal(1,"metadata bad row published mode=%0d",mode);
        if(dut.amax_bad_event) amax_errors++;
        if(dut.div_bad_event) div_errors++;
        if(pre_capture && pre_commit) simultaneous++;
        @(posedge clk);
        if(pre_capture) captures++;
        if(pre_commit) commits++;
        if(pre_release) releases++;
        @(negedge clk);
        if(inject_lane==12) release dut.mul_result[12];
        if(inject_lane==1) release dut.mul_result[1];
        if(inject_lane==15) release dut.mul_result[15];
        if(captures-commits != int'(dut.err_valid))
          $fatal(1,"metadata capture/commit conservation mode=%0d cap=%0d com=%0d valid=%b",
                 mode,captures,commits,dut.err_valid);
        if(mode==2 && dut.err_valid) begin
          if(captures!=1 || commits!=0 || physical_debt_zero || done_valid)
            $fatal(1,"metadata reset trigger missing real candidate");
          $display("QUANT16_METADATA_RESET_CAPTURE real_mul_return=%0d pending=%b mask=%h base=%h",
                   mul_halves_returned,dut.err_valid,dut.err_bad_mask,
                   dut.err_key_base);
          rst=1;
          repeat(3) @(negedge clk);
          rst=0;
          if(dut.err_valid || dut.err_bad_mask || dut.err_key_base ||
             done_valid || out_valid || !physical_debt_zero)
            $fatal(1,"metadata reset retained candidate or debt");
          repeat(16) begin
            @(negedge clk);
            if(done_valid || out_valid || dut.protocol_error ||
               dut.err_valid || !physical_debt_zero)
              $fatal(1,"metadata reset ghost");
          end
          run_partition_recovery(mode);
          $display("QUANT16_METADATA_RESET_PASS real_capture=1 quarantine=16 recovery=original_wi");
          finished=1;
        end else if(done_valid) finished=1;
        cycles++;
      end
      if(!finished) $fatal(1,"metadata watchdog mode=%0d",mode);
      if(mode!=2) begin
        expected_key=(64'd4<<8) | 64'(mode==1 ? 12 : 31);
        if(done_status!==1 || first_bad_col!==16'(mode==1 ? 12 : 31) ||
           dut.first_error_key!==expected_key ||
           captures!=(mode==1 ? 2 : 1) || captures!=commits ||
           releases!=1 || accepted_groups!=groups_local ||
           covered_groups!=0 || !physical_debt_zero ||
           (mode==1 && simultaneous!=1) ||
           (mode==3 && (amax_errors==0 || div_errors==0)))
          $fatal(1,"metadata retirement mode=%0d status=%0d col=%0d key=%h cap=%0d com=%0d simultaneous=%0d release=%0d amax=%0d div=%0d debt=%b",
                 mode,done_status,first_bad_col,dut.first_error_key,
                 captures,commits,simultaneous,releases,amax_errors,
                 div_errors,physical_debt_zero);
        done_ready=1;
        @(posedge clk);if(!done_valid) $fatal(1,"metadata done hold");
        @(negedge clk);done_ready=0;
        run_partition_recovery(mode);
        $display("QUANT16_METADATA_PASS mode=%0d captured=%0d committed=%0d overlap=%0d release_with_commit=%0d amax_bad=%0d div_bad=%0d cycles=%0d controlled_return_data=1",
                 mode,captures,commits,simultaneous,releases,
                 amax_errors,div_errors,cycles);
      end
    end
  endtask

  initial begin
    // Controlled comparator operands exercise the tie rule. These are not
    // counted as a real row or as evidence of bank/FIFO traffic.
    if(dut.bank_min({1'b1,32'd17,5'd9},
                    {1'b1,32'd17,5'd3}) !==
       {1'b1,32'd17,5'd3} ||
       dut.bank_min({1'b1,32'd16,5'd9},
                    {1'b1,32'd17,5'd3}) !==
       {1'b1,32'd16,5'd9} ||
       dut.div_min({1'b1,32'd17,5'd9,32'd41},
                   {1'b1,32'd17,5'd3,32'd77}) !==
       {1'b1,32'd17,5'd3,32'd77} ||
       dut.div_min({1'b1,32'd16,5'd9,32'd41},
                   {1'b1,32'd17,5'd3,32'd77}) !==
       {1'b1,32'd16,5'd9,32'd41})
      $fatal(1,"controlled selector ordinal/tie comparator");
    $display("QUANT16_SELECTOR_TIE_PASS controlled_comparator_only=1");
    if (!$value$plusargs("FIXTURE=%s",fixture))
      $fatal(1,"FIXTURE plusarg required");
    $readmemh({fixture,"/wi_source_f32.mem"},wi_source);
    $readmemh({fixture,"/wi_q.mem"},wi_q);
    $readmemh({fixture,"/wi_scale.mem"},wi_scale);
    $readmemh({fixture,"/wi_amax.mem"},wi_amax);
    $readmemh({fixture,"/wi_d_full.mem"},wi_d);
    $readmemh({fixture,"/wi_reciprocal.mem"},wi_recip);
    $readmemh({fixture,"/down_source_f32.mem"},down_source);
    $readmemh({fixture,"/down_q.mem"},down_q);
    $readmemh({fixture,"/down_scale.mem"},down_scale);
    $readmemh({fixture,"/down_amax.mem"},down_amax);
    $readmemh({fixture,"/down_d_full.mem"},down_d);
    $readmemh({fixture,"/down_reciprocal.mem"},down_recip);
    run_case(0,32);
    run_case(1,82);
    for (int i=0;i<64;i++) begin
      wi_source[i]=0;
      wi_q[i]=0;
    end
    wi_amax[0]=0; wi_d[0]=0; wi_recip[0]=0; wi_scale[0]=0;
    wi_source[32]=32'h42fe0000; wi_q[32]=8'h7f;
    wi_source[33]=32'h3f000000; wi_q[33]=8'h01;
    wi_source[34]=32'hbf000000; wi_q[34]=8'hff;
    wi_source[35]=32'h3fc00000; wi_q[35]=8'h02;
    wi_source[36]=32'hbfc00000; wi_q[36]=8'hfe;
    wi_source[37]=32'h42fd0000; wi_q[37]=8'h7f;
    wi_source[38]=32'hc2fd0000; wi_q[38]=8'h81;
    wi_amax[1]=32'h42fe0000;
    wi_d[1]=32'h3f800000; wi_recip[1]=32'h3f800000;
    wi_scale[1]=16'h3c00;
    run_case(0,2);
    run_bad_second_mask();
    for (int i=0;i<64;i++) wi_source[i]=0;
    wi_source[0]=32'h501502f9; // F32 1.0e10, half(d_full) overflows.
    run_numeric_error(2,1,0,1,1);
    wi_source[0]=0; wi_source[5]=32'h7f800000;
    run_numeric_error(3,1,5,0,0);
    wi_source[5]=0;
    wi_source[0]=32'h501502f9;
    wi_source[32+3]=32'h7f800000;
    run_numeric_error(4,2,0,1,1); // Later group fails earlier in wall time.
    wi_source[0]=0; wi_source[32+3]=32'h7f800000;
    wi_source[1]=32'h7fc00000;
    run_numeric_error(5,2,1,0,0); // Both slots need independent poison.
    for (int i=0;i<64;i++) begin
      wi_source[i]=0;
      wi_q[i]=0;
    end
    wi_amax[0]=0; wi_d[0]=0; wi_recip[0]=0; wi_scale[0]=0;
    wi_source[32]=32'h42fe0000; wi_q[32]=8'h7f;
    wi_source[33]=32'h3f000000; wi_q[33]=8'h01;
    wi_source[34]=32'hbf000000; wi_q[34]=8'hff;
    wi_source[35]=32'h3fc00000; wi_q[35]=8'h02;
    wi_source[36]=32'hbfc00000; wi_q[36]=8'hfe;
    wi_source[37]=32'h42fd0000; wi_q[37]=8'h7f;
    wi_source[38]=32'hc2fd0000; wi_q[38]=8'h81;
    wi_amax[1]=32'h42fe0000;
    wi_d[1]=32'h3f800000; wi_recip[1]=32'h3f800000;
    wi_scale[1]=16'h3c00;
    run_reset_inflight(0);
    run_case(0,2);
    run_reset_inflight(1);
    run_case(0,2);
    $display("QUANT16_STREAM_OTHER_BOUNDARIES_PASS numerical=4 reset=2 protocol=1");
    wi_source[0]=32'h006ce3ee; // Frozen CPU boundary: F32 1.0e-38.
    run_numeric_error(1,1,0,1,1); // Reciprocal nonfinite.
    if (dut.amax[0]!==32'h006ce3ee || dut.d_full[0]!==32'h0000db7f ||
        dut.reciprocal[0]!==32'h7f800000)
      $fatal(1,"stream tiny original boundary scalar mismatch amax=%08x d=%08x reciprocal=%08x",
             dut.amax[0],dut.d_full[0],dut.reciprocal[0]);
    if ($value$plusargs("ADAPTER=%s",adapter_fixture)) run_adapter_cases();
    for(int phase=0;phase<4;phase++) run_partition_phase_reset(phase);
    $display("QUANT16_PARTITION_PHASES_PASS count=4 recovery_gold=original_wi_one_group");
    for(int mode=0;mode<4;mode++) run_metadata_case(mode);
    $display("QUANT16_METADATA_CASES_PASS count=4 real_handshake=1 controlled_return_data=1");
    $display("QUANT16_STREAM_REAL_ROWS_PASS groups=114 q_bytes=3648 edges=2 protocol=1 numerical=5 reset=2");
    $finish;
  end
endmodule
