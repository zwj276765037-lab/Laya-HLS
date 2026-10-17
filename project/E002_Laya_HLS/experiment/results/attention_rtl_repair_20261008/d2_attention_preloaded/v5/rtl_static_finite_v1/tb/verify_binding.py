#!/usr/bin/env python3
"""Rehash sealed finite source, derived pages, and compiled snapshot by mode."""
from __future__ import annotations
import argparse
import hashlib
import json
from datetime import datetime,timezone
from pathlib import Path

def sha(path:Path)->str:
    digest=hashlib.sha256()
    with path.open('rb') as source:
        for block in iter(lambda:source.read(1<<20),b''): digest.update(block)
    return digest.hexdigest()

def record(path:Path,relative=None):
    result={'bytes':path.stat().st_size,'sha256':sha(path)}
    if relative is None:
        result.update(path=str(path.resolve()),mode=oct(path.stat().st_mode & 0o777))
    else: result['relative_path']=str(relative)
    return result

def prepared_inventory(mode:str,prepared:Path):
    mat_path=prepared/'materialization.json'
    materialization=json.loads(mat_path.read_text())
    assert materialization['schema']=='attention_v5_finite_page_materialization_v1'
    assert materialization['mode']==mode and materialization['status']=='HOST_SOURCE_AND_FULL_IMAGE_CHECK_ONLY_NO_EDA'
    generated=materialization['generated']
    assert len(generated)==10
    assert {p.name for p in prepared.glob('*.memh')}==set(generated)
    pages=[]
    for name,info in sorted(generated.items()):
        path=prepared/name
        assert path.is_file() and not path.is_symlink()
        item=record(path,name)
        assert item['bytes']==info['memh_bytes'] and item['sha256']==info['memh_sha256']
        pages.append(item)
    check_path=prepared.parent/'independent_page_check.json'
    independent=json.loads(check_path.read_text())
    assert independent['schema']=='attention_v5_finite_independent_page_serialization_check_v1'
    assert independent['mode']==mode and independent['status']=='PASS_NO_EDA'
    assert independent['materialization_sha256']==sha(mat_path)
    assert len(independent['files'])==10
    return pages+[record(mat_path,'materialization.json'),record(check_path,'independent_page_check.json')]

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('packet',type=Path)
    parser.add_argument('mode',choices=('base_h15_r63','changed_h0_r0'))
    parser.add_argument('output',type=Path)
    parser.add_argument('--prepared',type=Path)
    parser.add_argument('--snapshot',type=Path)
    parser.add_argument('--expected-prepared-report',type=Path)
    parser.add_argument('--expected-snapshot-report',type=Path)
    parser.add_argument('--runtime',type=Path)
    args=parser.parse_args()
    assert not args.output.exists(),args.output
    if args.expected_prepared_report: assert args.prepared
    if args.expected_snapshot_report: assert args.snapshot
    if args.runtime: assert args.prepared and args.snapshot
    packet=json.loads(args.packet.read_text())
    assert packet['schema']=='attention_v5_finite_static_source_packet_v1'
    assert len(packet['verilog_modules'])==216 and len(packet['dat_files'])==35
    assert len(packet['fp_sim_vhdl_wrappers'])==6
    mode_row=packet['modes'][args.mode]
    assert mode_row['mode']==args.mode
    sources=[]
    for key in ('source_gate','cold_gate','accepted_endpoint','cold_v2_numeric_acceptance',
                'xsim_ini','xsim_lookup_manual'):
        sources.append(packet[key])
    for key in ('verilog_modules','dat_files','fp_sim_vhdl_wrappers',
                'testbench_and_runner','frozen_inputs','guard_scripts','schedule_reports'):
        sources.extend(packet[key])
    for group in packet['installed_library_files'].values(): sources.extend(group)
    seen=set()
    for item in sources:
        path=Path(item['path'])
        if str(path) in seen: continue
        seen.add(str(path))
        if record(path)!=item: raise RuntimeError(f'immutable source changed: {path}')
    prepared_files=prepared_inventory(args.mode,args.prepared) if args.prepared else []
    if args.expected_prepared_report:
        prior=json.loads(args.expected_prepared_report.read_text())
        assert prior['mode']==args.mode and prior['prepared_files']==prepared_files,'prepared pages changed'
    artifacts={f'att_finite_{args.mode}_static/{name}' for name in
               ('xsim_script.tcl','xsimSettings.ini','xsimkernel.log','xsimcrash.log')}
    snapshot_files=[]
    if args.snapshot:
        assert args.snapshot.is_dir()
        snapshot_files=[record(path,path.relative_to(args.snapshot))
                        for path in sorted(args.snapshot.rglob('*')) if path.is_file()]
    if args.expected_snapshot_report:
        prior=json.loads(args.expected_snapshot_report.read_text())
        assert prior['mode']==args.mode
        fixed=lambda rows:[row for row in rows if row['relative_path'] not in artifacts]
        assert fixed(snapshot_files)==fixed(prior['snapshot_files']),'snapshot changed outside four runtime artifacts'
    links=[]
    if args.runtime:
        snapshot=args.snapshot.resolve()
        link=args.runtime/'xsim.dir'
        assert link.is_symlink() and link.resolve()==snapshot
        links.append({'relative_path':'xsim.dir','target':str(snapshot)})
        expected={row['relative_path']:args.prepared/row['relative_path']
                  for row in prepared_files if row['relative_path'].endswith('.memh')}
        expected.update({Path(row['path']).name:Path(row['path']) for row in packet['dat_files']})
        assert {path.name for path in args.runtime.iterdir() if path.suffix in ('.memh','.dat')}==set(expected)
        for name,source in sorted(expected.items()):
            path=args.runtime/name
            assert path.is_symlink() and path.resolve()==source.resolve(),path
            links.append({'relative_path':name,'target':str(source.resolve())})
    result={'schema':'attention_v5_finite_binding_check_v1',
            'at_utc':datetime.now(timezone.utc).isoformat(),
            'mode':args.mode,'packet_sha256':sha(args.packet),
            'source_count':len(seen),'source_verified':True,
            'prepared_files':prepared_files,'snapshot_files':snapshot_files,'runtime_links':links}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(f'ATT_FINITE_BINDING_VERIFIED mode={args.mode} source={len(seen)} prepared={len(prepared_files)} snapshot={len(snapshot_files)}')

if __name__=='__main__': main()
