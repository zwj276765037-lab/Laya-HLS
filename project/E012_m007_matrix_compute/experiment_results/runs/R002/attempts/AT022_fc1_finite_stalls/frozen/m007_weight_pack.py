#!/usr/bin/env python3
"""M007-W576-v1: lossless source-byte packing; no numerical conversion."""
import argparse, hashlib, json, os
from pathlib import Path
LAYOUT='M007-W576-v1'
def sha(b): return hashlib.sha256(b).hexdigest()
def column(n,s,p,c): return (32*s+16*(p%2)+c+(2624 if p>=2 else 0)) if n==5248 else 64*s+16*p+c
def inverse(n,c):
    if n==5248:
        h,u=divmod(c,2624);s,r=divmod(u,32);return s,2*h+r//16,r%16
    s,r=divmod(c,64);return s,r//16,r%16

def pack_superblock(gguf,offset,k,n,s):
    gcount=k//32;out=[bytearray() for _ in range(4)]
    for p in range(4):
        for g in range(gcount):
            rec=bytearray(576)
            for c in range(16):
                col=column(n,s,p,c);gguf.seek(offset+34*(col*gcount+g));block=gguf.read(34)
                if len(block)!=34:raise ValueError('truncated GGUF')
                rec[32*c:32*c+32]=block[2:];rec[512+2*c:514+2*c]=block[:2]
            out[p].extend(rec)
    return out

def verify_independent(ports,gguf,offset,k,n,s,weight,bos):
    """Inverse via original column addresses, plus independently addressed old TN8 BOs."""
    groups=k//32;window=bytearray();bo_checked=0
    cols=sorted(column(n,s,p,c) for p in range(4) for c in range(16))
    for col in cols:
        ss,p,c=inverse(n,col)
        assert ss==s
        for g in range(groups):
            r=ports[p][576*g:576*(g+1)];restored=r[512+2*c:514+2*c]+r[32*c:32*c+32]
            gguf.seek(offset+34*(col*groups+g));original=gguf.read(34)
            assert restored==original,(col,g,'GGUF inverse mismatch')
            # Independent original exporter TN8 BO layout, not W576 addressing.
            tile,lane=divmod(col,8);shard=tile&1
            qaddr=weight['q_base'][shard]+((tile//2)*groups+g)*256+lane*32
            saddr=weight['scale_base']+((tile*groups+g)*8+lane)*2
            bos[shard].seek(qaddr);bos[2].seek(saddr)
            assert bos[2].read(2)+bos[shard].read(32)==original,(col,g,'old BO mismatch')
            window.extend(original);bo_checked+=34
    assert all(not any(port[i+544:i+576]) for port in ports for i in range(0,len(port),576))
    return {'original_column_major_window_sha256':sha(window),'original_window_bytes':len(window),'inverse_checked_bytes':len(window),'old_bo_checked_bytes':bo_checked}

def main():
    p=argparse.ArgumentParser();p.add_argument('--map',required=True,type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args()
    mapping=json.loads(a.map.read_text());mp=Path(mapping['manifest']['path']);raw=mp.read_bytes()
    assert sha(raw)==mapping['manifest']['sha256'],'manifest drift'
    manifest=json.loads(raw);a.out.mkdir(parents=True,exist_ok=True)
    ggpath=Path(mapping['remapped_source_model_path']);bos=[(mp.parent/manifest['bo'][key]['file']).open('rb') for key in ('w_q0','w_q1','w_scale')]
    reports=[]
    with ggpath.open('rb') as gf:
        for index,r in enumerate(mapping['records']):
            k,n=r['K'],r['N'];s=81 if n==5248 else 0
            ports=pack_superblock(gf,r['tensor_descriptor']['source_offset'],k,n,s)
            verify=verify_independent(ports,gf,r['tensor_descriptor']['source_offset'],k,n,s,r['weight_descriptor'],bos)
            d=a.out/r['tensor'].replace('.','_');d.mkdir(exist_ok=True)
            files=[]
            for port,b in enumerate(ports):
                (d/f'p{port}.bin').write_bytes(b)
                (d/f'p{port}.hex').write_text(''.join(b[i:i+64][::-1].hex()+'\n' for i in range(0,len(b),64)))
                files.append({'port':port,'bytes':len(b),'sha256':sha(b),'file':str(d/f'p{port}.bin')})
            # Independent public-cache expected data from original GGUF, not pack output.
            with (d/'expected.hex').open('w') as exp:
                for g in range(k//32):
                    for port in range(4):
                        q=bytearray();sc=bytearray()
                        for c in range(16):
                            gf.seek(r['tensor_descriptor']['source_offset']+34*(column(n,s,port,c)*(k//32)+g));blk=gf.read(34);sc.extend(blk[:2]);q.extend(blk[2:])
                        exp.write((q+sc)[::-1].hex()+'\n')
            rec={'layout':LAYOUT,'layout_version':1,'tensor':r['tensor'],'K':k,'N':n,'G':k//32,'s':s,'model_sha256_inherited':mapping['stored_source_model']['sha256'],'model_full_sha_recomputed':False,'source_gguf':str(ggpath),'source_tensor':r['tensor_descriptor'],'old_bos':[{'path':str(mp.parent/manifest['bo'][key]['file']),'sha256_inherited':manifest['bo'][key]['sha256']} for key in ('w_q0','w_q1','w_scale')],'manifest_sha256':sha(raw),'ports':files,'matrix_port_span':576*(k//32)*(82 if n==5248 else n//64),'superblock_matrix_offset':576*(k//32)*s,'next_matrix_placement_gap':(-576*(k//32)*(82 if n==5248 else n//64))%4096,**verify}
            (d/'layout.json').write_text(json.dumps(rec,indent=2)+'\n');reports.append(rec)
    for f in bos:f.close()
    (a.out/'packing_report.json').write_text(json.dumps({'layout':LAYOUT,'cases':reports,'verdict':'PASS','scope':'four complete true-source superblocks; not full 120 tensor package'},indent=2)+'\n')
    print('M007_WEIGHT_PACK_PASS cases=4 inverse_bytes='+str(sum(r['inverse_checked_bytes'] for r in reports)),flush=True)
if __name__=='__main__':main()
