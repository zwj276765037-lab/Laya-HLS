`timescale 1ns/1ps
// No DUT, AXI endpoint, fixture, or numerical oracle is instantiated here.
module att_probe_owner #(
    parameter int PORT=0, parameter int SIDE=0
) (
    input logic clk, resetn, emit_record, inject_x,
    output logic [118:0] accepted_r_record,
    output logic [31:0] r_count
);
  function automatic logic [118:0] known_record(input int port, input int side);
    logic [31:0] ordinal;
    logic [63:0] address;
    ordinal=32'(port+1+side*16);
    address=64'h0000000023400000+64'(port*4096+side*256);
    return {1'b1,ordinal,address,8'(port+2),8'(port+4),
            3'(port%3),1'(side),1'(side),1'b1};
  endfunction
  // Synthetic owner stimulus uses the original owner's blocking-update style.
  always @(posedge clk) begin
    if (!resetn) begin
      accepted_r_record='0;
      r_count=0;
    end else if (emit_record) begin
      accepted_r_record=known_record(PORT,SIDE);
      r_count=32'(PORT+1+SIDE*16);
      if (inject_x && PORT==4 && SIDE==1)
        accepted_r_record[40]=1'bx;
    end
  end
endmodule

module att_probe_wrapper #(
    parameter int PORT=0
) (
    input logic clk, resetn, emit_record, inject_x,
    output logic [31:0] ram_r_count,
    output logic [118:0] ram_accepted_r_record
);
  logic [118:0] dut_monitor_accepted_r_record, ram_monitor_accepted_r_record;
  logic [31:0] dut_r_count;
  logic port_reset_seen_posedge=1'b0;
  always @(posedge clk) port_reset_seen_posedge <= !resetn;
  assign ram_accepted_r_record = ram_monitor_accepted_r_record;
  att_probe_owner #(.PORT(PORT),.SIDE(0)) dut_mon (
    .clk(clk),.resetn(resetn),.emit_record(emit_record),.inject_x(inject_x),
    .accepted_r_record(dut_monitor_accepted_r_record),.r_count(dut_r_count));
  att_probe_owner #(.PORT(PORT),.SIDE(1)) ram_mon (
    .clk(clk),.resetn(resetn),.emit_record(emit_record),.inject_x(inject_x),
    .accepted_r_record(ram_monitor_accepted_r_record),.r_count(ram_r_count));
endmodule

module record_boundary_probe;
  logic clk=0;
  always #3.333 clk=~clk;
  logic resetn=0, emit_record=0, inject_x=0;
  logic [31:0] ram_r_count [0:6];
  logic [118:0] ram_accepted_r_record [0:6];
  logic top_reset_seen_posedge=1'b0;
  integer total_cycles=0;
  integer failures=0;
  always @(posedge clk) top_reset_seen_posedge <= !resetn;
  att_probe_wrapper #(.PORT(0)) u_port_descriptor (
    .clk(clk),.resetn(resetn),.emit_record(emit_record),.inject_x(inject_x),
    .ram_r_count(ram_r_count[0]),
    .ram_accepted_r_record(ram_accepted_r_record[0]));
  att_probe_wrapper #(.PORT(1)) u_port_io (
    .clk(clk),.resetn(resetn),.emit_record(emit_record),.inject_x(inject_x),
    .ram_r_count(ram_r_count[1]),
    .ram_accepted_r_record(ram_accepted_r_record[1]));
  att_probe_wrapper #(.PORT(2)) u_port_aux (
    .clk(clk),.resetn(resetn),.emit_record(emit_record),.inject_x(inject_x),
    .ram_r_count(ram_r_count[2]),
    .ram_accepted_r_record(ram_accepted_r_record[2]));
  att_probe_wrapper #(.PORT(3)) u_port_qkv0 (
    .clk(clk),.resetn(resetn),.emit_record(emit_record),.inject_x(inject_x),
    .ram_r_count(ram_r_count[3]),
    .ram_accepted_r_record(ram_accepted_r_record[3]));
  att_probe_wrapper #(.PORT(4)) u_port_qkv1 (
    .clk(clk),.resetn(resetn),.emit_record(emit_record),.inject_x(inject_x),
    .ram_r_count(ram_r_count[4]),
    .ram_accepted_r_record(ram_accepted_r_record[4]));
  att_probe_wrapper #(.PORT(5)) u_port_att_out (
    .clk(clk),.resetn(resetn),.emit_record(emit_record),.inject_x(inject_x),
    .ram_r_count(ram_r_count[5]),
    .ram_accepted_r_record(ram_accepted_r_record[5]));
  att_probe_wrapper #(.PORT(6)) u_port_observed (
    .clk(clk),.resetn(resetn),.emit_record(emit_record),.inject_x(inject_x),
    .ram_r_count(ram_r_count[6]),
    .ram_accepted_r_record(ram_accepted_r_record[6]));

  `include "att_r_boundary_diagnostic.svh"

  logic [150:0] cap_owner_dut [0:3][0:6], cap_owner_ram [0:3][0:6];
  logic [150:0] cap_wrapper_dut [0:3][0:6], cap_wrapper_ram [0:3][0:6];
  logic [150:0] cap_wrapper_out [0:3][0:6];
  logic [150:0] cap_top_literal [0:3][0:6], cap_top_variable [0:3][0:6];
  logic cap_variable_unknown [0:3][0:6], cap_literal_unknown [0:3][0:6];
  logic cap_packed_unknown [0:3][0:6], cap_record_reduction_x [0:3][0:6];
  logic cap_variable_predicate [0:3][0:6], cap_literal_predicate [0:3][0:6];
  logic cap_seen_reset_posedge [0:3];

  task automatic capture_one(input int phase, p,
      input logic [150:0] owner_dut, owner_ram, wrapper_dut, wrapper_ram,
                           wrapper_out, top_literal, top_variable,
      input logic variable_unknown, literal_unknown,
                  variable_predicate, literal_predicate);
    cap_owner_dut[phase][p]=owner_dut;
    cap_owner_ram[phase][p]=owner_ram;
    cap_wrapper_dut[phase][p]=wrapper_dut;
    cap_wrapper_ram[phase][p]=wrapper_ram;
    cap_wrapper_out[phase][p]=wrapper_out;
    cap_top_literal[phase][p]=top_literal;
    cap_top_variable[phase][p]=top_variable;
    cap_variable_unknown[phase][p]=variable_unknown;
    cap_literal_unknown[phase][p]=literal_unknown;
    cap_packed_unknown[phase][p]=$isunknown(top_literal);
    cap_record_reduction_x[phase][p]=((^top_literal[150:32]) === 1'bx);
    cap_variable_predicate[phase][p]=variable_predicate;
    cap_literal_predicate[phase][p]=literal_predicate;
  endtask
  task automatic capture_all(input int phase);
    cap_seen_reset_posedge[phase]=top_reset_seen_posedge;
    for (int p=0;p<7;p++) begin
      case (p)
        0: capture_one(phase,0,
             {u_port_descriptor.dut_mon.accepted_r_record,u_port_descriptor.dut_mon.r_count},
             {u_port_descriptor.ram_mon.accepted_r_record,u_port_descriptor.ram_mon.r_count},
             {u_port_descriptor.dut_monitor_accepted_r_record,u_port_descriptor.dut_r_count},
             {u_port_descriptor.ram_monitor_accepted_r_record,u_port_descriptor.ram_r_count},
             {u_port_descriptor.ram_accepted_r_record,u_port_descriptor.ram_r_count},
             {ram_accepted_r_record[0],ram_r_count[0]},
             {ram_accepted_r_record[p],ram_r_count[p]},
             $isunknown({ram_accepted_r_record[p],ram_r_count[p]}),$isunknown({ram_accepted_r_record[0],ram_r_count[0]}),
             ($isunknown({ram_accepted_r_record[p],ram_r_count[p]}) || ram_accepted_r_record[p] !== 119'd0 || ram_r_count[p] !== 32'd0),
             ($isunknown({ram_accepted_r_record[0],ram_r_count[0]}) || ram_accepted_r_record[0] !== 119'd0 || ram_r_count[0] !== 32'd0));
        1: capture_one(phase,1,
             {u_port_io.dut_mon.accepted_r_record,u_port_io.dut_mon.r_count},
             {u_port_io.ram_mon.accepted_r_record,u_port_io.ram_mon.r_count},
             {u_port_io.dut_monitor_accepted_r_record,u_port_io.dut_r_count},
             {u_port_io.ram_monitor_accepted_r_record,u_port_io.ram_r_count},
             {u_port_io.ram_accepted_r_record,u_port_io.ram_r_count},
             {ram_accepted_r_record[1],ram_r_count[1]},
             {ram_accepted_r_record[p],ram_r_count[p]},
             $isunknown({ram_accepted_r_record[p],ram_r_count[p]}),$isunknown({ram_accepted_r_record[1],ram_r_count[1]}),
             ($isunknown({ram_accepted_r_record[p],ram_r_count[p]}) || ram_accepted_r_record[p] !== 119'd0 || ram_r_count[p] !== 32'd0),
             ($isunknown({ram_accepted_r_record[1],ram_r_count[1]}) || ram_accepted_r_record[1] !== 119'd0 || ram_r_count[1] !== 32'd0));
        2: capture_one(phase,2,
             {u_port_aux.dut_mon.accepted_r_record,u_port_aux.dut_mon.r_count},
             {u_port_aux.ram_mon.accepted_r_record,u_port_aux.ram_mon.r_count},
             {u_port_aux.dut_monitor_accepted_r_record,u_port_aux.dut_r_count},
             {u_port_aux.ram_monitor_accepted_r_record,u_port_aux.ram_r_count},
             {u_port_aux.ram_accepted_r_record,u_port_aux.ram_r_count},
             {ram_accepted_r_record[2],ram_r_count[2]},
             {ram_accepted_r_record[p],ram_r_count[p]},
             $isunknown({ram_accepted_r_record[p],ram_r_count[p]}),$isunknown({ram_accepted_r_record[2],ram_r_count[2]}),
             ($isunknown({ram_accepted_r_record[p],ram_r_count[p]}) || ram_accepted_r_record[p] !== 119'd0 || ram_r_count[p] !== 32'd0),
             ($isunknown({ram_accepted_r_record[2],ram_r_count[2]}) || ram_accepted_r_record[2] !== 119'd0 || ram_r_count[2] !== 32'd0));
        3: capture_one(phase,3,
             {u_port_qkv0.dut_mon.accepted_r_record,u_port_qkv0.dut_mon.r_count},
             {u_port_qkv0.ram_mon.accepted_r_record,u_port_qkv0.ram_mon.r_count},
             {u_port_qkv0.dut_monitor_accepted_r_record,u_port_qkv0.dut_r_count},
             {u_port_qkv0.ram_monitor_accepted_r_record,u_port_qkv0.ram_r_count},
             {u_port_qkv0.ram_accepted_r_record,u_port_qkv0.ram_r_count},
             {ram_accepted_r_record[3],ram_r_count[3]},
             {ram_accepted_r_record[p],ram_r_count[p]},
             $isunknown({ram_accepted_r_record[p],ram_r_count[p]}),$isunknown({ram_accepted_r_record[3],ram_r_count[3]}),
             ($isunknown({ram_accepted_r_record[p],ram_r_count[p]}) || ram_accepted_r_record[p] !== 119'd0 || ram_r_count[p] !== 32'd0),
             ($isunknown({ram_accepted_r_record[3],ram_r_count[3]}) || ram_accepted_r_record[3] !== 119'd0 || ram_r_count[3] !== 32'd0));
        4: capture_one(phase,4,
             {u_port_qkv1.dut_mon.accepted_r_record,u_port_qkv1.dut_mon.r_count},
             {u_port_qkv1.ram_mon.accepted_r_record,u_port_qkv1.ram_mon.r_count},
             {u_port_qkv1.dut_monitor_accepted_r_record,u_port_qkv1.dut_r_count},
             {u_port_qkv1.ram_monitor_accepted_r_record,u_port_qkv1.ram_r_count},
             {u_port_qkv1.ram_accepted_r_record,u_port_qkv1.ram_r_count},
             {ram_accepted_r_record[4],ram_r_count[4]},
             {ram_accepted_r_record[p],ram_r_count[p]},
             $isunknown({ram_accepted_r_record[p],ram_r_count[p]}),$isunknown({ram_accepted_r_record[4],ram_r_count[4]}),
             ($isunknown({ram_accepted_r_record[p],ram_r_count[p]}) || ram_accepted_r_record[p] !== 119'd0 || ram_r_count[p] !== 32'd0),
             ($isunknown({ram_accepted_r_record[4],ram_r_count[4]}) || ram_accepted_r_record[4] !== 119'd0 || ram_r_count[4] !== 32'd0));
        5: capture_one(phase,5,
             {u_port_att_out.dut_mon.accepted_r_record,u_port_att_out.dut_mon.r_count},
             {u_port_att_out.ram_mon.accepted_r_record,u_port_att_out.ram_mon.r_count},
             {u_port_att_out.dut_monitor_accepted_r_record,u_port_att_out.dut_r_count},
             {u_port_att_out.ram_monitor_accepted_r_record,u_port_att_out.ram_r_count},
             {u_port_att_out.ram_accepted_r_record,u_port_att_out.ram_r_count},
             {ram_accepted_r_record[5],ram_r_count[5]},
             {ram_accepted_r_record[p],ram_r_count[p]},
             $isunknown({ram_accepted_r_record[p],ram_r_count[p]}),$isunknown({ram_accepted_r_record[5],ram_r_count[5]}),
             ($isunknown({ram_accepted_r_record[p],ram_r_count[p]}) || ram_accepted_r_record[p] !== 119'd0 || ram_r_count[p] !== 32'd0),
             ($isunknown({ram_accepted_r_record[5],ram_r_count[5]}) || ram_accepted_r_record[5] !== 119'd0 || ram_r_count[5] !== 32'd0));
        6: capture_one(phase,6,
             {u_port_observed.dut_mon.accepted_r_record,u_port_observed.dut_mon.r_count},
             {u_port_observed.ram_mon.accepted_r_record,u_port_observed.ram_mon.r_count},
             {u_port_observed.dut_monitor_accepted_r_record,u_port_observed.dut_r_count},
             {u_port_observed.ram_monitor_accepted_r_record,u_port_observed.ram_r_count},
             {u_port_observed.ram_accepted_r_record,u_port_observed.ram_r_count},
             {ram_accepted_r_record[6],ram_r_count[6]},
             {ram_accepted_r_record[p],ram_r_count[p]},
             $isunknown({ram_accepted_r_record[p],ram_r_count[p]}),$isunknown({ram_accepted_r_record[6],ram_r_count[6]}),
             ($isunknown({ram_accepted_r_record[p],ram_r_count[p]}) || ram_accepted_r_record[p] !== 119'd0 || ram_r_count[p] !== 32'd0),
             ($isunknown({ram_accepted_r_record[6],ram_r_count[6]}) || ram_accepted_r_record[6] !== 119'd0 || ram_r_count[6] !== 32'd0));
      endcase
    end
  endtask

  function automatic logic [118:0] expected_record(input int port, side);
    logic [31:0] ordinal;
    logic [63:0] address;
    ordinal=32'(port+1+side*16);
    address=64'h0000000023400000+64'(port*4096+side*256);
    return {1'b1,ordinal,address,8'(port+2),8'(port+4),
            3'(port%3),1'(side),1'(side),1'b1};
  endfunction
  task automatic assert_captured();
    logic [118:0] dut_record, ram_record;
    logic [150:0] dut_expected, ram_expected;
    bit bad;
    // All four diagnostic phases were printed before this first assertion.
    for (int phase=0;phase<4;phase++) begin
      if (cap_seen_reset_posedge[phase] !== ((phase==0 || phase==2) ? 1'b1 : 1'b0)) begin
        $display("ATT_PROBE_FAIL phase=%0d reset_posedge_flag",phase);
        failures++;
      end
      for (int p=0;p<7;p++) begin
        if (phase==0 || phase==2) begin
          dut_expected='0;
          ram_expected='0;
        end else begin
          dut_record=expected_record(p,0);
          ram_record=expected_record(p,1);
          if (phase==3 && p==4) ram_record[40]=1'bx;
          dut_expected={dut_record,32'(p+1)};
          ram_expected={ram_record,32'(p+17)};
        end
        bad=(cap_owner_dut[phase][p] !== dut_expected ||
             cap_owner_ram[phase][p] !== ram_expected ||
             cap_wrapper_dut[phase][p] !== dut_expected ||
             cap_wrapper_ram[phase][p] !== ram_expected ||
             cap_wrapper_out[phase][p] !== ram_expected ||
             cap_top_literal[phase][p] !== ram_expected ||
             cap_top_variable[phase][p] !== ram_expected);
        if (phase==3 && p==4) begin
          // X is intentional; the alternate detectors must reject it.
          if (cap_record_reduction_x[phase][p] !== 1'b1 ||
              cap_packed_unknown[phase][p] !== 1'b1 ||
              cap_literal_unknown[phase][p] !== 1'b1)
            bad=1;
        end else if (cap_record_reduction_x[phase][p] !== 1'b0 ||
                     cap_packed_unknown[phase][p] !== 1'b0 ||
                     cap_literal_unknown[phase][p] !== 1'b0 ||
                     cap_variable_unknown[phase][p] !== 1'b0)
          bad=1;
        if (phase==0 || phase==2) begin
          if (cap_variable_predicate[phase][p] !== 1'b0 ||
              cap_literal_predicate[phase][p] !== 1'b0) bad=1;
        end else if (cap_variable_predicate[phase][p] !== 1'b1 ||
                     cap_literal_predicate[phase][p] !== 1'b1) bad=1;
        if (bad) begin
          $display("ATT_PROBE_FAIL phase=%0d port=%0d variable_unknown=%b literal_unknown=%b packed_unknown=%b reduction_x=%b variable_predicate=%b literal_predicate=%b",
            phase,p,cap_variable_unknown[phase][p],cap_literal_unknown[phase][p],
            cap_packed_unknown[phase][p],cap_record_reduction_x[phase][p],
            cap_variable_predicate[phase][p],cap_literal_predicate[phase][p]);
          failures++;
        end
      end
    end
    if (failures!=0) $fatal(1,"ATT_PROBE_FAILURES count=%0d",failures);
    $display("ATT_PROBE_PASS phases=4 ports=7 cycles=%0d",total_cycles);
  endtask

  always @(negedge clk) begin
    total_cycles=total_cycles+1;
    case (total_cycles)
      1: begin
        $display("ATT_PROBE_PHASE reset_initial cycle=%0d",total_cycles);
        att_dump_all_boundaries(); capture_all(0);
        resetn<=1'b1; emit_record<=1'b1;
      end
      2: begin
        $display("ATT_PROBE_PHASE distinct_known cycle=%0d",total_cycles);
        att_dump_all_boundaries(); capture_all(1);
        resetn<=1'b0; emit_record<=1'b0;
      end
      3: begin
        $display("ATT_PROBE_PHASE reset_again cycle=%0d",total_cycles);
        att_dump_all_boundaries(); capture_all(2);
        resetn<=1'b1; emit_record<=1'b1; inject_x<=1'b1;
      end
      4: begin
        $display("ATT_PROBE_PHASE injected_x_port4_ram cycle=%0d",total_cycles);
        att_dump_all_boundaries(); capture_all(3);
        emit_record<=1'b0; inject_x<=1'b0;
      end
      5: begin
        assert_captured();
        $finish;
      end
    endcase
  end
  initial begin
    repeat (8) @(negedge clk);
    $fatal(1,"ATT_PROBE_FINITE_WATCHDOG cycles=%0d",total_cycles);
  end
endmodule
