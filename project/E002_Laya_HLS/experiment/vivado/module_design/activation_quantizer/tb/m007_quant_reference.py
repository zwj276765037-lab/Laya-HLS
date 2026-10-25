#!/usr/bin/env python3
"""Independent QUANT03 fixtures from the frozen original arithmetic, never RTL."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import struct
import sys
import warnings

import numpy as np

ROOT=Path(__file__).resolve().parents[4]
REFERENCE=ROOT/'tests/full_reference.py'
REFERENCE_SHA='fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784'
ACTUAL=ROOT/'results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128/embedding_norm.f32.bin'
ACTUAL_SHA='5d88293829ae60ee880f931cb863fcccfa82aa41dd8ed46f791ec2e484213056'
LEGACY=ROOT/'results/cpu_embedding_q8_validation_20261010/attempts/task2_real_fixture_20/work/fixtures'
PINNED={'qkv_rows4_source_f32.bin':'a09f55f5da3f5dd8a879a972fd57dcad428bafd5d2eda2941d36e9cdc3a3bb7e',
        'qkv_rows4_a8_q.bin':'1db568e2c4fc97ae1d29e541d3f23929ec73e497826a778b8f9eb02b9fb4f28d',
        'qkv_rows4_a8_scale.bin':'e9c9645f745f88be8483cc6b85c8071fdd146693508755811650aaf74dc7b33f'}


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def bits(x):return int(np.asarray(x,dtype='<f4').view('<u4'))
def fbits(b):return np.asarray(b,dtype='<u4').view('<f4')[()]
def line(data):return bytes(data)[::-1].hex()


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    a.output.mkdir(parents=True,exist_ok=True)
    assert sha(REFERENCE)==REFERENCE_SHA and sha(ACTUAL)==ACTUAL_SHA
    spec=importlib.util.spec_from_file_location('m007_quant_original',REFERENCE);ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref)
    report={'status':'RUNNING','reference_sha256':REFERENCE_SHA,'numpy':np.__version__,'input_sha256':ACTUAL_SHA,'cases':[],'files':{}}
    raw=ACTUAL.read_bytes();assert len(raw)==524288
    actual=np.frombuffer(raw,dtype='<f4').reshape(128,1024)
    packed=ref.quantize_many(actual)
    assert len(packed)==4096*34
    groups=np.frombuffer(packed,dtype=ref.Q8_DTYPE).reshape(128,32)
    for name,expected in PINNED.items():assert sha(LEGACY/name)==expected
    assert (LEGACY/'qkv_rows4_source_f32.bin').read_bytes()==raw[:16384]
    assert (LEGACY/'qkv_rows4_a8_q.bin').read_bytes()==groups['q'][:4].tobytes()
    assert (LEGACY/'qkv_rows4_a8_scale.bin').read_bytes()==groups['scale'][:4].tobytes()
    report['original_first4_rows']={'status':'PASS','sources':PINNED,'q_bytes':4096,'scale_bytes':256,'same_actual_norm_prefix':True}
    rng=np.random.default_rng(20261021)
    tensors=[('enc0_norm128_K1024','actual_model_checkpoint',actual)]
    for K in(2624,4096):
        diagnostic=rng.normal(0,1,(128,K)).astype('<f4')
        diagnostic[:,::97]=np.float32(0)
        tensors.append((f'diagnostic128_K{K}','independent_diagnostic_not_model_trace',diagnostic))
    for name,kind,tensor in tensors:
        folder=a.output/name;folder.mkdir()
        output=ref.quantize_many(tensor)
        tile=bytearray()
        for row0 in range(0,128,16):tile+=ref.quantize_rows(tensor[row0:row0+16])
        assert output==tile,'original many/rows consistency'
        (folder/'source.f32.bin').write_bytes(tensor.tobytes());(folder/'expected.q8.bin').write_bytes(output)
        (folder/'input.hex').write_text(''.join(line(row.tobytes())+'\n'for row in tensor.reshape(-1,32)))
        # ABI is Q bytes low256, half high16, unlike original half-prefix disk order.
        (folder/'packed.hex').write_text(''.join(line(output[i+2:i+34]+output[i:i+2])+'\n'for i in range(0,len(output),34)))
        report['cases'].append({'name':name,'kind':kind,'rows':128,'K':tensor.shape[1],'groups':tensor.size//32,
            'input_sha256':hashlib.sha256(tensor.tobytes()).hexdigest(),'expected_sha256':hashlib.sha256(output).hexdigest(),
            'original_quantize_many_equals_quantize_rows':True})
    # Scalar-group arithmetic uses original F32 div/mul; original quantize_many
    # independently confirms success/error on an eightfold group tile.
    edge=[]
    for label,maximum in [('zero',0),('minsub',1),('tiny_div_zero_boundary',63),('tiny_div_nonzero_boundary',64),
        ('inverse_overflow',0x006ce3ee),('normal_min',0x00800000),('normal',0x3f800000),
        ('half_scale_near_zero',0x34800000),('half_scale_boundary',0x4afe0000),('half_scale_overflow',0x4b000000),
        ('largest_finite',0x7f7fffff)]:
        row=np.linspace(-1,1,32,dtype='<f4')*fbits(maximum);row[0]=fbits(maximum);row[1]=-fbits(maximum)
        edge.append((label,row.astype('<f4')))
    row=np.zeros(32,dtype='<f4');row[1::2]=np.float32(-0.);edge.append(('signed_zeros',row))
    for label,value,index in [('nan',np.nan,7),('positive_inf',np.inf,3),('negative_inf',-np.inf,31)]:
        row=np.ones(32,dtype='<f4');row[index]=value;edge.append((label,row))
    # Deterministic search demonstrates why rounded-half scale must not drive q.
    for attempt in range(2048):
        row=rng.normal(0,1,32).astype('<f4');m=np.max(np.abs(row)).astype('<f4');d=ref.div(m,np.float32(127));inverse=ref.div(np.float32(1),d)
        saved=np.float16(d).astype('<f4');wrong_inv=ref.div(np.float32(1),saved)
        def rounded(v):return np.copysign(np.floor(np.abs(v.astype(np.float64))+.5),v).astype(np.int32)
        if np.any(rounded(ref.mul(row,inverse))!=rounded(ref.mul(row,wrong_inv))):edge.append(('full_F32_scale_required',row));break
    else:raise AssertionError('no deterministic full-scale diagnostic')
    edge_input=[];edge_gold=[]
    for label,row in edge:
        status=0;stage=0;element=0;amax=d=inv=np.float32(0);half=0;q=np.zeros(32,dtype=np.int8)
        with np.errstate(all='ignore'),warnings.catch_warnings():
            warnings.simplefilter('ignore')
            bad=np.flatnonzero(~np.isfinite(row))
            if bad.size:status=1;stage=1;element=int(bad[0])
            else:
                amax=np.float32(np.max(np.abs(row)));d=ref.div(amax,np.float32(127))
                inv=np.float32(0)if d==0 else ref.div(np.float32(1),d)
                if not np.isfinite(d):status=1;stage=2
                elif not np.isfinite(inv):status=1;stage=4
                else:
                    saved=np.float16(d);half=int(saved.view('<u2'))
                    if not np.isfinite(saved):status=1;stage=3
                    else:
                        product=ref.mul(row,inv);bad=np.flatnonzero(~np.isfinite(product))
                        if bad.size:status=1;stage=5;element=int(bad[0])
                        else:
                            value=np.copysign(np.floor(np.abs(product.astype(np.float64))+.5),product).astype(np.int32)
                            bad=np.flatnonzero((value< -127)|(value>127))
                            if bad.size:status=1;stage=6;element=int(bad[0])
                            else:q=value.astype(np.int8)
            try:original=ref.quantize_many(np.tile(row,8).reshape(1,256));original_failed=False
            except (ValueError,ArithmeticError,OverflowError):original_failed=True
            assert original_failed==bool(status),label
            if not status:assert original[:34]==struct.pack('<H',half)+q.tobytes(),label
        edge_input.append(line(row.tobytes()))
        # status8, stage8, element8, amax32,d32,inverse32,packed272, little endian.
        gold=q.tobytes()+struct.pack('<HIII3B',half,bits(inv),bits(d),bits(amax),element,stage,status)
        edge_gold.append(line(gold))
        report.setdefault('edges',[]).append({'name':label,'status':status,'stage':stage,'element':element,
            'amax_u32':bits(amax),'d_full_u32':bits(d),'inverse_u32':bits(inv),'half_u16':half})
    (a.output/'edge_input.hex').write_text('\n'.join(edge_input)+'\n');(a.output/'edge_gold.hex').write_text('\n'.join(edge_gold)+'\n')
    # Direct format leaf tests include exact ties and range errors independently.
    formats=[0,0x80000000,1,0x80000001,0x3effffff,0x3f000000,0xbf000000,0x3f000001,
        0x3fc00000,0xbfc00000,0x42fdffff,0x42fe0000,0x42feffff,0x42ff0000,0x43000000,0xc3000000,
        0x33000000,0x33800000,0x387fc000,0x38800000,0x477fe000,0x477ff000,0x7f800000,0x7fc00000]
    formats+=rng.integers(0,1<<32,2048,dtype=np.uint32).tolist()
    fmt=[]
    for b in formats:
        value=fbits(b)
        with np.errstate(all='ignore'),warnings.catch_warnings():
            warnings.simplefilter('ignore');h=np.float16(value);half=int(h.view('<u2'))
        nonfinite=not np.isfinite(value);range_error=False;rounded=0
        if not nonfinite:
            rounded=int(np.copysign(np.floor(abs(float(value))+.5),float(value)))
            range_error=not -127<=rounded<=127
        if nonfinite:half=(b>>16&0x8000)|(0x7e00 if b&0x7fffff else 0x7c00)
        q=0 if nonfinite or range_error else rounded&255
        fmt.append(f'{int(nonfinite):x}{int(range_error):x}{int(not np.isfinite(h)):x}{q:02x}{half:04x}{b:08x}')
    (a.output/'format.hex').write_text('\n'.join(fmt)+'\n')
    for path in sorted(a.output.rglob('*')):
        if path.is_file():report['files'][str(path.relative_to(a.output))]={'sha256':sha(path),'bytes':path.stat().st_size}
    report.update(status='PASS_INDEPENDENT_QUANT_REFERENCE',edge_count=len(edge),format_count=len(formats),seed=20261021,
        full_graph_generated=False,board='NOT_RUN')
    (a.output/'report.json').write_text(json.dumps(report,indent=2,allow_nan=False)+'\n')
    print(f'M007_QUANT_REFERENCE_PASS actual_groups=4096 actual_bytes=139264 first4_exact=1 edges={len(edge)} formats={len(formats)} full_graph=NOT_RUN',flush=True)


if __name__=='__main__':main()
