#!/usr/bin/env python3
"""Count every actual sequential declaration; no physical resource estimate."""
import argparse
import hashlib
import json
from pathlib import Path
import re
LOCAL=Path(__file__).resolve().parents[1]
ENGINE={
 'active':1,'done_valid':1,'done_error':1,'aborting':1,'out_valid':1,
 'gamma_loading':1,'gamma_loaded':1,'gamma_coverage':32,'gamma_done_valid':1,'gamma_done_error':1,
 'gamma_mem':32*32*32,'held_model':64,'held_key':32,
 'ctx_active':4,'ctx_row':4*7,'raw_coverage':4*32,'delta_coverage':4*32,
 'raw_read_count':4*6,'delta_read_count':4*6,'output_count':4*6,
 'sum_wait':4,'square_sum_wait':4,'sqrt_wait':4,'mean_valid':4,'inverse_valid':4,
 'left_valid':2*4*5,'left_value':2*4*5*32,
 'add_hold_valid':1,'mul_hold_valid':1,'rd_hold_valid':1,'wr_hold_valid':1,'add_tail':6,'mul_tail':6,
 'add_debt':4*9,'mul_debt':4*9,'read_debt':4*7,'write_debt':4*7,'scalar_debt':4*4,
 'cycle_count':32,'peak_add_pending':7,'peak_mul_pending':7,'error_stage':5,'error_level':4,'error_row':7,'error_node':10,
 'mode_gamma':1,'rows':8,'input_row':8,'input_chunk':5,'total_retired':8,'next_row_cycle':32,
 'out_request_id':64,'out_generation':32,'out_epoch':32,'input_tags':4*32*96,
 'add_metadata':64*176,'mul_metadata':64*24,
 'add_hold_a':105*32,'add_hold_b':105*32,'mul_hold_a':96*32,'mul_hold_b':96*32,
 'add_hold_meta':176,'mul_hold_meta':24,'rd_hold_desc':16,'wr_hold_desc':16,'wr_hold_raw':1024,'wr_hold_delta':1024,
 'sum_value':4*32,'mean_value':4*32,'square_sum_value':4*32,'shift_value':4*32,'inverse_value':4*32,
 'out_row':7,'out_chunk':5,'out_tag':96,'out_data':1024,
}
SCALE={'rsp_valid':1,'rsp_error':1,'rsp_data':32,'rsp_tag':96}
SQRT={'busy':1,'rsp_valid':1,'rsp_error':1,'rsp_data':32,'rsp_tag':96,'step':5,'radicand':48,'remainder':50,'root':24,
 'work_tag':96,'work_error':1,'work_zero':1,'work_sign':1,'result_exponent':11}
def assigned(text):
 # These modules place their sole always_ff last. Parse only that sequential
 # region, then balance nested LHS indexes backwards from each assignment.
 text=text[text.index('always_ff'):];names=set()
 for match in re.finditer(r'<=',text):
  i=match.start()-1
  while i>=0 and text[i].isspace():i-=1
  while i>=0 and text[i]==']':
   depth=1;i-=1
   while depth:
    if text[i]==']':depth+=1
    elif text[i]=='[':depth-=1
    i-=1
   while i>=0 and text[i].isspace():i-=1
  name=re.search(r'([A-Za-z_]\w*)$',text[:i+1]);assert name
  names.add(name.group(1))
 return names
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 engine=LOCAL/'rtl/laya_m007_layernorm32_v1.sv';scalar=LOCAL/'rtl/laya_m007_ln_scalars_v1.sv';tb=LOCAL/'tb/m007_ln_engine_tb.sv'
 et=engine.read_text();st=scalar.read_text();parts=st.split('endmodule');tt=tb.read_text()
 for source,widths in ((et,ENGINE),(parts[0],SCALE),(parts[1],SQRT)):
  actual=assigned(source);assert actual==set(widths),(actual-set(widths),set(widths)-actual)
 gamma_bits=ENGINE['gamma_mem'];metadata=sum(ENGINE.values())-gamma_bits+sum(SCALE.values())+sum(SQRT.values());assert metadata<=8192*8
 instance_counts={name:len(re.findall(r'\b'+name+r'\s*(?:#\([^;]*?\))?\s*\w+\s*\(',tt))for name in ('laya_shared_fp256_v2','laya_shared_div8_v1','laya_ln_exp_storage_v1')}
 assert all(n==1 for n in instance_counts.values()),instance_counts
 assert not re.search(r'\b(laya_shared_fp256_v2|laya_shared_div8_v1|laya_ln_exp_storage_v1)\s*(?:#|\w+\s*\()',et)
 result={'status':'PASS_DECLARED_SEQUENTIAL_STORAGE_LEDGER','source_sha256':{str(x.relative_to(LOCAL)):hashlib.sha256(x.read_bytes()).hexdigest()for x in (engine,scalar,tb)},
  'engine_register_bits':ENGINE,'div1024_register_bits':SCALE,'sqrt_register_bits':SQRT,'coefficient_bits':gamma_bits,'coefficient_bytes':gamma_bits//8,
  'metadata_and_holding_bits_including_both_scalars':metadata,'metadata_and_holding_bytes_rounded':(metadata+7)//8,'metadata_limit_bytes':8192,
  'sole_external_LN_exp_payload_bytes':32768,'real_test_shell_instances':instance_counts,'shared_FP_and_DIV_return_credits':'Existing service storage counted once in shared resources; not duplicated by engine',
  'physical_resource_mapping':'NOT_RUN','parent_phase_physical_sharing':'NOT_RUN'}
 (a.output/'report.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
if __name__=='__main__':main()
