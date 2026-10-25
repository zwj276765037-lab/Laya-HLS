#!/usr/bin/env python3
"""Invoked only inside the E015 guard; all EDA uses frozen input RTL."""
import argparse,hashlib,json,re,subprocess,tarfile
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1];ROOT=MODULE.parents[5]
LOCAL=MODULE.relative_to(ROOT);VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
E008=ROOT/'project/E008_m007_strict_fp_shared_service/experiment_results/runs/R001/attempts'
FIXTURES=('AT001_native_reference_pilot','AT015_strict_mul_native_reference','AT010_direct_div_reference')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def execute(cmd,cwd):
 print('COMMAND',*[str(x)for x in cmd],flush=True);subprocess.run([str(x)for x in cmd],cwd=cwd,check=True)
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=('build','rtl','ooc'));p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);p.add_argument('--vectors',type=Path);p.add_argument('--op',type=int,default=0);p.add_argument('--variant',choices=('original','addz','addo','adde','divr4'),default='original');a=p.parse_args()
 a.output.mkdir(parents=True,exist_ok=False);frozen=a.output/'frozen';frozen.mkdir()
 with tarfile.open(a.output.parent/'sources.tar.gz')as arc:arc.extractall(frozen,filter='data')
 rtl=frozen/LOCAL/'rtl/laya_m007_tanh_fast_leaves_v1.sv';tb=frozen/LOCAL/'tb/m007_tanh_leaf_tb.sv';extras=[]
 if a.variant!='original':
  name={'addz':'laya_m007_tanh_add3_z_v1','addo':'laya_m007_tanh_add3_o_v1','adde':'laya_m007_tanh_add3_e_v1','divr4':'laya_m007_tanh_div12_r4_v1'}[a.variant];extras=[frozen/LOCAL/'rtl'/(name+'.sv')]
  text=tb.read_text().replace('laya_m007_tanh_add3_v1'if a.variant.startswith('add')else'laya_m007_tanh_div12_v1',name);tb=a.output/'variant_tb.sv';tb.write_text(text)
 if a.stage=='build':
  execute([VIV/'xvlog','--sv',rtl,*extras,tb],a.output)
  execute([VIV/'xelab','work.m007_tanh_leaf_tb','--relax','-mt','4','--O3','-s','tanh_fast_leaf_sim'],a.output)
  save(a.output/'report.json',{'status':'BUILD_COMPLETE','variant':a.variant,'selected_implementation':name if extras else 'original fast leaf modules','selected_rtl_sha256':sha(extras[0])if extras else sha(rtl),'extra_sha256':[sha(x)for x in extras],'rtl_sha256':sha(rtl),'tb_sha256':sha(tb),'snapshot':{str(x.relative_to(a.output)):sha(x)for x in(a.output/'xsim.dir').rglob('*')if x.is_file()}})
 elif a.stage=='rtl':
  b=a.build;manifest=json.loads((b/'report.json').read_text());assert manifest['rtl_sha256']==sha(rtl)and manifest['tb_sha256']==sha(tb),'build/source mismatch'
  assert manifest.get('variant','original')==a.variant and manifest.get('extra_sha256',[])==[sha(x)for x in extras],'variant/source mismatch'
  for path,digest in manifest['snapshot'].items():assert sha(b/path)==digest,'snapshot mismatch'
  fixture=a.vectors or E008/FIXTURES[a.op]/'work/vectors.hex';count=sum(1 for _ in fixture.open());identity={'path':str(fixture.relative_to(ROOT)),'sha256':sha(fixture),'bytes':fixture.stat().st_size,'count':count,'independent_reference':'independent native SSE F32 FE_TONEAREST, FTZ/DAZ off; fixture_record identifies E008 or focused boundary generator','fixture_record':json.loads((fixture.parents[1]/'fixture_identity.json').read_text())}
  assert identity['sha256']==identity['fixture_record']['sha256'];save(a.output/'input_identity.json',identity)
  execute([VIV/'xsim','tanh_fast_leaf_sim','-runall','-testplusarg','OP='+str(a.op),'-testplusarg','COUNT='+str(count),'-testplusarg','VECTORS='+str(fixture)],b)
  log=(b/'xsim.log').read_text();assert 'HARDWARE_AGENT_SIM_PASS TANH_FAST_LEAF'in log and not re.search(r'(?im)^\s*(?:Fatal|ERROR):',log)
  save(a.output/'report.json',{'status':'PASS','op':('add3','mul4','div12')[a.op],'variant':a.variant,'selected_implementation':name if extras else 'original fast leaf modules','selected_rtl_sha256':sha(extras[0])if extras else sha(rtl),'independent_vectors':count,'original_independent_vectors':count if not a.vectors else None,'CE_held_cycles':36,'reset_actual_inflight_discard':2,'post_reset_paired_valid_outputs':45,'rtl_sha256':sha(rtl),'tb_sha256':sha(tb),'xsim_log_sha256':sha(b/'xsim.log'),'snapshot_source':str(b)})
  (a.output/'xsim.log').write_text(log)
 else:
  top=('laya_m007_tanh_add3_v1','laya_m007_tanh_mul4_v1','laya_m007_tanh_div12_v1')[a.op]if a.variant=='original'else name
  xdc=a.output/'leaf.xdc';xdc.write_text('create_clock -name core -period 3.333333 [get_ports aclk]\nset_clock_uncertainty 0.100 [get_clocks core]\nset_input_delay -clock core 0.500 [get_ports -filter {DIRECTION == IN && NAME != aclk}]\nset_output_delay -clock core 0.500 [all_outputs]\n')
  tcl=a.output/'run.tcl';tcl.write_text(f'''set_param general.maxThreads 4
read_verilog -sv {{{rtl}}}
{''.join('read_verilog -sv {'+str(x)+'}\n'for x in extras)}
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
close $f
if {{[llength $blackboxes] != 0}} {{error "blackboxes present"}}
write_checkpoint -force leaf.dcp
exit
''')
  execute([VIV/'vivado','-mode','batch','-source',tcl],a.output)
  assert 'blackboxes=0'in(a.output/'status.txt').read_text()
  coverage=(a.output/'check_timing.rpt').read_text()
  for check in('no_clock','unconstrained_internal_endpoints','no_input_delay','no_output_delay'):assert re.search(r'checking '+check+r' \(0\)',coverage),check
  timing=(a.output/'timing_summary.rpt').read_text().split('| Design Timing Summary',1)[1]
  m=re.search(r'^\s*(-?\d+\.\d+)\s+(-?\d+\.\d+)\s+(\d+)\s+(\d+)\s+(-?\d+\.\d+)\s+(-?\d+\.\d+)\s+(\d+)\s+(\d+)',timing,re.M);assert m
  util=(a.output/'utilization.rpt').read_text();resources={}
  for key,label in(('LUT','CLB LUTs\\*?'),('FF','CLB Registers'),('DSP','DSPs'),('latches','Register as Latch')):
   metric=re.search(r'\|\s*'+label+r'\s*\|\s*(\d+)',util);assert metric,label;resources[key]=int(metric[1])
  save(a.output/'report.json',{'status':'SYNTHESIS_OPT_COMPLETE','top':top,'variant':a.variant,'selected_rtl_sha256':sha(extras[0])if extras else sha(rtl),'read_verilog_sources_sha256':{str(x.relative_to(frozen)):sha(x)for x in[rtl,*extras]},'rtl_sha256':sha(rtl),'xdc_sha256':sha(xdc),'tcl_sha256':sha(tcl),'part':'xcu55c-fsvh2892-2L-e','requested_period_ns':3.333333,'effective_period_ns':3.333,'resources':resources,'WNS_ns':float(m[1]),'TNS_ns':float(m[2]),'setup_failing_endpoints':int(m[3]),'WHS_ns':float(m[5]),'THS_ns':float(m[6]),'hold_failing_endpoints':int(m[7]),'blackboxes':0,'constraint_coverage_zero_missing':True,'checkpoint_sha256':sha(a.output/'leaf.dcp'),'physical_PnR':'NOT_RUN'})
if __name__=='__main__':main()
