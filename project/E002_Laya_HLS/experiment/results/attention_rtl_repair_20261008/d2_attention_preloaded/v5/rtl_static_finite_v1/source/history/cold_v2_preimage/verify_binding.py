#!/usr/bin/env python3
"""Rehash frozen V5 inputs, prepared pages and XSim snapshot at each stage."""
from __future__ import annotations
import argparse
import hashlib
import json
import shutil
from datetime import datetime,timezone
from pathlib import Path

ARTIFACTS={f'att_cold_static/{name}' for name in
           ('xsim_script.tcl','xsimSettings.ini','xsimkernel.log','xsimcrash.log')}

def sha(path:Path)->str:
    h=hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda:f.read(1<<20),b''): h.update(block)
    return h.hexdigest()

def record(path:Path,relative=None):
    row={'bytes':path.stat().st_size,'sha256':sha(path)}
    if relative is None:
        row.update(path=str(path.resolve()),mode=oct(path.stat().st_mode & 0o777))
    else: row['relative_path']=str(relative)
    return row

def prepared_inventory(prepared:Path,packet:dict):
    expected=packet['prepared_pages']
    assert expected is not None,'packet has no bound prepared pages'
    actual=[]
    for item in expected:
        name=item['relative_path']
        assert Path(name).name==name and name.endswith('.memh')
        path=prepared/name
        assert path.is_file() and not path.is_symlink(),path
        row=record(path,name)
        assert row==item,('prepared page changed',name)
        actual.append(row)
    assert {p.name for p in prepared.glob('*.memh')}=={x['relative_path'] for x in expected}
    m=record(prepared/'materialization.json','materialization.json')
    assert m==packet['materialization_record']
    return actual+[m]

def snapshot_inventory(snapshot:Path):
    assert snapshot.is_dir(),snapshot
    return [record(p,p.relative_to(snapshot)) for p in sorted(snapshot.rglob('*')) if p.is_file()]

def archive(snapshot:Path,out:Path):
    out.mkdir(parents=True,exist_ok=False)
    rows=[]
    for relative in sorted(ARTIFACTS):
        source=snapshot/relative
        if source.is_file():
            target=out/source.name
            shutil.copy2(source,target)
            rows.append(record(target,relative))
    missing=sorted(ARTIFACTS-{x['relative_path'] for x in rows})
    (out/'manifest.json').write_text(json.dumps({'schema':'attention_cold_xsim_artifact_archive_v1',
        'snapshot':str(snapshot.resolve()),'files':rows,'missing':missing},indent=2,sort_keys=True)+'\n')
    if missing: raise RuntimeError(f'four XSim artifact archive incomplete: {missing}')
    return rows

def main():
    p=argparse.ArgumentParser()
    p.add_argument('packet',type=Path); p.add_argument('output',type=Path)
    p.add_argument('--prepared',type=Path)
    p.add_argument('--snapshot',type=Path)
    p.add_argument('--expected-snapshot-report',type=Path)
    p.add_argument('--expected-prepared-report',type=Path)
    p.add_argument('--runtime',type=Path)
    p.add_argument('--archive-runtime-artifacts',type=Path)
    a=p.parse_args()
    if a.expected_snapshot_report and not a.snapshot: p.error('snapshot baseline needs snapshot')
    if a.expected_prepared_report and not a.prepared: p.error('prepared baseline needs prepared')
    if a.archive_runtime_artifacts and not a.snapshot: p.error('archive needs snapshot')
    packet=json.loads(a.packet.read_text())
    assert packet['schema']=='attention_v5_cold_static_source_packet_v2'
    assert len(packet['verilog_modules'])==216 and len(packet['dat_files'])==35
    assert len(packet['fp_sim_vhdl_wrappers'])==6 and len(packet['prepared_pages'])==10
    all_records=[]
    for key in ('source_gate','accepted_endpoint','xsim_ini','xsim_lookup_manual',
                'independent_page_serialization_check','independent_prepared_bytes_review',
                'materializer_guard_actual',
                'materializer_first_failure_actual'):
        all_records.append(packet[key])
    for key in ('verilog_modules','dat_files','fp_sim_vhdl_wrappers','testbench_and_runner',
                'frozen_inputs','guard_scripts','schedule_reports'):
        all_records.extend(packet[key])
    for rows in packet['installed_library_files'].values(): all_records.extend(rows)
    seen=set()
    for item in all_records:
        path=Path(item['path'])
        if str(path) in seen: continue
        seen.add(str(path))
        if record(path)!=item: raise RuntimeError(f'immutable source changed: {path}')
    prepared_files=prepared_inventory(a.prepared,packet) if a.prepared else []
    if a.expected_prepared_report:
        prior=json.loads(a.expected_prepared_report.read_text())
        if prepared_files!=prior['prepared_files']: raise RuntimeError('prepared pages changed')
    snapshot_files=snapshot_inventory(a.snapshot) if a.snapshot else []
    if a.expected_snapshot_report:
        prior=json.loads(a.expected_snapshot_report.read_text())
        fixed=lambda rows:[x for x in rows if x['relative_path'] not in ARTIFACTS]
        if fixed(snapshot_files)!=fixed(prior['snapshot_files']):
            raise RuntimeError('snapshot changed outside four exact XSim runtime artifacts')
    links=[]
    if a.runtime:
        assert a.prepared and a.snapshot
        target=a.snapshot.resolve()
        link=a.runtime/'xsim.dir'
        assert link.is_symlink() and link.resolve()==target
        links.append({'relative_path':'xsim.dir','target':str(target)})
        expected={x['relative_path']:a.prepared/x['relative_path'] for x in packet['prepared_pages']}
        expected.update({Path(x['path']).name:Path(x['path']) for x in packet['dat_files']})
        assert {x.name for x in a.runtime.iterdir() if x.suffix in ('.memh','.dat')}==set(expected)
        for name,source in sorted(expected.items()):
            path=a.runtime/name
            assert path.is_symlink() and path.resolve()==source.resolve(),path
            links.append({'relative_path':name,'target':str(source.resolve())})
    archived=archive(a.snapshot,a.archive_runtime_artifacts) if a.archive_runtime_artifacts else []
    result={'schema':'attention_v5_cold_binding_check_v1','at_utc':datetime.now(timezone.utc).isoformat(),
        'packet_sha256':sha(a.packet),'source_count':len(seen),'source_verified':True,
        'prepared_files':prepared_files,'snapshot_files':snapshot_files,
        'runtime_links':links,'archived_runtime_artifacts':archived}
    if a.output.exists(): raise FileExistsError(a.output)
    a.output.parent.mkdir(parents=True,exist_ok=True)
    a.output.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(f'ATT_COLD_BINDING_VERIFIED source={len(seen)} prepared={len(prepared_files)} snapshot={len(snapshot_files)}')
if __name__=='__main__': main()
