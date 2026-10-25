#!/usr/bin/env python3
"""Only the two authorized small scalar leaves, with complete IO constraints."""
import argparse
from datetime import datetime,timezone
import json
from pathlib import Path
import re
import tarfile
from m007_ln_scalars_run import VIV,LOCAL,execute,save,sha
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--leaf',choices=('div1024','sqrt','both'),required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 frozen=a.output/'frozen';frozen.mkdir()
 with tarfile.open(a.output.parent/'sources.tar.gz','r:gz')as archive:archive.extractall(frozen,filter='data')
 source=frozen/LOCAL/'rtl/laya_m007_ln_scalars_v1.sv';results={}
 tops=('laya_m007_ln_div1024_v1','laya_m007_ln_sqrt_v1')if a.leaf=='both'else('laya_m007_ln_'+a.leaf+'_v1',)
 for top in tops:
  work=a.output/top;work.mkdir();xdc=work/'leaf.xdc';xdc.write_text('create_clock -name core -period 3.333333 [get_ports clk]\nset_clock_uncertainty 0.100 [get_clocks core]\nset_input_delay -clock core 0.500 [get_ports -filter {DIRECTION == IN && NAME != clk}]\nset_output_delay -clock core 0.500 [all_outputs]\n')
  script=work/'run.tcl';script.write_text(f'''set_param general.maxThreads 4
read_verilog -sv {{{source}}}
read_xdc {{{xdc}}}
synth_design -top {top} -part xcu55c-fsvh2892-2L-e -mode out_of_context
opt_design
report_utilization -file utilization.rpt
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -file timing_summary.rpt
check_timing -verbose -file check_timing.rpt
report_timing -max_paths 10 -file timing.rpt
set blackboxes [get_cells -hier -filter {{IS_BLACKBOX == 1}}]
set f [open status.txt w]
puts $f "blackboxes=[llength $blackboxes]"
puts $f "input_ports=[llength [all_inputs]] output_ports=[llength [all_outputs]]"
close $f
if {{[llength $blackboxes] != 0}} {{error "blackboxes present"}}
write_checkpoint -force leaf.dcp
exit
''')
  execute([VIV/'vivado','-mode','batch','-source',script],work)
  status=(work/'status.txt').read_text();assert 'blackboxes=0'in status
  coverage=(work/'check_timing.rpt').read_text()
  for check in ('no_clock','unconstrained_internal_endpoints','no_input_delay','no_output_delay'):
   assert re.search(r'checking '+check+r' \(0\)',coverage),check+' coverage missing'
  timing=(work/'timing_summary.rpt').read_text().split('| Design Timing Summary',1)[1]
  metrics=re.search(r'^\s*(-?\d+\.\d+)\s+(-?\d+\.\d+)\s+(\d+)\s+(\d+)\s+(-?\d+\.\d+)\s+(-?\d+\.\d+)\s+(\d+)\s+(\d+)',timing,re.M);assert metrics
  utilization=(work/'utilization.rpt').read_text();resources={}
  for key,label in (('LUT','CLB LUTs\\*?'),('FF','CLB Registers'),('DSP','DSPs'),('latches','Register as Latch')):
   match=re.search(r'\|\s*'+label+r'\s*\|\s*(\d+)',utilization);assert match,label;resources[key]=int(match[1])
  results[top]={'source_sha256':sha(source),'xdc_sha256':sha(xdc),'tcl_sha256':sha(script),'status':status.strip(),
   'resources':resources,'WNS_ns':float(metrics[1]),'TNS_ns':float(metrics[2]),'setup_failing_endpoints':int(metrics[3]),'setup_total_endpoints':int(metrics[4]),
   'WHS_ns':float(metrics[5]),'THS_ns':float(metrics[6]),'hold_failing_endpoints':int(metrics[7]),'hold_total_endpoints':int(metrics[8]),'all_IO_and_internal_constraint_checks_zero':True,
   'utilization_report_sha256':sha(work/'utilization.rpt'),'timing_report_sha256':sha(work/'timing_summary.rpt'),'constraint_coverage_sha256':sha(work/'check_timing.rpt'),'checkpoint_sha256':sha(work/'leaf.dcp')}
  save(a.output/'partial_report.json',{'status':'COMPLETED_SELECTED_LEAVES','leaves':results})
 save(a.output/'report.json',{'status':'COMPLETE_SMALL_SCALAR_SYNTHESIS_OOC','part':'xcu55c-fsvh2892-2L-e','requested_clock_period_ns':3.333333,'effective_tool_period_ns':3.333,'stage':'synthesis+opt only, no placement/routing','leaves':results,'captured_utc':datetime.now(timezone.utc).isoformat(),'whole_LN_timing':'NOT_RUN'})
if __name__=='__main__':main()
