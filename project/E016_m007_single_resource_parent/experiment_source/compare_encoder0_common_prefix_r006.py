#!/usr/bin/env python3
"""Compare only actual checked milestones common to two possibly incomplete runs."""
import argparse
from decimal import Decimal
import hashlib
import json
from pathlib import Path
import re


def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def elapsed(e):return Decimal(str(e['elapsed_s']))
def extract(attempt,packed):
    receipt=read(attempt/'receipt_rtl.json')
    assert receipt['verdict']in('PASS','COST_STOP')and not receipt['error_or_fatal']
    if receipt['verdict']=='COST_STOP':assert receipt['guard']['trigger']=='timeout'
    assert receipt['kind']==3 and receipt['packed']==packed and receipt['stop_ffn_blocks']==3
    assert receipt['top']=='m007_encoder0_complete_tb'and receipt['stop_qkv_blocks']==receipt['stop_after_head']==0
    identity=read(attempt/'fixture_identity.json');build=Path(identity['build'])
    assert sha(build/'source_manifest.json')==identity['build_manifest_sha256']
    assert sha(attempt/'fixture_manifest.json')==identity['fixture_manifest_sha256']
    events=read(attempt/'work/encoder0_wall_events.json')['events']
    def unique(prefix):
        rows=[e for e in events if e['line'].startswith(prefix)];assert len(rows)==1,prefix;return rows[0]
    begin=elapsed(unique('M007_ENCODER0_BEGIN kind=3 '))
    fixture=elapsed(unique('M007_ENCODER0_FIXTURE_END'))-elapsed(unique('M007_ENCODER0_FIXTURE_BEGIN '))
    prepack=elapsed(unique('M007_ENCODER0_PREPACK_END '))-elapsed(unique('M007_ENCODER0_PREPACK_BEGIN '))if packed else Decimal(0)
    milestones={}
    for e in events:
        line=e['line'];key=None
        m=re.fullmatch(r'M007_ENCODER0_MATRIX_BLOCK phase=2 block=(\d+) values=(\d+) cycle=(\d+)',line)
        if m:key='Wi_block'+m[1]
        m=re.fullmatch(r'M007_FFN_G_BLOCK s=(\d+) cycle=(\d+) values=(\d+) nodes=(\d+)',line)
        if m:key='G_block'+m[1]
        if key:
            assert key not in milestones
            milestones[key]={'line':line,'driver_elapsed_s':str(elapsed(e)),'command_elapsed_s':str(elapsed(e)-begin)}
    assert 'Wi_block0'in milestones and 'G_block0'in milestones
    return {'attempt':str(attempt),'verdict':receipt['verdict'],'receipt_sha256':sha(attempt/'receipt_rtl.json'),'wall_events_sha256':sha(attempt/'work/encoder0_wall_events.json'),'fixture_identity':identity,'guard_wall_s':str(receipt['wall_s']),'fixture_s':str(fixture),'prepack_s':str(prepack),'driver_start_to_BEGIN_s':str(begin),'milestones':milestones,'FFN3_prefix_marker_found':receipt['marker_found'],'capture_downstream_eligible':False}


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--packed',type=Path,required=True);parser.add_argument('--scalar',type=Path,required=True);parser.add_argument('--out',type=Path,required=True);args=parser.parse_args()
    packed=extract(args.packed.resolve(),1);scalar=extract(args.scalar.resolve(),0)
    assert packed['fixture_identity']==scalar['fixture_identity'],'Snapshot/fixtures must match'
    common=sorted(packed['milestones'].keys()&scalar['milestones'].keys())
    rows=[]
    for key in common:
        p=packed['milestones'][key];s=scalar['milestones'][key];assert p['line']==s['line'],'Actual counts/cycles must match'
        pt=Decimal(p['command_elapsed_s']);st=Decimal(s['command_elapsed_s'])
        rows.append({'milestone':key,'actual_checked_counts_cycles':p['line'],'packed_command_elapsed_s':str(pt),'scalar_command_elapsed_s':str(st),'scalar_minus_packed_s':str(st-pt),'scalar_over_packed':str(st/pt)})
    result={'status':'ACTUAL_MATCHED_COMMON_MILESTONES_ONLY','scope':'legal kind3 unfinished FFN; only emitted checked milestones have comparable work','analysis_source_sha256':sha(Path(__file__)),'packed':packed,'scalar':scalar,'common_milestones':rows,'replicates_per_mode':1,'variance_estimated':False,'completed_FFN3_pair':packed['FFN3_prefix_marker_found']and scalar['FFN3_prefix_marker_found'],'full_FFN_or_kind4_acceptance':False,'kind4_cost_gate_authorized':False,'old_capture_binary_downstream_eligible':False,'timeout_was_increased':False}
    args.out.write_text(json.dumps(result,indent=2)+'\n');print('M007_ENCODER0_MATCHED_COMMON_MILESTONES_RECORDED '+str(args.out))


if __name__=='__main__':main()
