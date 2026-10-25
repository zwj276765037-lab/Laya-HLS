#!/usr/bin/env python3
"""G-COMPACT-14 source-declared state, with every new context/order bit.

Frozen AT071 remains the old complete declaration baseline. This audit changes
only seven tag widths and adds explicit context/order storage; no mask, debt,
coverage, numerical payload/alignment or unconsumed tail is deducted.
"""
import argparse,copy,hashlib,json,re
from fractions import Fraction
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1];ROOT=MODULE.parents[5]
BASE=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT071_g_exact_source_state_census/work/report.json'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False)
 baseline=json.loads(BASE.read_text());assert baseline['g_control_bits']==46938
 records=copy.deepcopy(baseline['entries']);math='laya_m007_g_math_v1';pool='laya_m007_g_vector_pool_v1'
 widths={(math,'tag_mem'):256,(math,'expected_tag'):36,(math,'pre_tag'):15,(math,'t_tag'):7,(math,'post_tag/r_tag'):14,('pre_credit32','tags32x96'):32,(pool,'tags across seven mul4/two add3'):34}
 changed=[]
 for q in records:
  key=(q['owner'],q['state']);source=ROOT/q['source'];text=source.read_text()
  if key in widths:
   count=widths[key];assert q['bits']==count*96;q['bits']=count*16;q['bytes_exact']=str(Fraction(q['bits'],8));q['compression_candidate_not_implemented']='Implemented fixed-context16-bit full G sequence; public96-bit boundaries reconstruct and fully validate generation/epoch/reserved/sequence'
   if q['owner']==pool:q['declaration_anchor']='logic [15:0] tags[0:LAT-1]'
   if q['owner']=='pre_credit32':q['state']='tags32x16';q['configuration_owner']=str((MODULE/'rtl/laya_m007_g_math_v1.sv').relative_to(ROOT))
   changed.append({'owner':q['owner'],'state':q['state'],'entries':count,'old_bits':count*96,'new_bits':count*16})
  assert q['declaration_anchor']in text,(q['owner'],q['state'])
 ms=(MODULE/'rtl/laya_m007_g_math_v1.sv').read_text();ps=(MODULE/'rtl/laya_m007_g_vector_pool_v1.sv').read_text()
 for pattern in [r'logic \[15:0\] tag_mem\[0:255\]',r'logic \[15:0\] expected_tag\[0:8\]\[0:3\]',r'logic \[15:0\] pre_tag\[0:14\]',r'logic \[15:0\] t_tag\[0:6\]',r'logic \[15:0\] post_tag\[0:12\],r_tag']:
  assert re.search(pattern,ms),pattern
 assert '.TAG_WIDTH(16),.LATENCY(15),.DEPTH(32)'in ms and 'logic [15:0] tags[0:LAT-1]'in ps
 assert sum(x['entries']for x in changed)==394
 extras=[(math,'tag_context/context_valid',65,'control_identity','logic [63:0] tag_context;logic context_valid'),(math,'next_input_seq',16,'control_real_credit','logic [15:0] next_input_seq'),(pool,'tag_context/context_valid/context_fault',66,'control_identity','logic context_valid,context_fault,candidate_found'),(pool,'next_seq9x16',144,'control_real_credit','logic [8:0][15:0] next_seq')]
 for owner,name,bits,category,anchor in extras:
  source=MODULE/'rtl'/(owner+'.sv');assert anchor in source.read_text()
  records.append({'owner':owner,'state':name,'bits':bits,'bytes_exact':str(Fraction(bits,8)),'category':category,'declaration_anchor':anchor,'compression_candidate_not_implemented':'Actual added state, fully charged; candidate_context/candidate_found are combinational and not duplicated storage','source':str(source.relative_to(ROOT))})
 totals={}
 for q in records:totals[q['category']]=totals.get(q['category'],0)+q['bits']
 control=sum(q['bits']for q in records if q['category'].startswith('control_'))
 assert control==46938-394*80+291==15709 and control<=2048*8
 assert totals['bounded_arithmetic_payload']==25600*8 and totals['fixed_numeric_alignment']==736*8
 sources={q['source']:sha(ROOT/q['source'])for q in records}
 report={'schema':'m007-g-source-state-census-v2','status':'DECLARATION_CENSUS_COMPLETE_G_LE_2048B','scope':'G-only source declarations with actual context/order state; no parent control overlay, logical-exclusion credit, numerical reclassification, synthesis or physical-fit claim. Existing SFU and numerical leaves separate and unchanged.','baseline_report_sha256':sha(BASE),'source_sha256':sources,'entries':records,'tag_width_changes':changed,'tag_entries_compacted':394,'tag_bits_saved':394*80,'new_context_valid_order_bits':291,'unread_tail_bits_removed':0,'category_bits':totals,'category_bytes_exact':{k:str(Fraction(v,8))for k,v in totals.items()},'g_control_bits':control,'g_control_bytes_exact':str(Fraction(control,8)),'g_control_bytes':control/8,'g_stage_target_B':2048,'g_stage_target_met':True,'joint_4KiB_fit_claimed':False,'preserved':'All numerical/peer/domain masks,live/available/sent/received,slot-specific pending/SFU/FP debt,precredit true validity,ACK coverage,covered/evaluated and lexicographic first error remain; no tail or state merge deduction'}
 (o/'report.json').write_text(json.dumps(report,indent=2)+'\n');print('G_COMPACT_STATE_CENSUS_PASS bits',control,'bytes',control/8,'new_bits',291,'joint_fit=OPEN',flush=True)
if __name__=='__main__':main()
