#!/usr/bin/env python3
"""Bounded source preparation/inverse check only for kind6 public BEGIN fields."""
from pathlib import Path
import argparse, ctypes, difflib, hashlib, json, os, resource, shutil, subprocess, sys, time


def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d): p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(d,indent=2)+'\n')


def main():
 start=time.monotonic();ap=argparse.ArgumentParser();ap.add_argument('--root',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();root=a.root.resolve();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
 resource.setrlimit(resource.RLIMIT_AS,(1024**3,1024**3));affinity=sorted(os.sched_getaffinity(0));nice=os.getpriority(os.PRIO_PROCESS,0);io=ctypes.CDLL(None).syscall(252,1,0);available=int(next(x.split()[1]for x in Path('/proc/meminfo').read_text().splitlines()if x.startswith('MemAvailable:')));assert affinity and set(affinity)<=set(range(4))and nice==19 and io>>13==3 and available>192*1024*1024
 r=root/'project/E016_m007_single_resource_parent/experiment_results/runs/R007';s=root/'project/E016_m007_single_resource_parent/experiment_source';tb=root/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/tb';old=r/'prepared/fullgraph_retire_progress_v3/frozen/m007_fullgraph_binary_tb.sv';live=tb/'m007_fullgraph_binary_tb.sv';previous_manifest=r/'prepared/binary_peer_posedge_unrolled_v2/source_manifest.json';prep=r/'prepared/fullgraph_kind6_public_abi_v4';f=prep/'frozen';f.mkdir(parents=True,exist_ok=False)
 assert sha(old)==sha(live)=='8b556ca2b32f2a41f7ca1d259d5f7c714a8dd473d131e8949f6dcabd1a3ea570'
 generator=s/'prepare_fullgraph_binary_checker_r007.py';proc=subprocess.run([sys.executable,str(generator)],cwd=root,text=True,capture_output=True,check=True);report=json.loads(proc.stdout);assert report['revision']==4
 before=old.read_text();after=live.read_text()
 old_line="  cmd_kind=3'(kind_run);cmd_layer=kind_run==7?0:5'(decision_local);cmd_qtype=2;cmd_marker_rows=0;cmd_marker_rows[0]=23;cmd_marker_rows[1]=33;cmd_marker_mask=16'h0003;cmd_candidate_count=2;\n"
 kind7="cmd_qtype=2;cmd_marker_rows=0;cmd_marker_rows[0]=23;cmd_marker_rows[1]=33;cmd_marker_mask=16'h0003;cmd_candidate_count=2;"
 kind6="cmd_qtype=0;cmd_marker_rows=0;cmd_marker_mask=0;cmd_candidate_count=0;"
 new_lines="  cmd_kind=3'(kind_run);cmd_layer=kind_run==7?0:5'(decision_local);\n  if(kind_run==7)begin "+kind7+"end\n  else begin "+kind6+"end\n"
 assert before.count(old_line)==1 and after.count(new_lines)==1 and after.replace(new_lines,old_line,1)==before
 assert old_line.endswith(kind7+'\n') and not any(x in new_lines for x in ['@','#','$','<='])
 # Independently check the existing public validation contract, not a new ABI.
 parent=root/'project/E016_m007_single_resource_parent/experiment_results/runs/R007/prepared/fullgraph_kind6_kind7_public_boundary_v2/frozen/laya_m007_single_parent_v3.sv';parent_text=parent.read_text();assert 'if(cmd_qtype!=0||cmd_marker_mask!=0||cmd_candidate_count!=0)'in parent_text and 'if(cmd_marker_rows[j]!=0)'in parent_text
 assert sha(tb/'m007_fullmodel_encoder_1d_tb.sv')=='505e0b93652303b2f12049325ea3b4a9d434d9452a8795e634b91ace969f9327' and sha(tb/'m007_fullmodel_encoder_binary_tb.sv')=='8a4a3956cff9289c026d16d1e1d7405d00393dc42ad586e62d4fdbb5624c4f8a'
 assert sha(tb/'m007_binary_weight_peer_tb.sv')=='f4d1c00d2f8da967681fd01fe393a82e7dfbd04b1ce30c650b1739ba9df75372'
 frozen=f/live.name;shutil.copy2(live,frozen)
 for p in [generator,s/'fullgraph_binary_checker_r007.svpart',Path(__file__),r/'fullgraph_binary_checker_source_preparation_v4.json']:shutil.copy2(p,f/p.name)
 patch=r/'fullgraph_kind6_public_abi_v4.patch';patch.write_text(''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile=str(old.relative_to(root)),tofile=str(frozen.relative_to(root)))))
 previous=json.loads(previous_manifest.read_text());rows=[];changed=0
 for row in previous['compile_sources']:
  assert sha(root/row['path'])==row['sha256'],row['path']
  if row['path']==str(old.relative_to(root)):rows.append({'path':str(frozen.relative_to(root)),'sha256':sha(frozen)});changed+=1
  else:rows.append(row)
 assert changed==1 and len(rows)==94
 for row in previous['ROM_initialization_files']:assert sha(root/row['path'])==row['sha256']
 binding=json.loads((r/'fullgraph_original_input_binding.json').read_text());checked=[]
 for key in ['kind6_Decision0_public_H','kind6_Decision1_public_H','checkpoint_gold']:
  row=binding['products'][key];assert sha(root/row['path'])==row['sha256'];checked.append(row)
 manifest={'schema':'m007-r007-kind6-public-begin-abi-v4','status':'SOURCE_FROZEN_STATIC_INVERSE_PASS_NOT_COMPILED_NOT_RUN','top':'m007_fullgraph_binary_tb','source':str(frozen.relative_to(root)),'sha256':sha(frozen),'previous_frozen_source':str(old.relative_to(root)),'previous_sha256':sha(old),'previous_source_manifest':str(previous_manifest.relative_to(root)),'previous_source_manifest_sha256':sha(previous_manifest),'compile_sources':rows,'compile_source_count':94,'ROM_initialization_files':previous['ROM_initialization_files'],'unchanged_compile_source_records':93,'only_change':'Kind7 retains original command assignment order/values; kind6 sets qtype,all16marker_rows,marker_mask,candidate_count to0 per unchanged production ABI. No other TB/stimulus/clock/assertion/gold/production change.','kind7_original_assignments_preserved':True,'inverse_reconstructs_8b55_byte_exactly':True,'current_AT005_frozen_8b55_snapshot_unchanged':True,'peer_f4d_source_and_prior_manifest_unchanged':True,'patch':str(patch.relative_to(root)),'patch_sha256':sha(patch),'generator_sources':[{'path':str(p.relative_to(root)),'sha256':sha(p)}for p in f.iterdir()if p.name!=live.name]}
 dump(prep/'source_manifest.json',manifest)
 audit={'schema':'m007-r007-kind6-public-begin-static-audit-v1','status':'PASS_STATIC_SOURCE_AND_EXISTING_ABI_ONLY','source_sha256':sha(frozen),'inverse_exact':True,'kind7_assignment_sequence_exact':True,'kind6_all_marker_rows_and_reserved_fields_zero':True,'legal_source_cases':[{'kind':7,'local':0,'fields':'old qtype2/rows23,33/mask0003/count2'},{'kind':6,'local':0,'fields':'all0'},{'kind':6,'local':1,'fields':'all0'}],'parameter_admission_and_all_assertions_unchanged':True,'compile_sources_checked':94,'only_top_record_changed':True,'fixture_SHA_checked_unchanged':checked,'current_running_snapshot_changed':False,'HDL_RTL_or_FP_run':False,'resources':{'affinity':affinity,'nice':nice,'ioprio_class':io>>13,'initial_MemAvailable_KiB':available,'max_RSS_KiB':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss},'wall_s':time.monotonic()-start}
 dump(out/'kind6_public_abi_audit.json',audit)
 dump(r/'fullgraph_kind6_public_abi_v4_delivery.json',{k:v for k,v in manifest.items()if k!='compile_sources'}|{'source_manifest':str((prep/'source_manifest.json').relative_to(root)),'source_manifest_sha256':sha(prep/'source_manifest.json'),'audit':str((out/'kind6_public_abi_audit.json').relative_to(root)),'runtime':'NOT_RUN_BY_A010','next_step':'A012 may bind frozen successor for separately budgeted kind6 Decision0/1; do not mutate running AT005/source8b55. No A010 EDA or lock request.'})
 print(json.dumps({'source_sha256':sha(frozen),'source_manifest':str((prep/'source_manifest.json').relative_to(root)),'status':audit['status'],'wall_s':audit['wall_s']}))


if __name__=='__main__':main()
