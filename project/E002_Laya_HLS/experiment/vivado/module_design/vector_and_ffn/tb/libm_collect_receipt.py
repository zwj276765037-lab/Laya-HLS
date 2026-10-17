#!/usr/bin/env python3
"""Collect completed module runs without creating or changing their gold."""
import hashlib
import json
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

attempt=Path(sys.argv[1]).resolve()
kind=sys.argv[2]
top='tanh_libm_leaf' if kind=='tanh' else 'geglu_libm_leaf'
wrapper='tanh_libm_wrapper' if kind=='tanh' else 'geglu_row_wrapper'
def ident(path):
 path=Path(path); data=path.read_bytes()
 return {'path':str(path.resolve()),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()}
def dump(name,value):
 (attempt/name).write_text(json.dumps(value,indent=2,sort_keys=True)+'\n')
guards={}
for directory in sorted(attempt.glob('guard_*')):
 f=directory/'guard_result.json'
 if f.exists():
  guards[directory.name]=json.loads(f.read_text())
  assert guards[directory.name]['child_exit_code']==0 and guards[directory.name]['trigger'] is None
xml=ET.parse(attempt/f'hls_project/solution1/syn/report/{top}_csynth.xml').getroot()
hls={}
for key,tag in [('latency_min','Best-caseLatency'),('latency_max','Worst-caseLatency'),('interval_min','Interval-min'),('interval_max','Interval-max')]:
 hls[key]=int(xml.find(f'.//SummaryOfOverallLatency/{tag}').text)
for tag in ('DSP','FF','LUT','BRAM_18K','URAM'):
 hls['estimated_'+tag.lower()]=int(xml.find(f'.//AreaEstimates/Resources/{tag}').text)
for op in ('add','mul','div'):
 x=ET.parse(attempt/f'hls_project/solution1/syn/report/fp_{op}_bits_csynth.xml').getroot()
 hls[op+'_latency_max']=int(x.find('.//SummaryOfOverallLatency/Worst-caseLatency').text)
hier=(attempt/'ooc/utilization_hierarchical.rpt').read_text()
rows=[]
for line in hier.splitlines():
 fields=[x.strip() for x in line.split('|')[1:-1]]
 if len(fields)==11 and fields[0]==wrapper:
  vals=list(map(int,fields[2:])); resources=dict(lut=vals[0],ff=vals[4],bram36=vals[5],bram18=vals[6],uram=vals[7],dsp=vals[8])
 if len(fields)==11 and fields[0].startswith('grp_fp_'):
  vals=list(map(int,fields[2:])); rows.append({'instance':fields[0],'module':fields[1],'lut':vals[0],'ff':vals[4],'dsp':vals[8]})
assert len(rows)==3
timing=(attempt/'ooc/timing_summary.rpt').read_text()
wns=re.search(r'WNS\(ns\).*?\n\s*-.*?\n\s*([\d.-]+)\s+([\d.-]+)',timing,re.S)
assert wns
log=(attempt/'guard_ooc_01/driver.log').read_text()
assert 'VIVADO_OOC_PASS blackboxes=0' in log
warn=[line for line in log.splitlines() if line.startswith('WARNING:')]
errors=[line for line in log.splitlines() if line.startswith(('ERROR:','CRITICAL WARNING:'))]
assert not errors
rtl=(attempt/'rtl_run/xsim.log').read_text()
cpu=(attempt/'guard_cpu_01/driver.log').read_text()
receipt={'schema':'laya-libm-module-actual-synthesis-v2','kind':kind,
 'status':'CPU_RTL_ACTUAL_OOC_COMPLETE_PENDING_POST_SYNTHESIS_ASSESSMENT',
 'scope':'standalone tanhf service' if kind=='tanh' else 'complete Wi5248 -> GEGLU2624 checkpoint replay with actual production arithmetic',
 'hls':hls,'ooc':{'top':wrapper,'part':'xcu55c-fsvh2892-2L-e','clock_period_ns':6.667,'configuration':'out_of_context flatten_hierarchy none RuntimeOptimized resource_sharing off',**resources,'helper_instances':rows,'blackboxes':0,'setup_wns_ns':float(wns.group(1)),'setup_tns_ns':float(wns.group(2)),'warning_count':len(warn),'warning_lines':warn,'error_count':0,'stage':'synthesized only; no place/route, interface timing, achieved Fmax, board or full-net claim','dcp':ident(attempt/f'ooc/{wrapper}_synth.dcp')},
 'numeric_rules':'separate binary32 RNE operations, subnormal and signed-zero preserved; no FMA, FTZ, reassociation or approximate inverse',
 'guards':guards,'cpu_pass_lines':[x for x in cpu.splitlines() if 'PASS' in x],
 'rtl_pass_lines':[x for x in rtl.splitlines() if any(s in x for s in ('PROFILE_PASS','BRANCH','RTL_PASS'))],
 'source_manifest':ident(attempt/'source_manifest.json')}
if kind=='tanh':
 assert 'ADD_BOUNDARY_DIRECTED_RTL_PASS count=345' in rtl
 assert 'TANH_LIBM_RTL_PASS count=3270' in rtl
 baseline=attempt.parent/'tanh_libm_round1_02'
 old=(baseline/'cpu/add_directed.mem').read_bytes()
 new=(attempt/'cpu/add_directed.mem').read_bytes()
 assert new[:len(old)]==old
 receipt['directed_add']={'count':345,'unchanged_original_count':52,'gold':'independent native volatile float FE_TONEAREST','original_prefix_unchanged':True,'mem':ident(attempt/'cpu/add_directed.mem')}
 profiles=[]
 for match in re.finditer(r'TANH_PROFILE_PASS mode=(\d+) count=(\d+) first_accept=(\d+) last_retire=(\d+) span=(\d+) min_accept_gap=(\d+) max_accept_gap=(\d+)',rtl):
  profiles.append(dict(zip(('mode','count','first_accept','last_retire','span_cycles','min_accept_gap','max_accept_gap'),map(int,match.groups()))))
 oldrec=json.loads((baseline/'receipt.json').read_text())
 receipt['profiles']=profiles
 receipt['same_configuration_baseline']=ident(baseline/'receipt.json')
 receipt['normal_span_improvement_fraction']=1-profiles[0]['span_cycles']/oldrec['rtl']['profiles'][0]['span_cycles']
else:
 assert 'GEGLU_ROW_RTL_PASS full_profiles=2' in rtl
 receipt['full_step_comparisons']=52480
 receipt['full_output_comparisons']=5248
 receipt['production_source_dependencies']=[ident(attempt/'frozen_source'/n) for n in ('vector_full_compute.cpp','vector_libm_bits.cpp','full_tasks_vector.cpp','gelu_libm_bits.cpp','gelu_libm_bits.h','tanh_libm_bits.cpp','tanh_libm_bits.h')]
files=[attempt/'source_manifest.json',*sorted((attempt/'frozen_source').glob('*')),*sorted((attempt/'fixture').glob('*')),
 *sorted((attempt/'hls_project/solution1/syn/verilog').glob('*.v')),*sorted((attempt/'hls_project/solution1/syn/report').glob('*csynth*')),
 *sorted((attempt/'ooc').glob('*.rpt')),attempt/f'ooc/{wrapper}_synth.dcp',attempt/'rtl_run/xsim.log']
for g in sorted(attempt.glob('guard_*')):
 files+=sorted(g.glob('*'))
files+=[f for f in (attempt/'static').glob('*') if f.is_file() and f.suffix in ('.log','.sv')]
if kind=='tanh': files.append(attempt/'cpu/add_directed.mem')
dump('evidence_manifest.json',{'schema':'laya-actual-module-evidence-v2','files':[ident(f) for f in files if f.is_file()]})
receipt['evidence_manifest']=ident(attempt/'evidence_manifest.json')
dump('receipt.json',receipt)
print(json.dumps({'receipt':ident(attempt/'receipt.json'),'ooc':resources,'wns_ns':float(wns.group(1))}))
