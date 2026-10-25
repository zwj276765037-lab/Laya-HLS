#!/usr/bin/env python3
"""Timestamp flushed real Encoder0 events; events do not authorize progress."""
import argparse
import datetime as dt
import json
from pathlib import Path
import subprocess
import time


def main():
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('command',nargs=argparse.REMAINDER);a=p.parse_args()
    assert a.command[:1]==['--'] and len(a.command)>1
    start=time.monotonic();events=[]
    data={'schema':'m007-encoder0-actual-wall-events-v2','started_at':dt.datetime.now(dt.timezone.utc).isoformat(),'command':a.command[1:],'scope':'Actual flushed stage/count events; elapsed includes startup/fixture/prepack/checker; no synthesized milestones','events':events}
    with subprocess.Popen(a.command[1:],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1)as child:
        for line in child.stdout:
            print(line,end='',flush=True)
            if any(token in line for token in ['M007_ENCODER0_','M007_FFN_','M007_PARENT_HEAD_BEGIN','M007_PARENT_HEAD_END','M007_PARENT_QKV_ALL_END','M007_PARENT_LAYER_ALL_END','M007_PARENT_CONTEXT_ALL_END','M007_PARENT_WO_','MATRIX_PROGRESS parent_state=','MATRIX_PROGRESS parent_QKV_retired_s=']):
                events.append({'elapsed_s':time.monotonic()-start,'line':line.rstrip()})
                a.out.write_text(json.dumps(data,indent=2)+'\n')
        rc=child.wait()
    data.update(elapsed_s=time.monotonic()-start,finished_at=dt.datetime.now(dt.timezone.utc).isoformat(),child_exit=rc)
    a.out.write_text(json.dumps(data,indent=2)+'\n')
    return rc


if __name__=='__main__':
    raise SystemExit(main())
