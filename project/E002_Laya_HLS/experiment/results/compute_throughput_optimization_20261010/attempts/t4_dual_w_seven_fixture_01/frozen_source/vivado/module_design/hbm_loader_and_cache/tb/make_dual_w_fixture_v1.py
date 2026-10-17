#!/usr/bin/env python3
"""Extract complete frozen r2 seven-shape weights and real AUX/bias fixtures."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path

MANIFEST_SHA='46bbd5abeeadc2d4305419d3129fd871aaeb04e962821ac4c6a6da957698018c'
WEIGHTS=(('wi','mlp_wi.0.weight'),('down','mlp_wo.0.weight'),
         ('act','act_fc2.weight'),('scorer','scorer_fc1.weight'),
         ('qkv','qkv.0.weight'),('decfc1','head_fc1.0.weight'),
         ('decfc2','head_fc2.0.weight'))

def digest(data:bytes)->str:
    return hashlib.sha256(data).hexdigest()

def emit(data:bytes,width:int)->str:
    if not data:
        data=bytes(width)
    return ''.join(f'{int.from_bytes(data[i:i+width],"little"):0{width*2}x}\n'
                   for i in range(0,len(data),width))

def main()->None:
    ap=argparse.ArgumentParser()
    ap.add_argument('manifest',type=Path)
    ap.add_argument('strict_inputs',type=Path)
    ap.add_argument('output',type=Path)
    a=ap.parse_args()
    manifest=a.manifest.resolve(strict=True)
    raw=manifest.read_bytes()
    assert digest(raw)==MANIFEST_SHA,'frozen r2 manifest identity'
    m=json.loads(raw);weights={w['name']:w for w in m['weights']}
    register=[int(x,16) for x in (a.strict_inputs/'register.hex').read_text().split()]
    assert len(register)==256 and register[0]==0x32533851 and register[64]==0
    model_words=register[32:48]+register[64:152]
    model_raw=b''.join(x.to_bytes(4,'little') for x in model_words)
    out=a.output.resolve()
    if out.exists(): raise FileExistsError('fresh fixture required')
    out.mkdir(parents=True)
    (out/'model_identity.hex').write_text(emit(model_raw,416))
    with (manifest.parent/'aux.bin').open('rb') as f: header=f.read(128)
    assert len(header)==128
    expected_header=b''.join(int(x,16).to_bytes(4,'little') for x in
                              (a.strict_inputs/'aux_header.hex').read_text().split())
    assert header==expected_header,'actual frozen AUX header'
    (out/'aux_header.hex').write_text(emit(header,16))
    (out/'expected_aux_header.hex').write_text(emit(header,128))
    records=[]
    for label,name in WEIGHTS:
        w=weights[name];G=w['K']//32;T=(w['N']+7)//8
        assert w['dtype']==8 and w['K']%32==0
        assert w['q_span']==[((T+1)//2)*G*256,(T//2)*G*256]
        assert w['scale_span']==T*G*16
        assert w['bias_span'] in (0,w['N']*4)
        assert ((T+1)//2)*G<=10496
        cfg=(w['K'],w['N'],w['family']|(w['layer']<<8),
             *w['q_base'],w['scale_base'],*w['q_span'],w['scale_span'],
             w['bias_base'],w['bias_span'],G,T)
        (out/f'{label}_config.hex').write_text(''.join(f'{v:016x}\n' for v in cfg))
        streams=[]
        for role,filename,offset,size,width in (
            ('q0','w_q0.bin',w['q_base'][0],w['q_span'][0],64),
            ('q1','w_q1.bin',w['q_base'][1],w['q_span'][1],64),
            ('scale','w_scale.bin',w['scale_base'],w['scale_span'],64),
            ('bias','aux.bin',w['bias_base'],w['bias_span'],4)):
            with (manifest.parent/filename).open('rb') as f:
                f.seek(offset);payload=f.read(size)
            assert len(payload)==size
            text=emit(payload,width)
            path=out/f'{label}_{role}.hex';path.write_text(text)
            streams.append({'role':role,'source':str(manifest.parent/filename),
                            'offset':offset,'bytes':size,'sha256':digest(payload),
                            'hex_path':str(path),'hex_sha256':digest(text.encode())})
        records.append({'name':label,'weight':name,'K':w['K'],'N':w['N'],
                        'G':G,'T':T,'streams':streams})
    fm={'schema':'t4_dual_w_fixture_v1','source_manifest':str(manifest),
        'source_manifest_sha256':MANIFEST_SHA,'generator_sha256':digest(Path(__file__).read_bytes()),
        'strict_input_manifest':str((a.strict_inputs/'manifest.json').resolve()),
        'cases':records,'files':{p.name:{'bytes':p.stat().st_size,
          'sha256':digest(p.read_bytes())} for p in sorted(out.iterdir()) if p.is_file()}}
    (out/'fixture_manifest.json').write_text(json.dumps(fm,indent=2,sort_keys=True)+'\n')
    print('T4_DUAL_W_FIXTURE_PASS',[(r['name'],sum(s['bytes'] for s in r['streams'])) for r in records])

if __name__=='__main__': main()
