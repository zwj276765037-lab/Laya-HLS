#!/usr/bin/env python3
"""Bounded E020 independent format, original metadata and coefficient checks."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import struct
import subprocess
import sys
import unittest

EXPERIMENT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(EXPERIMENT / 'tools'))
sys.path.insert(0, str(EXPERIMENT / 'tests'))
import m007_model_catalog as dut
from full_model_package_test import expected_bindings
from full_reference import embedding_row

GGUF = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/model/quantized/gguf/mys/laya-typed-decisions-GGUF/Q8_0/laya_typed_decisions_q8_0.gguf')
IDENTITY = {
 'model': '6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18',
 'graph': 'f33f7848434b73048f957dcd232e1bd4ff99e95b8cf41c98191b69fddad815f9',
 'numeric': 'aeb13e7937d29fe6a2c68c407249f294212aa24f4e45fd3862b092795ab066f7',
 'layout': '2d848b5fb78236c795cb1d442f088393a3fd6cbd7f8ecf3cf9f984c59b5e0991',
 'build': '7209eb09c3f265363cfb274f7790a73336e1570f5081bc9bbb2538c1ba5a50d5'}


def sim_addresses():
    records = []
    cursor = 0x100000
    for item in dut.bindings():
        records.append({'index': item['index'], 'name': item['name'],
                        'base': [cursor] * 4, 'span': [item['needed_per_port']] * 4})
        cursor = (cursor + item['needed_per_port'] + 4095) & -4096
    return {'address_space': 'SIM', 'apertures': [{'base': 0, 'span': 1 << 32} for _ in range(4)],
            'catalog': {'base': 0x10000, 'span': 8192}, 'records': records, 'dma_ranges': []}


def independent_crc(data):
    # Polynomial long division, separate from both tool implementations.
    value = int.from_bytes(data, 'big') << 64
    divisor = (1 << 64) | 0x42F0E1EBA9EA3693
    while value.bit_length() > 64:
        value ^= divisor << (value.bit_length() - 65)
    return value


def refresh_checksums(blob):
    result = bytearray(blob)
    payload = result[256:7936]
    result[176:208] = hashlib.sha256(payload).digest()
    struct.pack_into('<Q', result, 208, independent_crc(payload))
    return bytes(result)


class CatalogTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.info = dut.load_package()
        cls.addresses = sim_addresses()
        cls.blob = dut.build_catalog(cls.info['identity'], cls.addresses)

    def reject_address(self, mutate):
        addresses = copy.deepcopy(self.addresses)
        mutate(addresses)
        with self.assertRaises(dut.CatalogError):
            dut.build_catalog(IDENTITY, addresses)

    def test_01_standard_crc(self):
        for data, expected in ((b'', 0), (b'123456789', 0x6c40df5f0b497347)):
            self.assertEqual(dut.crc64(data), expected)
            self.assertEqual(dut.verify_crc64_bits(data), expected)
            self.assertEqual(independent_crc(data), expected)
        data = bytes(range(256)) * 3
        self.assertEqual(dut.crc64(data), independent_crc(data))
        self.assertEqual(dut.verify_crc64_bits(data), independent_crc(data))

    def test_02_fixed_bindings_original_package(self):
        self.assertEqual(self.info['identity'], IDENTITY)
        original = expected_bindings()
        self.assertEqual(len(dut.bindings()), 120)
        for index, item in enumerate(dut.bindings()):
            self.assertEqual(index, 4 * item['global_layer'] + 2 * item['pair_kind'] + item['slot'])
            self.assertEqual((item['family'], item['layer'], 'Q8_0', item['bias_name']), original[item['name']])
            src = self.info['original'][item['name']]
            self.assertEqual(src['ggml_ne'][:2], [item['K'], item['N']])
            self.assertEqual(item['tensor'], 1 + list(self.info['original']).index(item['name']))
            self.assertEqual(item['needed_per_port'], 576 * (item['K'] // 32) * (82 if item['N'] == 5248 else item['N'] // 64))
        self.assertEqual([x['needed_per_port'] for x in dut.bindings()[:4]], [884736,294912,1511424,755712])
        self.assertEqual([x['needed_per_port'] for x in dut.bindings()[114:116]], [1179648,1179648])

    def test_03_exact_header_and_all120_records(self):
        blob = self.blob
        self.assertEqual(len(blob), 8192)
        self.assertEqual(blob[:16], b'LAYAC25\0' + struct.pack('<4H', 1,256,120,64))
        for offset, key in zip((16,48,80,112,144), IDENTITY):
            self.assertEqual(blob[offset:offset+32].hex(), IDENTITY[key])
        self.assertEqual(blob[224:256], bytes(32))
        self.assertEqual(blob[7936:], bytes(256))
        self.assertEqual(struct.unpack_from('<Q',blob,216)[0], 7936)
        payload = bytearray()
        for item in self.addresses['records']:
            word = b''.join(struct.pack('<QQ', item['base'][port], item['span'][port]) for port in range(4))
            payload.extend(word)
            self.assertEqual(blob[256+64*item['index']:320+64*item['index']], word)
        self.assertEqual(blob[176:208], hashlib.sha256(payload).digest())
        self.assertEqual(struct.unpack_from('<Q',blob,208)[0], independent_crc(payload))
        report = dut.verify_catalog(blob, IDENTITY, self.addresses)
        self.assertEqual(report['record_count'],120)
        self.assertEqual(report['address_space'],'SIM')

    def test_04_header_identity_crc_reserved_tail_reject(self):
        for offset in (0,8,10,12,14,16,47,48,79,80,111,112,143,144,175,176,207,208,215,216,223,224,255,7936,8191):
            with self.subTest(offset=offset):
                blob = bytearray(self.blob); blob[offset] ^= 1
                with self.assertRaises(dut.CatalogError):
                    dut.verify_catalog(bytes(blob), IDENTITY, self.addresses)
        with self.assertRaises(dut.CatalogError):
            dut.verify_catalog(self.blob[:-1], IDENTITY, self.addresses)
        for identity in ('0'*32, 'F'*64, '0'*63, 0):
            bad = dict(IDENTITY, model=identity)
            with self.assertRaises(dut.CatalogError):
                dut.build_catalog(bad,self.addresses)

    def test_05_first_last_structure_after_valid_checksums(self):
        for index in (0,119):
            for port in range(4):
                for field,value in ((0,1), (1,1), (0,(1<<64)-4096)):
                    with self.subTest(index=index,port=port,field=field,value=value):
                        blob=bytearray(self.blob)
                        struct.pack_into('<Q',blob,256+64*index+16*port+8*field,value)
                        with self.assertRaises(dut.CatalogError):
                            dut.verify_catalog(refresh_checksums(blob),IDENTITY,self.addresses)
        blob=bytearray(self.blob)
        blob[256:320],blob[256+119*64:320+119*64] = blob[256+119*64:320+119*64],blob[256:320]
        with self.assertRaises(dut.CatalogError):
            dut.verify_catalog(refresh_checksums(blob),IDENTITY,self.addresses)

    def test_06_illegal_numeric_and_placement(self):
        for value in (True,False,1.0,float('nan'),float('inf'),-4096,1<<64):
            for field in ('base','span'):
                with self.subTest(field=field,value=repr(value)):
                    self.reject_address(lambda a,field=field,value=value:a['records'][0][field].__setitem__(0,value))
        self.reject_address(lambda a:a['records'][0]['base'].__setitem__(0,1))
        self.reject_address(lambda a:a['records'][0]['span'].__setitem__(0,884735))
        self.reject_address(lambda a:a['records'][0]['base'].__setitem__(0,(1<<64)-4096))
        self.reject_address(lambda a:a['apertures'][0].__setitem__('span',0x100000))
        self.reject_address(lambda a:a['records'][0]['base'].__setitem__(0,0x10000))
        self.reject_address(lambda a:a['catalog'].__setitem__('span',4096))
        self.reject_address(lambda a:a['catalog'].__setitem__('base',1))
        self.reject_address(lambda a:a['catalog'].__setitem__('base',(1<<64)-8192))
        self.reject_address(lambda a:a['records'][0].__setitem__('index',True))
        self.reject_address(lambda a:a['records'][0].__setitem__('name','wo.0.weight'))
        self.reject_address(lambda a:a['records'].pop())
        self.reject_address(lambda a:a.__setitem__('address_space','UNKNOWN'))
        self.reject_address(lambda a:a.__setitem__('address_space','PLATFORM'))
        self.reject_address(lambda a:a['dma_ranges'].append({'port':0,'base':0x10000,'span':64}))
        self.reject_address(lambda a:a['dma_ranges'].append({'port':2,'base':0x100000,'span':64}))
        self.reject_address(lambda a:a['dma_ranges'].append({'port':True,'base':0,'span':64}))
        legal=copy.deepcopy(self.addresses);legal['records'][0]['span'][0]+=1
        self.assertEqual(dut.verify_catalog(dut.build_catalog(IDENTITY,legal),IDENTITY,legal)['record_count'],120)
        for value in ('NaN','Infinity','-Infinity'):
            path=OUTPUT/('nonfinite_'+value+'.json');path.write_text('{"value":'+value+'}')
            with self.assertRaises(dut.CatalogError):dut.load_json(path)

    def test_07_original_coefficients_and_three_rows(self):
        report=dut.prepare_coefficients(self.info,GGUF,OUTPUT/'coefficients')
        self.assertEqual(report['chunk_count'],704)
        self.assertEqual(len(report['source_tensors']),10)
        raw=(OUTPUT/'coefficients/original_type_emb.weight.bin').read_bytes()
        expanded=(OUTPUT/'coefficients/type.f32.bin').read_bytes()
        comparisons=[]
        for row in range(3):
            expected=embedding_row(raw[row*1088:(row+1)*1088]).tobytes()
            actual=expanded[row*4096:(row+1)*4096]
            self.assertEqual(actual,expected)
            comparisons.append({'row':row,'count_f32':1024,'reference_sha256':hashlib.sha256(expected).hexdigest(),'actual_sha256':hashlib.sha256(actual).hexdigest()})
        lines=[json.loads(x) for x in (OUTPUT/'coefficients/coefficient_chunks.jsonl').read_text().splitlines()]
        cursor=0
        for kind,name,count in ((0,'bias.f32.bin',576),(1,'gamma.f32.bin',32),(2,'type.f32.bin',96)):
            self.assertEqual([(x['kind'],x['index']) for x in lines[cursor:cursor+count]],[(kind,i) for i in range(count)])
            self.assertEqual(b''.join(bytes.fromhex(x['data_hex']) for x in lines[cursor:cursor+count]),(OUTPUT/'coefficients'/name).read_bytes())
            cursor+=count
        (OUTPUT/'type_reference_comparison.json').write_text(json.dumps({'status':'PASS','original_reference':str(EXPERIMENT/'tests/full_reference.py'),'rows':comparisons,'f32_total':3072},indent=2)+'\n')
        # Domain tests exercise the original algorithm's rejected scale/S8 space.
        for scale,q in ((-1.0,1),(float('inf'),1),(float('nan'),1),(1.0,-128)):
            with self.assertRaises(dut.CatalogError):dut.expand_type_row((struct.pack('<e',scale)+struct.pack('<32b',*([q]*32)))*32)
        for scale in (0.0,-0.0,2**-24,1.0,65504.0):
            block=struct.pack('<e',scale)+struct.pack('<32b',*range(-16,16))
            self.assertEqual(dut.expand_type_row(block*32),embedding_row(block*32).tobytes())

    def test_08_cli_build_verify(self):
        addresses=OUTPUT/'cli_addresses.json'
        addresses.write_text(json.dumps(self.addresses)+'\n')
        cli=EXPERIMENT/'tools/m007_model_catalog.py'
        for stage in ('build','verify'):
            argv=[sys.executable,str(cli),stage,'--addresses',str(addresses),'--output',str(OUTPUT/('cli_'+stage))]
            if stage=='verify':argv+=['--catalog',str(OUTPUT/'cli_build/catalog.bin')]
            result=subprocess.run(argv,capture_output=True,text=True)
            self.assertEqual(result.returncode,0,result.stdout+result.stderr)
            self.assertEqual((OUTPUT/('cli_'+stage)/'catalog.bin').read_bytes(),self.blob)
        result=subprocess.run([sys.executable,str(cli),'verify','--addresses',str(addresses),'--output',str(OUTPUT/'cli_missing')],capture_output=True,text=True)
        self.assertNotEqual(result.returncode,0)
        self.assertIn('explicit catalog binary required',result.stderr)


def main():
    global OUTPUT
    parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
    OUTPUT=args.output;OUTPUT.mkdir(parents=True,exist_ok=False)
    suite=unittest.defaultTestLoader.loadTestsFromTestCase(CatalogTests)
    result=unittest.TextTestRunner(verbosity=2).run(suite)
    report={'status':'PASS' if result.wasSuccessful() else 'FAIL','tests_run':result.testsRun,'failures':len(result.failures),'errors':len(result.errors),'address_space':'SIM','actual_platform_DMA':'NOT_RUN','runtime_gold_generated':False}
    if result.wasSuccessful():
        addresses=sim_addresses();blob=dut.build_catalog(IDENTITY,addresses)
        (OUTPUT/'sim_addresses.json').write_text(json.dumps(addresses,indent=2)+'\n')
        (OUTPUT/'catalog.bin').write_bytes(blob)
        (OUTPUT/'catalog.hex').write_text(''.join(f'{int.from_bytes(blob[i:i+64],"little"):0128x}\n' for i in range(0,8192,64)))
        report['catalog']=dut.verify_catalog(blob,IDENTITY,addresses)
    (OUTPUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    raise SystemExit(0 if result.wasSuccessful() else 1)

if __name__=='__main__':main()
