from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';G=M/'vector_and_ffn';BASE=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R002/input_baseline'
s=(BASE/'m007_control_arena_validation_shell.sv').read_text().replace('module m007_control_arena_validation_shell(','''module m007_cancel17_normal_shell(
 input logic producer_cancel_valid,input logic [63:0]producer_cancel_request_id,
 input logic [31:0]producer_cancel_generation,producer_cancel_epoch,
 output logic producer_cancel_ready,producer_cancel_reject_valid,done_cancelled,''',1)
s=s.replace('laya_m007_control_workspace_joint_v1 joint(', 'laya_m007_control_workspace_joint_v1 joint(.g_producer_cancel_valid(producer_cancel_valid),.g_producer_cancel_request_id(producer_cancel_request_id),.g_producer_cancel_generation(producer_cancel_generation),.g_producer_cancel_epoch(producer_cancel_epoch),.g_producer_cancel_ready(producer_cancel_ready),.g_producer_cancel_reject_valid(producer_cancel_reject_valid),.g_done_cancelled(done_cancelled),',1)
(G/'tb/m007_cancel17_normal_shell.sv').write_text(s)
s=(BASE/'m007_control_arena_engine_tb.sv').read_text().replace('module m007_control_arena_engine_tb;', 'module m007_cancel17_normal_tb;').replace('m007_control_arena_validation_shell dut','m007_cancel17_normal_shell dut')
s=s.replace(' logic clk=0;', ' logic producer_cancel_valid=0,producer_cancel_ready,producer_cancel_reject_valid,done_cancelled;\n wire[63:0]producer_cancel_request_id;wire[31:0]producer_cancel_generation,producer_cancel_epoch;\n logic clk=0;',1)
s=s.replace('mode>1)', 'mode>2)')
s=s.replace('   wait(done_valid);@(negedge clk);', '''   if(mode==2)begin
    // Exact original full-normal terminal eligibility, sampled before its edge.
    @(negedge clk);
    while(!(dut.joint.g_engine.math_idle&&dut.joint.g_engine.math_control_retired&&!dut.joint.g_engine.write_pending&&dut.joint.g_engine.bank_issued==dut.joint.g_engine.bank_returned&&dut.joint.g_engine.read_index==41984&&dut.joint.g_engine.completed_groups==82&&slot_active==0&&dut.joint.g_engine.all_covered))@(negedge clk);
    producer_cancel_valid=1;#0.001;if(!producer_cancel_ready)$fatal(1,"FULL_TERMINAL_CANCEL_NOT_READY");
    @(posedge clk);@(negedge clk);producer_cancel_valid=0;
    if(done_valid)$fatal(1,"CANCEL_MUST_WIN_NORMAL_TERMINAL_EDGE");
   end
   wait(done_valid);@(negedge clk);
   if(done_cancelled!=(mode==2))$fatal(1,"DONE_CANCELLED_QUALIFIER");''',1)
s=s.replace('   if(!engine_idle)$fatal(1,"POST_DONE_NOT_IDLE");', '''   if(mode==2)begin
    if(!needs_discard||engine_idle||dut.joint.g_retired)$fatal(1,"CANCEL_NEEDS_EXPLICIT_DISCARD");
    discard_valid=1;#0.001;while(!discard_ready)begin @(negedge clk);#0.001;end
    @(posedge clk);@(negedge clk);discard_valid=0;
   end
   if(!engine_idle)$fatal(1,"POST_DONE_NOT_IDLE");''',1)
s=s.replace('if(!done_valid||done_status||cmd_ready||', 'if(!done_valid||done_status||done_cancelled!=(mode==2)||cmd_ready||',1)
s=s.replace('if(rst_n)begin\n   if(protocol_fault', 'if(rst_n)begin\n   if(producer_cancel_reject_valid)$fatal(1,"UNEXPECTED_CANCEL_REJECT");\n   if(protocol_fault',1)
s=s.replace('if(mode==0&&done_cycle', 'if(mode==0&&done_cycle')
# Additional evidence marker leaves the full original normal-data marker intact.
s=s.replace('  $fclose(progress_fd);', '  $display("CANCEL17_NORMAL_QUALIFIER mode=%0d full_terminal_cancel=%0d",mode,mode==2);\n  $fclose(progress_fd);',1)
s=s.replace(' m007_cancel17_normal_shell dut',' assign producer_cancel_request_id=request_id;assign producer_cancel_generation=generation;assign producer_cancel_epoch=epoch;\n m007_cancel17_normal_shell dut',1)
(G/'tb/m007_cancel17_normal_tb.sv').write_text(s)
s=(G/'tb/m007_control_arena_run.py').read_text().replace('m007_control_arena_validation_shell.sv','m007_cancel17_normal_shell.sv').replace('m007_control_arena_engine_tb','m007_cancel17_normal_tb').replace('control_arena_sim','cancel17_normal_sim').replace('choices=(0,1)','choices=(0,1,2)')
s=s.replace("metrics['held_final17']==(17 if a.mode else 0)","metrics['held_final17']==(17 if a.mode==1 else 0)")
(G/'tb/m007_cancel17_normal_run.py').write_text(s)
s=(G/'tb/m007_control_arena_guard_v1.py').read_text().replace("RUN=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R001'", "RUN=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R002'")
s=s.replace("'static':600,'rtl':1800", "'static':300,'rtl':600").replace('<=600','<=300').replace('limit=600','limit=300').replace('>1680','>480').replace('*1.10+10','*1.35+10').replace("=='0'\n  build", "in('0','2')\n  build")
s=s.replace("experiment_source/protocol.md'", "experiment_source/protocol_r002.md'")
s=s.replace("+sorted((MODULE.parent/'attention_and_fp_engine/tb').glob('m007_control*'))", "+sorted((MODULE.parent/'attention_and_fp_engine/tb').glob('m007_control*'))+sorted((MODULE.parent/'attention_and_fp_engine/tb').glob('m007_cancel17*'))")
s=s.replace("'schema':'m007-control-arena-guard-v1'", "'schema':'m007-producer-cancel-guard-v1'")
(G/'tb/m007_cancel17_guard_v1.py').write_text(s)
print('CANCEL17_NORMAL_AND_GUARD_PREPARED')
