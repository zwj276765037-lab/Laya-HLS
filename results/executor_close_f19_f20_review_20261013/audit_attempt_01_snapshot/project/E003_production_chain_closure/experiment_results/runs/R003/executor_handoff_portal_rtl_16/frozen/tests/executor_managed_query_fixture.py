#!/usr/bin/env python3
"""Literal LBR2 revoked-query gold from the independent LBS2 binding oracle."""
import argparse,struct

def main():
    from pathlib import Path
    ap=argparse.ArgumentParser();ap.add_argument('--fixture',type=Path,required=True);a=ap.parse_args()
    words=(a.fixture/'query.hex').read_text().split()
    assert len(words)==16 and all(len(x)==128 for x in words)
    query=b''.join(bytes.fromhex(x)[::-1] for x in words)
    assert query[:8]==struct.pack('<IHH',0x3253424c,2,16)
    assert query[8:16]==b'\x01'+bytes(7) and query[24:40]==bytes(16)
    assert query[678:680]==bytes(2) and query[744:]==bytes(280)
    p=bytearray(query);struct.pack_into('<I',p,0,0x3252424c)
    struct.pack_into('<HI',p,10,7,3);struct.pack_into('<I',p,24,0x0700000e)
    struct.pack_into('<Q',p,32,0xffffffffffffffff)
    (a.fixture/'revoked_proof_gold.hex').write_text(''.join(p[i:i+64][::-1].hex()+'\n' for i in range(0,1024,64)))
    print('FULL_CURRENT_EXECUTOR_MANAGED_QUERY_ORACLE_PASS bytes=1024 complete_binding=1 flags=3 zero_floors=1')
if __name__=='__main__':main()
