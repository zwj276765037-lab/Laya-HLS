import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'frozen'))
from gqdown_reset_guard import reset_aware_progress_decision as decide
line = 'FFR1_PROGRESS cfg=0 sar=0 sr=0 dar=0 dr=0 aa=0 ar=0 ac=0 aw=0 w=0 b=0 rsp='
prev, advanced, regression = decide(None, line + '20')
assert advanced and not regression
prev, advanced, regression = decide(prev, line + '0')
assert regression
prev, advanced, regression = decide(prev, 'GQDOWN_RESET_PRE phase=0 cmd=40')
assert prev is None and advanced and not regression
prev, advanced, regression = decide(prev, line + '0')
assert not regression
prev, advanced, regression = decide(prev, line + '1')
assert advanced and not regression
print('GQDOWN_RESET_GUARD_EPOCH_TEST_PASS')
