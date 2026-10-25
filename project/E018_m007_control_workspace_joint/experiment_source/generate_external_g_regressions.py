from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];MOD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';G=MOD/'vector_and_ffn';A=MOD/'attention_and_fp_engine'
# Every original assertion is retained. The standalone arithmetic tests select
# external state; the actual layer+G production composition is tested separately.
s=(G/'tb/m007_g_ring_tag_tb.sv').read_text().replace('module m007_g_ring_tag_tb;','module m007_control_arena_ring_tb;')
s=s.replace(' laya_m007_g_math_v1 dut(',''' logic [11342:0]external_q,external_next;
 always_ff @(posedge clk)external_q<=external_next;
 laya_m007_g_math_v1 #(.EXTERNAL_CONTROL(1)) dut(.external_control_enable(1'b1),.external_control_q(external_q),.external_control_next(external_next),.control_retired(),''',1)
(G/'tb/m007_control_arena_ring_tb.sv').write_text(s)
s=(G/'tb/m007_g_ring_tag_run.py').read_text().replace('m007_g_ring_tag_tb','m007_control_arena_ring_tb').replace('g_ring_tag_sim','control_ring_sim')
(G/'tb/m007_control_arena_ring_run.py').write_text(s)
s=(G/'tb/m007_g_tag_fault_validation_shell.sv').read_text().replace('module m007_g_tag_fault_validation_shell(', 'module m007_control_arena_tag_fault_shell(')
s=s.replace(' laya_m007_g_engine_v1 engine(',''' logic [12287:0]control_q;logic [11342:0]control_next;
 logic control_enable,a_enable,rearm,owner_g,owner_ready,g_retired,g_private_idle;
 wire request_a=active||done_valid||needs_discard||(release_valid&&release_ready);
 laya_m007_control_workspace_v1 workspace(.clk,.rst_n,.owner_req_valid(1'b1),.owner_req_g(!request_a),.owner_req_ready(owner_ready),
  .a_retired(1'b1),.a_private_idle(1'b1),.g_retired,.g_private_idle,.a_next(12288'b0),.g_next(control_next),.state_q(control_q),.a_enable,.g_enable(control_enable),.rearm,.owner_g);
 always @(posedge clk)if(rst_n&&owner_g&&request_a&&(active||done_valid||needs_discard))begin
  if(owner_ready||rearm||!control_enable)$fatal(1,"EXTERNAL_G_EARLY_OR_HELD_DONE_SWITCH");
 end
 laya_m007_g_engine_v1 #(.EXTERNAL_CONTROL(1)) engine(.external_control_enable(control_enable),.external_control_q(control_q[11342:0]),.external_control_next(control_next),.control_retired(g_retired),.control_private_idle(g_private_idle),''',1)
(G/'tb/m007_control_arena_tag_fault_shell.sv').write_text(s)
s=(G/'tb/m007_g_tag_fault_tb.sv').read_text().replace('module m007_g_tag_fault_tb;','module m007_control_arena_tag_fault_tb;').replace('m007_g_tag_fault_validation_shell dut','m007_control_arena_tag_fault_shell dut')
(G/'tb/m007_control_arena_tag_fault_tb.sv').write_text(s)
s=(G/'tb/m007_g_tag_fault_run.py').read_text().replace('m007_g_tag_fault_validation_shell.sv','m007_control_arena_tag_fault_shell.sv').replace('m007_g_tag_fault_tb','m007_control_arena_tag_fault_tb').replace('g_tag_fault_sim','control_tag_fault_sim')
s=s.replace("sources=[*shared,*[f/LOCAL/name for name in names]]", "sources=[*shared,*[f/LOCAL/name for name in names],f/(MODULE.parent/'attention_and_fp_engine/rtl/laya_m007_control_workspace_v1.sv').relative_to(ROOT)]")
(G/'tb/m007_control_arena_tag_fault_run.py').write_text(s)
print('EXTERNAL_G_REGRESSIONS_GENERATED all_original_assertions_retained')
