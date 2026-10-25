#!/usr/bin/env python3
"""Read-only bounded progress from actual semantic/wall events and receipts."""
import argparse,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('attempt',type=Path);p.add_argument('--compact',action='store_true');a=p.parse_args();r=a.attempt.resolve();d=json.loads((r/'work/ffn_wall_events.json').read_text());events=d['events'];matrix={0:[],1:[]};g=[];qa=[];states=[]
for e in events:
 line=e['line'];m=re.fullmatch(r'M007_FFN_MATRIX_BLOCK phase=(\d+) s=(\d+) cycle=(\d+) values=(\d+)',line)
 if m:matrix[int(m[1])].append({'s':int(m[2]),'cycle':int(m[3]),'values':int(m[4]),'wall_s':e['elapsed_s']})
 m=re.fullmatch(r'M007_FFN_G_BLOCK s=(\d+) cycle=(\d+) values=(\d+) nodes=(\d+)',line)
 if m:g.append({'s':int(m[1]),'cycle':int(m[2]),'values':int(m[3]),'nodes':int(m[4]),'wall_s':e['elapsed_s']})
 m=re.fullmatch(r'M007_FFN_Q8_ACK groups=(\d+) cycle=(\d+)',line)
 if m:qa.append({'groups':int(m[1]),'cycle':int(m[2]),'wall_s':e['elapsed_s']})
 if line.startswith('M007_FFN_STATE'):states.append(e)
result={'attempt':str(r),'started_at':d['started_at'],'wall_event_count':len(events),'last_event':events[-1]if events else None,'completed_Wi_blocks':len(matrix[0]),'completed_G_blocks':len(g),'completed_Down_blocks':len(matrix[1]),'last_Wi':matrix[0][-1]if matrix[0]else None,'last_G':g[-1]if g else None,'last_Down':matrix[1][-1]if matrix[1]else None,'last_Q8_ACK_checkpoint':qa[-1]if qa else None,'last_state':states[-1]if states else None,'process_state_is_inferred_from_events':False}
for cat in ['rtl','static']:
 rp=r/('receipt_'+cat+'.json')
 if rp.exists():result['receipt']=json.loads(rp.read_text())
print(json.dumps({k:result[k]for k in ['completed_Wi_blocks','completed_G_blocks','completed_Down_blocks','last_event','last_G','last_Q8_ACK_checkpoint']}if a.compact else result,indent=None if a.compact else 2))
