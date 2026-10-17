#!/usr/bin/env python3
"""Collect actual full-closure OOC resource/timing evidence without changing it."""
from pathlib import Path
import argparse, hashlib, json, re

def rec(p):
    b=p.read_bytes()
    return dict(path=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())

p=argparse.ArgumentParser()
p.add_argument('attempt',type=Path)
p.add_argument('run')
p.add_argument('--guard',required=True)
p.add_argument('--manifest',required=True)
args=p.parse_args()
a=args.attempt.resolve(); w=a/args.run; work=w/'work'; identity=a/args.manifest
g=json.loads((a/args.guard/'guard_result.json').read_text())
log=a/args.guard/'driver.log'
for r in json.loads(identity.read_text())['sources']:
    assert rec(Path(r['frozen']['path']))==r['frozen']
if g['child_exit_code']!=0 or g['trigger'] is not None:
    stop=a/args.guard/'guard_trigger.json'
    stop_data=json.loads(stop.read_text()) if stop.exists() else {}
    names=['utilization.rpt','utilization_hierarchical.rpt',
           'timing_summary.rpt','attention_tile_synth.dcp']
    body=dict(schema='attention-tile-ooc-result-v1',status='NOT_COMPLETE',
              scope='Attempted current full-capacity S1024 M16/A16/D4/EXP4 tile and its local same-clock CE closure, standalone xcu55c-fsvh2892-2L-e synthesis',
              source_manifest=rec(identity),source_manifest_sha256=rec(identity)['sha256'],
              input_manifest=rec(w/'input_manifest.json'),guard=g,raw_log=rec(log),
              tool_log=rec(work/'vivado.log'),collector=rec(Path(__file__).resolve()),
              stop_evidence=rec(stop) if stop.exists() else None,
              last_progress_line=stop_data.get('last_progress_line'),
              seconds_since_progress=stop_data.get('seconds_since_progress'),
              blackboxes=None,resources=None,timing_synth_only=None,
              artifacts=[rec(work/n) for n in names if (work/n).exists()],
              missing_artifacts=[n for n in names if not (work/n).exists()],
              limitations='Guard termination is not a completed resource, timing, blackbox or fit result. The semantic-stall trigger means no configured progress milestone was observed for the guard interval; it does not prove the synthesis algorithm was hung. No retry or ready blackbox publication is implied.')
    (w/'ooc_result.json').write_text(json.dumps(body,indent=2)+'\n')
    print('ATTENTION_SERVICE_TILE_OOC_RECEIPT_NOT_COMPLETE '+str(g['trigger']))
    raise SystemExit(0)
assert 'ATTENTION_SERVICE_TILE_OOC_PASS blackboxes=0' in log.read_text()
rows={}
for line in (work/'utilization.rpt').read_text().splitlines():
    if line.startswith('|'):
        cells=[x.strip() for x in line.split('|')[1:-1]]
        if len(cells)>1 and re.fullmatch(r'\d+(?:\.\d+)?',cells[1]):
            rows[cells[0].rstrip('*')]=float(cells[1])
r=dict(LUT=int(rows['CLB LUTs']),FF=int(rows['CLB Registers']),
       DSP=int(rows['DSPs']),RAMB36=int(rows['RAMB36/FIFO']),
       RAMB18=int(rows['RAMB18']),BRAM_tiles=rows['Block RAM Tile'],
       URAM=int(rows['URAM']))
r['BRAM18_equivalent']=2*r['RAMB36']+r['RAMB18']
assert r['BRAM_tiles']==r['BRAM18_equivalent']/2
t=(work/'timing_summary.rpt').read_text()
lines=t.splitlines(); i=next(i for i,x in enumerate(lines) if 'WNS(ns)' in x)
numbers=next(x.split() for x in lines[i+1:] if re.match(r'^\s*-?\d+\.\d+\s+',x))
timing=dict(requested_clock_period_ns=6.666666667,target_mhz=150,
            WNS_ns=float(numbers[0]),TNS_ns=float(numbers[1]),
            WHS_ns=float(numbers[4]),THS_ns=float(numbers[5]))
for label in ['no_input_delay','no_output_delay','unconstrained_internal_endpoints']:
    m=re.search(r'checking '+label+r' \((\d+)\)',t)
    timing[label]=int(m[1]) if m else None
files=[work/n for n in ['utilization.rpt','utilization_hierarchical.rpt',
                       'timing_summary.rpt','attention_tile_synth.dcp']]
body=dict(schema='attention-tile-ooc-result-v1',status='PASS',
          scope='Actual current full-capacity S1024 M16/A16/D4/EXP4 tile and its local same-clock CE closure, standalone xcu55c-fsvh2892-2L-e synthesis',
          source_manifest=rec(identity),source_manifest_sha256=rec(identity)['sha256'],
          input_manifest=rec(w/'input_manifest.json'),guard=g,raw_log=rec(log),
          blackboxes=0,resources=r,timing_synth_only=timing,
          artifacts=[rec(x) for x in files],collector=rec(Path(__file__).resolve()),
          not_proven=['enclosing production caller/unique service/13BO last-B',
                      'complete accelerator fit','place and route',
                      'realized clock or board throughput'])
(w/'ooc_result.json').write_text(json.dumps(body,indent=2)+'\n')
print('ATTENTION_SERVICE_TILE_OOC_RECEIPT_PASS '+json.dumps(r))
