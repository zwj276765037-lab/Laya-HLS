import importlib.util,json,sys
from pathlib import Path
spec=importlib.util.spec_from_file_location('guard',sys.argv[1]);g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g)
state=None;cases=[]
def check(line,expected):
 global state
 prior=state;ok,state=g.semantic_progress_advances(line,state,'rtl');assert ok==expected,(line,ok,expected);assert expected or state==prior;cases.append({'line':line,'expected_advance':expected})
check('M007_PARENT_CHECKED checked=4096 phase=PUBLIC_H cycle=100',True)
check('M007_RTL_RETIRE_PROGRESS retired=128 cycle=200',True)
check('M007_RTL_RETIRE_PROGRESS retired=128 cycle=201',False)
check('M007_RTL_RETIRE_PROGRESS retired=127 cycle=202',False)
check('M007_RTL_RETIRE_PROGRESS retired=256 cycle=200',False)
check('M007_RTL_RETIRE_PROGRESS retired=256 cycle=199',False)
check('M007_RTL_RETIRE_PROGRESS retired=256 cycle=201',True)
check('M007_PARENT_CHECKED checked=4096 phase=LAYER_H cycle=999',False)
check('M007_PARENT_CHECKED checked=8192 phase=LAYER_H cycle=202',True)
check('M007_RTL_RETIRE_PROGRESS retired=384 cycle=201',False)
check('M007_RTL_RETIRE_PROGRESS retired=384 cycle=203',True)
for line in ['cycle=999 state=7','M007_FULLGRAPH_LAYER_END global=0 checkpoint=0 cycle=999','M007_RTL_RETIRE_PROGRESS retired=512 cycle=204 extra=1','M007_RTL_RETIRE_PROGRESS retired=512 cycle=204heartbeat','prefix M007_RTL_RETIRE_PROGRESS retired=512 cycle=204','M007_PARENT_CHECKED checked=99999 phase=FAKE cycle=100','artifact files=99','M007_RTL_RETIRE_PROGRESS retired=0 cycle=999']:
 check(line,False)
assert state['checked']==(8192,202) and state['retired']==(384,203)
Path(sys.argv[2]).write_text(json.dumps({'verdict':'PASS','cases':cases,'separate_checked_highwater':state['checked'],'separate_retired_highwater':state['retired'],'retired_never_added_to_gold':True},indent=2)+'\n')
print('FULLGRAPH_GUARD_BRANCH_PASS',len(cases))
