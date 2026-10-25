#!/usr/bin/env python3
"""Only small amax leaf OOC; full engine/array synthesis is not invoked."""
import argparse
import json
from pathlib import Path
import re
import tarfile
from m007_quant_local_run import ROOT,VIV,LOCAL,sha,execute
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--checkpoint',type=Path);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 frozen=a.output/'frozen';frozen.mkdir()
 with tarfile.open(a.output.parent/'sources.tar.gz','r:gz')as archive:archive.extractall(frozen,filter='data')
 script='m007_quant_amax_ooc.tcl';extra=[]
 if a.checkpoint:
  prior=json.loads((a.checkpoint.parent/'report.json').read_text());assert prior['source_sha256']==sha(ROOT/LOCAL/'rtl/laya_m007_quant_amax32_v1.sv')
  script='m007_quant_amax_retime.tcl';extra=[a.checkpoint]
 log=execute([VIV/'vivado','-mode','batch','-source',frozen/LOCAL/'tb'/script,'-tclargs',frozen,a.output,*extra],a.output)
 match=re.search(r'M007_QUANT_AMAX_OOC_COMPLETE blackboxes=0 clock_ns=([\d.]+) wns_ns=(-?[\d.]+)',log);assert match,'no terminal OOC self-check'
 period=float(match[1]);wns=float(match[2]);util=(a.output/'utilization.rpt').read_text();timing=(a.output/'check_timing.rpt').read_text()
 coverage={}
 for item in('no_clock','unconstrained_internal_endpoints','no_input_delay','no_output_delay','partial_input_delay','partial_output_delay','loops','latch_loops'):
  found=re.search(r'checking '+item+r' \((\d+)\)',timing);assert found,item;coverage[item]=int(found[1])
 assert all(value==0 for value in coverage.values()),'timing coverage incomplete '+repr(coverage)
 def metric(label):
  result=re.search(r'\|\s*'+re.escape(label)+r'\s*\|\s*(\d+)\s*\|',util);assert result,label;return int(result[1])
 report={'status':'COMPLETE_HELPER_AMAX_OOC','top':'laya_m007_quant_amax32_v1','part':'xcu55c-fsvh2892-2L-e','clock_ns':period,'io_delays_ns':0.5,
  'wns_ns':wns,'synthesis_timing_verdict':'PASS'if wns>=0 else'FAIL','lut':metric('CLB LUTs*'),'ff':metric('CLB Registers'),
  'blackboxes':0,'timing_coverage':coverage,'checkpoint_reuse':str(a.checkpoint)if a.checkpoint else None,'checkpoint_sha256':sha(a.checkpoint)if a.checkpoint else None,'engine_timing':'NOT_RUN','place_route':'NOT_RUN','board':'NOT_RUN',
  'source_sha256':sha(ROOT/LOCAL/'rtl/laya_m007_quant_amax32_v1.sv'),'xdc_sha256':sha(ROOT/LOCAL/'tb/m007_quant_amax_clock.xdc')}
 (a.output/'report.json').write_text(json.dumps(report,indent=2)+'\n');print('M007_QUANT_AMAX_OOC_RECORDED '+json.dumps(report),flush=True)
if __name__=='__main__':main()
