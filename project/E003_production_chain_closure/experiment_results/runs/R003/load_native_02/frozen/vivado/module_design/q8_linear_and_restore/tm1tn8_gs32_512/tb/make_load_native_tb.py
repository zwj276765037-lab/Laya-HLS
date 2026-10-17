#!/usr/bin/env python3
"""Reuse LOAD cases with actual conversion, native arbitration and 32-bit peers."""
import json
from pathlib import Path

MODULE = Path(__file__).resolve().parents[1]
s = (MODULE / 'tb/laya_load_portal_tb_v1.sv').read_text()
s = s.replace('module laya_load_portal_tb_v1;', 'module laya_load_native_tb_v1;')
ports = json.loads((MODULE / 'tb/laya_load_axi_native_ports_v1.json').read_text())['ports']
extra = '  logic native_debt_zero,si_hold=0;\n  logic [2:0] converted_rvalid;\n  logic [511:0] held_wide_data;\n'
binds = []
for d, w, n in ports:
    if n.startswith('load_'):
        value = n.removeprefix('load_')
        if n == 'load_rvalid':
            value = 'converted_rvalid'
        elif n == 'load_rready':
            value = "rready & {2'b11,!si_hold}"
    elif n.startswith('aux_') or n in ('clk', 'rst_n'):
        value = n
    elif n == 'service_select':
        value = '(service_command_valid || dut.active) && !service_cancel'
    elif n == 'physical_debt_zero':
        value = 'native_debt_zero'
    else:
        extra += f'  logic {w} {n};\n'.replace('logic  ', 'logic ')
        value = n
    binds.append(f'    .{n}({value})')
extra += '  laya_load_axi_native_v1 native_adapter(\n' + ',\n'.join(binds) + '\n  );\n'
extra += "  assign rvalid=converted_rvalid & {2'b11,!si_hold};\n"
extra += '''  int held_buffer_cycles=0,narrow_aux_beats=0;
  logic [12:0] mi_reading=0;
  logic [12:0][63:0] mi_addr;
  int mi_index[13],mi_beats[13];
  logic mi_aux_tail[13];
'''
s = s.replace('  initial clk=0;', extra + '  initial clk=0;', 1)
s = s.replace('  assign arready=rst_n ? {2\'b11,!q_ar_block} : 0;\n  assign aux_arready=rst_n && !aux_reading;\n', '')
s = s.replace('assign physical_debt_zero=!physical_hold && reading==0 && !aux_reading && rvalid==0 && !aux_rvalid && arvalid==0 && !aux_arvalid;',
              'assign physical_debt_zero=!physical_hold && native_debt_zero;')
start = s.index('  always @(posedge clk)begin : peer')
end = s.index('  task automatic prepare(', start)
peer = '''  always_comb begin
    memory_arready=0;
    for(int bo=2;bo<=5;bo++)memory_arready[bo]=rst_n && !mi_reading[bo] &&
      !(bo==2 && q_ar_block) && cycles%7!=2;
    memory_awready=0;memory_wready=0;memory_bresp=0;
    memory_bid=0;memory_buser=0;memory_bvalid=0;
    reading=mi_reading[4:2];aux_reading=mi_reading[5];
  end
  always @(posedge clk)begin : peer
    int relative,word_byte;
    cycles++;
    if(cycles>30000)$fatal(1,"native LOAD cycle cap commands=%0d replies=%0d SIdebt=%b MIdebt=%b",commands,replies,upstream_read_pending,debt_zero);
    if(rst_n)begin
      for(int bo=2;bo<=5;bo++)begin
        if(memory_arvalid[bo] && memory_arready[bo])begin
          if(mi_reading[bo] || memory_arsize[bo]!=2 || memory_arburst[bo]!=1 ||
             memory_araddr[bo]<latched_bo_base[bo] || memory_araddr[bo][1:0]!=0 ||
             int'(memory_araddr[bo][11:0])+4*(int'(memory_arlen[bo])+1)>4096)
            $fatal(1,"native LOAD AR address/shape mismatch BO=%0d",bo);
          if(selected_owner[bo])begin
            if(memory_arid[bo]!=0 || memory_aruser[bo]!=0 || memory_arregion[bo]!=0 ||
               memory_arlock[bo]!=0 || memory_arcache[bo]!=3 || memory_arprot[bo]!=0 || memory_arqos[bo]!=0)
              $fatal(1,"native service AR sideband mismatch BO=%0d",bo);
          end else if(memory_arid[bo]!==controller_arid[bo] || memory_aruser[bo]!==controller_aruser[bo] ||
              memory_arregion[bo]!==controller_arregion[bo] || memory_arlock[bo]!==controller_arlock[bo] ||
              memory_arcache[bo]!==controller_arcache[bo] || memory_arprot[bo]!==controller_arprot[bo] ||
              memory_arqos[bo]!==controller_arqos[bo])$fatal(1,"controller sideband loss through native adapter");
          memory_rid[bo]<=memory_arid[bo];memory_ruser[bo]<=memory_aruser[bo];
          mi_reading[bo]<=1;mi_addr[bo]<=memory_araddr[bo];mi_index[bo]<=0;mi_beats[bo]<=int'(memory_arlen[bo])+1;
          mi_aux_tail[bo]<=bo==5 && memory_araddr[bo]-latched_bo_base[bo]==256;
          total_ar++;if(bo==2)q_ar++;if(bo==5)aux_ar++;
        end
        if(mi_reading[bo] && !memory_rvalid[bo] && cycles%3!=0 &&
           !(bo==2 && q_hold) && !(bo==5 && aux_hold))begin
          relative=int'(mi_addr[bo]-latched_bo_base[bo])+mi_index[bo]*4;
          for(int j=0;j<4;j++)begin
            word_byte=relative+j;
            if(bo==4)memory_rdata[bo][j*8+:8]<=word_byte%2==0 ? 8'h00 : 8'h3c;
            else if(bo==5)begin
              case(word_byte)
                256:memory_rdata[bo][j*8+:8]<=8'h00;
                257:memory_rdata[bo][j*8+:8]<=8'h00;
                258:memory_rdata[bo][j*8+:8]<=8'hc0;
                259:memory_rdata[bo][j*8+:8]<=8'h3f;
                260:memory_rdata[bo][j*8+:8]<=8'h00;
                261:memory_rdata[bo][j*8+:8]<=8'h00;
                262:memory_rdata[bo][j*8+:8]<=8'h20;
                263:memory_rdata[bo][j*8+:8]<=8'hc0;
                default:memory_rdata[bo][j*8+:8]<=0;
              endcase
            end else memory_rdata[bo][j*8+:8]<=qbyte(word_byte);
          end
          memory_rresp[bo]<=bo==5 && inject_aux_error ? 2 : 0;
          memory_rlast[bo]<=mi_index[bo]==mi_beats[bo]-1;memory_rvalid[bo]<=1;
        end
        if(memory_rvalid[bo] && memory_rready[bo])begin
          memory_rvalid[bo]<=0;mi_index[bo]<=mi_index[bo]+1;total_r++;
          if(bo==2)q_r++;
          if(bo==5)begin aux_r++;if(mi_aux_tail[bo])narrow_aux_beats++;end
          if(memory_rlast[bo])mi_reading[bo]<=0;
        end
        if(upstream_read_pending[bo-2] && !selected_owner[bo])
          $fatal(1,"native owner handed off with SI response debt BO=%0d",bo);
        if(upstream_read_pending[bo-2] && debt_zero[bo] && !mi_reading[bo])held_buffer_cycles++;
        if(protocol_error[bo])$fatal(1,"native arbiter protocol error BO=%0d",bo);
        if(controller_arready[bo] || controller_rvalid[bo] || controller_bvalid[bo])begin
          if(selected_owner[bo])$fatal(1,"inactive controller leaked handshake/response BO=%0d",bo);
        end
      end
      if(service_completion_valid && !native_debt_zero)$fatal(1,"LOAD completed with converter debt");
      if(service_command_valid && service_command_ready)commands++;
      if(service_completion_valid && service_completion_ready)replies++;
    end
  end
'''
s = s[:start] + peer + s[end:]
# These outputs are driven by actual converters, not initialized by the TB.
for n in ('rdata', 'rresp', 'rlast', 'rvalid', 'aux_rdata', 'aux_rresp', 'aux_rlast', 'aux_rvalid'):
    s = s.replace(f'    {n}=0;\n', '')
init = ''
for d, _, n in ports:
    if d == 'input' and n.startswith('controller_'):
        init += f'    {n}=0;\n'
init += '    clear_error=0;memory_rdata=0;memory_rresp=0;memory_rlast=0;memory_rvalid=0;memory_rid=0;memory_ruser=0;\n'
init += '    for(int bo=0;bo<13;bo++)begin mi_index[bo]=0;mi_beats[bo]=0;mi_aux_tail[bo]=0;end\n'
s = s.replace('  initial begin\n', '  initial begin\n' + init, 1)
s = s.replace('wait(arvalid[0]);repeat(2)tick();', 'wait(memory_arvalid[2]);repeat(2)tick();')
s = s.replace('if(!arvalid[0] || service_completion_valid)', 'if(!memory_arvalid[2] || service_completion_valid)')
s = s.replace('    if(commands!=11 || replies!=11', '''    // FIFO_MODE0 has a cut-through final MI word: holding the actual final
    // converted SI response also holds that real MI LAST. Both debts survive
    // a request to return ownership to the controller.
    prepare(10,12);submit();wait(converted_rvalid[0] && rlast[0]);
    @(negedge clk);si_hold=1;service_cancel=1;#1;held_wide_data=rdata[0];
    repeat(12)begin tick();
      if(!selected_owner[2] || !upstream_read_pending[0] || service_completion_valid ||
         !converted_rvalid[0] || !rlast[0] || rdata[0]!==held_wide_data)
        $fatal(1,"final buffered SI R debt lost across native owner cancel");
    end
    if(debt_zero[2] || !memory_rvalid[2] || !memory_rlast[2] || memory_rready[2])
      $fatal(1,"cut-through final MI LAST was lost while SI tail was held");
    @(negedge clk);si_hold=0;completion(7,4,10);
    prepare(11,13);submit();completion(0,2,11);check_stripe(11);
    if(commands!=13 || replies!=13''')
s = s.replace('cancel_cases=5', 'cancel_cases=6').replace('recoveries=2', 'recoveries=3')
s = s.replace('    if(commands!=13 || replies!=13', '''    // Real controller-side ownership is available again after cancellation
    // and recovery; all original native fields survive the shared adapter.
    wait(!selected_owner[2]);@(negedge clk);
    controller_araddr[2]=latched_bo_base[2]+64;controller_arlen[2]=0;
    controller_arsize[2]=2;controller_arburst[2]=1;controller_arid[2]=1;
    controller_aruser[2]=1;controller_arlock[2]=2;controller_arcache[2]=10;
    controller_arprot[2]=6;controller_arqos[2]=7;controller_arregion[2]=9;
    controller_arvalid[2]=1;
    do @(posedge clk);while(!controller_arready[2]);
    @(negedge clk);controller_arvalid[2]=0;wait(controller_rvalid[2]);#1;
    for(int j=0;j<4;j++)if(controller_rdata[2][j*8+:8]!==qbyte(64+j))$fatal(1,"controller recovery read byte");
    repeat(8)begin tick();
      if(!controller_rvalid[2] || !controller_rlast[2] || controller_rresp[2]!=0 ||
         !controller_rid[2] || !controller_ruser[2] || selected_owner[2] || native_debt_zero)
        $fatal(1,"controller recovery held return identity/owner/debt");
    end
    @(negedge clk);controller_rready[2]=1;tick();@(negedge clk);controller_rready[2]=0;repeat(3)tick();
    if(held_buffer_cycles==0 || narrow_aux_beats<2)$fatal(1,"native converter debt/narrow AUX coverage missing");
    if(commands!=13 || replies!=13''')
s = s.replace('FULL_CURRENT_LOAD_PORTAL_PASS commands=', 'FULL_CURRENT_LOAD_NATIVE_PASS converters=4 physical_BO=13 narrow_aux8B=1 SI_MI_debt=1 controller_recovery=1 commands=')
(MODULE / 'tb/laya_load_native_tb_v1.sv').write_text(s)
print('FULL_CURRENT_LOAD_NATIVE_TB_GENERATED')
