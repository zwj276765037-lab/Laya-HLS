#!/usr/bin/env python3
"""Emit bounded physical-retirement metadata checks with independent row counts."""
from pathlib import Path
import re

MODULE = Path(__file__).resolve().parents[1]
raw = (MODULE / 'rtl/tm4tn8_matrix_owner_ledger_v2.sv').read_text().split(
    'module tm4tn8_matrix_owner_ledger_v2 (', 1)[1].split(');', 1)[0]
ports = []
direction = width = ''
for token in raw.split(','):
    token = token.strip()
    match = re.fullmatch(r'(input|output)\s+logic\s*((?:\[[^]]+\]\s*)*)(\w+)', token)
    if match:
        direction, width, name = match.groups()
    else:
        assert re.fullmatch(r'\w+', token), token
        name = token
    ports.append((direction, width.strip(), name))
s = '''`timescale 1ns/1ps
// Producer metadata only. No fixture READY or arithmetic claim is inferred.
module laya_matrix_tensor_ledger_tb_v2;
'''
s += ''.join(f'  logic {w} {n};\n'.replace('logic  ', 'logic ') for _, w, n in ports)
s += '  tm4tn8_matrix_owner_ledger_v2 dut(\n' + ',\n'.join('    .' + n for _, _, n in ports) + '\n  );\n'
s += '''  initial clk=0;always #5 clk=~clk;
  int cycles=0,rejects=0,ps_epoch=0;
  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin cycles++;if(cycles>12000)$fatal(1,"tensor metadata cycle cap");if(claim_reject)rejects++;end
  task automatic prepare(input int request_id,dst_epoch,row0,batch,task_id,b=1,s=64);
    @(negedge clk);claim_numeric_identity=0;
    claim_numeric_identity[63:0]=64'(request_id);claim_numeric_identity[127:64]=1;
    claim_numeric_identity[143:128]=16'(b);claim_numeric_identity[159:144]=16'(s);
    claim_parent_context=0;claim_parent_context[31:0]=32'(task_id);
    claim_parent_context[39:32]=8'h31;claim_parent_context[47:40]=2;
    claim_parent_context[63:56]=8'(batch);claim_parent_context[87:72]=16'(row0);
    claim_parent_context[95:88]=16;
    claim_K=1024;claim_N=1024;claim_rows=4;claim_row_block_base=0;
    claim_source_ref=64'h0000000200000001;claim_a_ref=64'h0000002200000001;
    claim_w_ref=64'h0000002300000001;claim_ps_ref=64'h0000002400000000|64'(ps_epoch+1);
    claim_dst_ref=64'h0000000300000000|64'(dst_epoch);claim_model_identity=0;
    claim_model_identity[576+:64]=1;claim_output_binding=528'h1234;
  endtask
  task automatic admit;
    #1;if(!claim_ready || !claim_admitted)$fatal(1,"tensor claim rejected request=%0d row0=%0d PS=%0d dst=%0d",claim_numeric_identity[63:0],claim_parent_context[87:72],claim_ps_ref[31:0],claim_dst_ref[31:0]);
    claim_valid=1;tick();@(negedge clk);claim_valid=0;ps_epoch++;
  endtask
  task automatic reject;
    #1;if(!claim_ready || claim_admitted)$fatal(1,"wrong tensor identity/coverage admitted");
    claim_valid=1;tick();@(negedge clk);claim_valid=0;tick();@(negedge clk);
    if(dut.last_ps_epoch[0]!=ps_epoch)$fatal(1,"rejected future claim advanced epoch");
  endtask
  task automatic finish_parent(input int failing_view=-1);
    for(int v=0;v<4;v++)begin
      if(v!=0)begin claim_row_block_base=4'(v*4);admit_view();end
      retire_row_block_base=4'(v*4);retire_rows=4;retire_success=v!=failing_view;
      retire_valid=1;retire_debt_zero=0;
      repeat(3)begin tick();if(retire_ready || parent_complete)$fatal(1,"retire before real debt zero");end
      @(negedge clk);retire_debt_zero=1;tick();
      if(retire_error || parent_complete!=(v==3) || $countones(checked_rows)!=4*(v+1))$fatal(1,"independent parent checked-row coverage");
      @(negedge clk);retire_valid=0;tick();@(negedge clk);
    end
  endtask
  task automatic admit_view;
    #1;if(!claim_ready || !claim_admitted)$fatal(1,"next view rejected under sticky numerical failure");
    claim_valid=1;tick();@(negedge clk);claim_valid=0;
  endtask
  initial begin
'''
for d, _, n in ports:
    if d == 'input' and n != 'clk':
        s += f'    {n}=0;\n'
s += '''    repeat(4)tick();@(negedge clk);rst_n=1;retire_debt_zero=1;
    // Four distinct parent L tasks share one complete S64 destination epoch.
    for(int p=0;p<4;p++)begin
      prepare(1,1,p*16,0,100+p);
      if(p==1)begin
        claim_output_binding^=528'd1;reject();claim_output_binding^=528'd1;
        claim_model_identity[600]^=1'b1;reject();claim_model_identity[600]^=1'b1;
        claim_source_ref[31:0]+=1;reject();claim_source_ref[31:0]-=1;
        claim_parent_context[55:48]+=1;reject();claim_parent_context[55:48]-=1;
      end
      admit();finish_parent();
      if(parent_error || tensor_state!=(p==3 ? 2 : 1) || tensor_publications!=(p==3 ? 1 : 0))$fatal(1,"early whole tensor publication");
    end
    prepare(1,1,0,0,200);reject(); // completed coverage cannot replay.
    // A later parent failure cannot be cleared by succeeding parents/views.
    for(int p=0;p<4;p++)begin
      prepare(1,2,p*16,0,300+p);admit();finish_parent(p==1 ? 0 : -1);
      if(p>=1 && (tensor_state!=4 || !dut.tensor_failed[2]))$fatal(1,"tensor failure was cleared by local success");
      if(tensor_publications!=1)$fatal(1,"failed tensor published");
    end
    if($countones(dut.tensor_checked[2])!=64 || $countones(dut.tensor_covered[2])!=16)$fatal(1,"failed complete tensor checked/covered distinction");
    // New request in the same session restarts task IDs, not physical epochs.
    prepare(2,3,0,0,1);admit();
    retire_row_block_base=0;retire_rows=4;retire_success=1;retire_valid=1;tick();@(negedge clk);retire_valid=0;
    cancel_parent=1;retire_debt_zero=0;tick();@(negedge clk);cancel_parent=0;
    repeat(4)begin tick();if(claim_ready || !dut.parent_live)$fatal(1,"inter-view cancel forgot parent or drain");end
    @(negedge clk);retire_debt_zero=1;tick();@(negedge clk);
    if(dut.parent_live || tensor_state!=4)$fatal(1,"cancelled parent did not invalidate tensor");
    prepare(2,3,16,0,2);reject(); // cancelled tensor tickets cannot activate.
    for(int p=0;p<4;p++)begin
      prepare(3,4,p*16,0,1+p);admit();finish_parent();
      if(tensor_publications!=(p==3 ? 2 : 1))$fatal(1,"same-session recovery publication");
    end
    // Full legal B2/S1024: exactly 128 parents, 512 views and 2048 rows.
    for(int p=0;p<128;p++)begin
      prepare(4,5,(p%64)*16,p/64,p+1,2,1024);admit();finish_parent();
      if(tensor_state!=(p==127 ? 2 : 1) || tensor_publications!=(p==127 ? 3 : 2))$fatal(1,"max tensor published before B*S coverage");
    end
    if($countones(dut.tensor_checked[2])!=2048 || $countones(dut.tensor_covered[2])!=2048 || rejects!=6 || ps_epoch!=141)
      $fatal(1,"maximum tensor metadata coverage reject=%0d PS=%0d",rejects,ps_epoch);
    $display("FULL_CURRENT_MATRIX_TENSOR_PASS max_parents=128 max_views=512 max_rows=2048 shared_dst_epoch=1 sticky_failure=1 inter_view_cancel=1 same_session_task_restart=1 held_retire=1 rejects=%0d tensor_publications=%0d cycles=%0d",rejects,tensor_publications,cycles);$finish;
  end
endmodule
'''
(MODULE / 'tb/laya_matrix_tensor_ledger_tb_v2.sv').write_text(s)
print('FULL_CURRENT_MATRIX_TENSOR_TB_GENERATED')
