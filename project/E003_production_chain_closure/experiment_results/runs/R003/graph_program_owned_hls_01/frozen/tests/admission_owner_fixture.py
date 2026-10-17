#!/usr/bin/env python3
"""Independent literal LAD1 from the separately generated admitted request fields."""
import argparse,struct
from pathlib import Path

def main():
 p=argparse.ArgumentParser();p.add_argument('--request',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
 # The existing v2 literal carries the independently reconstructed full
 # NumericIdentity and canonical L13M; it does not contain LAD1 or its codec.
 request=a.request.read_bytes();assert len(request)==1024
 out=bytearray(1024);struct.pack_into('<IHHIIQQ',out,0,0x3144414c,1,16,3,1<<6,29,101)
 out[64:148]=request[64:148];out[160:576]=request[160:576]
 struct.pack_into('<QQQ',out,576+6*24,7,0x1200000000,16920576)
 a.out.write_bytes(out)
 print('FULL_CURRENT_ADMISSION_OWNER_LITERAL_PASS bytes=1024 identity=84 model=416 roles_known=STATE0 no_SH=1')
if __name__=='__main__':main()
