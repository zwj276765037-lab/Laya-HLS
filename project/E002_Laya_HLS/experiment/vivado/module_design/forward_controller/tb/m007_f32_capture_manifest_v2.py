#!/usr/bin/env python3
"""Verify direct public-handshake artifacts; never reconstruct from a checker."""
import argparse
import hashlib
import json
from pathlib import Path


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def read(path):return json.loads(path.read_text())


def verify_stream(prefix,metadata,input_stream=False):
    suffix='.input'if input_stream else''
    trace=Path(str(prefix)+suffix+'.accepted.jsonl');binary=Path(str(prefix)+suffix+'.f32.bin')
    seen=set();observed=bytearray(524288);last_cycle=-1
    with trace.open()as stream:
        for seq,line in enumerate(stream):
            record=json.loads(line)
            assert record['accept_seq']==seq and record['cycle']>last_cycle
            assert record['request_hex']==metadata['request_hex'] and record['generation']==metadata['generation'] and record['source_epoch']==metadata['source_epoch']
            row,col=record['row'],record['col'];assert 0<=row<128 and 0<=col<1024 and col%32==0
            address=row*32+col//32;assert address not in seen;seen.add(address)
            bits=record['data_hex_lane0_lsb'];assert len(bits)==256 and all(x in'0123456789abcdefABCDEF'for x in bits)
            observed[address*128:(address+1)*128]=int(bits,16).to_bytes(128,'little')
            last_cycle=record['cycle']
    assert len(seen)==4096 and binary.stat().st_size==524288 and binary.read_bytes()==observed
    return {'binary':str(binary),'data_sha256':sha(binary),'bytes':524288,'trace':str(trace),'trace_sha256':sha(trace),'unique_groups32':len(seen),'last_accept_cycle':last_cycle}


def main():
    p=argparse.ArgumentParser();p.add_argument('--prefix',type=Path,required=True);p.add_argument('--attempt',type=Path,required=True);a=p.parse_args()
    prefix=a.prefix.resolve();attempt=a.attempt.resolve();metadata_path=Path(str(prefix)+'.capture.json');m=read(metadata_path)
    assert m['schema']=='m007-observed-public-f32-v2' and m['complete']is True
    assert m['commands']==m['parent_receipts_consumed']==m['successful_parent_receipts_consumed']==1 and m['all_resources_retired']is True
    assert m['accepted_groups32']==m['unique_groups32']==m['input_accepted_groups32']==m['input_unique_groups32']==4096
    assert m['coordinate_errors']==m['duplicate_errors']==m['input_errors']==0
    output=verify_stream(prefix,m);source=verify_stream(prefix,m,True)
    assert output['last_accept_cycle']<m['actual_terminal_cycle']
    receipt=read(attempt/'receipt_rtl.json');assert receipt['verdict']=='PASS'
    fixture_identity=read(attempt/'fixture_identity.json');build=Path(fixture_identity['build']);build_manifest=read(build/'source_manifest.json')
    assert sha(build/'source_manifest.json')==fixture_identity['build_manifest_sha256']
    fixtures=read(attempt/'fixture_manifest.json')
    checker=[r for r in fixtures['files']if r.get('role')=='CHECKER_ONLY_NEVER_PRODUCER'and r['path'].endswith('encoder_00_out.f32.bin')]
    initial=[r for r in fixtures['files']if r.get('role')=='ONLY_INITIAL_PUBLIC_H_INPUT'and r['path'].endswith('embedding_norm.f32.bin')]
    if m['kind']==4:
        assert m['layer']==0 and len(checker)==len(initial)==1
        assert source['data_sha256']==initial[0]['sha256']
    # Checker identity comes from the immutable run manifest. No checker values
    # are read by this serialization verifier; the RTL TB performed comparison.
    result={'schema':'m007-actual-public-data-chain-manifest-v2','status':'ACTUAL_PUBLIC_INPUT_OUTPUT_SERIALIZATION_PASS','complete':True,'scope':'same-runtime Encoder0 final H'if m['kind']==4 else'legacy public FFN Down','request_hex':m['request_hex'],'generation':m['generation'],'source_epoch':m['source_epoch'],'layer':m['layer'],'kind':m['kind'],'shape':[1,128,1024],'input_actual':source,'output_actual':output,'parent_terminal_cycle':m['actual_terminal_cycle'],'terminal_receipt':str(attempt/'receipt_rtl.json'),'terminal_receipt_sha256':sha(attempt/'receipt_rtl.json'),'source_manifest':str(build/'source_manifest.json'),'source_manifest_sha256':sha(build/'source_manifest.json'),'parent_v2_sha256':build_manifest['parent_v2_sha256'],'runtime_fixture_identity_sha256':sha(attempt/'fixture_identity.json'),'compiled_snapshot_initial_identity':fixture_identity['snapshot_files'],'fixture_manifest_sha256':sha(attempt/'fixture_manifest.json'),'independent_checker_identity':checker,'capture_metadata_sha256':sha(metadata_path),'producer_substitution':False,'gold_values_consumed_by_this_postprocessor':False,'serialization':'row-major,lane0-first,F32bits-little-endian','safe_for_later_chain_only_when_complete_and_matching_context':True}
    out=Path(str(prefix)+'.validated_manifest.json');out.write_text(json.dumps(result,indent=2)+'\n')
    print('M007_ACTUAL_PUBLIC_DATA_CHAIN_MANIFEST_PASS '+str(out)+' output_sha256='+output['data_sha256'])


if __name__=='__main__':main()
