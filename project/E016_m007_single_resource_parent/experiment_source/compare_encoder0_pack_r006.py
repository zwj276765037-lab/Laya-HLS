#!/usr/bin/env python3
"""Compare two actual same-snapshot kind3 FFN prefixes; never authorizes kind4."""
import argparse
from decimal import Decimal
import hashlib
import json
from pathlib import Path
import re


def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def elapsed(event):return Decimal(str(event['elapsed_s']))
def extract(attempt,packed):
    receipt=read(attempt/'receipt_rtl.json')
    assert receipt['verdict']=='PASS'and receipt['top']=='m007_encoder0_complete_tb'
    assert receipt['kind']==3 and receipt['packed']==packed and receipt['stop_ffn_blocks']==3
    assert receipt['stop_qkv_blocks']==receipt['stop_after_head']==0
    identity=read(attempt/'fixture_identity.json');build=Path(identity['build'])
    assert sha(build/'source_manifest.json')==identity['build_manifest_sha256']
    assert sha(attempt/'fixture_manifest.json')==identity['fixture_manifest_sha256']
    wall=read(attempt/'work/encoder0_wall_events.json');events=wall['events']
    def unique(prefix):
        rows=[e for e in events if e['line'].startswith(prefix)];assert len(rows)==1,prefix;return rows[0]
    begin=unique('M007_ENCODER0_BEGIN ');end=unique('M007_ENCODER0_FFN_PREFIX_PASS ')
    match=re.fullmatch(r'M007_ENCODER0_FFN_PREFIX_PASS blocks=(\d+) Wi_values=(\d+) G_values=(\d+) nodes=(\d+) packed=(\d+) cycles=(\d+) unfinished=1',end['line']);assert match and int(match[1])==3 and int(match[5])==packed
    counts={'blocks':int(match[1]),'Wi_values':int(match[2]),'G_values':int(match[3]),'node_checks':int(match[4]),'command_to_prefix_cycles':int(match[6])}
    assert counts['Wi_values']>=24576 and counts['G_values']==12288 and counts['node_checks']>=122880
    matrix=unique('M007_ENCODER0_MATRIX_BEGIN phase=2 ')
    gblocks=[e for e in events if e['line'].startswith('M007_FFN_G_BLOCK ')];assert len(gblocks)==3
    matrixblocks=[e for e in events if e['line'].startswith('M007_ENCODER0_MATRIX_BLOCK phase=2 ')];assert len(matrixblocks)>=3
    fixture=elapsed(unique('M007_ENCODER0_FIXTURE_END'))-elapsed(unique('M007_ENCODER0_FIXTURE_BEGIN '))
    prepack_rows=[e for e in events if e['line'].startswith('M007_ENCODER0_PREPACK_')]
    if packed:
        assert len(prepack_rows)==2
        prepack=elapsed(unique('M007_ENCODER0_PREPACK_END '))-elapsed(unique('M007_ENCODER0_PREPACK_BEGIN '))
    else:assert not prepack_rows;prepack=Decimal(0)
    return {'attempt':str(attempt),'receipt_sha256':sha(attempt/'receipt_rtl.json'),'wall_events_sha256':sha(attempt/'work/encoder0_wall_events.json'),'identity':identity,'counts':counts,'metrics_s':{'guard_total':str(Decimal(str(receipt['wall_s']))),'fixture':str(fixture),'prepack':str(prepack),'driver_start_to_BEGIN':str(elapsed(begin)),'command_to_prefix':str(elapsed(end)-elapsed(begin)),'matrix_to_G_block0':str(elapsed(gblocks[0])-elapsed(matrix)),'G_block1_interval':str(elapsed(gblocks[1])-elapsed(gblocks[0])),'G_block2_interval':str(elapsed(gblocks[2])-elapsed(gblocks[1]))},'old_capture_downstream_eligible':False}


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--packed',type=Path,required=True);parser.add_argument('--scalar',type=Path,required=True);parser.add_argument('--out',type=Path,required=True);args=parser.parse_args()
    packed=extract(args.packed.resolve(),1);scalar=extract(args.scalar.resolve(),0)
    assert packed['identity']==scalar['identity'],'Causal pair requires identical build, fixtures and initial snapshot identities'
    assert packed['counts']==scalar['counts'],'Checker counts/cycles differ; cannot claim equivalent work'
    comparisons={}
    for key,value in packed['metrics_s'].items():
        p=Decimal(value);s=Decimal(scalar['metrics_s'][key]);comparisons[key]={'packed_s':str(p),'scalar_s':str(s),'scalar_minus_packed_s':str(s-p),'scalar_over_packed':str(s/p)if p else None}
    result={'status':'ACTUAL_MATCHED_PREFIX_PAIR','scope':'legal kind3 public norm_ff entry through unfinished Wi/G3 only','packed':packed,'scalar':scalar,'comparisons':comparisons,'replicates_per_mode':1,'variance_estimated':False,'complete_kind4_cost_proven':False,'kind4_entry_prefix_cost_must_be_measured_separately':True,'source_or_gold_substitution':False}
    args.out.write_text(json.dumps(result,indent=2)+'\n');print('M007_ENCODER0_MATCHED_PACK_PAIR_PASS '+str(args.out))


if __name__=='__main__':main()
