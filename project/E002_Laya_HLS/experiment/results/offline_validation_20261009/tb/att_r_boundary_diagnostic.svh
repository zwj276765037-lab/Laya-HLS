  // v4 source-only diagnostic: all seven constant-index boundaries are printed
  // before the preserved wrapper and top reset predicates are evaluated.
  logic diagnostic_snapshot_complete=1'b0;
  integer diagnostic_snapshot_cycle=-1;
  task automatic att_dump_pair(input int p, input string where,
                               input logic [150:0] pair);
    $display("ATT_R_BOUNDARY_RAW port=%0d where=%s time_ps=%0d clk=%b resetn=%b record_hex=%h record_bin=%b count_hex=%h count_bin=%b",
      p,where,longint'($realtime*1000.0),clk,resetn,
      pair[150:32],pair[150:32],pair[31:0],pair[31:0]);
  endtask
  task automatic att_dump_one(
      input int p, input logic port_seen,
      input logic [150:0] owner_dut, owner_ram, wrapper_dut, wrapper_ram,
                           wrapper_out, top_literal, top_variable,
      input logic variable_unknown, literal_unknown,
                  variable_predicate, literal_predicate);
    logic [150:0] packed_snapshot;
    packed_snapshot={top_literal[150:32],top_literal[31:0]};
    $display("ATT_R_BOUNDARY_BEGIN port=%0d time_ps=%0d clk=%b resetn=%b top_seen_reset_posedge=%b port_seen_reset_posedge=%b",
      p,longint'($realtime*1000.0),clk,resetn,top_reset_seen_posedge,port_seen);
    att_dump_pair(p,"owner_dut",owner_dut);
    att_dump_pair(p,"owner_ram",owner_ram);
    att_dump_pair(p,"wrapper_dut",wrapper_dut);
    att_dump_pair(p,"wrapper_ram",wrapper_ram);
    att_dump_pair(p,"wrapper_output",wrapper_out);
    att_dump_pair(p,"top_literal",top_literal);
    att_dump_pair(p,"top_variable",top_variable);
    $display("ATT_R_BOUNDARY_EXPR port=%0d record_case_nonzero=%b count_case_nonzero=%b record_reduction_x=%b count_reduction_x=%b record_isunknown=%b count_isunknown=%b variable_concat_isunknown=%b literal_concat_isunknown=%b packed_isunknown=%b variable_predicate=%b literal_predicate=%b packed_hex=%h packed_bin=%b",
      p,top_literal[150:32] !== 119'd0,top_literal[31:0] !== 32'd0,
      ((^top_literal[150:32]) === 1'bx),((^top_literal[31:0]) === 1'bx),
      $isunknown(top_literal[150:32]),$isunknown(top_literal[31:0]),
      variable_unknown,literal_unknown,$isunknown(packed_snapshot),
      variable_predicate,literal_predicate,packed_snapshot,packed_snapshot);
  endtask
  task automatic att_dump_all_boundaries();
    for (int p=0;p<7;p++) begin
      case (p)
        0: att_dump_one(0,u_port_descriptor.port_reset_seen_posedge,
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
        1: att_dump_one(1,u_port_io.port_reset_seen_posedge,
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
        2: att_dump_one(2,u_port_aux.port_reset_seen_posedge,
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
        3: att_dump_one(3,u_port_qkv0.port_reset_seen_posedge,
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
        4: att_dump_one(4,u_port_qkv1.port_reset_seen_posedge,
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
        5: att_dump_one(5,u_port_att_out.port_reset_seen_posedge,
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
        6: att_dump_one(6,u_port_observed.port_reset_seen_posedge,
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
    $display("ATT_R_BOUNDARY_ALL_COMPLETE time_ps=%0d cycle=%0d",
      longint'($realtime*1000.0),total_cycles);
  endtask
