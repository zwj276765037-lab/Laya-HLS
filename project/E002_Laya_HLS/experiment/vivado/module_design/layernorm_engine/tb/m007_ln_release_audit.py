#!/usr/bin/env python3
"""Final E014 evidence/version audit; no new numerical or EDA experiment."""
import argparse
import hashlib
import json
from pathlib import Path
import sys
import tarfile
import m007_ln_audit as ledger
from m007_ln_guard import RUN,EXPERIMENT,sha
from m007_ln_scalars_run import inventory
def read(path):return json.loads(path.read_text())
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 ats=RUN/'attempts';build=ats/'AT035_ln_gamma_arbitration_build/work';identity=read(build/'source_identity.json')
 assert all(sha(EXPERIMENT/name)==value==sha(build/'frozen'/name)for name,value in identity.items())
 argv=sys.argv[:];sys.argv=[argv[0],'--output',str(a.output/'ledger')];ledger.main();sys.argv=argv;storage=read(a.output/'ledger/report.json')
 assert storage['metadata_and_holding_bits_including_both_scalars']==44761
 frozen=read(build/'snapshot_build_sha256.json')['files'];current=inventory(build);assert all(current.get(k)==v for k,v in frozen.items())
 results={};snapshots={};receipts={}
 successful=('AT003_scalar_rtl','AT006_phase6_dependencies_rtl','AT010_ln_bank_rtl','AT031_ln_compliant_storage_ledger',
  'AT033_ln_four_ctx_finite_stalls','AT037_ln_gamma16_arbitrated_pilot','AT038_ln_gamma_arbitration_reset',
  'AT039_ln_input_error_newgen','AT040_ln_square_error_newgen','AT041_ln_tree_error_newgen','AT042_ln_plain_full128','AT043_ln_gamma_full128')
 for attempt in successful:
  at=ats/attempt;receipt=read(at/'receipt.json');assert receipt['status']=='EXIT_ZERO'
  assert sha(at/'sources.tar.gz')==receipt['source_archive_sha256']
  with tarfile.open(at/'sources.tar.gz')as archive:
   for name,digest in receipt['source_sha256'].items():assert hashlib.sha256(archive.extractfile(name).read()).hexdigest()==digest
  report=read(at/'work/report.json');results[attempt]={'report_sha256':sha(at/'work/report.json'),'report':report}
  receipts[attempt]={'receipt_sha256':sha(at/'receipt.json'),'wall_s':receipt['child_wall_s'],'phase':receipt['phase']}
  if attempt.startswith(('AT037','AT038','AT039','AT040','AT041','AT042','AT043')):
   assert report['source_identity']==identity
   pre_path=at/'work/snapshot_prerun_sha256.json';post_path=at/'work/snapshot_postrun_sha256.json';pre=read(pre_path)['files'];post=read(post_path)['files']
   assert sha(pre_path)==report['snapshot_prerun_sha256']and sha(post_path)==report['snapshot_postrun_sha256']
   assert all(pre.get(k)==v==post.get(k)for k,v in frozen.items())
   extras=sorted(set(post)-set(frozen));assert all(Path(k).name in ('xsimSettings.ini','xsim_script.tcl')for k in extras)
   snapshots[attempt]={'immutable_compiled_files':len(frozen),'compiled_files_unchanged':True,'extra_generated_control_files':extras,
    'actual_pre_post_control_differences':[k for k in sorted(set(pre)|set(post))if pre.get(k)!=post.get(k)]}
 for attempt in ('AT042_ln_plain_full128','AT043_ln_gamma_full128'):
  m=results[attempt]['report']['measurements'];assert m['rows']==128 and m['output_vectors']==4096 and m['tree_nodes']==261888 and m['first_cycles']<=448 and m['done_retired_cycles']<=16704
  for key,limit in (('pass1',128),('pass2',256),('pass3',64),('tree_tail',80),('div1024_with_scheduler',16),('sqrt_with_scheduler',32),('inverse',32)):assert m['stage_max_cycles'][key]<=limit
  assert read(ats/attempt/'work/cost_projection.json')['conservative_full_projection_s']<=120
 for attempt in ('AT039_ln_input_error_newgen','AT040_ln_square_error_newgen','AT041_ln_tree_error_newgen'):
  m=results[attempt]['report']['measurements'];assert m['new_generation_complete_recovery_without_reset']and m['observed_numeric_error']['error_to_done_cycles']<=128
 assert results['AT038_ln_gamma_arbitration_reset']['report']['measurements']['coefficient_begin_command_arbitration']
 stall=results['AT033_ln_four_ctx_finite_stalls']['report']['measurements'];assert stall['max_contexts']==4 and stall['held_output_cycles']>=1800 and stall['peak_mul_pending']<64
 # Reuse exactly the previously tested active flow. Only idle coefficient
 # admission changed; the stall fixture finishes gamma loading before cmd.
 old=(ats/'AT030_ln_final_guard_build/work/frozen/vivado/module_design/layernorm_engine/rtl/laya_m007_layernorm32_v1.sv').read_text()
 expected=old.replace('assign gamma_ready=rst_n&&gamma_loading','assign gamma_ready=rst_n&&!active&&gamma_loading').replace('cmd_ready=rst_n&&!active&&!done_valid&&cmd_rows','cmd_ready=rst_n&&!active&&!done_valid&&!gamma_loading&&!gamma_begin_valid&&cmd_rows')
 new=EXPERIMENT/'vivado/module_design/layernorm_engine/rtl/laya_m007_layernorm32_v1.sv';assert expected==new.read_text()
 ooc={}
 for attempt in ('AT044_ln_sqrt_only_io_ooc','AT045_ln_div1024_io_ooc'):
  at=ats/attempt;receipt=read(at/'receipt.json');assert receipt['status']in ('EXIT_ZERO','COST_STOP')
  if receipt['status']=='EXIT_ZERO':
   report=read(at/'work/report.json')
   for leaf in report['leaves'].values():assert leaf['all_IO_and_internal_constraint_checks_zero']and leaf['source_sha256']==identity['vivado/module_design/layernorm_engine/rtl/laya_m007_ln_scalars_v1.sv']
   ooc[attempt]={'guard_status':receipt['status'],'report_sha256':sha(at/'work/report.json'),'report':report}
  else:ooc[attempt]={'guard_status':'COST_STOP','leaf_complete':'NOT_VERIFIED','receipt_sha256':sha(at/'receipt.json')}
 measured={key:0.0 for key in ('reference','static','rtl','ooc')};attempt_costs={}
 for path in sorted(ats.glob('AT*/receipt.json')):
  r=read(path);measured[r['phase']]+=r['child_wall_s'];attempt_costs[path.parent.name]={'phase':r['phase'],'measured_wall_s':r['child_wall_s'],'status':r['status']}
 result={'status':'SUPPORTED_STRICT_LN_FULL128_FUNCTIONAL_AND_PROTOCOL','engine_sha256':sha(new),'compiled_source_identity':identity,'storage':storage,
  'results':results,'immutable_snapshot_checks':snapshots,'actual_runtime_receipts':receipts,'small_scalar_OOC':ooc,
  'budget_measured_before_current_audit_receipt_finalized_s':measured,'attempt_costs_before_current_audit_finalization':attempt_costs,
  'unknown_actual_wall':['AT018_ln_done_barrier_build'],'independent_conservative_budget_debit_s':{'static':120},'budget_adjustment_sha256':sha(RUN/'budget_adjustments.json'),
  'process_guard_counterexamples':{'report_sha256':sha(RUN/'process_guard_selftest.json'),'report':read(RUN/'process_guard_selftest.json')},
  'reused_stall_version_boundary':'AT033 engine a0975679 differs only by two idle coefficient-admission gates; active dataflow byte-equivalent after fully loaded gamma. Normal/current error/reset/full128 use2799427b.',
  'retirement_measurement':'Actual done_valid/ready handshake including deliberately held done; done available recorded separately; phase release after actual retirement and real debts zero.',
  'limitations':['No full LN synthesis/OOC/P&R/board timing','No parent phase physical sharing, LN→quant→matrix or60 LN invocations','Local observed numeric tuple and drain only; original16-row-tile/all-model first error order unverified',
   'AT018 monitor incident/UNKNOWN actual cost, AT020 overlap, AT022 harness lock-race failure and AT036 batch COST_STOP/incomplete IO constraints retained.']}
 destination=RUN/'release_evidence_v1.json';assert not destination.exists()
 destination.write_text(json.dumps(result,indent=2)+'\n');(a.output/'report.json').write_text(json.dumps(result,indent=2)+'\n')
 print('M007_LN_RELEASE_EVIDENCE_PASS full_cases=2 metadata_bits=44761 output_F32_per_case=131072 tree_nodes_per_case=261888',flush=True)
if __name__=='__main__':main()
