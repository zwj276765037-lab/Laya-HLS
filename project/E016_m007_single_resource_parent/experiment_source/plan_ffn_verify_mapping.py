#!/usr/bin/env python3
"""Read-only byte correspondence checks; no arithmetic oracle, new gold or EDA."""
import datetime as dt, hashlib, json, os, resource, time
from pathlib import Path
resource.setrlimit(resource.RLIMIT_AS,(1024**3,1024**3))
os.sched_setaffinity(0,{0,1,2,3})
started=time.monotonic()
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'project/E016_m007_single_resource_parent/experiment_results/planning/ffn_control_arena_20261022'
ORIG='project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT007_encoder0_real_local_reference/work'
PACK='project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT058_g_original_product_fixture/work'
MATRIX='project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture'
files=[]
def read(rel):
 b=(ROOT/rel).read_bytes();files.append({'path':rel,'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()});return b
report_raw=read(ORIG+'/report.json');report=json.loads(report_raw)
products={}
for name,d in report['products'].items():
 b=read(d['path']);assert hashlib.sha256(b).hexdigest()==d['sha256'];assert len(b)==d['bytes'];products[name]=b
wi=products['wi'];x=products['x'];gate=products['gate']
for row in range(128):
 assert wi[4*(row*5248):4*(row*5248+2624)]==x[4*row*2624:4*(row+1)*2624]
 assert wi[4*(row*5248+2624):4*(row+1)*5248]==gate[4*row*2624:4*(row+1)*2624]
pr=json.loads(read(PACK+'/report.json'))
assert hashlib.sha256(report_raw).hexdigest()==pr['reference_report_sha256']
names=pr['record_fields_msb_first'];assert names==['x','gate','u','v','w','t','z','h','r','s','y','geglu']
raw=read(PACK+'/geglu_vectors.hex');assert hashlib.sha256(raw).hexdigest()==pr['vectors_sha256']
lines=raw.splitlines();assert len(lines)==335872
for i,line in enumerate(lines):
 b=bytes.fromhex(line.decode());assert len(b)==48
 for n,name in enumerate(names):assert b[4*n:4*n+4][::-1]==products[name][4*i:4*i+4]
vectors=0
for s in range(82):
 for row in range(128):
  for chunk in range(4):
   seq=s*512+row*4+chunk
   assert (seq>>9,seq>>2&127,seq&3)==(s,row,chunk)
   for lane in range(8):
    scalar=row*2624+32*s+8*chunk+lane
    assert lines[scalar][:8].decode()==x[4*scalar:4*scalar+4][::-1].hex()
    assert lines[scalar][8:16].decode()==gate[4*scalar:4*scalar+4][::-1].hex()
   vectors+=1
folder=MATRIX+'/mlp_wi_0_weight'
fixture=json.loads(read(folder+'/fixture.json'))
expected=read(folder+'/expected_f32.bin');output=read(folder+'/output.hex').splitlines();assert len(output)==82*256
for s in range(82):
 for row in range(128):
  for half in range(2):
   col=32*s+2624*half;idx=s*256+row*2+half
   assert bytes.fromhex(output[idx].decode())[::-1]==expected[4*(row*5248+col):4*(row*5248+col+32)]
weight=read(folder+'/original_weight_q8.bin');assert hashlib.sha256(weight).hexdigest()==fixture['tensor_source']['source_sha256']
packed=[read(folder+f'/p{p}.bin')for p in range(4)]
weight_records=0
for s in range(82):
 for p in range(4):
  for group in range(32):
   off=(s*32+group)*576
   for lane in range(16):
    col=32*s+16*(p%2)+lane+(2624 if p>=2 else 0)
    blk=weight[34*(col*32+group):34*(col*32+group+1)]
    assert packed[p][off+32*lane:off+32*lane+32]==blk[2:]
    assert packed[p][off+512+2*lane:off+514+2*lane]==blk[:2]
    weight_records+=1
wi_source=read(folder+'/source_f32.bin')
downfolder=MATRIX+'/mlp_wo_0_weight';dfixture=json.loads(read(downfolder+'/fixture.json'));downsource=read(downfolder+'/source_f32.bin')
def equal_rows(a,b,width):return [row for row in range(128)if a[4*row*width:4*(row+1)*width]==b[4*row*width:4*(row+1)*width]]
same_wi=equal_rows(wi_source,products['norm_ff'],1024);same_down=equal_rows(downsource,products['geglu'],2624)
result={'schema':'m007-ffn-read-only-mapping-v1','status':'BYTE_CORRESPONDENCE_PASS','scope':'Existing original products and packed fixture layout only; no new numeric gold, RTL, EDA or performance run','original_wi_shape':[128,5248],'g_shape':[128,2624],'original_wi_to_x_gate_values':671744,'AT058_fields_bitwise_checked':335872*12,'g_vector_addresses_checked':vectors,'matrix_wi_output_beats_checked':len(output),'matrix_wi_output_values_checked':len(output)*32,'original_weight_records_checked':weight_records,'original_weight_bytes_checked':weight_records*34,'native_schedule':list(range(82)),'candidate_0_41_reorder':'REJECTED: every native block already contains both halves; paired block indices are not original half indices','mapping':{'Wi_column':'32*s + local_column%32 + (2624 if local_column>=32 else 0)','Wi_output_order':'s 0..81, row 0..127, half 0 then1, lane 0..31','W_port_column':'32*s + 16*(p%2) + lane + (2624 if p>=2 else0)','W_offset_per_port':'base[p] + s*32*576; each block32 records576B','G_fill':'slot=s%2, fill_s=s, fill_half=(out_col>=2624), fill_row=out_row','G_read_output_order':'s 0..81, row 0..127, chunk 0..3; lane0..7','G_seq':'s*512+row*4+chunk','G_original_scalar':'row*2624+32*s+8*chunk+lane','G_gate_input':'Wi[:,2624:] (the multiplicative gate/value; distinct from GELU intermediate v)','G_x_input':'Wi[:,:2624] (GELU input; distinct from GELU z)'},'fixture_boundary':{'E012_Wi_input_matches_AT007_norm_ff_rows':same_wi,'E012_Down_input_matches_AT007_G_rows':same_down,'E012_Wi_classification':fixture['activation_classification'],'E012_Down_classification':dfixture['activation_classification'],'full_same_runtime_down_gold_available_from_these_files':len(same_down)==128,'warning':'E012 mixed diagnostic fixtures are layout/weight evidence; they are not full128-row original FFN chain expected results.'},'files':files}
(OUT/'mapping_byte_checks.json').write_text(json.dumps(result,indent=2)+'\n')
elapsed=time.monotonic()-started;assert elapsed<20
receipt={'stage':'mapping_byte_checks','started_at':dt.datetime.now(dt.timezone.utc).isoformat(),'elapsed_s':elapsed,'peak_self_rss_kb':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'peak_child_rss_kb':0,'address_space_limit_bytes':1024**3,'timeout_s':20,'cpu_ids':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'ionice':'idle actual launch','files':files,'scope':result['scope']}
(OUT/'mapping_byte_checks_read_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
receipts=[json.loads(q.read_text())for q in sorted(OUT.glob('*_read_receipt.json'))];used=sum(x['elapsed_s']for x in receipts);assert used<=60
(OUT/'planning_ledger.json').write_text(json.dumps({'limits_s':{'planning_read':60},'used_s':used,'remaining_s':60-used,'receipts':receipts,'R003_balances_transferred':False},indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items()if k!='files'},indent=2));print('M007_FFN_BYTE_CHECK_PASS elapsed_s',elapsed,'RSS_KiB',receipt['peak_self_rss_kb'])
