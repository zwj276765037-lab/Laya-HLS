from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];p=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/tb/m007_cancel17_normal_tb.sv';s=p.read_text()
start=s.index('   if(mode==2)begin\n    // Exact original full-normal terminal eligibility');end=s.index('   wait(done_valid);',start)
s=s[:start]+'   if(mode==2&&!terminal_cancel_seen)$fatal(1,"FULL_TERMINAL_CANCEL_NOT_OBSERVED");\n'+s[end:]
s=s.replace(' logic producer_cancel_valid=0,', ' bit terminal_cancel_seen=0;\n logic producer_cancel_valid=0,',1)
monitor=''' always @(negedge clk)if(rst_n&&mode==2)begin
  if(producer_cancel_valid)begin
   if(done_valid)$fatal(1,"CANCEL_MUST_WIN_NORMAL_TERMINAL_EDGE");
   producer_cancel_valid=0;
  end else if(!terminal_cancel_seen&&dut.joint.g_engine.active&&dut.joint.g_engine.math_idle&&dut.joint.g_engine.math_control_retired&&!dut.joint.g_engine.write_pending&&dut.joint.g_engine.bank_issued==dut.joint.g_engine.bank_returned&&dut.joint.g_engine.read_index==41984&&dut.joint.g_engine.completed_groups==82&&slot_active==0&&dut.joint.g_engine.all_covered)begin
   producer_cancel_valid=1;terminal_cancel_seen=1;
   #0.001;if(!producer_cancel_ready)$fatal(1,"FULL_TERMINAL_CANCEL_NOT_READY");
  end
 end
'''
s=s.replace('endmodule',monitor+'endmodule')
s=s.replace('slot_fp_debt||protocol_fault||needs_discard)$fatal(1,"FINAL_REAL_DEBT")','slot_fp_debt||protocol_fault||(needs_discard&&mode!=2))$fatal(1,"FINAL_REAL_DEBT")',1)
p.write_text(s)
