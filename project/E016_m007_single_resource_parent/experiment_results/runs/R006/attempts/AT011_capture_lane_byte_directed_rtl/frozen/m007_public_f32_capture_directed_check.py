#!/usr/bin/env python3
"""Independently check observer-test bytes; never create an actual-data artifact."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path


def check(prefix,case,manifest_tool):
    metadata=json.loads(Path(str(prefix)+'.capture.json').read_text())
    total=16 if case==5 else 4095 if case==6 else 4096
    assert metadata['complete']is(case==0)
    assert metadata['request_hex']=='0123456789abcdef'
    assert metadata['generation']==17 and metadata['source_epoch']==29
    assert metadata['commands']==1 and metadata['layer']==0 and metadata['kind']==4
    assert metadata['input_unique_groups32']==metadata['unique_groups32']==total
    assert metadata['input_accepted_groups32']==metadata['accepted_groups32']==(18 if case==5 else total)
    assert metadata['input_errors']==(2 if case==5 else 0)
    assert metadata['coordinate_errors']==metadata['duplicate_errors']==(1 if case==5 else 0)
    assert metadata['parent_receipts_consumed']==(0 if case==1 else 1)
    assert metadata['successful_parent_receipts_consumed']==(0 if case in(1,2,3)else 1)
    assert metadata['all_resources_retired']is(case!=3)
    stream_results=[]
    for stream_id,suffix,multiplier,offset in[(0,'.input',2053,97),(1,'',3077,243)]:
        trace=Path(str(prefix)+suffix+'.accepted.jsonl')
        binary=Path(str(prefix)+suffix+'.f32.bin')
        records=[json.loads(line)for line in trace.read_text().splitlines()]
        assert len(records)==(18 if case==5 else total)
        actual=binary.read_bytes()
        checked_addresses=set()
        checked_bytes=0
        last_cycle=-1
        for seq,record in enumerate(records[:total]):
            address=(seq*multiplier+offset)%4096
            assert record['accept_seq']==seq and record['cycle']>last_cycle
            assert record['row']==address//32 and record['col']==address%32*32
            assert record['request_hex']==metadata['request_hex']and record['generation']==17 and record['source_epoch']==29
            # Bytewise independent reference. Every lane and octet is covered.
            expected=bytes((address*13+lane*17+octet*67+stream_id*37)%256 for lane in range(32)for octet in range(4))
            assert bytes.fromhex(record['data_hex_lane0_lsb'])[::-1]==expected
            assert actual[address*128:(address+1)*128]==expected,(case,suffix,address)
            checked_addresses.add(address);checked_bytes+=128;last_cycle=record['cycle']
        assert len(checked_addresses)==total
        if case!=5:assert len(actual)==524288
        if case in(0,1,2,3,4):
            verified=manifest_tool.verify_stream(prefix,metadata,bool(stream_id==0))
            assert verified['unique_groups32']==4096
        stream_results.append({'stream':'input'if stream_id==0 else'output','checked_groups':total,'checked_bytes':checked_bytes,'binary_bytes':len(actual),'binary_sha256':hashlib.sha256(actual).hexdigest(),'trace_sha256':hashlib.sha256(trace.read_bytes()).hexdigest()})
    return {'case':case,'complete_expected':case==0,'complete_actual':metadata['complete'],'streams':stream_results,'scope':'synthetic observer serialization and completeness only; no production model run'}


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--work',type=Path,required=True);parser.add_argument('--verifier',type=Path,required=True);args=parser.parse_args()
    spec=importlib.util.spec_from_file_location('capture_manifest',args.verifier);tool=importlib.util.module_from_spec(spec);spec.loader.exec_module(tool)
    rows=[check(args.work/f'case{case}',case,tool)for case in range(7)]
    result={'status':'PASS','test_cases':rows,'lane_count':32,'octets_per_lane':4,'out_of_order_full_coverage':True,'model_or_gold_data_used':False,'downstream_artifact_eligibility':False}
    (args.work/'capture_directed_checks.json').write_text(json.dumps(result,indent=2)+'\n')
    print('HARDWARE_AGENT_SIM_PASS M007_CAPTURE_DIRECTED_INDEPENDENT cases=7 lanes=32 octets=4')


if __name__=='__main__':main()
