#!/usr/bin/env python3
"""Generate new v3 only, preserving every frozen v2 non-process byte and statement."""
from pathlib import Path
import hashlib,json,re
HERE=Path(__file__).resolve().parent;MODULE=HERE.parent
CORE_SHA='13df84ea5dc06ece43a3d83b8af2d778fcd3b9bd1bda78e831d0e35ffd53dd10'
WRAPPER_SHA='8c37896cbc20d0cf20b024cb39a771bb39b19aea5ad60f7434bef34d7ebdf248'

def transform(old):
 lines=old.splitlines(keepends=True);data=[];base=[];valid=None
 for line in lines:
  if not re.match(r'\s*always\b',line):base.append(line);continue
  match=re.fullmatch(r'\s*always @\(posedge clk\) if\(core_ce\) (\w+) <= (.+);\n',line)
  if match:data.append((match[1],match[2]));continue
  assert line.strip()=='always @(posedge clk)if(reset)valid_pipe<=0;else if(core_ce)valid_pipe<={valid_pipe[150:0],in_valid};'
  assert valid is None;valid=line.strip().split(')',1)[1]
 assert len(data)==2446 and len({x[0]for x in data})==2446 and valid
 merged=' always @(posedge clk) begin\n  if(reset) valid_pipe<=0;\n  else if(core_ce) valid_pipe<={valid_pipe[150:0],in_valid};\n  if(core_ce) begin\n'+''.join('   '+target+' <= '+expr+';\n'for target,expr in data)+'  end\n end\n'
 result=''.join(base).replace('laya_m007_tanh_core_v2','laya_m007_tanh_core_v3')
 result=result.replace('endmodule',merged+'endmodule')
 return result,data,merged

def main():
 rtl=MODULE/'rtl';old=(rtl/'laya_m007_tanh_core_v2.sv').read_text();wrapper=(rtl/'laya_m007_tanh8_v2.sv').read_text()
 assert hashlib.sha256(old.encode()).hexdigest()==CORE_SHA and hashlib.sha256(wrapper.encode()).hexdigest()==WRAPPER_SHA
 new,data,merged=transform(old)
 (rtl/'laya_m007_tanh_core_v3.sv').write_text(new)
 (rtl/'laya_m007_tanh8_v3.sv').write_text(wrapper.replace('laya_m007_tanh8_v2','laya_m007_tanh8_v3').replace('laya_m007_tanh_core_v2','laya_m007_tanh_core_v3'))
 text=(HERE/'m007_tanh_ce_tb.sv').read_text().replace('module m007_tanh_ce_tb;', '''`ifdef TANH_V3
 `define TANH_PRIMARY laya_m007_tanh8_v3
`else
 `define TANH_PRIMARY laya_m007_tanh8_v2
`endif
`ifdef TANH_EQ
 `define TANH_OBSERVER auto_dut
`else
 `define TANH_OBSERVER dut
`endif
module m007_tanh_process_tb;''')
 text=text.replace(' laya_m007_tanh8_v1 dut(', ' `TANH_PRIMARY dut(')
 start=text.index(' laya_m007_tanh8_v2 #(.FORCE_CORE_CE(1)) forced_dut(')
 end=text.index(' laya_m007_tanh8_v2 #(.FORCE_CORE_CE(0)) auto_dut(',start)
 text=text[:start]+'`ifdef TANH_EQ\n'+text[end:]
 text=text.replace('laya_m007_tanh8_v2 #(.FORCE_CORE_CE(0)) auto_dut(', 'laya_m007_tanh8_v3 #(.FORCE_CORE_CE(0)) auto_dut(')
 marker='\n task automatic idle_noise'
 pos=text.index(marker)
 alias='''
`else
 assign {ce_lease_ready[1],ce_release_ready[1],ce_active[1],ce_draining[1],ce_ir[1],ce_ov[1],ce_reject[1],ce_reject_code[1],ce_fault[1],ce_pending[1],ce_flight[1],ce_rrid[1],ce_gen[1],ce_epoch[1],ce_phase[1],ce_y[1],ce_status[1],ce_tag[1],ce_mask[1]}=
 {lease_ready,release_ready,active,draining,ir,ov,reject_valid,reject_code,fault,pending,flight,rrid,rgen,repoch,rphase,y,status,ot,om};
`endif
 int secondary_node_checks=0;
 task automatic cost_mark(input string stage_name);
  $display("TANH_PROCESS_STAGE stage=%s cycle=%0d",stage_name,wall);$fflush();
 endtask
'''
 text=text[:pos]+alias+text[pos:]
 text=text.replace('auto_dut.','`TANH_OBSERVER.')
 text=text.replace('||\n      dut.tanh_lane[lane].core.valid_pipe!==forced_dut.tanh_lane[lane].core.valid_pipe','')
 text=text.replace('   if(!forced_dut.core_ce)$fatal(1,"CE_FORCED_ONE");\n','')
 text=text.replace('for(int variant=0;variant<2;variant++)','for(int variant=1;variant<2;variant++)')
 text=text.replace(' task automatic idle_noise(input int clocks);\n',' task automatic idle_noise(input int clocks);\n  cost_mark("IDLE");\n')
 text=text.replace('  end\n endtask\n for(genvar lane=0;lane<8;lane++)begin:ce_token_monitor','  end\n  cost_mark("RUN");\n endtask\n for(genvar lane=0;lane<8;lane++)begin:ce_token_monitor')
 text=text.replace(' initial begin\n  if(!$value$plusargs',' initial begin\n  cost_mark("INIT");\n  if(!$value$plusargs')
 text=text.replace('if(!progress_fd)$fatal(1,"PROGRESS_OPEN");','if(!progress_fd)$fatal(1,"PROGRESS_OPEN");cost_mark("RUN");')
 text=text.replace('"TANH_CE_EQUIVALENCE_PASS ', '"TANH_PROCESS_WORKLOAD_PASS ')
 text=text.replace('  if(fault||pending||flight||checked!=count+2630)', '''`ifdef TANH_EQ
  if(secondary_node_checks!=node_checks)$fatal(1,"SECONDARY_NODE_COUNTS primary=%0d secondary=%0d",node_checks,secondary_node_checks);
  $display("TANH_PROCESS_SAME_RUNTIME_PASS secondary_node_checks=%0d",secondary_node_checks);
`endif
  if(fault||pending||flight||checked!=count+2630)''')
 text=text.replace('release_external_debt=1",checked,node_checks,first_latency,peak_pending,peak_flight,held_cycles,rejections);$finish;', 'release_external_debt=1",checked,node_checks,first_latency,peak_pending,peak_flight,held_cycles,rejections);cost_mark("DONE");$finish;')
 text=text.replace('m007_tanh8_node_checks.svh','m007_tanh_process_nodes.svh')
 # Same-input same-cycle trace allows separate snapshots to be compared independently.
 text=text.replace('string vf,nf,pf;integer progress_fd;', 'string vf,nf,pf,trace_path;integer progress_fd,trace_fd;')
 text=text.replace('cost_mark("INIT");', 'cost_mark("INIT");if(!$value$plusargs("TRACE_FILE=%s",trace_path))$fatal(1,"TRACE_REQUIRED");trace_fd=$fopen(trace_path,"w");if(!trace_fd)$fatal(1,"TRACE_OPEN");')
 text=text.replace('   if(ov&&ready)begin\n', '   if(ov&&ready)begin\n    $fdisplay(trace_fd,"%0d %0d %h %h %h %h %h %h %h %h",wall,phase,y,status,ot,om,rrid,rgen,repoch,rphase);\n')
 text=text.replace('cost_mark("DONE");$finish;', 'cost_mark("DONE");$fclose(trace_fd);$finish;')
 (HERE/'m007_tanh_process_tb.sv').write_text(text)
 print(json.dumps({'generated':'v3 core/wrapper and common eq/single-cost TB','core_v3_sha256':hashlib.sha256(new.encode()).hexdigest(),'data_targets':len(data),'new_core_processes':1,'old_sources_modified':False}))
if __name__=='__main__':main()
