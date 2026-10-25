#!/usr/bin/env python3
"""Only the authorized <=30s source preparation/check; no heavy lock or EDA."""
from pathlib import Path
from decimal import Decimal
import json,shutil,subprocess,time
import fullmodel_r007_run as run

r,root=run.R,run.ROOT;at=r/'attempts/AT055_kind6_public_begin_abi_static';assert not at.exists();(at/'frozen').mkdir(parents=True);(at/'work').mkdir();source=run.S/'prepare_kind6_public_abi_v4_r007.py';shutil.copy2(source,at/'frozen'/source.name);shutil.copy2(Path(__file__),at/'actual_orchestrator.py');used=run.costs();assert Decimal(run.CAP['static'])-used['static']>=30
cmd=['timeout','--signal=TERM','--kill-after=2','30','taskset','-c','0-3','nice','-n','19','ionice','-c','3',run.sys.executable,str(at/'frozen'/source.name),'--root',str(root),'--out',str(at/'work/audit')];run.dump(at/'command_static.json',{'argv':cmd,'authorization':'Root explicit kind6-only public BEGIN ABI ordinary TB repair; <=30s original D32 static','EDA':'NOT_RUN','heavy_lock_used':False,'used_before_seconds':{k:str(v)for k,v in used.items()}});start=time.monotonic()
with(at/'driver.log').open('w')as log:rc=subprocess.call(cmd,cwd=root,stdout=log,stderr=subprocess.STDOUT)
wall=time.monotonic()-start;success=rc==0 and(at/'work/audit/kind6_public_abi_audit.json').exists();run.dump(at/'receipt_static.json',{'category':'static','wall_s':wall,'verdict':'PASS_SOURCE_PREPARATION_STATIC_AUDIT_ONLY'if success else'COST_STOP'if rc==124 else'FAIL','exit_code':rc,'EDA':'NOT_RUN','kind6_command_fields_only':True,'kind7_runtime':'NOT_RUN'});new=run.costs();run.dump(r/'budget_ledger.json',{'schema':'m007-r007-budget-v1','limits_seconds':run.CAP,'used_seconds':{k:str(v)for k,v in new.items()},'remaining_seconds':{k:str(Decimal(run.CAP[k])-v)for k,v in new.items()},'rtl_reserve_seconds':400,'old_run_budget_transferred':False});print(json.dumps({'attempt':at.name,'success':success,'wall_s':wall,'EDA':'NOT_RUN'}));raise SystemExit(0 if success else 1)
