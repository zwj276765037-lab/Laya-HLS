#!/usr/bin/env python3
"""G-RING-TAG-15: exact single-array 2048-bit reduction from frozen AT106."""
import argparse,copy,hashlib,json
from fractions import Fraction
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1];ROOT=MODULE.parents[5]
BASE=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT106_g_compact16_explicit_context_state_census/work/report.json'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
 b=json.loads(BASE.read_text());assert b['g_control_bits']==15709
 r=copy.deepcopy(b);records=r['entries'];changes=[]
 r['compact16_stage_tag_width_changes']=r.pop('tag_width_changes');r['compact16_stage_tag_bits_saved']=r.pop('tag_bits_saved')
 for q in records:
  if q['owner']=='laya_m007_g_math_v1' and q['state']=='tag_mem':
   assert q['bits']==4096;q.update(state='tag_mem_hi',bits=2048,bytes_exact='256',declaration_anchor='logic [7:0] tag_mem_hi[0:255]',compression_candidate_not_implemented='Implemented high8 stored, low8 from actual slot address; fullseq16 reconstructed explicitly and independently checked against expected16')
   changes.append({'owner':q['owner'],'old_state':'tag_mem','new_state':'tag_mem_hi','entries':256,'old_bits':4096,'new_bits':2048})
  assert q['declaration_anchor'] in (ROOT/q['source']).read_text(),(q['owner'],q['state'])
 assert len(changes)==1
 totals={}
 for q in records:totals[q['category']]=totals.get(q['category'],0)+q['bits']
 control=sum(q['bits'] for q in records if q['category'].startswith('control_'));assert control==13661
 assert totals['bounded_arithmetic_payload']==25600*8 and totals['fixed_numeric_alignment']==736*8
 ms=(MODULE/'rtl/laya_m007_g_math_v1.sv').read_text()
 assert 'logic [15:0] expected_tag[0:8][0:3]' in ms and 'tag_mem_hi[reserve_ptr]<=in_tag[15:8]' in ms
 assert 'function automatic [15:0] slot_seq(input logic [7:0] high_seq,input logic [7:0] slot_index)' in ms
 assert 'return {high_seq,slot_index};' in ms
 for path,digest in b['source_sha256'].items():
  if not path.endswith('/laya_m007_g_math_v1.sv'):assert sha(ROOT/path)==digest,path
 r.update(schema='m007-g-source-state-census-v3-ring-high8',status='DECLARATION_CENSUS_COMPLETE_G_1707_625B',scope='Exact math slot tag16->high8 plus actual slot index, every other declaration unchanged; no parent physical reuse/fit credit',compact16_baseline_report_sha256=sha(BASE),source_sha256={q['source']:sha(ROOT/q['source']) for q in records},ring_tag_changes=changes,ring_tag_bits_saved=2048,tag_bits_saved=394*80+2048,ring_tag_new_storage_bits=0,category_bits=totals,category_bytes_exact={k:str(Fraction(v,8)) for k,v in totals.items()},g_control_bits=control,g_control_bytes_exact=str(Fraction(control,8)),g_control_bytes=control/8)
 (a.output/'report.json').write_text(json.dumps(r,indent=2)+'\n');print('G_RING_TAG_STATE_CENSUS_PASS bits',control,'bytes',control/8,'saved_bits2048 new_bits0 joint_fitOPEN',flush=True)
if __name__=='__main__':main()
