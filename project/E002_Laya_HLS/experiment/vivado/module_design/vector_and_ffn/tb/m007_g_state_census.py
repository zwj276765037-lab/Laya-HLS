#!/usr/bin/env python3
"""Source declaration census, not synthesis/RAM inference or a physical fit.

Counts sequentially assigned storage once at its declaring owner. Wires,
combinational temporaries and module-port aliases are not duplicated. Fixed
numeric leaf pipelines and the frozen shared TANH service remain separate.
"""
import argparse,hashlib,json
from fractions import Fraction
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1]
ROOT=MODULE.parents[5]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False)
 records=[]
 def add(owner,name,bits,category,anchor,compression):
  source=MODULE/('rtl/'+owner+'.sv')if owner!='pre_credit32'else MODULE.parent/'attention_and_fp_engine/rtl/laya_return_vector_credit_v1.sv'
  text=source.read_text();assert anchor in text,(owner,name,'declaration changed; audit required')
  records.append({'owner':owner,'state':name,'bits':bits,'bytes_exact':str(Fraction(bits,8)),'category':category,'declaration_anchor':anchor,'compression_candidate_not_implemented':compression,'source':str(source.relative_to(ROOT))})
 math='laya_m007_g_math_v1';pair='laya_m007_g_pairs_v1';engine='laya_m007_g_engine_v1';pool='laya_m007_g_vector_pool_v1'
 add(math,'x_mem/gate_mem/result_mem',3*256*256,'bounded_arithmetic_payload','x_mem[0:255],gate_mem[0:255],result_mem[0:255]','x/gate payload is real delayed arithmetic data; output payload holds real blocked results, not derivable metadata')
 add(math,'tag_mem',256*96,'control_identity','tag_mem[0:255]','gen/epoch constant for one command; lower16 s-major vector sequence plus live state identifies reservation; request already single-owner')
 add(math,'numeric_bad/peer_bad/z_good_mem',3*256*8,'control_lane_masks','numeric_bad[0:255],peer_bad[0:255],z_good_mem[0:255]','actual per-lane errors and eligible domains are not generally derivable; possible lifetime reuse requires proof')
 add(math,'live/available/sent/received',4*256,'control_real_credit','live,available,sent,received','real live/returned/held state cannot be deleted as constant; ordered FIFO/range encoding is a future proved option')
 add(math,'reserve_ptr/head_ptr',16,'control_real_credit','reserve_ptr,head_ptr','real ordered queue position; could share a proved monotonic sequence representation')
 add(math,'expected_valid',9*4,'control_real_credit','expected_valid;','fixed latency validity is actual accepted FP request debt')
 add(math,'expected_tag',9*4*96,'control_identity','expected_tag[0:8][0:3]','gen/epoch constant; vector index compact16; node identity implicit in physical channel')
 add(math,'pre_tag',15*96,'control_identity','pre_tag[0:14]','constant generation/epoch and monotonic vector index; retain needed true valid alignment')
 add(math,'x_good_pipe',15*8,'control_lane_masks','x_good_pipe[0:14]','actual finite masks, may prove shorter lifetime but not discard numeric semantics')
 add(math,'x_delay',4*256,'fixed_numeric_alignment','x_delay[0:3]','real operand data, counted separately from control')
 add(math,'t_delay',7*256,'fixed_numeric_alignment','t_delay[0:6]','real operand data, counted separately from control')
 add(math,'t_tag',7*96,'control_identity','t_tag[0:6]','single-command constants/compact sequence; true alignment validation retained')
 add(math,'t_valid',7,'control_real_credit','t_valid;','actual accepted-return alignment')
 add(math,'ugood/vgood/tgood/zeligible_delay',(4+3+7+4)*8,'control_lane_masks','zeligible_delay[0:3]','actual original-domain masks')
 add(math,'h0/x0/r_aligned',3*256,'fixed_numeric_alignment','h0,x0,gate_delay[0:8],r_aligned','real operands/alignments')
 add(math,'gate_delay',9*256,'fixed_numeric_alignment','gate_delay[0:8]','real delayed gate operands')
 add(math,'post_tag/r_tag',(13+1)*96,'control_identity','post_tag[0:12],r_tag','command constants/compact vector index; valid and order still real')
 add(math,'post_valid/r_valid',14,'control_real_credit','post_valid;logic r_valid','actual accepted SFU/FP return progression')
 add(math,'post_good/yeligible/geligible_delay',(13+4+4)*8,'control_lane_masks','yeligible_delay[0:3],geligible_delay[0:3]','actual eligible numerical-domain masks')
 add(math,'pending/slot_pending/slot_sfu_debt/slot_fp_debt',9+18+18+16,'control_real_credit','output logic [1:0][7:0] slot_fp_debt','real total/slot debt must survive peer mismatches and held output; widths may be bounded with proof')
 add(math,'covered/evaluated',2*8*19,'control_coverage','covered,evaluated','actual stage coverage/evaluated counts; original-domain dominated counts derived by subtraction')
 add(math,'first_error record/protocol_fault',1+3+7+12+1,'control_error','output logic first_error_valid','actual lexicographic first error and fault record')
 add('pre_credit32','payload32x256',32*256,'bounded_arithmetic_payload','payload[DEPTH]','real pre-SFU returned values while SFU admission blocked')
 add('pre_credit32','tags32x96',32*96,'control_identity','tags[DEPTH]','single-command constants and compact vector index')
 add('pre_credit32','pointers/available/issued_valid/pending/in_flight/fault',3*5+32+15+2*6+1,'control_real_credit','logic[LATENCY-1:0]issued_valid','actual accepted and returned/held credit; aliases in math are not counted twice')
 add(pair,'coverage2x256',512,'control_coverage','logic [1:0][255:0] coverage','actual matching RAM-write ACK coverage; not set by producer intent')
 add(pair,'next_claim_s/write_sequence',7+16,'control_identity','logic [15:0] write_sequence','s monotonic; write sequence real ACK correlation may use tighter proved width')
 add(pair,'pending_slot/half_row/s/write_tag',1+8+7+96,'control_real_credit','logic pending_slot;','one actual accepted write metadata record; tag command constants and coordinates may be reconstructed with proof')
 add(pair,'bound/request_id/generation/epoch',1+64+32+32,'control_identity','output logic bound','one full command owner needed; reuse parent-validated binding requires explicit interface decision')
 add(pair,'slot_active/slot_s/issued_vectors/returned_vectors',2+14+20+20,'control_real_credit','output logic [1:0] slot_active','actual slot ownership/read debt; slot_s constrained parity/sequence but cannot assume away live ownership')
 add(pair,'write_pending/protocol_fault',2,'control_real_credit','output logic write_pending,protocol_fault','actual pending write and sticky peer fault')
 add(engine,'active/needs_discard/done_valid/status/error',1+1+1+32+3+7+12,'control_error','output logic engine_idle,active,needs_discard,protocol_fault','held status/identity lifecycle is real; status codes may be compact internal encoding')
 add(engine,'read_index/completed_groups/slot_consumed_vectors',16+7+20,'control_real_credit','logic [15:0] read_index','real accepted read/output/release counters; ordering may permit proved inferred coordinates')
 add(pool,'tags across seven mul4/two add3',(7*4+2*3)*96,'control_identity','logic [95:0] tags[0:LAT-1]','physical channel implicit node; command constants + compact vector index')
 add(pool,'valid_pipe/alignment_fault',7*4+2*3+9,'control_real_credit','logic [LAT-1:0] valid_pipe','actual FP request/leaf-return alignment and sticky fault')
 totals={}
 for q in records:totals[q['category']]=totals.get(q['category'],0)+q['bits']
 control=sum(q['bits']for q in records if q['category'].startswith('control_'))
 sources={q['source']:sha(ROOT/q['source'])for q in records}
 report={'schema':'m007-g-source-state-census-v1','status':'DECLARATION_CENSUS_COMPLETE','scope':'Exact listed sequential declarations at source widths, no synthesis/primitive optimization claim. Each owner storage counted once, port aliases excluded. Fixed56mul16add numerical leaf internals and frozen TANH8/SFU are separate and NOT deducted from this G control tally.','source_sha256':sources,'entries':records,'category_bits':totals,'category_bytes_exact':{k:str(Fraction(v,8))for k,v in totals.items()},'g_control_bits':control,'g_control_bytes_exact':str(Fraction(control,8)),'g_control_exceeds_4KiB':control>4096*8,'compression_status':'Candidate fields only; no compact implementation or shared-SFU protocol change applied','lower_bound_previously_reported_bytes':4352}
 (o/'report.json').write_text(json.dumps(report,indent=2)+'\n');print('G_SOURCE_STATE_CENSUS',json.dumps(report['category_bytes_exact']),'control_bytes',report['g_control_bytes_exact'],flush=True)
if __name__=='__main__':main()
