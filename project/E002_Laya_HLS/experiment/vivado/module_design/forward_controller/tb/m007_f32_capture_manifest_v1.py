#!/usr/bin/env python3
"""Validate actual observed public output serialization; never consume gold."""
import argparse,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--prefix',type=Path,required=True);p.add_argument('--run-manifest',type=Path,required=True);a=p.parse_args();prefix=str(a.prefix.resolve());meta=Path(prefix+'.capture.json');trace=Path(prefix+'.accepted.jsonl');binary=Path(prefix+'.f32.bin');m=json.loads(meta.read_text());assert m['complete']is True and m['commands']==1 and m['accepted_groups32']==m['unique_groups32']==4096 and m['coordinate_errors']==m['duplicate_errors']==0 and m['bytes']==524288
seen=set();observed=bytearray(524288)
with trace.open()as stream:
 for seq,line in enumerate(stream):
  q=json.loads(line);assert q['accept_seq']==seq and q['request_hex']==m['request_hex']and q['generation']==m['generation']and q['source_epoch']==m['source_epoch'];row,col=q['row'],q['col'];assert 0<=row<128 and 0<=col<1024 and col%32==0;key=row*32+col//32;assert key not in seen;seen.add(key);bits=q['data_hex_lane0_lsb'];assert len(bits)==256 and all(x in '0123456789abcdefABCDEF'for x in bits);raw=int(bits,16).to_bytes(128,'little');observed[key*128:(key+1)*128]=raw
assert len(seen)==4096 and binary.read_bytes()==observed
sha=lambda q:hashlib.sha256(q.read_bytes()).hexdigest();run=a.run_manifest.resolve();assert run.is_file();result={**m,'status':'ACTUAL_PUBLIC_OUTPUT_SERIALIZATION_PASS','data_sha256':sha(binary),'trace_sha256':sha(trace),'capture_metadata_sha256':sha(meta),'run_manifest':str(run),'run_manifest_sha256':sha(run),'observed_coordinate_coverage':len(seen),'data_file':str(binary),'trace_file':str(trace),'production_output_substitution':False,'gold_inputs_consumed':False};out=Path(prefix+'.validated_manifest.json');out.write_text(json.dumps(result,indent=2)+'\n');print('M007_ACTUAL_PUBLIC_CAPTURE_MANIFEST_PASS '+str(out)+' sha256='+result['data_sha256'])
