#!/usr/bin/env python3
"""Independent literal LBS2/LBR2 oracle; v1 oracle remains unchanged."""
import argparse
from pathlib import Path
import struct
import subprocess
import sys

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--model-header', type=Path, required=True)
    ap.add_argument('--model-aux', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    args = ap.parse_args()
    args.output.mkdir(exist_ok=False)
    subprocess.run([sys.executable, str(Path(__file__).with_name('executor_bootstrap_fixture.py')),
        '--model-header', str(args.model_header), '--model-aux', str(args.model_aux),
        '--output', str(args.output/'v1')], check=True)
    request = bytearray(1024)
    request[:664] = (args.output/'v1/snapshot_request.bin').read_bytes()[:664]
    struct.pack_into('<IHH', request, 0, 0x3253424c, 2, 16)
    # mode, Buffer::NORM, bank, region, Bo::STATE0, reserved response state
    struct.pack_into('<H6B', request, 672, 1, 2, 0, 0, 6, 0, 0)
    struct.pack_into('<8Q', request, 680, 19, 7, 0x1200000000, 16920576,
                     8388608, 262144, 4096, 4194304)
    response = bytearray(request)
    struct.pack_into('<I', response, 0, 0x3252424c)
    struct.pack_into('<I', response, 12, 255)
    struct.pack_into('<Q', response, 32, (1 << 64) - 1)
    response[678] = 2 # old inactive target
    struct.pack_into('<5I', response, 744, 15, 15, 4, 1, 7)
    struct.pack_into('<Q', response, 768, 23) # actual transport may exceed event count
    for name, data in [('checkpoint_request', request), ('checkpoint_response', response)]:
        (args.output/(name+'.bin')).write_bytes(data)
        (args.output/(name+'.hex')).write_text(''.join(
            data[i:i+64][::-1].hex()+'\n' for i in range(0, 1024, 64)))
    print('FULL_CURRENT_EXECUTOR_CHECKPOINT_FIXTURE_PASS v2_bytes=2048 v1_bytes=1536')

if __name__ == '__main__': main()
