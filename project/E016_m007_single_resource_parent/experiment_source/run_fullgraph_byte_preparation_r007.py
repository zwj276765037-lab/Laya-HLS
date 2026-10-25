#!/usr/bin/env python3
"""One <=20s source/byte preparation, no EDA or heavy-tool resource claim."""
from pathlib import Path
from decimal import Decimal
import hashlib,json,shutil,subprocess,time
import fullmodel_r007_run as run
root=run.ROOT;r=run.R;at=r/'attempts/AT044_original47_fullgraph_byte_binding';assert not at.exists();(at/'frozen').mkdir(parents=True);(at/'work').mkdir();source=run.S/'prepare_fullgraph_original_bytes_r007.py';shutil.copy2(source,at/'frozen'/source.name);shutil.copy2(Path(__file__),at/'actual_orchestrator.py');used=run.costs();assert Decimal(run.CAP['static'])-used['static']>=20
cmd=['timeout','--signal=TERM','--kill-after=2','20','taskset','-c','0-3','nice','-n','19','ionice','-c','3',run.sys.executable,str(at/'frozen'/source.name),'--root',str(root),'--out',str(at/'work/fixture')]
run.dump(at/'command_static.json',{'argv':cmd,'operation':'source and original-byte serialization only','no_EDA_or_heavy_tool':True,'heavy_lock_used':False,'authorization':'Controller continuation source preparation may proceed while A012 has heavy window','used_before_seconds':{k:str(v)for k,v in used.items()}})
start=time.monotonic()
with(at/'driver.log').open('w')as log:rc=subprocess.call(cmd,cwd=root,stdout=log,stderr=subprocess.STDOUT)
wall=time.monotonic()-start;success=rc==0 and(at/'work/fixture/manifest.json').exists();run.dump(at/'receipt_static.json',{'category':'static','wall_s':wall,'verdict':'PASS_SOURCE_BYTES_ONLY'if success else'COST_STOP'if rc==124 else'FAIL','exit_code':rc,'EDA':'NOT_RUN','bounded_source_only':True,'fullgraph':'NOT_RUN'})
if success:
 manifest=run.read(at/'work/fixture/manifest.json');run.dump(at/'source_manifest.json',{'files':[{'frozen':source.name,'sha256':run.sha(at/'frozen'/source.name),'source':str(source.relative_to(root))}],'fixture_manifest_sha256':run.sha(at/'work/fixture/manifest.json'),'actual_resource_policy_self':manifest['resource_policy'],'model_effort_actual':'UNKNOWN'})
new=run.costs();run.dump(r/'budget_ledger.json',{'schema':'m007-r007-budget-v1','limits_seconds':run.CAP,'used_seconds':{k:str(v)for k,v in new.items()},'remaining_seconds':{k:str(Decimal(run.CAP[k])-v)for k,v in new.items()},'rtl_reserve_seconds':400,'old_run_budget_transferred':False});print(json.dumps({'attempt':at.name,'verdict':'PASS_SOURCE_BYTES_ONLY'if success else'FAIL','wall_s':wall,'EDA':'NOT_RUN'}));raise SystemExit(0 if success else 1)
