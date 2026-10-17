#!/usr/bin/env python3
"""Publish a separate tile binding only from matching actual module receipts."""
from pathlib import Path
import argparse,hashlib,json,re

def rec(p):
 b=p.read_bytes();return dict(path=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())

p=argparse.ArgumentParser();p.add_argument('attempt',type=Path);p.add_argument('--manifest',required=True);p.add_argument('--rtl-result',type=Path,required=True);p.add_argument('--ooc-result',type=Path,required=True);p.add_argument('--cpu-result',type=Path,required=True);args=p.parse_args()
a=args.attempt.resolve();m=Path(__file__).resolve().parents[1];identity=a/args.manifest
source=json.loads(identity.read_text())
for r in source['sources']:assert rec(Path(r['frozen']['path']))==r['frozen']
proofs={}
for kind,path in [('module_rtl',args.rtl_result),('module_ooc',args.ooc_result),('c_model',args.cpu_result)]:
 path=path.resolve();r=json.loads(path.read_text());assert r['status']=='PASS' and r['guard']['child_exit_code']==0 and r['guard']['trigger'] is None
 if kind!='c_model':assert r['source_manifest_sha256']==rec(identity)['sha256'],kind
 proofs[kind]=dict(receipt=rec(path),scope=r['scope'])
 if kind=='module_ooc':assert r['blackboxes']==0;resources=r['resources']
cpu_manifest=json.loads((a/'cpu_01/input_manifest.json').read_text())
for r in cpu_manifest['sources']:
 assert rec(Path(r['frozen']['path']))==r['frozen']
 assert rec(Path(r['source']['path']))==r['source']
params=[dict(c_name=n,c_port_direction='in',rtl_ports=dict(data_read_in=n)) for n in ['command','index','payload','epoch']]
params += [dict(c_name=n,c_port_direction='out',rtl_ports=dict(data_write_out=n,data_write_valid=n+'_ap_vld')) for n in ['result','status']]
closure=json.loads((a/'rtl_closure.json').read_text())
for r in [*closure['rtl'],*closure['ip_tcl'],*closure['memory_init']]:assert rec(Path(r['path']))==r
rtl=[Path(x['path']) for x in closure['rtl']]
record=dict(c_function_name='laya_attention_tile_service',rtl_top_module_name='attention_tile_service_v1',
 c_files=[dict(c_file=str(m/'source'/n),cflag='-I'+str(m/'source')+' -std=c++17 -fno-fast-math -ffp-contract=off') for n in ['attention_tile_service.cpp','attention_exp_bits.cpp']],
 rtl_files=[str(x) for x in rtl],c_parameters=params,
 rtl_common_signal=dict(module_clock='ap_clk',module_reset='ap_rst',module_clock_enable='ap_ce',ap_ctrl_chain_protocol_idle='ap_idle',ap_ctrl_chain_protocol_start='ap_start',ap_ctrl_chain_protocol_ready='ap_ready',ap_ctrl_chain_protocol_done='ap_done',ap_ctrl_chain_protocol_continue='ap_continue'),
 rtl_performance=dict(latency='1',II='1'),
 rtl_resource_usage={k:str(resources[v]) for k,v in [('FF','FF'),('LUT','LUT'),('BRAM','BRAM18_equivalent'),('URAM','URAM'),('DSP','DSP')]})
target=m/'source/blackbox/laya_attention_tile_service.json';target.write_text(json.dumps(record,indent=2)+'\n')
ip=[Path(x['path']) for x in closure['ip_tcl']];data=[Path(x['path']) for x in closure['memory_init']]
inputs=[*rtl,*ip,*data,identity,a/'helper_ce_manifest.json',a/'rtl_closure.json',a/'cpu_01/input_manifest.json',Path(__file__).resolve()]
inputs += [m/'source'/n for n in ['attention_tile_service.cpp','attention_tile_service.h','attention_exp_bits.cpp','attention_exp_bits.h']]
(target.parent/'tile_dependencies.json').write_text(json.dumps(dict(schema='attention-tile-blackbox-dependencies-v1',status='MODULE_PASS_PRODUCTION_GENERATED_CALLER_PENDING',source_manifest=rec(identity),module_verification=proofs,
 scheduler_metadata_is_measurement=False,ip_setup_tcl=[str(x) for x in ip],memory_init=[str(x) for x in data],inputs=[rec(x) for x in inputs],
 integration_requirement='One generated caller/service instance, actual variable-latency chain retirement; preserve 13BO owner/lease/output behavior; B2 legacy fallback remains separately verified.',
 resource_scope='Measured standalone full-capacity tile OOC; all physical M16/A16/D4/EXP4 and RAM paid; no full-top/P&R or realized frequency claim.'),indent=2)+'\n')
print('ATTENTION_SERVICE_TILE_BLACKBOX_READY '+str(target))
