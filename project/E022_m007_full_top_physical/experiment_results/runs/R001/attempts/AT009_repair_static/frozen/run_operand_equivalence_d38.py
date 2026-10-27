#!/usr/bin/env python3
"""Actual XSim compile/elaborate and four-state RTL equivalence driver."""
import json,shutil,subprocess,sys
from pathlib import Path
BIN=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
stage,at_s,run_s=sys.argv[1:];at=Path(at_s);run=Path(run_s);work=at/'work'
commands=[]
def execute(argv):
 commands.append(argv);(at/'tool_commands.json').write_text(json.dumps(commands,indent=2)+'\n')
 subprocess.run(argv,cwd=work,check=True)
if stage=='repair_static':
 execute([str(BIN/'xvlog'),'--sv','--work','work',str(at/'frozen/old_storage.sv'),str(at/'frozen/new_storage.sv'),str(at/'frozen/operand_storage_equivalence_tb.sv')])
 execute([str(BIN/'xelab'),'--maxdelay','--debug','typical','--mt','4','--snapshot','operand_eq','work.operand_storage_equivalence_tb'])
 (run/'repair/static_attempt.txt').write_text(str(at)+'\n')
elif stage=='repair_rtl':
 static=Path((run/'repair/static_attempt.txt').read_text().strip());rec=json.loads((static/'receipt.json').read_text());assert rec['verdict']=='PASS'
 shutil.copytree(static/'work/xsim.dir',work/'xsim.dir')
 execute([str(BIN/'xsim'),'operand_eq','--runall','--log',str(at/'xsim.log')])
 log=(at/'xsim.log').read_text();assert 'OPERAND_STORAGE_EQUIVALENCE_PASS'in log and 'Fatal:'not in log and 'Error:'not in log
else:raise ValueError(stage)
(at/'stage_complete.txt').write_text(stage+' PASS\n')
